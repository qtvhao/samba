#!/bin/bash

set -xeo pipefail
which docker-compose || apt-get install -y docker-compose
which kompose || (curl -L https://github.com/kubernetes/kompose/releases/download/v1.32.0/kompose-linux-amd64 -o kompose && chmod +x kompose && mv kompose /usr/local/bin/kompose)

# kompose convert -f ./docker-compose.yml
FILE="samba-service.yaml samba-pod.yaml samba-claim0-persistentvolumeclaim.yaml samba-client-pod.yaml"
for f in $FILE; do
    kubectl apply -f $f
done
# docker-compose up -d
# docker-compose logs -f
