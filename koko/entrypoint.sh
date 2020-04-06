#!/bin/bash
#

sleep 5s
while [ "$(curl -I -m 10 -o /dev/null -s -w %{http_code} $CORE_HOST)" != "302" ]
do
    echo "wait for jms_core ready"
    sleep 2
done

if [ ! -f "/opt/koko/config.yml" ]; then
    cp /opt/koko/config_example.yml /opt/koko/config.yml
    sed -i '5d' /opt/koko/config.yml
    sed -i "5i CORE_HOST: $CORE_HOST" /opt/koko/config.yml
    sed -i "s/BOOTSTRAP_TOKEN: <PleasgeChangeSameWithJumpserver>/BOOTSTRAP_TOKEN: $BOOTSTRAP_TOKEN/g" /opt/koko/config.yml
    sed -i "s/# LOG_LEVEL: INFO/LOG_LEVEL: ERROR/g" /opt/koko/config.yml
    sed -i "s@# SFTP_ROOT: /tmp@SFTP_ROOT: /@g" /opt/koko/config.yml
fi

cd /opt/koko
./koko
