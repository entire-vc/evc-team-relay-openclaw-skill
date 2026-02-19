# EVC Team Relay — OpenClaw Skill

[OpenClaw](https://github.com/openclaw/openclaw) skill for reading and writing Obsidian notes via [EVC Team Relay](https://github.com/entire-vc/evc-team-relay) REST API.

## What it does

Gives AI agents REST access to collaborative Obsidian vault documents managed by EVC Team Relay:

- **List** shared documents and folders
- **Read** note content as Markdown text
- **Write** (create/update) note content

## Prerequisites

- A running [EVC Team Relay](https://github.com/entire-vc/evc-team-relay) instance (control plane + relay server)
- A user account on the Relay control plane with access to shares
- [OpenClaw](https://github.com/openclaw/openclaw) installed
- `curl` and `jq` on the host

## Installation

```bash
# Copy skill to OpenClaw skills directory
cp -r . ~/.openclaw/skills/evc-team-relay/

# Make scripts executable
chmod +x ~/.openclaw/skills/evc-team-relay/scripts/*.sh
```

## Configuration

Add credentials to `~/.openclaw/openclaw.json`:

```json
{
  "skills": {
    "entries": {
      "evc-team-relay": {
        "env": {
          "RELAY_CP_URL": "https://cp.your-domain.com",
          "RELAY_EMAIL": "agent@your-domain.com",
          "RELAY_PASSWORD": "your-password"
        }
      }
    }
  }
}
```

| Variable | Description |
|----------|-------------|
| `RELAY_CP_URL` | Control plane URL (e.g. `https://cp.your-domain.com`) |
| `RELAY_EMAIL` | User email for authentication |
| `RELAY_PASSWORD` | User password |

## Verify installation

```bash
export RELAY_CP_URL="https://cp.your-domain.com"
export RELAY_EMAIL="agent@your-domain.com"
export RELAY_PASSWORD="your-password"

# Test auth
TOKEN=$(~/.openclaw/skills/evc-team-relay/scripts/auth.sh)
echo "OK: token ${#TOKEN} chars"

# List available shares
~/.openclaw/skills/evc-team-relay/scripts/list-shares.sh "$TOKEN"
```

## Usage

Once installed, the agent can use the skill with natural language:

- "Read the meeting notes from Relay"
- "Update the project status document"
- "List all shared documents in the vault"
- "Write a summary to the daily notes"

## Scripts

| Script | Purpose |
|--------|---------|
| `scripts/auth.sh` | Authenticate, print JWT token |
| `scripts/list-shares.sh` | List accessible shares |
| `scripts/read.sh` | Read document content |
| `scripts/write.sh` | Write document content |

See `SKILL.md` for detailed API usage and `references/api.md` for the full API reference.

## License

MIT
