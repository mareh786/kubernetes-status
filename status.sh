#!/bin/bash

# --- CONFIGURATION ---
WEBHOOK_URL="https://default6432230809a947a38c1cb82871d605.68.environment.api.powerplatform.com:443/powerautomate/automations/direct/workflows/3e2569d19fc8433b85a1746afb37fcde/triggers/manual/paths/invoke?api-version=1&sp=%2Ftriggers%2Fmanual%2Frun&sv=1.0&sig=qIqI3tBZpeYDONNFrZuqzWlsXOGdsezzn7Wjj_fIc6s"
CLUSTER_NAME=$(hostname)

# --- CHECK FOR DOWN NODES ---
# Filters for any node that is NOT "Ready"
DOWN_NODES=$(kubectl get nodes --no-headers | awk '$2 != "Ready" {print "- " $1 " (**" $2 "**)"}')

# Also check if the cluster returns 0 nodes entirely
NODE_TOTAL=$(kubectl get nodes --no-headers | wc -l)

if [[ "$NODE_TOTAL" -eq 0 ]]; then
    DOWN_NODES="- **CRITICAL**: No nodes found in cluster!"
fi

# --- TRIGGER ONLY IF DOWN ---
if [[ -n "$DOWN_NODES" ]]; then
    echo "Nodes are down. Sending notification..."

    PAYLOAD=$(cat <<EOF
{
  "type": "message",
  "attachments": [
    {
      "contentType": "application/vnd.microsoft.card.adaptive",
      "content": {
        "type": "AdaptiveCard",
        "body": [
          {
            "type": "TextBlock",
            "text": "🚨 NODE DOWN ALERT",
            "weight": "Bolder",
            "size": "Large",
            "color": "Attention"
          },
          {
            "type": "TextBlock",
            "text": "Cluster Host: $CLUSTER_NAME",
            "isSubtle": true
          },
          {
            "type": "TextBlock",
            "text": "$DOWN_NODES",
            "wrap": true
          }
        ],
        "\$schema": "http://adaptivecards.io",
        "version": "1.4"
      }
    }
  ]
}
EOF
)

    curl -s -X POST \
      -H 'Content-Type: application/json' \
      -d "$PAYLOAD" \
      "$WEBHOOK_URL" > /dev/null
else
    # Do nothing and exit if all nodes are healthy
    exit 0
fi
 
