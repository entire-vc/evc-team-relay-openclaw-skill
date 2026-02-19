#!/usr/bin/env bash
# Read document content from Relay.
# Usage: scripts/read.sh <token> <share_id> [doc_id] [key]
# Args:
#   token    — JWT access token
#   share_id — share UUID (for ACL check)
#   doc_id   — (optional) document ID, defaults to share_id
#   key      — (optional) Yjs key, defaults to "content"
# Env: RELAY_CP_URL
# Output: document content as JSON (doc_id, content, format)
set -euo pipefail

: "${RELAY_CP_URL:?Set RELAY_CP_URL}"
TOKEN="${1:?Usage: read.sh <token> <share_id> [doc_id] [key]}"
SHARE_ID="${2:?Usage: read.sh <token> <share_id> [doc_id] [key]}"
DOC_ID="${3:-$SHARE_ID}"
KEY="${4:-content}"

curl -sf "${RELAY_CP_URL}/v1/documents/${DOC_ID}/content?share_id=${SHARE_ID}&key=${KEY}" \
  -H "Authorization: Bearer $TOKEN" | jq '.'
