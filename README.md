# Auto AGENTS.md Generator for Git

Automatically creates a starter `AGENTS.md` file (with `CLAUDE.md` symlink) when cloning empty repositories.

## Installation

### Setup git template directory

```bash
# Create template directory
mkdir -p ~/.git-templates/hooks

# Copy the post-checkout hook
cp post-checkout ~/.git-templates/hooks/post-checkout

# Make it executable
chmod +x ~/.git-templates/hooks/post-checkout

# Configure git to use this template for all new repos
git config --global init.templateDir ~/.git-templates
```

### That's it!

Now every time you clone a repository, the hook will automatically check if it's empty and create AGENTS.md if needed.

### Test it

```bash
# Clone an empty repository
git clone git@github.com:yourusername/new-empty-repo.git
cd new-empty-repo

# Check if AGENTS.md was created
ls -la
# You should see both AGENTS.md and CLAUDE.md (symlink)
```

## File Structure

This hook creates:
- `AGENTS.md` - The canonical agent configuration file (works with Cursor, Zed, OpenCode, etc.)
- `CLAUDE.md` - Symlink to AGENTS.md for Claude Code compatibility

**Why this approach?**
- AGENTS.md is an open standard supported by multiple tools
- Claude Code specifically looks for CLAUDE.md
- Using a symlink ensures both tools read the same configuration
- You only maintain one file (AGENTS.md)

## How It Works

The git post-checkout hook:

1. Runs automatically after `git clone` (and `git checkout`)
2. Checks if the repository is "empty" (fewer than 3 files/directories excluding `.git`)
3. Skips if `AGENTS.md` already exists
4. Creates the template `AGENTS.md` if conditions are met
5. Creates a symlink `CLAUDE.md -> AGENTS.md` for Claude Code compatibility

### Empty Repository Detection

A repository is considered "empty" if it has:
- Fewer than 3 files or directories (excluding `.git`)
- This catches brand new repos, even with just a README or LICENSE

Adjust the threshold in the hook if needed:
```bash
if [ $TOTAL -lt 3 ]; then  # Change 3 to your preferred number
```

### Why post-checkout hook?

- Runs after both `git clone` and `git checkout`
- For clone operations, it only runs once on the initial checkout
- The hook checks `branch_checkout` flag to ensure it only runs on actual checkouts
- Works with any git workflow, not just ghq

## Template Design Philosophy

The generated `AGENTS.md` follows these principles:

### Core Guidelines (Non-negotiable)

1. **No backward compatibility** - Break things boldly unless user explicitly requests compatibility
2. **20-30 line budget** - This is CRITICAL. Every instruction competes for the agent's limited attention (~150-200 total instructions across all context)
3. **Living document** - Commands and patterns change frequently; update immediately

### Evolution-Ready Structure

The template provides placeholder sections that guide the file's growth:

- **Project Overview**: Filled in as project structure emerges
- **Commands**: Updated continuously as workflows evolve
- **Code Conventions**: Kept minimal - linters handle most of this
- **Architecture**: Rewritten when major architectural changes occur
- **Maintenance Notes**: Permanent reminder of continuous maintenance requirements

**Notable omissions:**
- No "Important Context" section - such catch-all sections are high-risk for context pollution
- No file structure documentation - paths change too frequently
- No code style details - that's what linters are for

### Continuous Maintenance Philosophy

Unlike traditional documentation, this file requires **active maintenance**:

- The "Maintenance Notes" section is permanent - it's not scaffolding to remove
- Stale instructions actively poison the agent's context
- Regular reviews are essential (not quarterly - whenever patterns change)
- Commands must be updated immediately when they change
- Delete anything the agent can infer from code

**The goal is not a complete reference manual, but a minimal set of critical, current instructions.**

## Customization

### Modify the Template

Edit the template content in `post-checkout` between the `cat > AGENTS.md << 'EOF'` and `EOF` markers.

### Add Your Own Guidelines

