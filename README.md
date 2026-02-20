# EVC Team Relay — OpenClaw Skill

**Give your AI agent read/write access to your Obsidian vault.**

> Your agent reads your notes, creates new ones, and stays in sync — all through the Team Relay API.

---

## What It Does

This [OpenClaw](https://github.com/openclaw/openclaw) skill connects your AI agent to Obsidian notes managed by [EVC Team Relay](https://github.com/entire-vc/evc-team-relay):

- **List** shared folders and documents
- **Read** note content as Markdown
- **Create** new notes in shared folders
- **Write** updates to existing notes
- **Delete** notes when no longer needed

Your agent works with the same notes your team edits in Obsidian — no copy/paste, no stale context.

---

## Use Cases

### AI-Assisted Knowledge Management
Your agent reads specs, updates status docs, creates meeting notes — all directly in your vault.

### Agent-to-Human Handoff
Agent writes analysis/research into a shared folder → you review in Obsidian → refine → agent picks up changes.

### Automated Documentation
Agent monitors code changes and keeps vault docs up to date. Combined with [Local Sync](https://github.com/entire-vc/evc-local-sync-plugin), it closes the loop: code → repo docs → vault → agent → code.

---

## Prerequisites

- [OpenClaw](https://github.com/openclaw/openclaw) installed
- A running [EVC Team Relay](https://github.com/entire-vc/evc-team-relay) instance (self-hosted or [hosted](https://entire.vc))
- A user account on the Relay control plane with access to shared folders
- `curl` and `jq` on the host

---

## Install

```bash
# Copy to OpenClaw skills directory
cp -r . ~/.openclaw/skills/evc-team-relay/
chmod +x ~/.openclaw/skills/evc-team-relay/scripts/*.sh
```

## Configure

Set environment variables in your OpenClaw config:

```json
{
  "skills": {
    "entries": {
      "evc-team-relay": {
        "env": {
          "RELAY_CP_URL": "https://cp.yourdomain.com",
          "RELAY_EMAIL": "agent@yourdomain.com",
          "RELAY_PASSWORD": "your-password"
        }
      }
    }
  }
}
```

---

## Scripts

| Script | What it does |
|--------|-------------|
| `auth.sh` | Authenticate and get JWT token |
| `list-shares.sh` | List all accessible shared folders |
| `list-files.sh` | List files in a shared folder |
| `read.sh` | Read note content |
| `write.sh` | Update existing note |
| `create-file.sh` | Create new note in a folder |
| `delete-file.sh` | Delete a note |

---

## Quick Test

```bash
cd ~/.openclaw/skills/evc-team-relay

# Authenticate
TOKEN=$(bash scripts/auth.sh)

# List shared folders
bash scripts/list-shares.sh "$TOKEN"

# List files in a folder
bash scripts/list-files.sh "$TOKEN" "<share_id>"

# Read a note
bash scripts/read.sh "$TOKEN" "<share_id>" "<doc_id>"
```

---

## Part of the Entire VC Toolbox

| Product | What it does | Link |
|---|---|---|
| **Local Sync** | vault ↔ local folders, solo | [repo](https://github.com/entire-vc/evc-local-sync-plugin) |
| **Team Relay Server** | self-hosted collaboration infrastructure | [repo](https://github.com/entire-vc/evc-team-relay) |
| **Team Relay Plugin** | Obsidian plugin for Team Relay | [repo](https://github.com/entire-vc/evc-team-relay-obsidian-plugin) |
| **OpenClaw Skill** (you are here) | AI agent ↔ vault access | this repo |

---

## License

MIT — Copyright (c) 2025 Entire VC
