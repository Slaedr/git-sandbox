#!/bin/bash

source $(dirname "${BASH_SOURCE[0]}")/bot-base.sh

echo -n "Collecting information on triggering PR"
PR_URL=$(jq -er .pull_request.url "$GITHUB_EVENT_PATH")
echo -n .
ISSUE_URL=$(jq -er .pull_request.issue_url "$GITHUB_EVENT_PATH")
echo .

echo "Retrieving PR file list"
PR_FILES=$(api_get "$PR_URL/files?&per_page=1000" | jq -er '.[] | .filename')

echo "Retrieving PR label list"
OLD_LABELS=$(api_get "$ISSUE_URL" | jq -er '[.labels | .[] | .name]')

NEW_LABELS="[]"
if echo "$PR_FILES" | grep .cpp; then
  NEW_LABELS="$NEW_LABELS + [\"bug\"]"
fi
echo $OLD_LABELS, $NEW_LABELS
NEW_LABELS=$(jq -rn "$OLD_LABELS + $NEW_LABELS | unique")
