#!/usr/bin/env bash
# Backup Utility with Terminal UI (whiptail)

set -euo pipefail

BACKUP_ROOT="$HOME/backup"
LOG_DIR="$HOME/.backup_logs"
mkdir -p "$BACKUP_ROOT" "$LOG_DIR"

log_file="$LOG_DIR/backup-$(date +%Y-%m-%d).log"

log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$log_file"
}

msg() {
  whiptail --title "Backup Utility" --msgbox "$*" 12 70
}

perform_backup() {
  SRC=$(whiptail --inputbox "Enter full path of directory to back up:" 10 70 3>&1 1>&2 2>&3)
  [ -z "$SRC" ] && return

  if [ ! -d "$SRC" ]; then
    msg "Invalid directory! Please try again."
    return
  fi

  TIMESTAMP=$(date +"%d-%m-%Y_%H-%M-%S")
  DEST="$BACKUP_ROOT/$(basename "$SRC")-$TIMESTAMP"

  mkdir -p "$DEST"
  log "Starting backup: $SRC → $DEST"

  whiptail --title "Backup Progress" --infobox "Backing up...\n\nFrom: $SRC\nTo: $DEST" 10 70

  rsync -a --info=progress2 "$SRC/" "$DEST/" >> "$log_file" 2>&1

  msg "✅ Backup completed!\nSaved to: $DEST"
  log "Backup complete: $SRC → $DEST"
}

view_backups() {
  if command -v xdg-open >/dev/null; then
    xdg-open "$BACKUP_ROOT" >/dev/null 2>&1 &
  fi
  msg "Opened backup folder:\n$BACKUP_ROOT"
}

view_logs() {
  if [ -f "$log_file" ]; then
    whiptail --textbox "$log_file" 20 80
  else
    msg "No logs yet. Run a backup first."
  fi
}

while true; do
  CHOICE=$(whiptail --title "🗂️ Backup Utility" --menu "Choose an option" 15 60 4 \
  "1" "Start Backup" \
  "2" "View Backup Folder" \
  "3" "View Logs" \
  "4" "Exit" 3>&1 1>&2 2>&3)

  case $CHOICE in
    1) perform_backup ;;
    2) view_backups ;;
    3) view_logs ;;
    4) break ;;
  esac
done
