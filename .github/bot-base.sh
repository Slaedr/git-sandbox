#!/bin/bash

set -e

API_HEADER="Accept: application/vnd.github.v3+json"
AUTH_HEADER="Authorization: token $GITHUB_TOKEN"
ISSUE_URL=$(jq -r ".issue.url" "$GITHUB_EVENT_PATH")
if [[ "$ISSUE_URL" == "null" ]]; then
  echo "Could not determine issue URL"
  exit 1
fi

api_get() {
  curl -X GET -s -H "${AUTH_HEADER}" -H "${API_HEADER}" "$1"
}

api_post() {
  curl -X POST -s -H "${AUTH_HEADER}" -H "${API_HEADER}" "$1" -d "$2"
}

bot_error() {
  echo "$1"
  api_post $ISSUE_URL/comments "{\"body\":\"Error: $1\"}"
  exit 1
}

set -o xtrace
