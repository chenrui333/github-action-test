#!/bin/bash
set -euo pipefail

# Authenticate with `gh auth login` or an existing GH_TOKEN/GITHUB_TOKEN environment.
# No token is passed in process arguments. The API command fails on HTTP errors.
if [[ "${1:-}" == "--help" ]]; then
  echo "Usage: repository-dispatch-trigger.sh [--dry-run]"
  exit 0
fi
if [[ $# -gt 1 || ( $# -eq 1 && "$1" != "--dry-run" ) ]]; then
  echo "Usage: repository-dispatch-trigger.sh [--dry-run]" >&2
  exit 2
fi

payload='{"event_type":"trigger-event","client_payload":{"id":"962368b5c27b7ec5ecfcb4ed8f8c57adb52a8442","unit":false,"integration":true}}'
if [[ "${1:-}" == "--dry-run" ]]; then
  printf '%s\n' "$payload"
  exit 0
fi

printf '%s\n' "$payload" | gh api --method POST \
  -H 'Accept: application/vnd.github+json' \
  repos/chenrui333/github-action-test/dispatches --input -
