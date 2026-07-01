#!/bin/bash

# ------------------------------
# Auto Git Backup Script
# ------------------------------

# Paths
REPO_PATH="#!/bin/bash

# ------------------------------
# Auto Git Backup Script
# ------------------------------

# Paths
REPO_PATH="/storage/omprakash/MetaOral_Analysis/MetaOral_Data_Analysis"
LOG_DIR="#!/bin/bash

# ------------------------------
# Auto Git Backup Script
# ------------------------------

# Paths
REPO_PATH="/storage/omprakash/MetaOral_Analysis/MetaOral_Data_Analysis"
LOG_DIR="/storage/omprakash/MetaOral_Analysis/git_logs"

# Create log directory if it doesn't exist
mkdir -p "$LOG_DIR"

# Go to the repo
cd "$REPO_PATH" || { echo "Repo path not found! Exiting."; exit 1; }

# Log all .RData files (for record)
LOG_FILE="$LOG_DIR/skipped_RData_$(date +%F).txt"
find . -type f -name "*.RData" ! -path "./.git/*" > "$LOG_FILE"

# Stage all changes EXCEPT .RData files
git add . ':!*.RData'

# Only commit if there is something staged
if ! git diff --cached --quiet; then
    COMMIT_MSG="Daily auto-backup: $(date '+%Y-%m-%d %H:%M:%S')"
    git commit -m "$COMMIT_MSG"
    
    # Push changes to the remote repo
    git push origin main
else
    echo "No changes to commit today."
fi
/git_logs"

# Create log directory if it doesn't exist
mkdir -p "$LOG_DIR"

# Go to the repo
cd "$REPO_PATH" || { echo "Repo path not found! Exiting."; exit 1; }

# Log all .RData files (for record)
LOG_FILE="$LOG_DIR/skipped_RData_$(date +%F).txt"
find . -type f -name "*.RData" ! -path "./.git/*" > "$LOG_FILE"

# Stage all changes EXCEPT .RData files
git add . ':!*.RData'

# Only commit if there is something staged
if ! git diff --cached --quiet; then
    COMMIT_MSG="Daily auto-backup: $(date '+%Y-%m-%d %H:%M:%S')"
    git commit -m "$COMMIT_MSG"
    
    # Push changes to the remote repo
    git push origin main
else
    echo "No changes to commit today."
fi
"
LOG_DIR="/storage/omprakash/MetaOral_Analysis/git_logs"

# Create log directory if it doesn't exist
mkdir -p "$LOG_DIR"

# Go to the repo
cd "$REPO_PATH" || { echo "Repo path not found! Exiting."; exit 1; }

# Log all .RData files (for record)
LOG_FILE="$LOG_DIR/skipped_RData_$(date +%F).txt"
find . -type f -name "*.RData" ! -path "./.git/*" > "$LOG_FILE"

# Stage all changes EXCEPT .RData files
git add . ':!*.RData'

# Only commit if there is something staged
if ! git diff --cached --quiet; then
    COMMIT_MSG="Daily auto-backup: $(date '+%Y-%m-%d %H:%M:%S')"
    git commit -m "$COMMIT_MSG"
    
    # Push changes to the remote repo
    git push origin main
else
    echo "No changes to commit today."
fi
