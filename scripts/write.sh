#!/usr/bin/env bash
# Write document content to Relay (doc shares only).
# WARNING: For folder shares, use upsert-file.sh instead!
#          write.sh does NOT register files in folder metadata —
#          new files written this way will be invisible to Obsidian.
#
# Usage: scripts/write.sh <token> <share_id> <doc_id> <content> [key]
#    or: echo "content" | scripts/write.sh <token> <share_id> <doc_id> - [key]
# Args:
#   token    — JWT access token
#   share_id — share UUID (for ACL check)
#   doc_id   — document ID
#   content  — text content to write, or "-" to read from stdin
#   key      — (optional) Yjs key, defaults to "contents"
# Env: RELAY_CP_URL
set -euo pipefail

: "${RELAY_CP_URL:?Set RELAY_CP_URL}"
TOKEN="${1:?Usage: write.sh <token> <share_id> <doc_id> <content> [key]}"
SHARE_ID="${2:?Usage: write.sh <token> <share_id> <doc_id> <content> [key]}"
DOC_ID="${3:?Usage: write.sh <token> <share_id> <doc_id> <content> [key]}"
CONTENT_ARG="${4:?Usage: write.sh <token> <share_id> <doc_id> <content> [key]}"
KEY="${5:-contents}"

if [ "$CONTENT_ARG" = "-" ]; then
  CONTENT=$(cat)
else
  CONTENT="$CONTENT_ARG"
fi

# Build JSON payload with jq to handle escaping
PAYLOAD=$(jq -n \
  --arg sid "$SHARE_ID" \
  --arg content "$CONTENT" \
  --arg key "$KEY" \
  '{share_id: $sid, content: $content, key: $key}')

curl -sf -X PUT "${RELAY_CP_URL}/v1/documents/${DOC_ID}/content" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d "$PAYLOAD" | jq '.'
