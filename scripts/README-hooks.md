# Claude Code Auto-Announce Hooks

Smart notification system for Claude Code that announces when processing is complete across multiple tmux sessions, with auto-learning path configurations.

## Features

- 🔊 **Voice announcements** when Claude Code finishes processing
- 🎨 **Visual tmux indicators** with color-coded window flashing
- 📍 **Auto-learning paths** - automatically configures new directories
- 🔔 **System sounds** - different sounds for different project types
- 💻 **Mac notifications** with timestamps
- 🧠 **Smart pattern detection** for common project structures

## Installation

The hooks are already installed in `~/.claude/hooks/`. The system consists of:

1. **`auto-announce.sh`** - Main hook script that runs when Claude stops
2. **`manage-paths.sh`** - Path configuration manager
3. **`path-config.json`** - Stores path-specific configurations

## How It Works

### Auto-Detection

When you run Claude Code in a new directory, the hook automatically:
1. Detects the project type based on path patterns
2. Assigns an appropriate name, sound, and color
3. Saves the configuration for future use

### Pattern Matching

| Path Pattern | Announcement | Sound | Color |
|-------------|--------------|-------|-------|
| `*/docker-*` | "Docker [name] ready" | Glass | green |
| `*/MCP/*` or `*/mcp-*` | "MCP [name] ready" | Ping | cyan |
| `*/conductor/*` | "Conductor [name] ready" | Pop | yellow |
| `*/test*` or `*-test` | "Test [name] ready" | Morse | magenta |
| `*/build*` | "Build [name] ready" | Blow | blue |
| `*/.*` (hidden) | "Config [name] ready" | Tink | white |
| Others | "[parent]/[project] ready" | Purr | default |

### Special Cases

- **`~/u/docker-openwisp`** and subdirectories always announce "D O ready"
- Different subdirectories get different sounds/colors while maintaining the same announcement

## Managing Path Configurations

### Command Line Tool

```bash
# Show all configured paths
~/.claude/hooks/manage-paths.sh list

# Add or update a path configuration
~/.claude/hooks/manage-paths.sh add <path> <name> [sound] [color]

# Update a specific field
~/.claude/hooks/manage-paths.sh update <path> name|sound|color <value>

# Test the announcement for current directory
~/.claude/hooks/manage-paths.sh test

# Remove a path configuration
~/.claude/hooks/manage-paths.sh remove <path>

# Clear all configurations
~/.claude/hooks/manage-paths.sh clear
```

### Examples

```bash
# Configure current directory
~/.claude/hooks/manage-paths.sh add . "My Project" Glass green

# Configure a specific path
~/.claude/hooks/manage-paths.sh add /Users/s1/project "Alpha" Hero cyan

# Change just the sound
~/.claude/hooks/manage-paths.sh update /Users/s1/project sound Ping

# Test what the current directory would announce
~/.claude/hooks/manage-paths.sh test
```

### Available Options

**Sounds:**
- Glass, Ping, Pop, Blow, Morse, Hero, Tink, Purr

**Colors:** 
- green, cyan, yellow, blue, magenta, red, white, default

## Configuration Files

### `~/.claude/settings.json`

The hook is registered in Claude Code settings:

```json
{
  "hooks": {
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "/Users/s1/.claude/hooks/auto-announce.sh",
            "timeout": 2
          }
        ]
      }
    ]
  }
}
```

### `~/.claude/hooks/path-config.json`

Stores path-specific configurations:

```json
{
  "/Users/s1/project": {
    "name": "Project Alpha",
    "sound": "Glass",
    "color": "green"
  }
}
```

## Notifications

When Claude Code finishes processing, you'll get:

1. **Voice announcement** at 40% volume: "[Project] ready"
2. **System sound** based on project type
3. **Mac notification** with title and timestamp
4. **Tmux visual** (if in tmux):
   - Window name shows ✓ prefix
   - Window color changes based on project
   - Auto-resets after 5 seconds

## Troubleshooting

### Hook fires too often
The `Stop` hook should only fire when Claude completely finishes responding. If it's firing after every tool use:
1. Restart Claude Code to ensure settings are reloaded
2. Check `~/.claude/hooks/completion.log` for debugging info

### No announcements
1. Ensure the hook script is executable: `chmod +x ~/.claude/hooks/auto-announce.sh`
2. Check if hooks are disabled in settings
3. Restart Claude Code after configuration changes

### Custom paths not working
1. Use absolute paths when configuring
2. Check `~/.claude/hooks/path-config.json` for saved configs
3. Test with: `~/.claude/hooks/manage-paths.sh test`

## Logs

Debug information is logged to:
- `~/.claude/hooks/completion.log` - Shows when announcements fire and path configurations

## Tips

- The system learns as you go - just use Claude Code in new directories and they'll auto-configure
- Use the management script to fine-tune announcements for important projects
- Different sounds help distinguish between multiple Claude sessions running in parallel
- The tmux visual indicators make it easy to see which session finished at a glance

## Requirements

- macOS (for voice and notifications)
- `jq` for JSON processing
- `tmux` (optional, for visual indicators)
- System sounds at `/System/Library/Sounds/`

## Customization

To modify the auto-detection patterns, edit the `get_path_config()` function in `~/.claude/hooks/auto-announce.sh`.

To change the special "D O" announcement for docker-openwisp, modify the override section in the same file.

---

**Note:** The hook system requires Claude Code to be restarted when settings are changed. Use `exit` then `claude` to reload.