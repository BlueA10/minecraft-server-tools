#!/usr/bin/env bash

# backup.sh

# Exit on any errors
#set -e
set -x
# (We want this off to ensure auto-saves will be appropriately turned on at
# the end in the event of any errors. We'll try to handle errors instead.)

# shellcheck source=./common_vars.sh
. "$(dirname "$(realpath "${0}")")/common_vars.sh"
# shellcheck source=./common_functions.sh
. "$(dirname "$(realpath "${0}")")/common_functions.sh"

echo "Notifying server players of backup initialization."
server_cmd "say World backup initiated..."

echo "Disabling auto-saves on server."
server_cmd_wait "save-off" \
        "Automatic saving is now disabled"

echo "Triggering manual save on server."
server_cmd_wait "save-all" \
        "Saved the game"

# Neccessary envvars for borg
BORG_REPO="${server_backup_dir}"
export BORG_REPO
BORG_PASSPHRASE=$(<"${server_borg_pass_src}")
export BORG_PASSPHRASE

# Prepare for handling errors with borg
trap 'echo Backup interrupted >&2; exit 2' INT TERM

echo "Starting borg backup of world folder."
borg create \
        --verbose \
        --filter AME \
        --list \
        --stats \
        --show-rc \
        --compression zstd \
        --exclude-caches \
        --exclude "${server_dir}/*/session.lock" \
        "::{hostname}-worlds-{utcnow}" \
        "${server_dir}/world" \
        "${server_dir}/world_nether" \
        "${server_dir}/world_the_end"
backup_exit="${?}"

echo "Re-enabling auto-saves on server."
server_cmd_wait "save-on" \
        "Automatic saving is now enabled"

# Prune backups if backup was successful
if [[ ${backup_exit} -lt 2 ]]; then
        echo "Notifying server players of backup completion."
        server_cmd "say World backup complete."

        echo "Pruning borg repo."
        borg prune \
                --list \
                --prefix '{hostname}-world-' \
                --show-rc \
                --keep-daily 7 \
                --keep-weekly 4 \
                --keep-monthly 6
        prune_exit=$?
else
        echo "Notifying server players of backup error."
        server_cmd "say World backup failed; Please inform the administrator."

        # Just match prune exit to backup exit for later comparison
        prune_exit=${backup_exit}
fi

# Use highest exit code as global exit code
global_exit=$(( backup_exit > prune_exit ? backup_exit : prune_exit ))
if [[ ${global_exit} -eq 0 ]]; then
        echo "Backup and Prune finished successfully."
elif [[ ${global_exit} -eq 1 ]]; then
        echo "Backup and/or Prune finished with warnings."
else
        echo "Backup and/or Prune finished with errors."
fi

exit ${global_exit}
