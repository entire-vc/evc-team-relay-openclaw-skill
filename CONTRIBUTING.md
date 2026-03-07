# Contributing to EVC Team Relay OpenClaw Skill

Thanks for your interest in contributing! This skill lets OpenClaw AI agents read and write Obsidian notes via the Team Relay REST API.

## Getting Started

1. Fork the repository
2. Clone your fork locally
3. Create a feature branch: `git checkout -b feature/my-feature`

## Development

The skill is a set of bash scripts. No build step required.

```bash
# Configure your relay endpoint
export RELAY_BASE_URL=http://localhost:8000
export RELAY_TOKEN=your-token

# Test a script
bash scripts/list-shares.sh
bash scripts/read-file.sh <share-id> path/to/note.md
```

## Testing

```bash
# Lint with shellcheck
shellcheck scripts/*.sh

# Integration test - requires a running relay instance
bash scripts/list-shares.sh
```

## Pull Requests

1. Create a branch from `main`
2. Make your changes
3. Ensure `shellcheck scripts/*.sh` passes
4. Test manually against a local relay instance
5. Write a clear PR description explaining what and why
6. Submit the PR

## Reporting Bugs

Use the [Bug Report](https://github.com/entire-vc/evc-team-relay-openclaw-skill/issues/new?template=bug_report.md) issue template.

## Requesting Features

Use the [Feature Request](https://github.com/entire-vc/evc-team-relay-openclaw-skill/issues/new?template=feature_request.md) issue template.

## Code Style

- POSIX-compatible bash where possible
- Shellcheck-clean
- Each script does one thing well
- Keep error handling explicit

## License

By contributing, you agree that your contributions will be licensed under the [MIT License](LICENSE).
