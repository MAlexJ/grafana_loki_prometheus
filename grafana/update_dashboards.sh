#!/bin/bash

# Set variables
GRAFANA_URL="${GRAFANA_URL}"
GRAFANA_API_KEY="${GRAFANA_API_KEY}"
DASHBOARD_DIR="${DASHBOARD_DIR}"
COMMIT_MESSAGE="${COMMIT_MESSAGE}"
UNIX_TIMESTAMP="${UNIX_TIMESTAMP}"

# Function to update a single dashboard
update_dashboard() {
    local dashboard_file=$1

    # Read the dashboard JSON content
    dashboard_json=$(cat "$dashboard_file")

    # replace version with unix timestamp
    updated_version=$(echo "$dashboard_json" | jq --arg ts "$UNIX_TIMESTAMP" '.version = $ts')

    # Wrap the dashboard JSON in the required structure
    payload=$(jq -c -n --arg commit_message "$COMMIT_MESSAGE" --argjson dashboard "$updated_version" '{
        dashboard: $dashboard,
        folderId: 0,
        overwrite: true,
        message: $commit_message
    }')

    curl --location "$GRAFANA_URL/api/dashboards/db" \
        --header 'Content-Type: application/json' \
        --header "Authorization: Bearer $GRAFANA_API_KEY" \
        --data "$payload"
}

# Loop through all JSON files in the dashboard directory
for dashboard_file in "$DASHBOARD_DIR"/*.json; do
    if [ -f "$dashboard_file" ]; then
        update_dashboard "$dashboard_file"
    fi
done
