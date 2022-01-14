#!/usr/bin/env bash

# take-zfs-snapshot.sh

# Exit on any errors
#set -e
# Debug (echo each line)
#set -x
# (We want this off to ensure auto-saves will be appropriately turned on at
# the end in the event of any errors. We'll try to handle errors instead.)

# shellcheck source=./common_vars.sh
. "$(dirname "$(realpath "${0}")")/common_vars.sh"
# shellcheck source=./common_functions.sh
. "$(dirname "$(realpath "${0}")")/common_functions.sh"

trap 'echo ZFS snapshot interrupted >&2; exit 3' INT TERM

snapshot_time="$(date -u +%FT%R)"
zfs snapshot -r "${server_zfs_dataset}@${snapshot_time}"
zfs_exit=$?

if [[ ${zfs_exit} -eq 0 ]]; then
        echo "Snapshot created at ${snapshot_time}"
        # Look into pruning ZFS snapshots. Won't have to worry for a while
        #
        # echo "Pruning borg repo."
        # borg prune \
        #         --list \
        #         --prefix '{hostname}-world-' \
        #         --show-rc \
        #         --keep-daily 7 \
        #         --keep-weekly 4 \
        #         --keep-monthly 6
        # prune_exit=$?
else
        if [[ ${zfs_exit} -eq 1 ]]; then
                echo "zfs-snapshot reported an error; Snapshot creation failed."

                # # Just match prune exit to backup exit for later comparison
                # prune_exit=${backup_exit}
        elif [[ ${zfs_exit} -eq 2 ]]; then
                echo "zfs-snapshot reported an invalid argument; Check configuration."
        fi
fi

# # Use highest exit code as global exit code
# global_exit=$(( backup_exit > prune_exit ? backup_exit : prune_exit ))
# if [[ ${global_exit} -eq 0 ]]; then
#         echo "Backup and Prune finished successfully."
# elif [[ ${global_exit} -eq 1 ]]; then
#         echo "Backup and/or Prune finished with warnings."
# else
#         echo "Backup and/or Prune finished with errors."
# fi

# TODO: Rewrite to be like above sample once a pruning system is in place.
global_exit=${zfs_exit}
if [[ ${global_exit} -eq 0 ]]; then
        echo "Snapshot script finished successfully."
else
        echo "Snapshot script finished with errors!"
fi

exit ${global_exit}
