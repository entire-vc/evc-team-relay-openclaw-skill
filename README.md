# EVC Team Relay — MCP Server & OpenClaw Skill

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![MCP](https://img.shields.io/badge/MCP-server-4A90D9)](https://modelcontextprotocol.io)
[![OpenClaw](https://img.shields.io/badge/OpenClaw-skill-FF5A2D)](https://github.com/openclaw/openclaw)
[![Entire VC](https://img.shields.io/badge/Entire_VC-toolbox-525769)](https://entire.vc)

**Give your AI agent read/write access to your Obsidian vault.**

> Your agent reads your notes, creates new ones, and stays in sync — all through the Team Relay API.

Works with **Claude Code**, **Codex CLI**, **OpenCode**, **OpenClaw**, and any MCP-compatible client.

---

## Quick Start (MCP)

### 1. Install

```bash
git clone https://github.com/entire-vc/evc-team-relay-openclaw-skill.git
cd evc-team-relay-openclaw-skill
uv sync   # or: pip install .
```

### 2. Set environment variables

```bash
export RELAY_CP_URL="https://cp.yourdomain.com"
export RELAY_EMAIL="agent@yourdomain.com"
export RELAY_PASSWORD="your-password"
```

### 3. Add to your AI tool

**Claude Code** — add to `.mcp.json` (project or `~/.claude/.mcp.json`):

```json
{
  "mcpServers": {
    "evc-relay": {
      "command": "uv",
      "args": ["run", "--directory", "/path/to/evc-team-relay-openclaw-skill", "relay_mcp.py"],
      "env": {
        "RELAY_CP_URL": "https://cp.yourdomain.com",
        "RELAY_EMAIL": "agent@yourdomain.com",
        "RELAY_PASSWORD": "your-password"
      }
    }
  }
}
```

**Codex CLI** — add to `codex.json`:

```json
{
  "mcp_servers": {
    "evc-relay": {
      "type": "stdio",
      "command": "uv",
      "args": ["run", "--directory", "/path/to/evc-team-relay-openclaw-skill", "relay_mcp.py"],
      "env": {
        "RELAY_CP_URL": "https://cp.yourdomain.com",
        "RELAY_EMAIL": "agent@yourdomain.com",
        "RELAY_PASSWORD": "your-password"
      }
    }
  }
}
```

**OpenCode** — add to `opencode.json`:

```json
{
  "mcpServers": {
    "evc-relay": {
      "command": "uv",
      "args": ["run", "--directory", "/path/to/evc-team-relay-openclaw-skill", "relay_mcp.py"],
      "env": {
        "RELAY_CP_URL": "https://cp.yourdomain.com",
        "RELAY_EMAIL": "agent@yourdomain.com",
        "RELAY_PASSWORD": "your-password"
      }
    }
  }
}
```

See `config/` for ready-to-copy config templates.

---

## MCP Tools

| Tool | Description |
|------|-------------|
| `authenticate` | Authenticate with credentials (auto-managed) |
| `list_shares` | List accessible shares (filter by kind, ownership) |
| `list_files` | List files in a folder share |
| **`read_file`** | Read a file by path from a folder share |
| `read_document` | Read document by doc_id (low-level) |
| **`upsert_file`** | Create or update a file by path |
| `write_document` | Write to a document by doc_id |
| `delete_file` | Delete a file from a folder share |

**Recommended workflow:** `list_shares` → `list_files` → `read_file` / `upsert_file`

Authentication is automatic — the server logs in and refreshes tokens internally.

---

## Remote Mode (HTTP Transport)

Run as an HTTP server for remote or shared deployments:

```bash
# Direct
uv run relay_mcp.py --transport http --port 8888

# Docker
docker compose up -d
```

Then point your MCP client to `http://your-server:8888/mcp` using the streamable-http transport type.

### Docker

```bash
# Build and run
docker compose up -d

# With custom env
RELAY_CP_URL=https://cp.yourdomain.com \
RELAY_EMAIL=agent@yourdomain.com \
RELAY_PASSWORD=your-password \
docker compose up -d
```

---

## OpenClaw Skill (Legacy)

This repo also works as a classic OpenClaw bash-scripts skill. See [SKILL.md](SKILL.md) for the original bash-based interface.

```bash
cp -r . ~/.openclaw/skills/evc-team-relay/
chmod +x ~/.openclaw/skills/evc-team-relay/scripts/*.sh
```

---

## How It Works

```
┌─────────────┐     MCP / REST     ┌──────────────┐     Yjs CRDT      ┌──────────────┐
│  AI Agent   │ ◄──────────────► │  Team Relay  │ ◄──────────────► │   Obsidian   │
│ (any tool)  │   read / write   │   Server     │    real-time     │    Client    │
└─────────────┘                  └──────────────┘      sync         └──────────────┘
```

The MCP server talks to Team Relay's REST API. Team Relay stores documents as Yjs CRDTs and syncs them to Obsidian clients in real-time. Changes made by the agent appear in Obsidian instantly — and vice versa.

---

## Prerequisites

- Python 3.10+ with [uv](https://docs.astral.sh/uv/) (recommended) or pip
- A running [EVC Team Relay](https://github.com/entire-vc/evc-team-relay) instance (self-hosted or [hosted](https://entire.vc))
- A user account on the Relay control plane

---

## Part of the Entire VC Toolbox

| Product | What it does | Link |
|---------|-------------|------|
| **Local Sync** | Vault ↔ AI dev tools sync | [repo](https://github.com/entire-vc/evc-local-sync-plugin) |
| **Team Relay** | Self-hosted collaboration server | [repo](https://github.com/entire-vc/evc-team-relay) |
| **Team Relay Plugin** | Obsidian plugin for Team Relay | [repo](https://github.com/entire-vc/evc-team-relay-obsidian-plugin) |
| **Spark MCP** | MCP server for AI workflow catalog | [repo](https://github.com/entire-vc/evc-spark-mcp) |
| **Relay MCP** ← you are here | AI agent ↔ vault access | this repo |

## Community

- [entire.vc](https://entire.vc)
- [Discussions](https://github.com/entire-vc/.github/discussions)
- in@entire.vc

## License

MIT — Copyright (c) 2026 Entire VC
