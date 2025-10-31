#!/usr/bin/env bash
# Enhanced Backup Utility with TUI and Extra Features

set -euo pipefail

# === CONFIG ===
BACKUP_ROOT="${HOME}/backup"
LOG_DIR="${HOME}/.backup_logs"
CONFIG_FILE="${HOME}/.backup_config"
mkdir -p "$BACKUP_ROOT" "$LOG_DIR"

# === LOGGING ===
log_file="$LOG_DIR/backup-$(date +%Y-%m-%d).log"
log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$log_file"; }

# === MESSAGE HELPERS ===
msg() { whiptail --title "📦 Backup Utility" --msgbox "$*" 12 70; }
confirm() { whiptail --yesno "$1" 10 70; }

# === SETTINGS ===
load_settings() {
  if [[ -f "$CONFIG_FILE" ]]; then
    source "$CONFIG_FILE"
  else
    COMPRESS="yes"
    echo "COMPRESS=$COMPRESS" > "$CONFIG_FILE"
  fi
}

save_settings() {
  echo "COMPRESS=$COMPRESS" > "$CONFIG_FILE"
}

# === MAIN FUNCTIONS ===

perform_backup() {
  SRC=$(whiptail --inputbox "Enter full path of directory to back up:" 10 70 3>&1 1>&2 2>&3) || return
  [ -z "$SRC" ] && return

  if [ ! -d "$SRC" ]; then
    msg "Invalid directory! Please try again."
    return
  fi

  TIMESTAMP=$(date +"%d-%m-%Y_%H-%M-%S")
  DEST_DIR="$BACKUP_ROOT/$(basename "$SRC")-$TIMESTAMP"

  mkdir -p "$DEST_DIR"
  log "Starting backup: $SRC → $DEST_DIR"

  whiptail --title "Backup Progress" --infobox "Backing up...\n\nFrom: $SRC\nTo: $DEST_DIR" 10 70

  rsync -a --info=progress2 "$SRC/" "$DEST_DIR/" >>"$log_file" 2>&1

  if [[ "$COMPRESS" == "yes" ]]; then
    TAR_FILE="$DEST_DIR.tar.gz"
    log "Compressing backup..."
    tar -czf "$TAR_FILE" -C "$BACKUP_ROOT" "$(basename "$DEST_DIR")"
    rm -rf "$DEST_DIR"
    log "Compressed to: $TAR_FILE"
  fi

  notify-send "Backup Completed" "Backup of $(basename "$SRC") finished successfully!" 2>/dev/null || true
  msg "✅ Backup completed!\nSaved to: ${COMPRESS:+$TAR_FILE}${COMPRESS:no → $DEST_DIR}"
  log "Backup complete."
}

restore_backup() {
  BACKUP_FILE=$(find "$BACKUP_ROOT" -maxdepth 1 -type f -name "*.tar.gz" -o -type d | sort -r)
  if [ -z "$BACKUP_FILE" ]; then
    msg "No backups found."
    return
  fi

  BACKUP_LIST=$(printf "%s\n" $BACKUP_FILE | awk '{printf "%d %s\n", NR, $0}')
  SELECTED=$(whiptail --title "Restore Backup" --menu "Choose backup to restore:" 20 70 10 $BACKUP_LIST 3>&1 1>&2 2>&3) || return

  TARGET=$(echo "$BACKUP_FILE" | sed -n "${SELECTED}p")
  RESTORE_DIR=$(whiptail --inputbox "Enter destination path to restore:" 10 70 "$HOME/restore" 3>&1 1>&2 2>&3) || return

  mkdir -p "$RESTORE_DIR"
  log "Restoring $TARGET → $RESTORE_DIR"

  if [[ "$TARGET" == *.tar.gz ]]; then
    tar -xzf "$TARGET" -C "$RESTORE_DIR"
  else
    rsync -a "$TARGET/" "$RESTORE_DIR/"
  fi

  msg "✅ Restore completed!\nRestored to: $RESTORE_DIR"
  log "Restore complete: $TARGET → $RESTORE_DIR"
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

change_settings() {
  COMPRESS=$(whiptail --title "Settings" --menu "Toggle Compression" 15 60 2 \
    "yes" "Enable tar.gz compression" \
    "no" "Disable compression" 3>&1 1>&2 2>&3) || return
  save_settings
  msg "Settings updated successfully!"
}

# === MAIN MENU ===
load_settings

while true; do
  CHOICE=$(whiptail --title "🗂️  Enhanced Backup Utility" --menu "Choose an option" 18 70 8 \
    "1" "Start Backup" \
    "2" "Restore Backup" \
    "3" "View Backup Folder" \
    "4" "View Logs" \
    "5" "Change Settings" \
    "6" "Exit" 3>&1 1>&2 2>&3) || break

  case $CHOICE in
    1) perform_backup ;;
    2) restore_backup ;;
    3) view_backups ;;
    4) view_logs ;;
    5) change_settings ;;
    6) break ;;
  esac
done
