#!/bin/bash


INACTIVE_PODS=$(kubectl get pods -A --no-headers \
  | awk '$4!="Running" && $4!="Completed" && $4!="Succeeded" {c++} END{print c+0}')

echo "Inactive (not Running/Completed): $INACTIVE_PODS"

# Optionally list them
if [ "$INACTIVE_PODS" -gt 0 ]; then
  echo -e "\nPods not Running/Completed:"
  kubectl get pods -A --no-headers \
    | awk '$4!="Running" && $4!="Completed" && $4!="Succeeded" {printf "%-20s %-45s %-12s %-10s\n", $1, $2, $3, $4}'
fi