```bash
# Example: Add team-specific principles
cat > AGENTS.md << 'EOF'
# Agent Guidelines

**CRITICAL: Do NOT maintain backward compatibility unless explicitly requested.**

## Our Team Principles

- Accessibility first (WCAG 2.1 AA minimum)
- Mobile-first responsive design
- Test coverage above 80%

...
EOF

# Create symlink for Claude Code
ln -s AGENTS.md CLAUDE.md
```

### Change Detection Threshold

Modify the empty repository detection logic in the hook:

```bash
# Current: fewer than 3 items
if [ $TOTAL -lt 3 ]; then

# More aggressive: only truly empty repos
if [ $TOTAL -eq 0 ]; then

# More lenient: repos with up to 10 items
if [ $TOTAL -lt 10 ]; then
```

### Enable Debug Logging

Uncomment the debug lines in the hook to troubleshoot:

```bash
# Uncomment these lines in post-checkout:
echo "$(date): post-checkout hook in $(pwd)" >> ~/.git-hooks.log
echo "Files: $FILE_COUNT, Dirs: $DIR_COUNT" >> ~/.git-hooks.log
```

## Best Practices

### What to Add to AGENTS.md (Eventually)

✅ **DO include:**
- Non-obvious project decisions
- Critical gotchas or footguns
- Essential commands that aren't in package.json
- High-level architecture (rewrite on major changes)
- Domain-specific terminology

❌ **DON'T include:**
- Code style rules (use linters/formatters)
- Complete directory listings (they change constantly)
- Information the agent can infer from code
- Obvious conventions from your language/framework
- Generic programming advice
- Catch-all "Important Context" sections (high risk for context pollution)

### Architecture Updates Are Mandatory

When you make significant architectural changes:
- **Rewrite the Architecture section** - don't patch it
- Old architecture docs actively mislead the agent
- A clean rewrite is faster than trying to maintain consistency

### Avoiding Context Pollution

The biggest risk is accumulating stale or low-value information:
- Generic sections like "Important Context" become dumping grounds
- Outdated commands worse than no commands
- Architecture docs from 6 months ago poison current understanding
- Every line you add makes all other lines less effective

**Rule of thumb:** If you can't justify why a line is critical RIGHT NOW, delete it.

### Progressive Disclosure Strategy

As your AGENTS.md grows beyond ~30 lines:

1. **Extract to separate files:**
   ```
   .claude/          # For Claude Code
   ├── rules/
   │   ├── testing.md
   │   └── deployment.md
   
   .cursor/          # For Cursor
   ├── rules/
   │   └── ...
   
   docs/             # Tool-agnostic
   ├── architecture.md
   └── conventions.md
   ```

2. **Reference, don't duplicate:**
   ```markdown
   ## Testing
   See @docs/testing.md for detailed testing conventions.
   ```

3. **Keep AGENTS.md as the index:**
   The root file should remain the "table of contents" pointing to details.

## Why This Approach?

### The 20-30 Line Budget is Critical

This is the single most important constraint. LLMs can reliably follow ~150-200 instructions total. Coding agents' system prompts already consume a significant portion. Your AGENTS.md competes with:
- Conversation history
- File contents
- Tool outputs
- Other context

**Every unnecessary instruction degrades overall performance uniformly.** This isn't about what fits - it's about what the agent can actually follow consistently.

### Instruction Budget Reality

When instruction count increases, agents don't just ignore newer instructions - they begin to ignore **all of them uniformly**. A bloated AGENTS.md doesn't just waste space; it actively degrades the agent's ability to follow any instructions at all.

### The "No Backward Compatibility" Principle

This template explicitly forbids backward compatibility by default. Why?

- **For new projects:** There's nothing to be compatible with yet
- **For evolving projects:** Bold refactoring keeps code clean
- **User override:** If they need compatibility, they'll ask explicitly
- **Self-cleaning:** Users will remove this guideline when it no longer applies

This prevents accumulation of legacy code from day one.

### Commands and Architecture Change Constantly

**Commands** evolve frequently:
- Build tools get updated
- Scripts get renamed
- New workflows emerge
- Old processes become obsolete

**Architecture** changes less often but with higher impact:
- Major refactorings restructure the codebase
- New patterns replace old ones
- Stale architecture docs are worse than no docs

