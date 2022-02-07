#!/usr/bin/env bash

# zfs-snapshot.sh

# Exit on any errors
#set -e
# Debug (echo each line)
#set -x

# shellcheck source=./common_vars.sh
. "$(dirname "$(realpath "${0}")")/common_vars.sh"
# shellcheck source=./common_functions.sh
. "$(dirname "$(realpath "${0}")")/common_functions.sh"

trap 'echo ZFS snapshot interrupted >&2; exit 3' INT TERM

snapshot_time="$(date --utc +%FT%TZ)" # '%FT%TZ' = 'YYYY-MM-DDTHH:MM:SSZ'
snapshot_name="${server_zfs_dataset}@${snapshot_time}"
zfs snapshot "${snapshot_name}"
zfs_exit=$?

if [[ ${zfs_exit} -eq 0 ]]
then
        snapshot_limit=$(zfs get \
                -Ho value \
                snapshot_limit \
                "${server_zfs_dataset}")
        snapshot_count=$(zfs get \
                -Ho value \
                snapshot_count \
                "${server_zfs_dataset}")

        if [[ "${snapshot_count}" -ge "${snapshot_limit}" ]]
        then
                snapshot_list=( $(zfs list \
                        -Ho name \
                        -s creation \
                        -t snapshot \
                        "${server_zfs_dataset}") )

                if [[ "${snapshot_list[0]}" != "${server_zfs_dataset}" ]]
                then
                        zfs destroy "${snapshot_list[0]}"
                else
                        echo "Snapshot pruning tried to delete base dataset!!!"
                fi
        fi
else
        if [[ ${zfs_exit} -eq 1 ]]; then
                echo "zfs-snapshot reported an error; Snapshot creation failed."
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

global_exit=${zfs_exit}
if [[ ${global_exit} -eq 0 ]]
then
        true
else
        echo "Snapshot script finished with errors!"
fi

exit ${global_exit}
