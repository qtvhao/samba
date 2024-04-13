#!/bin/bash
set -xeo pipefail

_term() {
    echo "Caught SIGTERM signal! It means that the container is being stopped. Saving the database...";
    redis-cli -a $REDIS_PASSWORD -h redis set hello world;
    redis-cli -a $REDIS_PASSWORD -h localhost save;
    cp /bitnami/redis/data/dump.rdb /bitnami/redis/data/backup-service/dump.rdb
    kill -TERM "$child"
}

trap _term SIGTERM

echo "Doing some initial work...";
if [ -f /bitnami/redis/data/backup-service/dump.rdb ]; then
    cp /bitnami/redis/data/backup-service/dump.rdb /bitnami/redis/data/dump.rdb
fi
/opt/bitnami/scripts/redis/entrypoint.sh /opt/bitnami/scripts/redis/run.sh & child=$!
sleep 2
redis-cli -a $REDIS_PASSWORD -h redis get hello
HELLO=`redis-cli -a $REDIS_PASSWORD -h redis get hello`
if [ "$HELLO" == "world" ]; then
    echo "Database is restored successfully!";
else
    echo "Database is not restored successfully!";
fi
wait "$child"
