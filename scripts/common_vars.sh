# vars.sh
# Common variables for server scripts
# Generally shouldn't be run directly

# Env vars that can be inherited and used instead:
#         MC_SERVER_DIR            - Server files directory
#         MC_SERVER_TMP_DIR        - Server temp files like pipes
#         MC_SERVER_IN_PIPE        - Filepath for server input pipe
#         MC_SERVER_BACKUP_DIR     - Backups directory
#         MC_SERVER_JAR            - Server jar filename
#         MC_SERVER_MEM_MAX        - Max mem to allocate, in MiB
#         MC_SERVER_BORG_PASS_SRC  - Borg backup repo source
#                 For now this is expected to be a file containing only the
#                 passphrase text.
#         MC_SERVER_ARGS           - (Array) Server jar arguments

# Include guard
[[ -n "${MC_SERVER_COMMON_VARS}" ]] && return

export MINECRAFT_SERVER_COMMON_VARS=true

export server_zfs_dataset="rpool/srv/minecraft"
export server_dir="${MC_SERVER_DIR:-/srv/minecraft}"
export server_tmp_dir="${MC_SERVER_TMP_DIR:-/tmp/minecraft}"
# export server_backup_dir="${MC_SERVER_BACKUP_DIR:-${server_dir}/backup}"
export server_backup_dir="${MC_SERVER_BACKUP_DIR:-/tank/netshare/Backups/minecraft/java/apartment_server}"
export server_jar="${MC_SERVER_JAR:-${server_dir}/paper-server.jar}"
export server_mem_max="${MC_SERVER_MEM_MAX:-10240}" # 10GiB good start
export server_in_pipe="${MC_SERVER_IN_PIPE:-${server_tmp_dir}/in_pipe}"
export server_borg_pass_src="${MC_SERVER_BORG_PASS_SRC:-${server_dir}/.borg_pass}"

export server_args="${MC_SERVER_ARGS}"
if [[ -z ${server_args} ]]; then
        export server_args=( \
                '-XX:+UseG1GC' \
                '-XX:+ParallelRefProcEnabled' \
                '-XX:MaxGCPauseMillis=200' \
                '-XX:+UnlockExperimentalVMOptions' \
                '-XX:+DisableExplicitGC' \
                '-XX:+AlwaysPreTouch' \
                '-XX:G1NewSizePercent=30' \
                '-XX:G1MaxNewSizePercent=40' \
                '-XX:G1HeapRegionSize=8M' \
                '-XX:G1ReservePercent=20' \
                '-XX:G1HeapWastePercent=5' \
                '-XX:G1MixedGCCountTarget=4' \
                '-XX:InitiatingHeapOccupancyPercent=15' \
                '-XX:G1MixedGCLiveThresholdPercent=90' \
                '-XX:G1RSetUpdatingPauseTimePercent=5' \
                '-XX:SurvivorRatio=32' \
                '-XX:+PerfDisableSharedMem' \
                '-XX:MaxTenuringThreshold=1' \
                '-Dusing.aikars.flags=https://mcflags.emc.gs' \
                '-Daikars.new.flags=true' \
        )
fi
