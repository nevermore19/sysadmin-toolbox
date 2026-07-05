#!/bin/bash

SOURCE_DIR="/etc"
BACKUP_DIR="/var/backups"
DATE=$(date +%Y-%m-%d_%H-%M-%S)
BACKUP_FILE="$BACKUP_DIR/etc_backup_$DATE.tar.gz"
RETENTION_DAYS=7
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m'
LOADING=("", ".", "..", "...")


echo "=== STARTING BACKUP PROCESS: $(date) ==="

if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}[ERROR] This script must be executed as root!${NC}" >&2
    exit 1
fi

if [ ! -d "$BACKUP_DIR" ]; then
    echo -e "${YELLOW}[WARNING] $BACKUP_DIR does not exist${NC}"
    read -p "[?] Create $BACKUP_DIR? (Y/N): " confirm && [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]] || exit 1
    echo "[INFO] Creating backup folder: $BACKUP_DIR"
    mkdir -p "$BACKUP_DIR"
fi

tar -czf "$BACKUP_FILE" "$SOURCE_DIR" 2>/dev/null &
pid=$!
echo -n "\r[PROCESS] Backing up $SOURCE_DIR into file"
while kill -0 "$pid" 2>/dev/null; do
    for i in "${LOADING[@]}"; do
        kill -0 "$pid" 2>/dev/null
        printf "\r[PROCESS] Backing up %s into file%-3s" "$SOURCE_DIR" "$i"
        sleep 0.3
    done
done
echo ""

wait "$pid"

if [ $? -eq 0 ]; then
    echo -e "${GREEN}[SUCCESS] Backup created successfully: $BACKUP_FILE${NC}"
    echo "[INFO] File size: $(du -sh "$BACKUP_FILE" | awk '{print $1}')"
else
    echo -e "${RED}[ERROR] An error occurred while creating the tar archive${NC}" >&2
    exit 1
fi

echo -n -e "[?] ${RED}Delete${NC} backups older than $RETENTION_DAYS days? (Y/N): "
read -r confirm

if [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]]; then

    DELETED_COUNT=$(find "$BACKUP_DIR" -type f -name "etc_backup_*.tar.gz" -mtime +$RETENTION_DAYS | wc -l)

    find "$BACKUP_DIR" -type f -name "etc_backup_*.tar.gz" -mtime +$RETENTION_DAYS -exec rm {} \; &
    pid=$!

    echo -n "[PROCESS] Deleting older backups"
    while kill -0 "$pid" 2>/dev/null; do
      for i in "${LOADING[@]}"; do
        kill -0 "$pid" 2>/dev/null
        printf "\r[PROCESS] Deleting older backups%-3s" "$i"
        sleep 0.3
      done
    done
    echo ""
    if [ $DELETED_COUNT == 0 ]; then
        echo "There are no older backups that can be deleted!"
    else
        echo -e "${GREEN}[SUCCESS] Removed $DELETED_COUNT old backup(s).${NC}"
    fi
fi
echo "=== BACKUP PROCESS ENDED SUCCESSFULLY ==="