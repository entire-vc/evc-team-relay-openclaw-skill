---
name: evc-team-relay
description: >
  Read and write Obsidian notes stored in EVC Team Relay collaborative vault.
  Use when agent needs to: read note content from a shared Obsidian vault,
  create or update documents, list available shared folders and documents,
  or search across shared vault content. Relay stores documents as Yjs CRDTs;
  this skill provides a REST interface to read/write their text content.
---

# EVC Team Relay

REST API skill for reading and writing collaborative Obsidian vault documents via EVC Team Relay.

## Environment variables

| Variable | Required | Description |
|----------|----------|-------------|
| `RELAY_CP_URL` | yes | Control plane URL, e.g. `https://cp.your-domain.com` |
| `RELAY_EMAIL` | yes | User email for authentication |
| `RELAY_PASSWORD` | yes | User password |

## Quick start

```bash
# 1. Authenticate — get a JWT token
TOKEN=$(scripts/auth.sh)

# 2. List shares to find available documents
scripts/list-shares.sh "$TOKEN"

# 3. Read a document (doc share)
scripts/read.sh "$TOKEN" <share_id> <doc_id>

# 4. List files in a folder share
scripts/list-files.sh "$TOKEN" <share_id>

# 5. Create or update a file in a folder share (RECOMMENDED)
scripts/upsert-file.sh "$TOKEN" <folder_share_id> "note.md" "# Content"

# 6. Delete a file from a folder share
scripts/delete-file.sh "$TOKEN" <folder_share_id> "old-note.md"
```

## Critical: folder shares vs doc shares

There are two kinds of shares:

- **`doc` shares** — single documents. The `share_id` IS the `doc_id`. Use `read.sh` / `write.sh` directly.
- **`folder` shares** — contain multiple files. Each file has its own `doc_id` stored in the folder's metadata registry (`filemeta_v0`).

**For folder shares, ALWAYS use `upsert-file.sh`** to create or update files. This script:
1. Checks if the file already exists in the folder metadata
2. If it exists → updates content via `PUT /content`
3. If it's new → creates the file AND registers it in folder metadata via `POST /files`

**Why this matters**: Files in folder shares MUST be registered in `filemeta_v0` to be visible in Obsidian. Using `write.sh` directly on a folder share writes content to the relay but does NOT register the file — the Obsidian plugin will never see it.

| Operation | Doc share | Folder share |
|-----------|-----------|--------------|
| Read | `read.sh <token> <share_id>` | `read.sh <token> <share_id> <file_doc_id>` |
| Create/Update | `write.sh <token> <share_id> <doc_id> <content>` | **`upsert-file.sh <token> <share_id> <file_path> <content>`** |
| Delete | N/A | `delete-file.sh <token> <share_id> <file_path>` |

## Authentication

All API calls require a Bearer JWT token. Get one via login:

```bash
curl -s -X POST "$RELAY_CP_URL/v1/auth/login" \
  -H "Content-Type: application/json" \
  -d '{"email": "'$RELAY_EMAIL'", "password": "'$RELAY_PASSWORD'"}' \
  | jq -r '.access_token'
```

Response:
```json
{
  "access_token": "eyJ...",
  "refresh_token": "...",
  "token_type": "bearer",
  "expires_in": 3600
}
```

Use the `access_token` as `Authorization: Bearer <token>` header on all subsequent requests.

When the token expires (1 hour), refresh it:
```bash
curl -s -X POST "$RELAY_CP_URL/v1/auth/refresh" \
  -H "Content-Type: application/json" \
  -d '{"refresh_token": "'$REFRESH_TOKEN'"}'
```

## Listing shares

Shares are the access units — each share maps to a document or folder in the Obsidian vault.

```bash
curl -s "$RELAY_CP_URL/v1/shares" \
  -H "Authorization: Bearer $TOKEN" | jq
```

Response (array):
```json
[
  {
    "id": "a1b2c3d4-...",
    "kind": "doc",
    "path": "Projects/meeting-notes.md",
    "visibility": "private",
    "is_owner": true,
    "user_role": null,
    "web_published": false
  },
  {
    "id": "e5f6g7h8-...",
    "kind": "folder",
    "path": "Projects/",
    "visibility": "private",
    "is_owner": false,
    "user_role": "editor"
  }
]
```

Key fields:
- **`id`** — share UUID, used as `share_id` parameter for document operations
- **`kind`** — `doc` (single file) or `folder` (directory)
- **`path`** — Obsidian vault-relative path
- **`user_role`** — `viewer` (read-only), `editor` (read-write), or `null` (owner)

For `doc` shares: `share_id` is used directly as the `doc_id` in document operations.
For `folder` shares: each file inside has its own `doc_id` (discover via `list-files.sh`).

Filter options: `?kind=doc`, `?owned_only=true`, `?member_only=true`, `?skip=0&limit=50`.

## Listing files in a folder share

