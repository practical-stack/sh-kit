# Git Tools - CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with the Git tools in this directory.

## Overview

This directory contains a comprehensive Git workflow enhancement tool that provides interactive operations using fuzzy finding (`fzf`) and enhanced display tools.

## Architecture

### Single-File Design
The Git tools follow a consolidated single-file architecture:

- **`git-tools.sh`**: Main script containing all Git tool functions (600+ lines)
- **Modular sections**: Organized into functional categories within the single file
- **Command dispatching**: Single entry point with case-based command routing

### Function Organization
```bash
# Utility Functions
get_main_branch()

# Branch Tools  
branch_list(), branch_select(), branch_clean_interactive(), etc.

# Commit Tools
commit_select()

# Diff & Staging Tools
diff_select(), diff_unselect(), diff_info()

# Stash Tools
stash_list(), stash_select(), git_stash_tools()

# Sync Tools
git_sync(), git_update(), select_remote()

# Advanced Tools
git_force_push_selected(), git_replay_onto(), git_tag_refresh()

# Diagnostics
git_alias_doctor(), check_tool()

# Main Entry Point
Command dispatcher with case statement
```

## Access Patterns

### 1. PATH-Based Execution (Primary)
```bash
gt branch-tools    # or gt bb
gt commit-select   # or gt c-s
gt doctor         # dependency check
```

### 2. Git Alias Integration
```bash
# .gitconfig setup
[alias]
    bb = "!gt branch-tools"
    pfc = "!gt force-push-chain"
    c-s = "!gt commit-select"
    doctor = "!gt alias-doctor"
```

### 3. Direct Function Access (Advanced)
```bash
# Source for function access
source git-tools.sh
branch_select
commit_select
```

## Dependencies

### Required
- **`fzf`**: Interactive fuzzy finder (core dependency for all selection operations)
- **`git`**: Git version control system
- **Standard Unix tools**: `awk`, `sed`, `column`, `head`, `tail`

### Optional
- **`bat`**: Enhanced file preview (fallback to `cat` if unavailable)
- **`pygmentize`**: Code syntax highlighting

### Dependency Verification
Run `gt doctor` to check all dependencies and git configuration status.

## Common Commands

### Testing Dependencies
```bash
gt doctor    # Check all dependencies and git alias configuration
```

### Direct Command Execution
```bash
gt branch-tools      # or gt bb
gt commit-select     # or gt c-s
gt force-push-chain     # or gt pfc
gt help              # Show available commands
```

### Git Alias Usage
```bash
git bb       # Branch tools
git pfc      # Force push chain
git c-s      # Commit select
git doctor   # Dependency check
```

## Code Patterns

### Interactive Selection Pattern
Standard pattern used throughout:
1. Generate list with metadata (dates, authors, etc.)
2. Pipe to `fzf` for interactive selection with previews
3. Extract relevant field with `awk`
4. Perform Git operation on selected item(s)

Example:
```bash
branch_select() {
    branch_list | fzf | awk '{print $2}'
}
```

### Error Handling
- Conditional checks for tool availability
- Graceful degradation for optional dependencies (e.g., `bat` → `cat` fallback)
- Clear error messages with installation guidance

### Shell Compatibility
- Cross-compatible shebang: `#!/usr/bin/env bash`
- Conditional strict mode for execution vs. sourcing
- Works with both Bash and Zsh

## Development Guidelines

### Adding New Commands
1. Add function to appropriate section in `git-tools.sh`
2. Update command dispatcher case statement (line 586+)
3. Add to help function (`git_tools_help`)
4. Test with both direct execution and alias usage

### Automatic Reflection System

**Key Advantage**: Changes to `git-tools.sh` are immediately reflected through the symbolic link:

```bash
# After editing git-tools.sh
gt help           # Immediately reflects changes
git bb           # Git aliases also work immediately
```

**Development Workflow**:
1. Edit `git-tools.sh` directly
2. Test changes immediately with `gt [command]`
3. No restart or reload required
4. Changes apply to all access patterns (direct, PATH, git aliases)

**Important Notes**:
- **Function modifications**: Immediate effect
- **New functions**: Add to appropriate section, immediate effect
- **New commands**: Must update case statement in main dispatcher
- **File structure changes**: May break symbolic link - verify with `ls -la bin/gt`

### Function Naming Convention
- Main tools: `git_[category]_tools` (e.g., `git_branch_tools`)
- Helper functions: `[category]_[action]` (e.g., `branch_select`)
- Utility functions: `[descriptive_name]` (e.g., `get_main_branch`)

### Testing Commands
```bash
# Test direct execution
gt help
gt branch-tools
gt commit-select

# Test git integration  
git bb
git c-s

# Test dependency checking
gt doctor
```

## Command Reference

### Branch Tools (`gt branch-tools` or `gt bb`)
- Default: Interactive branch checkout
- `gt bb list`: List branches with metadata
- `gt bb clean`: Clean merged branches
- `gt bb d`: Delete selected branches
- `gt bb pb`: Pull selected branch

### Commit Tools
- `gt commit-select` (`gt c-s`): Interactive commit selection

### Diff & Staging Tools
- `gt diff-tools`: File diff and staging operations
- `gt diff-select`: Select files to stage
- `gt diff-unselect`: Select files to unstage

### Stash Tools
- `gt stash-tools`: Stash management operations

### Sync Tools
- `gt sync`: Sync with remote branch
- `gt update`: Update with rebase

### Advanced Tools
- `gt force-push-chain` (`gt pfc`): Multi-branch force push
- `gt replay-onto`: Replay commits onto branch
- `gt tag-refresh`: Interactive tag refresh

### Diagnostics
- `gt doctor`: Check dependencies and configuration

## Integration Notes

### Git Configuration
The tool integrates seamlessly with Git through aliases. Users typically add these to their `.gitconfig`:

```ini
[alias]
    bb = "!gt branch-tools"
    pfc = "!gt force-push-chain"  
    c-s = "!gt commit-select"
    doctor = "!gt alias-doctor"
```

### Environment Setup
Users need to add the parent `bin/` directory to their PATH:
```bash
export SHELL_SCRIPTS_HOME="/path/to/shell-scripts"
export PATH="$SHELL_SCRIPTS_HOME/bin:$PATH"
```

## Performance Considerations

- Uses efficient shell patterns and minimal external dependencies
- Caches branch lists and commit logs where appropriate  
- Provides progress indicators for long operations (multi-branch push)
- Optimized for repositories with hundreds of branches and thousands of commits

## Security Notes

- Never logs or exposes sensitive information
- Uses `--force-with-lease` for safer force pushes
- Validates user inputs to prevent shell injection
- Disables Husky hooks where appropriate to prevent interference