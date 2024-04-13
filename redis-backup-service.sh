#!/bin/bash

_term() { 
    echo "Caught SIGTERM signal!"
    kill -TERM "\$child" 2>/dev/null
}

trap _term SIGTERM

echo "Doing some initial work...";
/opt/bitnami/scripts/redis/entrypoint.sh /opt/bitnami/scripts/redis/run.sh &

child=$! 
wait "$child"
