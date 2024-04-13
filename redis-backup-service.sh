#!/bin/bash
set -xeo pipefail

_term() { 
    echo "Caught SIGTERM signal! It means that the container is being stopped. Saving the database...";
    redis-cli -a $REDIS_PASSWORD -h redis set hello world;
    redis-cli -a $REDIS_PASSWORD -h localhost save;
    sleep 8
    cp /bitnami/redis/data/dump.rdb /bitnami/redis/data/backup-service/dump.rdb
    kill -TERM "$child"
}

trap _term SIGTERM

echo "Doing some initial work...";
/opt/bitnami/scripts/redis/entrypoint.sh /opt/bitnami/scripts/redis/run.sh &
sleep 2
redis-cli -a $REDIS_PASSWORD -h redis get hello

child=$! 
wait "$child"
