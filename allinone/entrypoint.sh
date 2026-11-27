#!/bin/bash
set -euo pipefail

if [[ ${1:-} == bash || ${1:-} == sh ]]; then
    exec "$@"
fi

export SECRET_KEY=${SECRET_KEY:-PleaseChangeMe} BOOTSTRAP_TOKEN=${BOOTSTRAP_TOKEN:-PleaseChangeMe}
export CORE_HOST=${CORE_HOST:-http://localhost:8080} LOG_LEVEL=${LOG_LEVEL:-INFO} GIN_MODE=release
export DB_HOST=${DB_HOST:-127.0.0.1} DB_PORT=${DB_PORT:-5432} DB_ENGINE=${DB_ENGINE:-postgresql}
export DB_NAME=${DB_NAME:-jumpserver} DB_USER=${DB_USER:-postgres} DB_PASSWORD=${DB_PASSWORD:-PleaseChangeMe}
export REDIS_HOST=${REDIS_HOST:-127.0.0.1} REDIS_PORT=${REDIS_PORT:-6379} REDIS_PASSWORD=${REDIS_PASSWORD:-PleaseChangeMe}

# Preserve Core's signing key across upgrades from the Supervisor image.
if [[ -z ${CHAT_AI_DELEGATION_SECRET:-} ]]; then
    CHAT_AI_DELEGATION_SECRET=$(/opt/py3/bin/python -c \
        'import hashlib, hmac, os; print(hmac.new(os.environ["BOOTSTRAP_TOKEN"].encode(), b"jumpserver-chat-ai-delegation-v1", hashlib.sha256).hexdigest())')
fi
export CHAT_AI_DELEGATION_SECRET

persist_dir() {
    local src=$1 dst=$2
    mkdir -p "$dst"
    if [[ -L $src ]]; then
        [[ "$src" -ef "$dst" ]] || { echo "Unexpected data link: $src" >&2; exit 1; }
        return
    fi
    if [[ -d $src ]]; then
        # Seed missing files (including dotfiles), leaving an existing volume's data in place.
        find "$src" -mindepth 1 -maxdepth 1 -exec cp -a --update=none -t "$dst" -- {} +
        rm -r -- "$src"
    fi
    ln -s "$dst" "$src"
}

(umask 077; mkdir -p /opt/data/kael)
for app in jumpserver koko kael; do
    persist_dir "/opt/$app/data" "/opt/data/$app"
done
persist_dir /var/log/nginx /opt/data/nginx
persist_dir /var/lib/redis /opt/data/redis
mkdir -p /var/cache/nginx
grep -qxF '127.0.0.1 core koko' /etc/hosts || echo '127.0.0.1 core koko' >> /etc/hosts
if [[ -f /opt/jumpserver/config.yml ]]; then
    : > /opt/jumpserver/config.yml
fi
rm -f /opt/jumpserver/tmp/*.pid

# s6-rc compiles the graph at /init. Only add the local daemons when selected.
deps=/etc/s6-overlay/s6-rc.d/storage-ready/dependencies.d
if [[ $DB_HOST == 127.0.0.1 && $DB_ENGINE == postgresql ]]; then
    read -r PG_VERSION PG_CLUSTER _ _ _ PG_DATA_DIR _ < <(pg_lsclusters --no-header)
    export PG_VERSION PG_CLUSTER PG_DATA_DIR
    chown -R postgres:postgres "$PG_DATA_DIR"
    touch "$deps/postgresql"
else
    rm -f "$deps/postgresql"
fi
if [[ $REDIS_HOST == 127.0.0.1 ]]; then
    chown -R redis:redis /opt/data/redis
    touch "$deps/redis"
else
    rm -f "$deps/redis"
fi

exec /init
