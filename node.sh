#!/bin/bash
 
echo "Checking on: $(hostname)"
 
#Availability of nodes
 
NODES=$(kubectl get nodes --no-headers | wc -l)
if [[ "$NODES" -eq 0 ]]; then
        echo "NO NODES FOUND"
        exit 1
fi
 
#Nodes Status Check
 
NOT_READY_NODE=$(kubectl get node --no-headers | awk '$2 != "Ready" {print $1}' | wc -l)
if [[ "$NOT_READY_NODE" -eq 0 ]]; then
        echo "Nodes: Healthy"
        echo "Total Nodes: $NODES"
        exit 0
else
        echo "Nodes: Not Healthy"
        echo "Unhealthy Nodes:"
        kubectl get nodes --no-headers | awk '$2 != "Ready" {print $1}'
        exit 1
fi
