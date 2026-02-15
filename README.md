# agents-md-generator

[日本語](README-ja.md)

A git hook that automatically creates a starter `AGENTS.md` (with `CLAUDE.md` symlink) when you clone an empty repository.

> Blog post: [AGENTS.mdを自動で育てる仕組みを作った](https://nyosegawa.github.io/posts/agents-md-generator/)

## Why

Every new repository needs an `AGENTS.md` — the [open standard](https://agents.md/) for guiding AI coding agents (Cursor, Zed, Codex, Gemini CLI, GitHub Copilot, etc.). Claude Code reads `CLAUDE.md`. Setting up both manually every time is tedious.

This hook plants the seed automatically. You just grow it as your project evolves.

## Setup

```bash
mkdir -p ~/.git-templates/hooks
cp post-checkout ~/.git-templates/hooks/post-checkout
chmod +x ~/.git-templates/hooks/post-checkout
git config --global init.templateDir ~/.git-templates
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

The `post-checkout` hook runs after `git clone` and:

1. Checks if the repo is empty (< 3 items excluding `.git`)
2. Skips if `AGENTS.md` already exists
3. Creates `AGENTS.md` from a built-in template
4. Creates `CLAUDE.md` as a symlink to `AGENTS.md`

## Template Design

The generated `AGENTS.md` is scaffolding, not a finished document. Key principles:

- **20–30 line budget** — LLMs degrade when given too many instructions. Keep it lean
- **No backward compatibility by default** — Bold refactoring over legacy support
- **Placeholder sections** — Fill them in as your project grows, then remove the placeholders
- **Permanent Maintenance Notes** — A reminder that `AGENTS.md` is a living document, not a config file
- **Section protection via HTML comments** — Guards the file structure from accidental modification by agents

## Customization

Edit the template inside `post-checkout` between `cat > AGENTS.md << 'EOF'` and `EOF`.

Change the empty-repo threshold:

```bash
if [ $TOTAL -lt 3 ]; then  # adjust this number
```

## Supported Tools

| Tool | Reads |
|------|-------|
| Cursor, Zed, OpenCode, Codex, Gemini CLI, ... | `AGENTS.md` |
| Claude Code | `CLAUDE.md` (symlink → `AGENTS.md`) |

## License

[MIT](LICENSE)
