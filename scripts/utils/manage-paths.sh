#!/bin/bash

CONFIG_FILE="$HOME/.claude/hooks/path-config.json"

# Initialize config file if it doesn't exist
if [ ! -f "$CONFIG_FILE" ]; then
    mkdir -p "$(dirname "$CONFIG_FILE")"
    echo '{}' > "$CONFIG_FILE"
fi

case "$1" in
    list)
        echo "Configured paths:"
        jq -r 'to_entries | .[] | "\(.key)\n  Name: \(.value.name)\n  Sound: \(.value.sound)\n  Color: \(.value.color)\n"' "$CONFIG_FILE"
        ;;
    
    add)
        if [ -z "$2" ] || [ -z "$3" ]; then
            echo "Usage: $0 add <path> <name> [sound] [color]"
            echo "Sounds: Glass, Ping, Pop, Blow, Morse, Hero, Tink, Purr"
            echo "Colors: green, cyan, yellow, blue, magenta, red, white, default"
            exit 1
        fi
        PATH_TO_ADD="$2"
        NAME="$3"
        SOUND="${4:-Purr}"
        COLOR="${5:-default}"
        
        jq --arg p "$PATH_TO_ADD" \
           --arg n "$NAME" \
           --arg s "$SOUND" \
           --arg c "$COLOR" \
           '.[$p] = {"name": $n, "sound": $s, "color": $c}' \
           "$CONFIG_FILE" > "$CONFIG_FILE.tmp" && mv "$CONFIG_FILE.tmp" "$CONFIG_FILE"
        
        echo "Added: $PATH_TO_ADD -> '$NAME ready' ($SOUND sound, $COLOR color)"
        ;;
    
    remove)
        if [ -z "$2" ]; then
            echo "Usage: $0 remove <path>"
            exit 1
        fi
        jq --arg p "$2" 'del(.[$p])' "$CONFIG_FILE" > "$CONFIG_FILE.tmp" && mv "$CONFIG_FILE.tmp" "$CONFIG_FILE"
        echo "Removed: $2"
        ;;
    
    update)
        if [ -z "$2" ] || [ -z "$3" ]; then
            echo "Usage: $0 update <path> name|sound|color <value>"
            exit 1
        fi
        PATH_TO_UPDATE="$2"
        FIELD="$3"
        VALUE="$4"
        
        jq --arg p "$PATH_TO_UPDATE" \
           --arg f "$FIELD" \
           --arg v "$VALUE" \
           '.[$p][$f] = $v' \
           "$CONFIG_FILE" > "$CONFIG_FILE.tmp" && mv "$CONFIG_FILE.tmp" "$CONFIG_FILE"
        
        echo "Updated $PATH_TO_UPDATE: $FIELD = $VALUE"
        ;;
    
    test)
        # Test the current directory
        bash ~/.claude/hooks/auto-announce.sh
        echo "Tested announcement for: $(pwd)"
        ;;
    
    clear)
        echo '{}' > "$CONFIG_FILE"
        echo "Cleared all path configurations"
        ;;
    
    *)
        echo "Claude Code Path Manager"
        echo ""
        echo "Usage: $0 {list|add|remove|update|test|clear}"
        echo ""
        echo "Commands:"
        echo "  list                                    - Show all configured paths"
        echo "  add <path> <name> [sound] [color]     - Add/update a path"
        echo "  remove <path>                          - Remove a path"
        echo "  update <path> name|sound|color <value> - Update specific field"
        echo "  test                                   - Test announcement for current dir"
        echo "  clear                                  - Remove all configurations"
        echo ""
        echo "Available sounds: Glass, Ping, Pop, Blow, Morse, Hero, Tink, Purr"
        echo "Available colors: green, cyan, yellow, blue, magenta, red, white, default"
        echo ""
        echo "Examples:"
        echo "  $0 add /Users/s1/project 'Project Alpha' Glass green"
        echo "  $0 add . 'Current Project' Ping cyan"
        echo "  $0 update /Users/s1/project sound Hero"
        ;;
esac