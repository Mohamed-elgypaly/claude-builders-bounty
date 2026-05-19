# Changelog

## [Unreleased]

### Added
- Initial release

### How to use

Run `claude changelog` in any git repository to auto-generate a changelog from commit history.

## CLAUDE.md Skill Definition

```markdown
## Skills

### changelog
Generate a CHANGELOG.md from git history since the last tag.
Usage: Ask Claude to "generate a changelog" or "update the changelog"
Accepts: `--since <tag>` (default: last tag), `--output <file>` (default: CHANGELOG.md)
Format: Keeps existing [Unreleased] section, appends new entries under [Unreleased]
Commit types mapped: feat → Added, fix → Fixed, breaking → Changed, docs → Documentation, refactor → Changed, test → Testing, chore → Maintenance
```
