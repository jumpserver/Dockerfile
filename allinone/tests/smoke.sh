#!/bin/bash
# Run against a locally built all-in-one image. All volumes belong to this test.
set -euo pipefail
image=${1:?usage: smoke.sh <image>}
container='' data='' pgdata=''
cleanup() {
    if [[ -n $container ]]; then docker rm -fv "$container" >/dev/null; fi
    if [[ -n $data ]]; then docker volume rm "$data" >/dev/null; fi
    if [[ -n $pgdata ]]; then docker volume rm "$pgdata" >/dev/null; fi
}
trap cleanup EXIT
data=$(docker volume create)
pgdata=$(docker volume create)
export SECRET_KEY BOOTSTRAP_TOKEN REDIS_PASSWORD
SECRET_KEY=$(openssl rand -hex 32)
BOOTSTRAP_TOKEN=$(openssl rand -hex 24)
REDIS_PASSWORD=$(openssl rand -hex 24)

start() {
    container=$(docker run -d --pull=never --network none -e SECRET_KEY -e BOOTSTRAP_TOKEN -e REDIS_PASSWORD \
        -e CORE_WORKER=1 -e KAEL_ENABLED="$1" -v "$data:/opt/data" -v "$pgdata:/var/lib/postgresql" "$image")
    local path deadline=$((SECONDS + 360))
    local endpoints=(koko/chen/healthy)
    if [[ $1 == 1 ]]; then endpoints+=(kael/health/ready); fi
    for path in "${endpoints[@]}"; do
        until docker exec "$container" curl -fsS --max-time 3 "http://localhost/$path" 2>/dev/null | grep -q '"status"'; do
            if [[ $(docker inspect -f '{{.State.Running}}' "$container") != true || $SECONDS -ge $deadline ]]; then
                echo "Timed out waiting for /$path" >&2
                docker logs --tail 40 "$container" >&2
                return 1
            fi
            sleep 2
        done
    done
}

stop() {
    docker stop -t 90 "$container" >/dev/null
    [[ $(docker inspect -f '{{.State.ExitCode}}' "$container") == 0 ]]
    docker rm -v "$container" >/dev/null
    container=
}

start 1
docker exec "$container" sh -ec '
    grep -qx s6-svscan /proc/1/comm
    for srv in postgresql redis cron core koko guacd kael web; do
        test "$(/command/s6-svstat -o up /run/service/$srv)" = true
    done
    curl -fsS http://localhost/koko/chen/api/v1/capabilities | grep -q managed
    mkdir -p /opt/data/chen
    touch /opt/data/chen/legacy
    REDISCLI_AUTH="$REDIS_PASSWORD" redis-cli SET smoke:volume persisted | grep -qx OK
    chmod 0700 /opt/data
'
key=$(docker exec "$container" sha256sum /opt/kael/data/keys/.access_key)
stop
start 0
docker exec "$container" sh -ec '
    test ! -d /run/service/kael
    test ! -e /etc/nginx/includes/kael.conf
    REDISCLI_AUTH="$REDIS_PASSWORD" redis-cli --raw GET smoke:volume | grep -qx persisted
    test -e /opt/data/chen/legacy
'
[[ $(docker exec "$container" sha256sum /opt/kael/data/keys/.access_key) == "$key" ]]
stop
