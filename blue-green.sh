#!/bin/bash

GREEN_PATH="starter/apps/blue-green/green.yml"

# Deploying
echo "[*] Deploying Green" 
kubectl apply -f ${GREEN_PATH}

ATTEMPTS=0
ROLLOUT_STATUS_CMD="kubectl rollout status deployment/green -n udacity"
until $ROLLOUT_STATUS_CMD || [ $ATTEMPTS -eq 60 ]; do
  $ROLLOUT_STATUS_CMD
  ATTEMPTS=$((attempts + 1))
  sleep 1
done
echo "[+] Green deployment successful!"

echo "[*] Waiting for green service to come up."
SERVICE_URL="curl $(kubectl get svc | grep green-svc | awk '{print $4}')"
ATTEMPTS=0
until $SERVICE_URL 2> /dev/null || [ $ATTEMPTS -eq 300 ]; do
  echo "Service URL not available yet ..."
  sleep 2
done

if ${SERVICE_URL} 2> /dev/null; then
  echo "[+] URL is up"
else
  echo "[-] URL not initialized"
fi
