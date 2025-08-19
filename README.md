# sh-kit

Interactive shell script toolkit for enhanced development workflows with fuzzy finding.

[한국어 README](README.kr.md)

## 📁 Project Structure

```
~/sh-kit/
├── README.md                    # This file (project overview)
├── README.kr.md                 # Korean documentation
├── CLAUDE.md                    # Project-wide Claude Code guide
├── .gitignore                   # Git ignore patterns
├── .zshrc.tmpl                  # ZSH configuration template
├── .gitconfig.tmpl              # Git configuration template
├── bin/                         # Executable commands (added to PATH)
│   └── gt -> ../git/git-tools.sh    # Git tools symlink
└── git/                         # Git workflow tools
    ├── README.md               # Git tools detailed documentation
    ├── CLAUDE.md               # Git tools Claude Code guide
    └── git-tools.sh            # Git tools implementation script
```

## 🚀 Quick Start

```bash
# 1. Clone repository
git clone <repository-url> sh-kit
cd sh-kit

# 2. Check configuration templates
cat .zshrc.tmpl      # ZSH configuration template
cat .gitconfig.tmpl  # Git configuration template

# 3. ZSH setup (refer to .zshrc.tmpl)
export SH_KIT_HOME="$(pwd)"
export PATH="$SH_KIT_HOME/bin:$PATH"

# Or add to ~/.zshrc:
echo "export SH_KIT_HOME=\"$(pwd)\"" >> ~/.zshrc
echo "export PATH=\"\$SH_KIT_HOME/bin:\$PATH\"" >> ~/.zshrc
source ~/.zshrc

# 4. Git alias setup (refer to .gitconfig.tmpl)
git config --global alias.bb "!gt branch-tools"
git config --global alias.c-s "!gt commit-select"
git config --global alias.pfs "!gt force-push-selected"
git config --global alias.al "!gt alias-select"

# 5. Ensure execution permissions (if needed)
chmod +x git/git-tools.sh

# 6. Verify installation
gt doctor

# 7. Start using
gt help              # Tool list
gt bb                # Branch tools
git bb               # Use via Git alias
git al               # Alias selector
```

## 📦 Tool Categories

### 🛠️ Git Tools (`gt` command)
- **Branch Management**: Interactive branch selection/deletion/cleanup
- **Commit Tools**: Commit selection and manipulation
- **Staging**: File diff and staging tools
- **Stash Management**: Stash listing and operations
- **Synchronization**: Remote repository synchronization
- **Advanced Features**: Force push, replay, tag management

📖 **Detailed Documentation**: [`git/README.md`](git/README.md)

### 🔮 Future Expansion Plans
- **Docker Tools** (`dt`): Container management
- **Kubernetes Tools** (`kt`): K8s resource management  
- **AWS Tools** (`at`): Cloud resource management
- **Database Tools** (`dbt`): Database operations

## 🏗️ Architecture

### Extensible Structure
Each tool category consists of independent directories and symbolic links:
- **Category Directory**: Implementation and documentation for each tool
- **bin/ Directory**: Executable commands accessible via PATH
- **Symbolic Links**: Combines benefits of single file management with PATH access

### Adding New Categories
```bash
# 1. Create new category directory (e.g., docker)
mkdir docker
# 2. Write main script (docker/docker-tools.sh)
# 3. Create symbolic link
ln -s ../docker/docker-tools.sh bin/dt
```

## 📋 Common Dependencies

- **Required**: `fzf` (interactive selection), standard Unix tools
- **Optional**: `bat` (file preview), `pygmentize` (syntax highlighting)

## 📚 Documentation

- **Project Overview**: [README.md](README.md) (this file)
- **Korean Documentation**: [README.kr.md](README.kr.md)
- **Development Guide**: [CLAUDE.md](CLAUDE.md) (project architecture and extension guide)
- **Category User Guides**: Each category's README.md
- **Category Development Guides**: Each category's CLAUDE.md
- **Dependency Check**: Each tool's `doctor` command

## 🤝 Contributing

1. Add new tool categories
2. Improve existing tools
3. Update documentation
4. Report bugs

---

⭐ **Tip**: Each tool provides usage information via `help` command (`gt help`, `dt help`, etc.)