The template treats both as **living documentation** requiring immediate updates when they change. Outdated architecture information actively misleads the agent, causing it to look in wrong places and suggest inappropriate patterns.

### Maintenance is Continuous, Not Periodic

The "Maintenance Notes" section stays permanently because:
- Stale instructions actively poison context
- Reviewing "quarterly" is too slow for active projects
- The notes remind you that AGENTS.md is not "set and forget"
- Continuous maintenance is the price of effective AI assistance

### AGENTS.md as the Standard

AGENTS.md is an open standard supported by:
- Cursor
- Zed
- OpenCode
- Many other AI coding tools

Claude Code uses CLAUDE.md, but by creating a symlink, we support both naming conventions while maintaining a single source of truth.

### Works Everywhere

This git-based approach:
- Works with any git workflow (`git clone`, `ghq get`, IDE cloning, etc.)
- No dependency on specific tools like ghq
- Uses git's native hook system
- Automatically applies to all new repositories

## Troubleshooting

### Hook not running

```bash
# Check if template directory is configured
git config --global init.templateDir
# Should output: /Users/yourusername/.git-templates (or similar)

# Check if hook exists and is executable
ls -la ~/.git-templates/hooks/post-checkout

# Test with a new clone
git clone git@github.com:someone/empty-repo.git
cd empty-repo
ls -la  # Should show AGENTS.md and CLAUDE.md
```

### Hook exists but AGENTS.md not created

Enable debug logging to see what's happening:

```bash
# Uncomment debug lines in ~/.git-templates/hooks/post-checkout
# Then check the log after cloning
tail -f ~/.git-hooks.log
```

Common issues:
- Repository has more than 3 files (adjust threshold)
- AGENTS.md already exists in the repo
- Hook didn't run because it wasn't a branch checkout (shouldn't happen on clone)

### Symlink not created

Check if the script completed successfully:

```bash
# Manually create symlink if needed
cd /path/to/repo
ln -s AGENTS.md CLAUDE.md
```

### Apply to existing repositories

The hook only runs on new clones. To add AGENTS.md to existing repos:

```bash
#!/bin/bash
# add-agents-md.sh

# Run this from your repositories root directory
find . -type d -name ".git" | while read gitdir; do
  repo_dir=$(dirname "$gitdir")
  cd "$repo_dir"
  
  # Check if empty-ish and no AGENTS.md
  file_count=$(find . -maxdepth 1 -type f | wc -l)
  dir_count=$(find . -maxdepth 1 -type d ! -name "." ! -name ".git" | wc -l)
  total=$((file_count + dir_count))
  
  if [ $total -lt 5 ] && [ ! -f "AGENTS.md" ]; then
    cp ~/.git-templates/hooks/AGENTS.md.template ./AGENTS.md 2>/dev/null || {
      # If template doesn't exist, create inline
      cat > AGENTS.md << 'TEMPLATE'
# Agent Guidelines
...
TEMPLATE
    }
    ln -s AGENTS.md CLAUDE.md
    echo "Added AGENTS.md to $repo_dir"
  fi
done
```

### Works with ghq

This git-based approach works perfectly with ghq since ghq uses `git clone` internally:

```bash
ghq get username/repo
# The git post-checkout hook runs automatically!
```

## References

- Original tweet inspiration: https://x.com/kenn/status/2022862500958765227
- [Complete Guide to AGENTS.md](https://www.aihero.dev/a-complete-guide-to-agents-md)
- [Writing a good CLAUDE.md](https://www.humanlayer.dev/blog/writing-a-good-claude-md) (applies to AGENTS.md too)
- [CLAUDE.md guide from Builder.io](https://www.builder.io/blog/claude-md-guide)
- [Skill authoring best practices](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices)

## Tool Support

This configuration works with:
- **Claude Code** (reads CLAUDE.md)
- **Cursor** (reads AGENTS.md)
- **Zed** (reads AGENTS.md)
- **OpenCode** (reads AGENTS.md)
- **Other AI coding tools** that follow the AGENTS.md standard

## License

Public domain. Use however you want.
