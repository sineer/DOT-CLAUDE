#!/bin/bash

# Get current working directory where Claude Code was started
CWD=$(pwd)
PROJECT_NAME=$(basename "$CWD")
PARENT_DIR=$(basename "$(dirname "$CWD")")
FULL_PATH=$(realpath "$CWD" 2>/dev/null || echo "$CWD")

# Path configuration files
CONFIG_FILE="$HOME/.claude/config/paths.json"
PATTERNS_FILE="$HOME/.claude/config/special-patterns.json"

# Initialize config files if they don't exist
if [ ! -f "$CONFIG_FILE" ]; then
    mkdir -p "$(dirname "$CONFIG_FILE")"
    echo '{}' > "$CONFIG_FILE"
fi

if [ ! -f "$PATTERNS_FILE" ]; then
    mkdir -p "$(dirname "$PATTERNS_FILE")"
    echo '{"patterns": []}' > "$PATTERNS_FILE"
fi

# Function to check special patterns
check_special_patterns() {
    local path="$1"
    local patterns=$(jq -r '.patterns[] | "\(.pattern)|\(.exact)|\(.name)|\(.sound)|\(.color)"' "$PATTERNS_FILE" 2>/dev/null)
    
    while IFS='|' read -r pattern exact name sound color; do
        if [ -n "$pattern" ]; then
            if [ "$exact" = "true" ]; then
                # Exact match - normalize paths for comparison
                local normalized_path=$(realpath "$path" 2>/dev/null || echo "$path")
                local normalized_pattern=$(realpath "${pattern/\*/$(dirname "$path")}" 2>/dev/null || echo "${pattern/\*/$(dirname "$path")}")
                if [[ "$normalized_path" == "$normalized_pattern" ]]; then
                    echo "$name|$sound|$color"
                    return 0
                fi
            else
                # Pattern match
                if [[ "$path" == $pattern ]]; then
                    echo "$name|$sound|$color"
                    return 0
                fi
            fi
        fi
    done <<< "$patterns"
    
    return 1
}

# Function to get or create config for current path
get_path_config() {
    local path="$1"
    local config=$(jq -r --arg p "$path" '.[$p] // null' "$CONFIG_FILE" 2>/dev/null)
    
    if [ "$config" = "null" ] || [ -z "$config" ]; then
        # Auto-generate config based on path patterns
        local auto_name=""
        local auto_sound=""
        local auto_color=""
        
        # Smart detection based on common patterns
        if [[ "$path" == */docker-* ]]; then
            auto_name="Docker $(basename "$path" | sed 's/docker-//')"
            auto_sound="Glass"
            auto_color="green"
        elif [[ "$path" == */MCP/* ]] || [[ "$path" == */mcp-* ]]; then
            auto_name="MCP $(basename "$path")"
            auto_sound="Ping"
            auto_color="cyan"
        elif [[ "$path" == */conductor/* ]]; then
            auto_name="Conductor $(basename "$path")"
            auto_sound="Pop"
            auto_color="yellow"
        elif [[ "$path" == */test* ]] || [[ "$path" == *-test ]]; then
            auto_name="Test $(basename "$path")"
            auto_sound="Morse"
            auto_color="magenta"
        elif [[ "$path" == */build* ]]; then
            auto_name="Build $(basename "$path")"
            auto_sound="Blow"
            auto_color="blue"
        elif [[ "$path" == */.* ]]; then
            # Hidden/config directories
            auto_name="Config $(basename "$path")"
            auto_sound="Tink"
            auto_color="white"
        else
            # Default: use last two parts of path for context
            if [ "$PARENT_DIR" != "/" ] && [ "$PARENT_DIR" != "." ]; then
                auto_name="${PARENT_DIR}/${PROJECT_NAME}"
            else
                auto_name="$PROJECT_NAME"
            fi
            auto_sound="Purr"
            auto_color="default"
        fi
        
        # Save the auto-generated config
        jq --arg p "$path" \
           --arg n "$auto_name" \
           --arg s "$auto_sound" \
           --arg c "$auto_color" \
           '.[$p] = {"name": $n, "sound": $s, "color": $c}' \
           "$CONFIG_FILE" > "$CONFIG_FILE.tmp" && mv "$CONFIG_FILE.tmp" "$CONFIG_FILE"
        
        echo "$auto_name|$auto_sound|$auto_color"
    else
        # Use existing config
        echo "$config" | jq -r '"\(.name)|\(.sound)|\(.color)"'
    fi
}

# Check for special patterns first
SPECIAL_CONFIG=$(check_special_patterns "$FULL_PATH")
if [ $? -eq 0 ]; then
    # Use special pattern config
    IFS='|' read -r CONTEXT SOUND COLOR <<< "$SPECIAL_CONFIG"
else
    # Get or auto-generate config for this path
    CONFIG=$(get_path_config "$FULL_PATH")
    IFS='|' read -r CONTEXT SOUND COLOR <<< "$CONFIG"
fi

# Voice announcement
say "$CONTEXT ready" &

# System sound
afplay /System/Library/Sounds/${SOUND}.aiff 2>/dev/null &

# Mac notification with more details
osascript -e "display notification \"Processing complete\" with title \"$CONTEXT\" subtitle \"$(date '+%H:%M:%S')\""

# If in tmux, update window status
if [ -n "$TMUX" ]; then
    WINDOW_INDEX=$(tmux display-message -p '#I')
    WINDOW_NAME=$(tmux display-message -p '#W')
    
    # Flash the window status
    tmux set-window-option -t "$WINDOW_INDEX" window-status-style "fg=$COLOR,bold,bg=black"
    tmux rename-window -t "$WINDOW_INDEX" "✓ ${WINDOW_NAME}"
    
    # Reset after 5 seconds
    (sleep 5 && \
     tmux set-window-option -t "$WINDOW_INDEX" window-status-style "fg=default" && \
     tmux rename-window -t "$WINDOW_INDEX" "${WINDOW_NAME/✓ /}") &
fi

# Log to a file for debugging
echo "$(date '+%Y-%m-%d %H:%M:%S') | $CONTEXT | $CWD" >> ~/.claude/hooks/completion.log

# Show current config in log
echo "Path configs saved: $(jq -r 'keys | length' "$CONFIG_FILE" 2>/dev/null || echo 0)" >> ~/.claude/hooks/completion.log