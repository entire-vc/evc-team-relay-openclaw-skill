#!/usr/bin/env bash
# List accessible shares from Relay Control Plane.
# Usage: scripts/list-shares.sh <token> [kind] [owned_only]
# Args:
#   token       — JWT access token
#   kind        — (optional) "doc" or "folder"
#   owned_only  — (optional) "true" to show only owned shares
# Env: RELAY_CP_URL
set -euo pipefail

: "${RELAY_CP_URL:?Set RELAY_CP_URL}"
TOKEN="${1:?Usage: list-shares.sh <token> [kind] [owned_only]}"
KIND="${2:-}"
OWNED="${3:-}"

URL="${RELAY_CP_URL}/v1/shares"
PARAMS=""
[ -n "$KIND" ] && PARAMS="${PARAMS}&kind=${KIND}"
[ -n "$OWNED" ] && PARAMS="${PARAMS}&owned_only=${OWNED}"
[ -n "$PARAMS" ] && URL="${URL}?${PARAMS:1}"

curl -sf "$URL" -H "Authorization: Bearer $TOKEN" | jq '.'
