#!/bin/bash

# Enhanced Claude Code Status Line with Powerline Styling
# Reads JSON input from stdin and displays comprehensive status information

# Read JSON input
input=$(cat)

# Extract data from JSON
model_name=$(echo "$input" | jq -r '.model.display_name // "Unknown Model"')
model_id=$(echo "$input" | jq -r '.model.id // "unknown"')
session_id=$(echo "$input" | jq -r '.session_id // "no-session"')
current_dir=$(echo "$input" | jq -r '.workspace.current_dir // ""')
project_dir=$(echo "$input" | jq -r '.workspace.project_dir // ""')
output_style=$(echo "$input" | jq -r '.output_style.name // "default"')
version=$(echo "$input" | jq -r '.version // "unknown"')

# Color codes for powerline styling
BG_DARK_BLUE="\033[48;5;24m"
BG_BLUE="\033[48;5;39m"
BG_GREEN="\033[48;5;28m"
BG_ORANGE="\033[48;5;208m"
BG_RED="\033[48;5;196m"
BG_PURPLE="\033[48;5;129m"
BG_YELLOW="\033[48;5;220m"
BG_GRAY="\033[48;5;240m"
BG_DARK_GRAY="\033[48;5;235m"

FG_WHITE="\033[38;5;15m"
FG_BLACK="\033[38;5;16m"
FG_GRAY="\033[38;5;250m"
FG_DARK_BLUE="\033[38;5;24m"
FG_BLUE="\033[38;5;39m"
FG_GREEN="\033[38;5;28m"
FG_ORANGE="\033[38;5;208m"
FG_RED="\033[38;5;196m"
FG_PURPLE="\033[38;5;129m"
FG_YELLOW="\033[38;5;220m"

RESET="\033[0m"
SEPARATOR="⮀"

# Function to add powerline segment
add_segment() {
    local bg_color="$1"
    local fg_color="$2"
    local content="$3"
    local next_bg="$4"
    
    if [ -n "$next_bg" ]; then
        printf "${bg_color}${fg_color} ${content} ${next_bg}${bg_color}${SEPARATOR}${RESET}"
    else
        printf "${bg_color}${fg_color} ${content} ${RESET}${bg_color}${SEPARATOR}${RESET}"
    fi
}

# Git information (with enhanced detection)
git_info=""
git_context=""
if [ -n "$current_dir" ] && [ -d "$current_dir" ]; then
    cd "$current_dir" 2>/dev/null
    if git rev-parse --git-dir >/dev/null 2>&1; then
        branch=$(git branch --show-current 2>/dev/null || git rev-parse --short HEAD 2>/dev/null || echo "detached")
        
        # Check for worktree
        worktree_indicator=""
        if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
            git_dir=$(git rev-parse --git-dir 2>/dev/null)
            if [[ "$git_dir" == *".git/worktrees"* ]]; then
                worktree_indicator="⚡"
            fi
        fi
        
        # Check for submodule and superproject
        submodule_indicator=""
        superproject_info=""
        if git rev-parse --show-superproject-working-tree >/dev/null 2>&1; then
            superproject_path=$(git rev-parse --show-superproject-working-tree 2>/dev/null)
            if [ -n "$superproject_path" ]; then
                # We're in a submodule, get superproject status
                cd "$superproject_path" 2>/dev/null
                if git rev-parse --git-dir >/dev/null 2>&1; then
                    super_branch=$(git branch --show-current 2>/dev/null || git rev-parse --short HEAD 2>/dev/null || echo "detached")
                    superproject_info="↗$super_branch"
                fi
                cd "$current_dir" 2>/dev/null
                submodule_indicator="⊂"
            fi
        fi
        
        # Status indicators
        status_flags=""
        if ! git diff-index --quiet HEAD -- 2>/dev/null; then
            status_flags+="●"  # Modified files
        fi
        if [ -n "$(git ls-files --others --exclude-standard 2>/dev/null)" ]; then
            status_flags+="+"  # Untracked files
        fi
        if ! git diff-index --quiet --cached HEAD -- 2>/dev/null; then
            status_flags+="✓"  # Staged files
        fi
        
        # Ahead/behind counts
        ahead_behind=""
        upstream=$(git rev-parse --abbrev-ref @{upstream} 2>/dev/null)
        if [ -n "$upstream" ]; then
            ahead=$(git rev-list --count HEAD..@{upstream} 2>/dev/null || echo "0")
            behind=$(git rev-list --count @{upstream}..HEAD 2>/dev/null || echo "0")
            if [ "$ahead" -gt 0 ] || [ "$behind" -gt 0 ]; then
                ahead_behind=" ↑$behind ↓$ahead"
            fi
        fi
        
        git_info="${worktree_indicator}${submodule_indicator}$branch$status_flags$ahead_behind"
        if [ -n "$superproject_info" ]; then
            git_context="$superproject_info"
        fi
    fi
fi

# Project context
project_name=""
relative_path=""
if [ -n "$project_dir" ] && [ -n "$current_dir" ]; then
    project_name=$(basename "$project_dir")
    if [[ "$current_dir" == "$project_dir"* ]]; then
        relative_path=${current_dir#$project_dir}
        relative_path=${relative_path#/}
        [ -z "$relative_path" ] && relative_path="."
    else
        relative_path=$(pwd)
    fi
else
    project_name=$(basename "$(pwd)")
    relative_path="."
fi

# System information
hostname=$(hostname -s)
username=$(whoami)

# Build status line segments
segments=""

# Session and output style segment (fixing the "default @ session" issue)
session_display="$output_style"
if [[ "$output_style" == "default" ]]; then
    session_display="Standard"
fi
segments+=$(add_segment "$BG_BLUE" "$FG_WHITE" "$session_display" "$BG_GREEN")

# Model segment
model_short=$(echo "$model_name" | sed 's/Claude //' | sed 's/ Sonnet//')
segments+=$(add_segment "$BG_GREEN" "$FG_BLACK" "$model_short" "$BG_ORANGE")

# System info segment
segments+=$(add_segment "$BG_ORANGE" "$FG_BLACK" "$username@$hostname" "$BG_YELLOW")

# Project segment
segments+=$(add_segment "$BG_YELLOW" "$FG_BLACK" "$project_name" "$BG_PURPLE")

# Directory segment
next_color="$BG_GRAY"
if [ -n "$git_info" ]; then
    next_color="$BG_RED"
elif [ -n "$git_context" ]; then
    next_color="$BG_DARK_GRAY"
fi
segments+=$(add_segment "$BG_PURPLE" "$FG_WHITE" "$relative_path" "$next_color")

# Git context segment (superproject info)
if [ -n "$git_context" ] && [ -n "$git_info" ]; then
    segments+=$(add_segment "$BG_DARK_GRAY" "$FG_WHITE" "$git_context" "$BG_RED")
elif [ -n "$git_context" ] && [ -z "$git_info" ]; then
    segments+=$(add_segment "$BG_DARK_GRAY" "$FG_WHITE" "$git_context" "$BG_GRAY")
fi

# Git segment (if available)
if [ -n "$git_info" ]; then
    segments+=$(add_segment "$BG_RED" "$FG_WHITE" "$git_info" "$BG_GRAY")
fi

# Version segment
segments+=$(add_segment "$BG_GRAY" "$FG_WHITE" "v$version" "")

# Output the complete status line
printf "$segments\n"