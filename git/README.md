# sh-kit Git Tools

Comprehensive Git workflow enhancement tools with interactive operations.

[한국어 README](README.kr.md)

## 📁 Directory Structure

```
~/sh-kit/
├── bin/
│   └── gt -> ../git/git-tools.sh    # Symbolic link to executable command
└── git/
    ├── README.md               # This file (Git tools documentation)
    ├── README.kr.md            # Korean Git tools documentation
    ├── CLAUDE.md               # Development guidance for Claude Code
    └── git-tools.sh            # Integrated Git tools script
```

## 🛠️ Git Tools

### Key Files

- **`git/git-tools.sh`**: Single script integrating all Git tools
- **`bin/gt`**: Symbolic link to git-tools.sh (directly executable from PATH)

### Available Tools

#### 📂 Branch Tools

- `gt branch-tools` (or `gt bb`) - Branch management
- `gt branch-select` - Interactive branch selection
- `gt branch-list` - Branch listing
- `gt branch-clean` - Delete squash-merged branches

#### 💾 Commit Tools

- `gt commit-select` (or `gt c-s`) - Interactive commit selection

#### 📝 Diff & Staging Tools

- `gt diff-tools` - File diff and staging tools
- `gt diff-select` - Select files to stage
- `gt diff-unselect` - Select files to unstage

#### 📚 Stash Tools

- `gt stash-tools` - Stash management

#### 🔄 Sync Tools

- `gt sync` - Sync with remote branch
- `gt update` - Update with rebase

#### 🚀 Advanced Tools

- `gt force-push-selected` (or `gt pfs`) - Interactive multi-branch force push
- `gt replay-onto` - Replay commits onto branch
- `gt replay-onto-main` - Replay commits onto main
- `gt tag-refresh` - Interactive tag refresh

#### 🩺 Diagnostics

- `gt doctor` - Dependency check

## 🚀 Usage

### 1. Installation

```bash
# 1. Clone repository (to your preferred location)
git clone <repository-url> sh-kit
cd sh-kit

# 2. Create symbolic link (if not already exists)
ln -s ../git/git-tools.sh bin/gt

# 3. Add to PATH in .zshrc
# To automatically use current directory path:
echo "export SH_KIT_HOME=\"$(pwd)\"" >> ~/.zshrc
echo "export PATH=\"\$SH_KIT_HOME/bin:\$PATH\"" >> ~/.zshrc

# Or manually edit .zshrc:
# export SH_KIT_HOME="/path/to/your/cloned/directory"
# export PATH="$SH_KIT_HOME/bin:$PATH"

# 4. Restart shell or reload configuration
source ~/.zshrc

# 5. Verify installation
gt doctor
```

### Clone Location Examples

```bash
# Clone to home directory
git clone <repository-url> ~/sh-kit

# Clone to development tools directory
git clone <repository-url> ~/dev/sh-kit

# Clone to projects directory
git clone <repository-url> ~/projects/sh-kit
```

### 2. Direct Execution

```bash
# Check available tools
gt help

# Execute commands
gt bb              # Branch tools
gt c-s             # Commit selection
gt doctor          # Dependency check
```

### 3. Git Alias Setup

```bash
# Add to .gitconfig
[alias]
    bb = "!gt branch-tools"
    pfs = "!gt force-push-selected"
    c-s = "!gt commit-select"
    al = "!gt alias-select"
```

## 📋 Dependencies

### Required

- **fzf**: Fuzzy finder for interactive selection
- **bat**: File preview (fallback to cat if unavailable)

### Optional

- **pygmentize**: Code syntax highlighting

Verification: `gt doctor`

## 🔧 Configuration

### Environment Variables

- `SH_KIT_HOME`: Script home directory (set according to cloned path)

### Git Configuration

Aliases in `.gitconfig`:

```ini
[alias]
    bb = "!gt branch-tools"
    pfs = "!gt force-push-selected"
    c-s = "!gt commit-select"
    al = "!gt alias-select"
```

## 🎯 Benefits

1. **Single File Management**: All Git tools integrated in one file
2. **Multiple Usage Patterns**: Support for both direct execution and Git aliases
3. **Clean Structure**: Simple structure without complex wrappers
4. **Standard Approach**: Unix/Linux standard bin directory pattern
5. **Extensibility**: Easy structure for adding new tools

## 🔗 Symbolic Link Structure

`bin/gt` is a symbolic link to `git/git-tools.sh`:

- Actual file: `git/git-tools.sh` (all functionality implemented)
- Symbolic link: `bin/gt` (accessible from PATH)
- Benefits: Single file management, PATH-based execution, extensibility

### ⚡ Automatic Reflection System

Due to symbolic link characteristics, **modifications to `git-tools.sh` are immediately reflected**:

```bash
# After modifying git-tools.sh
gt help           # Immediately reflected (no restart needed)
git bb           # Git aliases also immediately reflected

# Verification method
gt doctor        # Check dependencies and configuration
```

**Important Notes:**

- Adding new functions: Just modify the script
- Adding new commands: Update command branching (case statements)
- Moving/deleting files: Be careful as symbolic links may break
