#!/bin/bash

source $(dirname "${BASH_SOURCE[0]}")/bot-base.sh

echo -n "Collecting information on triggering PR"
PR_URL=$(jq -er .pull_request.url "$GITHUB_EVENT_PATH")
echo .

PR_FILES=$(api_get "$PR_URL/files?&per_page=1000" | jq -er '.[] | .filename')
echo $PR_FILES
