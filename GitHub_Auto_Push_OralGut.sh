#!/bin/bash

# ------------------------------
# Auto Git Backup Script
# ------------------------------

REPO_PATH="/storage/omprakash/OralGut_Analysis/OralGut_Data_Analysis"
LOG_DIR="/storage/omprakash/OralGut_Analysis/git_logs"

# Create log directory
mkdir -p "$LOG_DIR"

# Go to repo
cd "$REPO_PATH" || { echo "Repo path not found! Exiting."; exit 1; }

# Log skipped .RData files
LOG_FILE="$LOG_DIR/skipped_RData_$(date +%F).txt"
find . -type f -name "*.RData" ! -path "./.git/*" > "$LOG_FILE"

# Add all except .RData
git add . ':!*.RData'

# Commit if changes exist
if ! git diff --cached --quiet; then
    COMMIT_MSG="Updated backup: $(date '+%Y-%m-%d %H:%M:%S')"
    git commit -m "$COMMIT_MSG"
    git push origin main
else
    echo "No changes to commit today."
fi
