# 🤖 DOT-CLAUDE - Clean & Simple Claude Configuration

A refactored Claude Code setup with git tracking, smart management, and organized structure.

> ⚠️ **Privacy Note**: This repo contains configuration templates only. All personal data (projects, todos, paths) is gitignored and never committed.

## 📁 Directory Structure

```
~/.claude/
├── config/               # All configurations
│   ├── main.json        # Main Claude settings
│   ├── powerline.json   # Powerline statusline config
│   └── paths.json       # Path-specific announcements
├── scripts/             # Executable scripts
│   ├── hooks/          
│   │   └── announce.sh  # Completion announcements
│   └── utils/          
│       └── manage-paths.sh
├── data/                # Runtime data (gitignored)
│   ├── cache/          
│   ├── logs/           
│   └── temp/           
├── archive/             # Compressed old data
│   ├── projects/       
│   └── todos/          
├── projects/            # Active project transcripts
├── todos/               # Active todo files
├── claude-manage        # Main management script
└── settings.json        # Claude Code settings
```

## 🎯 Quick Start

### Main Management Command

```bash
# Add to your ~/.zshrc or ~/.bashrc
alias cm='~/.claude/claude-manage'

# Then use:
cm status   # Check disk usage
cm clean    # Clean old files
cm backup   # Save to git
cm archive  # Archive projects/todos
cm paths    # Manage announcements
cm test     # Test announcement
```

### Common Tasks

```bash
# Check how much space Claude is using
cm status

# Clean old files (manual, asks for confirmation)
cm clean

# Backup your configuration
cm backup

# Configure announcement for current directory
cm paths add . "My Project" Glass green
```

## 🔔 Announcement System

### How It Works
When Claude Code finishes processing, you'll get:
- Voice announcement: "[Project] ready"
- System sound based on project type
- Mac notification with timestamp
- Tmux window flash (if in tmux)

### Path Management

```bash
# List all configured paths
cm paths list

# Add current directory
cm paths add . "Project Name" Sound Color

# Update existing path
cm paths update /path/to/project sound Hero

# Remove a path
cm paths remove /path/to/project

# Test announcement
cm test
```

### Auto-Detection
New directories are automatically configured based on patterns:
- `*/docker-*` → Docker projects
- `*/MCP/*` → MCP modules
- `*/test*` → Test projects
- Hidden dirs → Config directories

### Special Paths
- `~/u/docker-openwisp/*` always announces "D O ready"

## 🧹 Maintenance

### Manual Cleanup
```bash
cm clean
```

Removes (with confirmation):
- Todos older than 30 days
- Shell snapshots older than 7 days
- Logs larger than 10MB
- Temp files

### Archiving
```bash
cm archive
```

Compresses and moves to `archive/`:
- All projects → `archive/projects/`
- All todos → `archive/todos/`

## 💾 Backups

### Git Backup
```bash
cm backup
```
- Commits all changes to git
- Creates timestamped commit

### Manual Archive
Also creates `.claude-backup-YYYYMMDD.tar.gz` in home directory with configs only.

## ⚙️ Configuration Files

### Main Settings
`~/.claude/settings.json` - Claude Code settings

### Powerline
`~/.claude/config/powerline.json` - Status line configuration

### Paths
`~/.claude/config/paths.json` - Path-specific announcements

## 🎨 Powerline Status Line

Current configuration:
- Light theme
- Powerline style with separators
- Shows: directory, git, model, session cost, context, metrics

### What Each Segment Shows
- **Directory** - Current working directory
- **Git** - Branch, status, worktree, operations
- **Model** - Current Claude model (Opus 4.1, etc)
- **Session** - Cost of current session
- **Context** - Token usage percentage
- **Metrics** - Response times, message count, lines changed

## 📊 Disk Usage

After refactoring:
- Reduced from ~146MB to ~24MB
- Archived 163 old todos
- Compressed 17 old projects
- Organized into clean structure

## 🔧 Troubleshooting

### Announcement not working?
1. Restart Claude Code (settings reload on start)
2. Test with: `cm test`
3. Check logs: `~/.claude/hooks/completion.log`

### Too many files accumulating?
```bash
cm status   # Check counts
cm clean    # Clean old files
cm archive  # Archive everything
```

### Need to restore?
Backups are in:
- Git history: `cd ~/.claude && git log`
- Archive files: `~/.claude-backup-*.tar.gz`
- Full backup: `~/.claude.backup.YYYYMMDD_HHMMSS/`

## 🚀 Tips

1. **Regular maintenance**: Run `cm clean` weekly
2. **Backup before changes**: `cm backup`
3. **Archive when done**: `cm archive` after finishing projects
4. **Custom announcements**: Configure important projects with unique sounds
5. **Git tracking**: All configs are version controlled

## 📝 Git Commands

```bash
cd ~/.claude

# View history
git log --oneline

# Restore previous config
git checkout <commit-hash> -- settings.json

# See what changed
git diff

# Push to remote (if you set one up)
git remote add origin <your-repo>
git push -u origin main
```

## 🔒 Privacy & Security

### What's Shared (Safe)
- ✅ Management scripts
- ✅ Configuration structure  
- ✅ Hook scripts
- ✅ Documentation
- ✅ Empty plugin configs

### What's Never Shared (Gitignored)
- ❌ `/projects/` - Your conversation transcripts
- ❌ `/todos/` - Your todo files
- ❌ `/data/` - All runtime data
- ❌ `/archive/` - Archived personal data
- ❌ `config/paths.json` - Your personal project paths
- ❌ Any `.jsonl` files - Session data
- ❌ All logs and temp files

## 🎉 Enjoy Your Clean Setup!

Your Claude configuration is now:
- ✅ **Organized** - Clear structure
- ✅ **Tracked** - Git version control
- ✅ **Managed** - Single command for everything
- ✅ **Clean** - Manual cleanup control
- ✅ **Smart** - Auto-learning paths
- ✅ **Efficient** - 84% less disk usage

---

Created with 💙 during the Great Claude Refactor of $(date +%Y)