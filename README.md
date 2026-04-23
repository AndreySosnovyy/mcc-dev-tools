# mcc-dev-tools

Developer tooling for Flutter projects managed by MCC Taganrog.

---

## setup.sh — project setup

Run once after cloning your Flutter project repository:

```bash
curl -fsSL https://raw.githubusercontent.com/AndreySosnovyy/mcc-dev-tools/main/scripts/setup.sh | bash
```

Re-run at any time to update to the latest version.

### What it sets up

| Tool | Location | Purpose |
|------|----------|---------|
| `commit-msg` hook | `.githooks/commit-msg` | Validates commit messages (Conventional Commits) |
| `commitlint.config.js` | project root | commitlint configuration |
| `git alias pm` | local git config | `git pm` → push + auto-create Draft MR on GitLab |

### Requirements

- Git repository
- Node.js + npm (for commitlint — optional, hook degrades gracefully if absent)

### Commit format

```
<type>: <description>

Types: feat | fix | chore | docs | refactor | ci | test
```

---

## sync-claude.sh — sync Claude config to server

Syncs your local `~/.claude/` to the MCC server over SSH.
Run this after changing any Claude Code configuration (CLAUDE.md, skills, settings).

### Prerequisites

1. **SSH access to the server** — key-based authentication recommended:
   ```bash
   ssh-copy-id your-username@mac-mini.local
   ```
2. **Network access** — either connected to the corporate VPN or on the local network

### Finding the server address

When on the corporate VPN or local network, the Mac Mini is usually reachable by hostname:
```bash
ping mac-mini.local   # works if Bonjour/mDNS is available on the network
```

If mDNS does not work over VPN, ask your IT team for the Mac Mini's IP address,
or check it directly on the server: **System Settings → General → About → IP address**.

The address format is `username@hostname-or-ip`, where `username` is the macOS account
name on the Mac Mini — the one used when the machine was first set up (e.g. `andrey`).

### Option A — run directly (one-off)

No installation needed:

```bash
curl -fsSL https://raw.githubusercontent.com/AndreySosnovyy/mcc-dev-tools/main/scripts/sync-claude.sh | bash -s -- andrey@mac-mini.local
```

Dry-run to preview what will be synced without making changes:

```bash
curl -fsSL https://raw.githubusercontent.com/AndreySosnovyy/mcc-dev-tools/main/scripts/sync-claude.sh | bash -s -- --dry-run andrey@mac-mini.local
```

### Option B — install locally (recommended for regular use)

Install once to `~/.local/bin/` so you can call it from anywhere:

```bash
mkdir -p ~/.local/bin
curl -fsSL https://raw.githubusercontent.com/AndreySosnovyy/mcc-dev-tools/main/scripts/sync-claude.sh \
  -o ~/.local/bin/sync-claude && chmod +x ~/.local/bin/sync-claude
```

Make sure `~/.local/bin` is in your PATH (add to `~/.zshrc` if needed):
```bash
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc && source ~/.zshrc
```

Then use it directly:
```bash
sync-claude andrey@mac-mini.local
sync-claude --dry-run andrey@mac-mini.local
```

To avoid typing the address every time, set `SERVER_SSH` in your `~/.zshrc`:
```bash
export SERVER_SSH="andrey@mac-mini.local"
```

Then just:
```bash
sync-claude
```

### What is synced

| Synced | Skipped |
|--------|---------|
| `CLAUDE.md` | `projects/` — per-machine conversation history |
| `settings.json` | `todos/` — per-session task tracking |
| `skills/` | `plans/` — plan mode files |
| `commands/` | `.cache/` — model cache |
| `rules/` | `*.jsonl` — conversation logs |

---

## Claude Code skills

Reusable Claude Code skills you can install into your local `~/.claude/skills/`. Once installed, Claude Code activates them automatically based on the skill description when you ask relevant questions.

### Available skills

| Skill | Purpose |
|---|---|
| `mr-template-author` | Author or modify MCC-compatible MR description templates (Mustache). Use when you want to customize how Draft MRs created by `cc <task>` look in GitLab. |

### Install

Requirements: `git`, `curl`.

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/AndreySosnovyy/mcc-dev-tools/main/scripts/install-skill.sh) mr-template-author
```

The script clones `mcc-dev-tools` (shallow), copies the skill to `~/.claude/skills/<skill-name>/`, and backs up any previous version. Restart Claude Code (or open a new session) for the skill to be picked up.

To install a different skill, replace `mr-template-author` with the skill name. Run without arguments to see the list:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/AndreySosnovyy/mcc-dev-tools/main/scripts/install-skill.sh)
```

After install, just describe what you want in Claude Code — e.g. "create an MR template for project X with focus on test coverage" — the skill activates automatically.

---

## Contents

```
scripts/
  setup.sh          — Flutter project setup (commit hook, commitlint, git alias)
  sync-claude.sh    — sync ~/.claude/ to MCC server over SSH
  install-skill.sh  — install a Claude Code skill into ~/.claude/skills/
hooks/
  commit-msg        — Conventional Commits git hook
config/
  commitlint.config.js  — commitlint rules
skills/
  mr-template-author/   — author MCC MR description templates (Mustache)
VERSION             — current version
```
