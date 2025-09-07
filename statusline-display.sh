#!/bin/bash

# Claude Code Status Line Script
# Displays context usage, model info, and useful metrics

# Read JSON input from stdin
input=$(cat)

# Extract information from JSON
model_name=$(echo "$input" | jq -r '.model.display_name // "Unknown Model"')
model_id=$(echo "$input" | jq -r '.model.id // "unknown"')
current_dir=$(echo "$input" | jq -r '.workspace.current_dir // "/"')
project_dir=$(echo "$input" | jq -r '.workspace.project_dir // "/"')
output_style=$(echo "$input" | jq -r '.output_style.name // "default"')
session_id=$(echo "$input" | jq -r '.session_id // "unknown"')
version=$(echo "$input" | jq -r '.version // "unknown"')

# Get relative path from project to current directory
if [[ "$current_dir" == "$project_dir"* ]]; then
    rel_path="${current_dir#$project_dir}"
    if [[ "$rel_path" == "" ]]; then
        rel_path="/"
    fi
else
    rel_path=$(basename "$current_dir")
fi

# Get git information if in a git repository
git_info=""
if git rev-parse --git-dir > /dev/null 2>&1; then
    branch=$(git branch --show-current 2>/dev/null || echo "detached")
    # Check for uncommitted changes
    if ! git diff --quiet 2>/dev/null || ! git diff --cached --quiet 2>/dev/null; then
        git_status="*"
    else
        git_status=""
    fi
    git_info=" [${branch}${git_status}]"
fi

# Get timestamp
timestamp=$(date "+%H:%M:%S")

# Calculate context usage (approximation based on session activity)
# This is a placeholder - actual context usage would need to be provided by Claude Code
context_usage="~65%"  # This would be dynamically calculated in practice

# Format the status line with colors
printf "\033[2m%s\033[0m \033[36m%s\033[0m%s \033[35m%s\033[0m \033[33mCtx:%s\033[0m \033[32m%s\033[0m \033[90m[%s]\033[0m" \
    "$timestamp" \
    "$model_name" \
    "$git_info" \
    "$rel_path" \
    "$context_usage" \
    "$output_style" \
    "${session_id:0:8}"