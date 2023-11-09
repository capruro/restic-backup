#!/bin/bash

INCLUDE_PATH="/path/to/your/logfile.log/include-path.txt"
EXCLUDE_PATH="/path/to/your/logfile.log/exclude-path.txt"
LOG_FILE="/var/log/backup.log"  # Set your desired log file path

log() {
    local log_message="$1"
    local timestamp=$(date +'%Y-%m-%d %H:%M:%S')
    local pid=$$

    echo "$timestamp $(hostname) [$pid] [$(basename "$CONFIG_FILE")]: $log_message" | tee -a "$LOG_FILE"
}

# Check if a configuration file is provided as an argument
if [ $# -ne 1 ]; then
    echo "Usage: $0 <config_file>"
    exit 1
fi

# Check if the provided configuration file exists
if [ ! -e "$LOG_FILE" ]; then
    touch $LOG_FILE
fi

# Check if the provided configuration file exists
CONFIG_FILE="$1"
if [ ! -e "$CONFIG_FILE" ]; then
    log "Configuration file '$CONFIG_FILE' does not exist. Please provide a valid configuration file."
    exit 1
fi

# Define a lock file location
LOCK_FILE="/tmp/restic_backup.lock"

# Check if the lock file exists
if [ -e "$LOCK_FILE" ]; then
    log "Another backup is already running. Exiting backup $CONFIG_FILE."
    exit 1
fi

log "Create a lock file to prevent concurrent execution"
echo $$ > "$LOCK_FILE"

# Function to remove the lock file on script exit
cleanup() {
    rm -f "$LOCK_FILE"
    log "Lock file deleted"
    exit
}

trap cleanup EXIT

log "Running Restic backup with $CONFIG_FILE as $USER"

# Import the configuration settings from the provided file
source "$CONFIG_FILE"

log "Backup started"

# Run the backup and capture the output, including errors
backup_output=$(restic backup --exclude-file $EXCLUDE_PATH --files-from $INCLUDE_PATH 2>&1)

# Check if the backup was successful
if [ $? -eq 0 ]; then
    log "Backup completed"
else
    log "Error during backup: $backup_output"
    exit 1
fi

# Remove old backups. Enable if your REST server is not in append-only mode.
log "Removing old backups"
forget_output=$(restic forget \
    --keep-hourly 40 \
    --keep-daily 180 \
    --keep-weekly 52 \
    --keep-monthly 32 \
    --keep-yearly 10 2>&1)

# Check if the forget operation was successful
if [ $? -eq 0 ]; then
    log "Old backups removed"
else
    log "Error during forget operation: $forget_output"
    exit 1
fi

# reset credentials
unset RESTIC_REPOSITORY
unset RESTIC_PASSWORD
unset AWS_ACCESS_KEY_ID
unset AWS_SECRET_ACCESS_KEY

log "Restic backup with $CONFIG_FILE completed as $USER"
