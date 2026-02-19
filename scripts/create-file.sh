#!/usr/bin/env bash
# Create a new file inside a folder share.
# Usage: scripts/create-file.sh <token> <folder_share_id> <file_path> <content>
#    or: echo "content" | scripts/create-file.sh <token> <folder_share_id> <file_path> -
# Args:
#   token           — JWT access token
#   folder_share_id — folder share UUID (used as both doc_id and share_id)
#   file_path       — file name within the folder (e.g. "notes.md")
#   content         — text content to write, or "-" to read from stdin
# Env: RELAY_CP_URL
# Output: JSON with doc_id, path, status, length
set -euo pipefail

: "${RELAY_CP_URL:?Set RELAY_CP_URL}"
TOKEN="${1:?Usage: create-file.sh <token> <folder_share_id> <file_path> <content>}"
FOLDER_SHARE_ID="${2:?Usage: create-file.sh <token> <folder_share_id> <file_path> <content>}"
FILE_PATH="${3:?Usage: create-file.sh <token> <folder_share_id> <file_path> <content>}"
CONTENT_ARG="${4:?Usage: create-file.sh <token> <folder_share_id> <file_path> <content>}"

if [ "$CONTENT_ARG" = "-" ]; then
  CONTENT=$(cat)
else
  CONTENT="$CONTENT_ARG"
fi

# Build JSON payload with jq to handle escaping
PAYLOAD=$(jq -n \
  --arg sid "$FOLDER_SHARE_ID" \
  --arg path "$FILE_PATH" \
  --arg content "$CONTENT" \
  '{share_id: $sid, path: $path, content: $content}')

curl -sf -X POST "${RELAY_CP_URL}/v1/documents/${FOLDER_SHARE_ID}/files" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d "$PAYLOAD" | jq '.'
