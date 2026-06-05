#!/bin/bash

# Read JSON input from stdin
input=$(cat)

# Extract values from JSON
current_dir=$(echo "$input" | jq -r '.workspace.current_dir')
project_dir=$(echo "$input" | jq -r '.workspace.project_dir')
model=$(echo "$input" | jq -r '.model.display_name')
output_style=$(echo "$input" | jq -r '.output_style.name')

# Get current directory name
dir_name=$(basename "$current_dir")

# Get git status if we're in a git repo
git_status=""
if cd "$current_dir" 2>/dev/null && git rev-parse --git-dir >/dev/null 2>&1; then
    # Get current branch
    branch=$(git branch --show-current 2>/dev/null)

    # Get git status indicators
    if [[ -n $(git status --porcelain 2>/dev/null) ]]; then
        git_status=" \033[33m⚡\033[0m $branch"
    else
        git_status=" \033[32m✓\033[0m $branch"
    fi
fi

# Build the status line similar to Powerlevel10k lean style
# Format: 🍎 directory git_status | model [output_style] user@host
printf "\033[2m🍎 \033[34m%s\033[0m%s \033[2m|\033[0m \033[36m%s\033[0m \033[2m[%s] %s@%s\033[0m" \
    "$dir_name" \
    "$git_status" \
    "$model" \
    "$output_style" \
    "$(whoami)" \
    "$(hostname -s)"