Before reading individual documents inside a folder share, list the files to discover their `doc_id` values.

```bash
scripts/list-files.sh "$TOKEN" <share_id>
```

Or directly via curl:

```bash
curl -s "$RELAY_CP_URL/v1/documents/{share_id}/files?share_id={share_id}" \
  -H "Authorization: Bearer $TOKEN" | jq
```

Response:
```json
{
  "doc_id": "e5f6g7h8-...",
  "files": {
    "meeting-notes.md": {"id": "abc123", "type": "markdown", "hash": "h1a2b3c4"},
    "project-plan.md": {"id": "def456", "type": "markdown", "hash": "h5e6f7g8"}
  }
}
```

Each key is the file's virtual path within the folder. Use the file's `id` as `doc_id` to read its content with the `/content` endpoint. The `share_id` for the content request is the folder share's ID.

Access: requires at least `viewer` role or ownership.

## Reading documents

```bash
curl -s "$RELAY_CP_URL/v1/documents/{doc_id}/content?share_id={share_id}" \
  -H "Authorization: Bearer $TOKEN" | jq
```

Parameters:
- **`doc_id`** (path) — document identifier. For `doc` shares, this equals the `share_id`.
- **`share_id`** (query, required) — share UUID for ACL check.
- **`key`** (query, optional, default: `contents`) — Yjs shared type key.

Response:
```json
{
  "doc_id": "a1b2c3d4-...",
  "content": "# Meeting Notes\n\nDiscussed project timeline...",
  "format": "text"
}
```

The `content` field contains the full document text (Markdown).

Access: requires at least `viewer` role or ownership.

## Writing documents

### For folder shares — use upsert-file.sh (RECOMMENDED)

```bash
# Create or update — auto-detects which operation is needed
scripts/upsert-file.sh "$TOKEN" <folder_share_id> "note.md" "# Updated content"

# Pipe content from stdin
echo "# Content" | scripts/upsert-file.sh "$TOKEN" <folder_share_id> "note.md" -
```

Response includes an `operation` field: `"created"` or `"updated"`.

### For doc shares — use write.sh

```bash
scripts/write.sh "$TOKEN" <share_id> <doc_id> "# Updated Notes"
```

Or directly via curl:

```bash
curl -s -X PUT "$RELAY_CP_URL/v1/documents/{doc_id}/content" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "share_id": "a1b2c3d4-...",
    "content": "# Updated Notes\n\nNew content here.",
    "key": "contents"
  }' | jq
```

Body fields:
- **`share_id`** (required) — share UUID for ACL check.
- **`content`** (required) — full document text to write (replaces entire document).
- **`key`** (optional, default: `contents`) — Yjs shared type key.

Response:
```json
{
  "doc_id": "a1b2c3d4-...",
  "status": "ok",
  "length": 42
}
```

Access: requires `editor` role or ownership. Viewers cannot write.

**Important**: PUT replaces the entire document content. To append, first read the current content, modify it, then write back.

## Common workflows

### Read a specific note by path

1. List shares: `GET /v1/shares?kind=doc`
2. Find the share where `path` matches (e.g. `Projects/meeting-notes.md`)
3. Read content: `GET /v1/documents/{share.id}/content?share_id={share.id}`

### Read a file from a folder share

1. Find the folder share: `GET /v1/shares?kind=folder`
2. List files: `scripts/list-files.sh "$TOKEN" <share_id>`
3. Find the file entry by its virtual path (e.g. `meeting-notes.md`)
4. Read content using the file's `id` as doc_id: `scripts/read.sh "$TOKEN" <share_id> <file_id>`

### Create or update a file in a folder share

Use `upsert-file.sh` — it handles both cases automatically:

```bash
# Always works, whether the file exists or not
scripts/upsert-file.sh "$TOKEN" <folder_share_id> "note.md" "# Content"
```

### Update an existing doc share

1. Read current content: `scripts/read.sh "$TOKEN" <share_id>`
2. Modify the text (append, edit sections, etc.)
3. Write back: `scripts/write.sh "$TOKEN" <share_id> <share_id> "$NEW_CONTENT"`

### Delete a file from a folder share

```bash
scripts/delete-file.sh "$TOKEN" <folder_share_id> "old-note.md"
```

Or via curl:

```bash
curl -s -X DELETE "$RELAY_CP_URL/v1/documents/{folder_share_id}/files/{file_path}?share_id={folder_share_id}" \
  -H "Authorization: Bearer $TOKEN" | jq
```

Removes the file from the folder's metadata. The file disappears from Obsidian on next sync.

## Error codes

| Status | Meaning |
|--------|---------|
| 400 | Invalid share_id format |
| 401 | Missing or expired token — re-authenticate |
| 403 | Insufficient permissions (viewer trying to write, or non-member) |
| 404 | Share not found |
| 422 | Missing required field (share_id, content) |
| 502 | Relay server unavailable — retry later |

## References

- `references/api.md` — full API reference with all endpoints
