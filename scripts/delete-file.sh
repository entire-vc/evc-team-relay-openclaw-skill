#!/usr/bin/env bash
# Delete a file from a folder share.
# Usage: scripts/delete-file.sh <token> <folder_share_id> <file_path>
# Args:
#   token           — JWT access token
#   folder_share_id — folder share UUID
#   file_path       — file name within the folder (e.g. "notes.md")
# Env: RELAY_CP_URL
# Output: JSON with path and status
set -euo pipefail

: "${RELAY_CP_URL:?Set RELAY_CP_URL}"
TOKEN="${1:?Usage: delete-file.sh <token> <folder_share_id> <file_path>}"
FOLDER_SHARE_ID="${2:?Usage: delete-file.sh <token> <folder_share_id> <file_path>}"
FILE_PATH="${3:?Usage: delete-file.sh <token> <folder_share_id> <file_path>}"

# URL-encode the file path for safety
ENCODED_PATH=$(python3 -c "import urllib.parse; print(urllib.parse.quote('$FILE_PATH', safe=''))")

curl -sf -X DELETE "${RELAY_CP_URL}/v1/documents/${FOLDER_SHARE_ID}/files/${ENCODED_PATH}?share_id=${FOLDER_SHARE_ID}" \
  -H "Authorization: Bearer $TOKEN" | jq '.'
