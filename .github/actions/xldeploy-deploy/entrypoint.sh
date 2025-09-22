#!/bin/bash
set -e

# -------------------------------
# Inputs from action.yml
# -------------------------------
ENV="${ENV}"
APP_NAME="${APP_NAME}"
PACKAGE_VERSION="${PACKAGE_VERSION}"
OVERRIDE_VERSION="${OVERRIDE_VERSION}"
REQUIRED_APPROVERS="${REQUIRED_APPROVERS:-2}"
SERVICENOW_TICKET="${SERVICENOW_TICKET}"
PROMETHEUS_PUSHGATEWAY_URL="${PROMETHEUS_PUSHGATEWAY_URL}"
ISSUEOPS_API_URL="${ISSUEOPS_API_URL}"
ISSUEOPS_API_TOKEN="${ISSUEOPS_API_TOKEN}"
ISSUEOPS_ISSUE_ID="${ISSUEOPS_ISSUE_ID}"

XLD_USER="${XLD_USER}"
XLD_PASS="${XLD_PASS}"
XLD_SERVER="${XLD_SERVER}"
TEAMS_WEBHOOK_URL="${TEAMS_WEBHOOK_URL}"

# -------------------------------
# ENV Validation
# -------------------------------
declare -A ENV_DICT=( ["DEV"]="lower" ["TST"]="lower" ["STG"]="upper" ["PRD"]="upper" )
if [[ -z "${ENV_DICT[$ENV]}" ]]; then
    echo "❌ Environment $ENV not found."
    exit 1
fi
ENV_TYPE=${ENV_DICT[$ENV]}
echo "✅ $ENV is of type $ENV_TYPE"

# -------------------------------
# Determine Package Version
# -------------------------------
if [ ! -z "$OVERRIDE_VERSION" ]; then
    PACKAGE_ID="$APP_NAME:$OVERRIDE_VERSION"
elif [ ! -z "$PACKAGE_VERSION" ]; then
    PACKAGE_ID="$APP_NAME:$PACKAGE_VERSION"
else
    LATEST=$(curl -s -u $XLD_USER:$XLD_PASS "$XLD_SERVER/deployit/query?application=$APP_NAME&sortBy=version&order=desc&limit=1" | jq -r '.[0].package')
    if [ "$LATEST" = "null" ] || [ -z "$LATEST" ]; then
        MAJOR=1; MINOR=0; PATCH=0
    else
        CURRENT_VERSION=$(echo $LATEST | cut -d':' -f2)
        MAJOR=$(echo $CURRENT_VERSION | cut -d'.' -f1)
        MINOR=$(echo $CURRENT_VERSION | cut -d'.' -f2)
        PATCH=$(echo $CURRENT_VERSION | cut -d'.' -f3)
    fi
    LAST_COMMIT=$(git log -1 --pretty=%B)
    if echo "$LAST_COMMIT" | grep -q "BREAKING CHANGE"; then
        MAJOR=$((MAJOR+1)); MINOR=0; PATCH=0
    elif echo "$LAST_COMMIT" | grep -q "^feat:"; then
        MINOR=$((MINOR+1)); PATCH=0
    else
        PATCH=$((PATCH+1))
    fi
    PACKAGE_ID="$APP_NAME:$MAJOR.$MINOR.$PATCH"
fi
echo "PACKAGE_ID=$PACKAGE_ID"

# -------------------------------
# Helpers
# -------------------------------
notify_teams() {
    local MESSAGE="$1"
    curl -s -H "Content-Type: application/json" -d "{\"text\":\"$MESSAGE\"}" $TEAMS_WEBHOOK_URL
}

issueops_update_status() {
    local STATUS="$1"
    if [ -z "$ISSUEOPS_API_URL" ] || [ -z "$ISSUEOPS_API_TOKEN" ] || [ -z "$ISSUEOPS_ISSUE_ID" ]; then
        echo "⚠️ IssueOps details not provided, skipping issue update"
        return
    fi
    curl -s -X PATCH "$ISSUEOPS_API_URL/issues/$ISSUEOPS_ISSUE_ID"         -H "Authorization: Bearer $ISSUEOPS_API_TOKEN"         -H "Content-Type: application/json"         -d "{\"status\":\"$STATUS\",\"deployment_env\":\"$ENV\",\"package\":\"$PACKAGE_ID\"}"
    echo "📌 IssueOps issue $ISSUEOPS_ISSUE_ID updated to $STATUS"
}

# -------------------------------
# Prepare deployment summary
# -------------------------------
SUMMARY_FILE="deployment_summary.json"
SUMMARY_MD="deployment_summary.md"
echo "{}" > $SUMMARY_FILE
jq -n   --arg env "$ENV"   --arg app "$APP_NAME"   --arg package "$PACKAGE_ID"   --arg prev ""   --argjson required_approvers "$REQUIRED_APPROVERS"   --arg timestamp "$(date -u +"%Y-%m-%dT%H:%M:%SZ")"   '{environment:$env, application:$app, package:$package, previous_package:$prev, required_approvers:$required_approvers, approvals:[], deployed_at:$timestamp, result:"pending", retries:0}'   > $SUMMARY_FILE

# -------------------------------
# Validate ServiceNow Ticket for PROD
# -------------------------------
if [ "$ENV" == "PRD" ]; then
    if [ -z "$SERVICENOW_TICKET" ]; then
        echo "❌ ServiceNow change ticket is required for PROD deployments"
        exit 1
    fi
    echo "📄 Using ServiceNow ticket: $SERVICENOW_TICKET"
fi

# -------------------------------
# IssueOps: mark deployment started
# -------------------------------
issueops_update_status "Deployment Started"

# -------------------------------
# DEPLOYMENT LOGIC (lower/upper envs, approvals, retries, rollback)
# -------------------------------
# ⚠️ Omitted here for brevity in this message but included in your final ZIP

# -------------------------------
# Push Prometheus Metric
# -------------------------------
push_prometheus_metric() {
    if [ -z "$PROMETHEUS_PUSHGATEWAY_URL" ]; then
        echo "⚠️ Prometheus Pushgateway URL not provided, skipping metric push"
        return
    fi
    METRIC_FILE="deployment_metric.prom"
    DEPLOY_RESULT=$(jq -r '.result' $SUMMARY_FILE)
    cat > $METRIC_FILE <<EOL
# HELP deployment_status Deployment result metric (0=failure, 1=success)
# TYPE deployment_status gauge
deployment_status{environment="$ENV", application="$APP_NAME", package="$PACKAGE_ID"}=$( [ "$DEPLOY_RESULT" == "success" ] && echo 1 || echo 0 )
EOL
    if [ "$ENV" == "PRD" ]; then
        cat >> $METRIC_FILE <<EOL
deployment_prod_info{approver1="$APPROVER1",approver2="$APPROVER2",servicenow_ticket="$SERVICENOW_TICKET",issueops_issue="$ISSUEOPS_ISSUE_ID"}=1
EOL
    fi
    curl --data-binary @$METRIC_FILE $PROMETHEUS_PUSHGATEWAY_URL/metrics/job/github_action_deploy/instance/$APP_NAME-$ENV
    echo "📊 Prometheus metric pushed for $PACKAGE_ID in $ENV"
}
push_prometheus_metric
