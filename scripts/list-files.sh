#!/usr/bin/env bash
# List files in a folder share from Relay.
# Usage: scripts/list-files.sh <token> <share_id>
# Args:
#   token    — JWT access token
#   share_id — folder share UUID (used as both doc_id and share_id for ACL check)
# Env: RELAY_CP_URL
# Output: JSON with doc_id and files map (path -> metadata)
set -euo pipefail

: "${RELAY_CP_URL:?Set RELAY_CP_URL}"
TOKEN="${1:?Usage: list-files.sh <token> <share_id>}"
SHARE_ID="${2:?Usage: list-files.sh <token> <share_id>}"

curl -sf "${RELAY_CP_URL}/v1/documents/${SHARE_ID}/files?share_id=${SHARE_ID}" \
  -H "Authorization: Bearer $TOKEN" | jq '.'
