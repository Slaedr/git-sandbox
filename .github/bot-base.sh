#!/bin/bash

set -e

API_HEADER="Accept: application/vnd.github.v3+json"
AUTH_HEADER="Authorization: token $GITHUB_TOKEN"

api_get() {
  (set +x; curl -X GET -s -H "${AUTH_HEADER}" -H "${API_HEADER}" "$1")
}

api_post() {
  (set +x; curl -X POST -s -H "${AUTH_HEADER}" -H "${API_HEADER}" "$1" -d "$2")
}

api_patch() {
  (set +x; curl -X PATCH -s -H "${AUTH_HEADER}" -H "${API_HEADER}" "$1" -d "$2")
}
