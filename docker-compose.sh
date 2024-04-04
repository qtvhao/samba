#!/bin/bash

set -xeo pipefail
which docker-compose || apt-get install -y docker-compose
which kompose || (curl -L https://github.com/kubernetes/kompose/releases/download/v1.32.0/kompose-linux-amd64 -o kompose && chmod +x kompose && mv kompose /usr/local/bin/kompose)

kompose convert -f ./docker-compose.yml
docker-compose up -d
docker-compose logs -f
