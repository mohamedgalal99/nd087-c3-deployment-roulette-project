#!/bin/bash

DEPLOY_INCREMENTS=1

function manual_verification {
  read -p "Replacing 50% of current canary-v1 with canary-v2 ? (y/n) " answer

    if [[ $answer =~ ^[Yy]$ ]] ;
    then
        echo "Deploying ..."
    else
        exit
    fi
}

function canary_deploy {
  NUM_OF_V1_PODS=$(kubectl get pods -n udacity | grep -c canary-v1)
  echo "V1 PODS: $NUM_OF_V1_PODS"
  NUM_OF_V2_PODS=$(kubectl get pods -n udacity | grep -c canary-v2)
  echo "V2 PODS: $NUM_OF_V2_PODS"

  # This will rolling out 50% of old remaining canary v1 with canary v2
  [[ ${NUM_OF_V1_PODS} -eq 1 ]] && DEPLOY_INCREMENTS=1 || DEPLOY_INCREMENTS=$(( ${NUM_OF_V1_PODS} / 2 ))
  
  #echo "${DEPLOY_INCREMENTS}"

  kubectl scale deployment canary-v2 --replicas=$(( NUM_OF_V2_PODS + $DEPLOY_INCREMENTS ))
  kubectl scale deployment canary-v1 --replicas=$(( NUM_OF_V1_PODS - $DEPLOY_INCREMENTS ))

  ATTEMPTS=0
  ROLLOUT_STATUS_CMD="kubectl rollout status deployment/canary-v2 -n udacity"
  until $ROLLOUT_STATUS_CMD || [ $ATTEMPTS -eq 60 ]; do
    $ROLLOUT_STATUS_CMD
    ATTEMPTS=$((attempts + 1))
    sleep 1
  done
  echo "Canary deployment of $DEPLOY_INCREMENTS replicas successful!"
}

while [ $(kubectl get pods -n udacity | grep -c canary-v1) -gt 0 ]
do
  manual_verification
  canary_deploy
done

echo "Canary deployment of v2 successful"
