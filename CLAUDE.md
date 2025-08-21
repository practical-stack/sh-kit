# sh-kit - CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with the sh-kit repository.

## Project Overview

sh-kit is a modular interactive shell script toolkit designed to enhance development workflows through command-line tools. The project follows a category-based architecture that promotes extensibility and maintainability.

## Repository Architecture

### Directory Structure
```
~/sh-kit/
├── README.md                    # Project overview and quick start
├── CLAUDE.md                    # This file (project-wide guidance)
├── .zshrc.tmpl                  # Shell configuration template
├── .gitconfig.tmpl              # Git configuration template
├── .gitignore                   # Git ignore patterns
├── bin/                         # Executable commands (added to PATH)
│   └── gt -> ../git/git-tools.sh    # Symbolic links to tools
└── [category]/                  # Tool categories (git, docker, k8s, etc.)
    ├── README.md               # Category-specific user documentation
    ├── CLAUDE.md               # Category-specific development guidance
    └── [tool-scripts]          # Implementation files
```

### Design Principles

1. **Category-Based Organization**: Each tool type (git, docker, kubernetes, etc.) gets its own directory
2. **Unified Access Pattern**: All tools accessible via `bin/` directory through symbolic links
3. **Self-Contained Categories**: Each category includes documentation, implementation, and guidance
4. **Extensible Architecture**: Easy to add new tool categories without affecting existing ones

## Current Categories

### Git Tools (`git/`)
**Purpose**: Enhanced Git workflow operations with interactive selection
**Command**: `gt`
**Documentation**: `git/README.md`, `git/CLAUDE.md`
**Implementation**: `git/git-tools.sh`

**Key Features**:
- Interactive branch management with fzf
- Commit selection and manipulation
- File staging with previews
- Stash management
- Remote synchronization
- Advanced operations (force push, replay, tagging)

## Access Patterns

### 1. PATH-Based Execution (Primary)
Users add `bin/` to their PATH and use commands directly:
```bash
gt branch-tools    # Git branch management
gt commit-select   # Git commit selection
gt doctor         # Dependency check
```

### 2. Git Alias Integration
Git aliases for seamless workflow integration:
```bash
git bb            # Branch tools
git c-s           # Commit select  
git pfc           # Force push chain
```

### 3. Direct Function Access (Advanced)
Sourcing scripts for function-level access:
```bash
source git/git-tools.sh
branch_select
commit_select
```

## Extension Guidelines

### Adding New Tool Categories

1. **Create Category Directory**
   ```bash
   mkdir new-category
   cd new-category
   ```

2. **Implement Main Script**
   - Follow single-file pattern with command dispatching
   - Include help system (`[cmd] help`)
   - Include dependency checking (`[cmd] doctor`)
   - Use interactive selection with fzf where appropriate

3. **Create Documentation**
   - `README.md`: User-facing documentation
   - `CLAUDE.md`: Development guidance for Claude Code

4. **Add Symbolic Link**
   ```bash
   ln -s ../new-category/main-script.sh ../bin/nc
   ```

5. **Update Root Documentation**
   - Add category to root README.md
   - Update this CLAUDE.md file

### Automatic Reflection System

**Key Architecture Benefit**: The symbolic link system provides immediate reflection of changes:

```bash
# Development workflow for any category
vim git/git-tools.sh          # Edit implementation
gt help                       # Test immediately - no restart needed
git bb                        # Git aliases work immediately

# For new categories
vim docker/docker-tools.sh    # Edit new tool
dt help                       # Test immediately via symbolic link
```

**Important Considerations**:
- **Script modifications**: Immediate effect through symbolic links
- **New symbolic links**: Require manual creation with `ln -s`
- **File moves/renames**: Will break symbolic links - update accordingly
- **Permissions**: Ensure scripts remain executable (`chmod +x`)

**Verification Commands**:
```bash
# Check symbolic link integrity
ls -la bin/

# Check executable permissions
ls -la git/git-tools.sh       # Should show -rwxr-xr-x

# Fix permissions if needed
chmod +x git/git-tools.sh

# Test tool accessibility
which gt                      # Should show bin/gt
gt doctor                     # Should work without errors
```

### Expected Future Categories

- **Docker Tools** (`dt`): Container lifecycle management
- **Kubernetes Tools** (`kt`): K8s resource operations
- **AWS Tools** (`at`): Cloud resource management
- **Database Tools** (`dbt`): Database operations and queries
- **Network Tools** (`nt`): Network diagnostics and management

### Consistent Patterns Across Categories

1. **Command Structure**: `[cmd] [action] [modifiers]`
2. **Interactive Selection**: Use fzf for user choices
3. **Help System**: `[cmd] help` shows available commands
4. **Dependency Checking**: `[cmd] doctor` verifies requirements
5. **Error Handling**: Graceful degradation for missing optional tools
6. **Documentation**: Complete user and developer documentation

## Development Standards

### Script Structure
```bash
#!/usr/bin/env bash

# Header with description and usage
# Utility functions
# Main feature sections
# Help function
# Main entry point with command dispatching
```

### Interactive Selection Pattern
```bash
# 1. Generate list with metadata
# 2. Pipe to fzf with preview
# 3. Extract selection with awk
# 4. Perform operation on selection
```

### Error Handling
- Check tool availability before use
- Provide clear error messages with installation guidance
- Implement fallbacks for optional dependencies

### Cross-Shell Compatibility
- Use `#!/usr/bin/env bash` shebang
- Test with both Bash and Zsh
- Conditional strict mode for execution vs. sourcing

## Testing Guidelines

### Dependency Verification
Each tool should include comprehensive dependency checking:
```bash
[cmd] doctor    # Check all dependencies
```

### Manual Testing
```bash
# Test direct execution
[cmd] help
[cmd] [action]

# Test PATH integration
which [cmd]

# Test git integration (for git tools)
git [alias]
```

### Installation Testing
Test installation from various clone locations:
```bash
# Different clone paths
~/shell-scripts
~/dev/shell-scripts  
~/projects/tools/shell-scripts
```

## Common Dependencies

### Core Requirements
- **fzf**: Interactive fuzzy finder (essential for all selection operations)
- **Standard Unix tools**: awk, sed, column, head, tail, grep

### Category-Specific Dependencies
Each category may introduce specific dependencies:
- **Git tools**: git, bat (optional), pygmentize (optional)
- **Docker tools**: docker, docker-compose
- **Kubernetes tools**: kubectl, kubectx, kubens
- **AWS tools**: aws-cli, jq

## Documentation Standards

### User Documentation (README.md)
- Installation instructions
- Usage examples
- Available commands
- Dependencies
- Configuration options

### Developer Documentation (CLAUDE.md)
- Architecture overview
- Code patterns
- Extension guidelines
- Testing procedures
- Common pitfalls

### Code Comments
- Minimal inline comments (code should be self-documenting)
- Function headers for complex operations
- Section dividers for organization

## Maintenance Guidelines

### Adding Commands to Existing Categories
1. Implement function in appropriate script
2. Update command dispatcher case statement
3. Add to help function
4. Update documentation
5. Test all access patterns

### Version Management
- Use semantic versioning for releases
- Tag releases with git
- Maintain changelog for user-facing changes

### Performance Considerations
- Use efficient shell patterns
- Minimize external tool dependencies
- Cache expensive operations when possible
- Provide progress indicators for long operations

## Security Considerations

- Never log or expose sensitive information
- Validate user inputs for shell injection
- Use appropriate file permissions
- Avoid hardcoded credentials or paths

This guidance ensures consistent, maintainable, and extensible development across all tool categories in the shell scripts collection.