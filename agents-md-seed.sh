#!/usr/bin/env bash
# agents-md-seed: git clone時にAGENTS.mdを自動生成するシェルラッパー
# Usage: .bashrc / .zshrc に以下を追加
#   source /path/to/agents-md-seed.sh

_agents_md_seed() {
  local dir="$1"

  [[ -f "$dir/AGENTS.md" ]] && return 0

  local file_count dir_count total
  file_count=$(find "$dir" -maxdepth 1 -type f 2>/dev/null | wc -l | tr -d ' ')
  dir_count=$(find "$dir" -maxdepth 1 -type d ! -name "." ! -name ".git" 2>/dev/null | wc -l | tr -d ' ')
  total=$((file_count + dir_count))
  (( total >= 3 )) && return 0

  # カスタムテンプレートがあればそちらを使う
  local template="${AGENTS_MD_TEMPLATE:-$HOME/.config/agents-md/template.md}"
  if [[ -f "$template" ]]; then
    cp "$template" "$dir/AGENTS.md"
  else
    cat > "$dir/AGENTS.md" << 'AGENTS_TEMPLATE'
# Agent Guidelines

<!-- Do not restructure or delete sections. Update individual values in-place when they change. -->

## Core Principles

- **Do NOT maintain backward compatibility** unless explicitly requested. Break things boldly.
- **Keep this file under 20-30 lines of instructions.** Every line competes for the agent's limited context budget (~150-200 total).

---

## Project Overview

<!-- Update this section as the project takes shape -->

**Project type:** [To be determined - e.g., web app, CLI tool, library]
**Primary language:** [To be determined]
**Key dependencies:** [To be determined]

---

## Commands

<!-- Update these as your workflow evolves - commands change frequently -->

```bash
# Development
# [Add your dev server command here]

# Testing
# [Add your test command here]

# Build
# [Add your build command here]
```

---

## Code Conventions

<!-- Keep this minimal - let tools like linters handle formatting -->

- Follow the existing patterns in the codebase
- Prefer explicit over clever
- Delete dead code immediately

---

## Architecture

<!-- Major architecture changes MUST trigger a rewrite of this section -->

```
[Add directory structure overview when it stabilizes]
```

---

## Maintenance Notes

<!-- This section is permanent. Do not delete. -->

**Keep this file lean and current:**

1. **Remove placeholder sections** (sections still containing `[To be determined]` or `[Add your ... here]`) once you fill them in
2. **Review regularly** - stale instructions poison the agent's context
3. **CRITICAL: Keep total under 20-30 lines** - move detailed docs to separate files and reference them
4. **Update commands immediately** when workflows change
5. **Rewrite Architecture section** when major architectural changes occur
6. **Delete anything the agent can infer** from your code

**Remember:** Coding agents learn from your actual code. Only document what's truly non-obvious or critically important.
AGENTS_TEMPLATE
  fi

  ln -s AGENTS.md "$dir/CLAUDE.md"
  echo "✓ Created AGENTS.md and CLAUDE.md symlink in $dir"
}

_agents_md_clone_dir() {
  local positional=()
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -b|--branch|--depth|-o|--origin|-c|--config|-j|--jobs|--filter|\
      --reference|--reference-if-able|--separate-git-dir|--template|\
      --shallow-since|--shallow-exclude|--bundle-uri|--server-option)
        shift 2 ;;
      -*) shift ;;
      *) positional+=("$1"); shift ;;
    esac
  done
  if (( ${#positional[@]} >= 2 )); then
    echo "${positional[1]}"
  elif (( ${#positional[@]} == 1 )); then
    basename "${positional[0]%/}" .git
  fi
}

git() {
  command git "$@"
  local rc=$?
  [[ $rc -ne 0 || "$1" != "clone" ]] && return $rc

  local dir
  dir=$(_agents_md_clone_dir "${@:2}")
  [[ -n "$dir" && -d "$dir" ]] && _agents_md_seed "$dir"
  return $rc
}
