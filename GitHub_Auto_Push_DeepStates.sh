#!/bin/bash

REPO_PATH="/storage/omprakash/Microbiome_DeepStates_Analysis/Microbiome_DeepStates"
LOG_DIR="/storage/omprakash/Microbiome_DeepStates_Analysis/git_logs"

mkdir -p "$LOG_DIR"

cd "$REPO_PATH" || {
    echo "Repo path not found!"
    exit 1
}

LOG_FILE="$LOG_DIR/skipped_RData_$(date +%F).txt"
find . -type f -name "*.RData" ! -path "./.git/*" > "$LOG_FILE"

git add . ':!*.RData'

if ! git diff --cached --quiet; then
    COMMIT_MSG="Updated backup: $(date '+%Y-%m-%d %H:%M:%S')"
    git commit -m "$COMMIT_MSG"
    git push origin main
else
    echo "No changes to commit today."
fi