#!/bin/bash

set -xeo pipefail
which docker-compose || apt-get install -y docker-compose
which kompose || (curl -L https://github.com/kubernetes/kompose/releases/download/v1.32.0/kompose-linux-amd64 -o kompose && chmod +x kompose && mv kompose /usr/local/bin/kompose)

export RANDOM=`date +%s`
kompose convert -f ./docker-compose.yml
FILE="samba-service.yaml samba-deployment.yaml samba-claim0-persistentvolumeclaim.yaml"
for f in $FILE; do
    kubectl apply -f $f
done
CLUSTER_IP=$(kubectl get svc samba -o jsonpath='{.spec.clusterIP}')
sed -i "s/203.0.112.2/$CLUSTER_IP/g" samba-client-pod.yaml
kubectl delete pod samba-client || true
kubectl apply -f samba-client-pod.yaml
docker-compose down
mkdir -p ./samba-storage/
chmod -R 0777 ./samba-storage/
docker-compose up -d samba
docker-compose up -d
docker-compose logs -f
while true; do
    kubectl logs pod/samba-client -f && break || true
    sleep 8
done
kubectl logs deployment/samba -f
