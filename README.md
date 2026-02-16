# agents-md-generator

[日本語](README-ja.md)

A shell wrapper that automatically creates a starter `AGENTS.md` (with `CLAUDE.md` symlink) when you clone an empty repository.

> Blog post: [AGENTS.mdを自動で育てる仕組みを作った](https://nyosegawa.github.io/posts/agents-md-generator/)

## Why

Every new repository needs an `AGENTS.md` — the [open standard](https://agents.md/) for guiding AI coding agents (Cursor, Zed, Codex, Gemini CLI, GitHub Copilot, etc.). Claude Code reads `CLAUDE.md`. Setting up both manually every time is tedious.

This wrapper plants the seed automatically. You just grow it as your project evolves.

## Setup

Add to your `.bashrc` or `.zshrc`:

```bash
source /path/to/agents-md-seed.sh
```

If you use ghq:

```bash
ghq get nyosegawa/agents-md-generator
# .zshrc / .bashrc
source "$(ghq root)/github.com/nyosegawa/agents-md-generator/agents-md-seed.sh"
```

Or download directly:

```bash
curl -sL https://raw.githubusercontent.com/nyosegawa/agents-md-generator/main/agents-md-seed.sh -o ~/.agents-md-seed.sh
echo 'source ~/.agents-md-seed.sh' >> ~/.zshrc  # or .bashrc
```

## Usage

```bash
# Just clone as usual
git clone git@github.com:you/new-repo.git

# AGENTS.md and CLAUDE.md (symlink) are already there
ls new-repo/
# AGENTS.md  CLAUDE.md -> AGENTS.md

# Works with ghq too
ghq get you/new-repo
```

## How It Works

The script defines a thin `git()` wrapper function that runs after every `git clone`:

1. Parses clone arguments to find the target directory
2. Checks if the repo is empty (< 3 items excluding `.git`)
3. Skips if `AGENTS.md` already exists
4. Creates `AGENTS.md` from a built-in template (or custom template)
5. Creates `CLAUDE.md` as a symlink to `AGENTS.md`

## Customization

### Custom template

Set `AGENTS_MD_TEMPLATE` or place a template at `~/.config/agents-md/template.md`:

```bash
export AGENTS_MD_TEMPLATE="$HOME/my-agents-template.md"
```

### Empty-repo threshold

The default threshold is 3 items. To change it, modify the `(( total >= 3 ))` line in `agents-md-seed.sh`.

## Template Design

The generated `AGENTS.md` is scaffolding, not a finished document. Key principles:

- **20–30 line budget** — LLMs degrade when given too many instructions. Keep it lean
- **No backward compatibility by default** — Bold refactoring over legacy support
- **Placeholder sections** — Fill them in as your project grows, then remove the placeholders
- **Permanent Maintenance Notes** — A reminder that `AGENTS.md` is a living document, not a config file
- **Section protection via HTML comments** — Guards the file structure from accidental modification by agents

## Supported Tools

| Tool | Reads |
|------|-------|
| Cursor, Zed, OpenCode, Codex, Gemini CLI, ... | `AGENTS.md` |
| Claude Code | `CLAUDE.md` (symlink → `AGENTS.md`) |

## License

[MIT](LICENSE)
