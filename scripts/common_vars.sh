# vars.sh
# Common variables for server scripts
# Generally shouldn't be run directly

# Env vars that can be inherited and used instead:
#         MINECRAFT_SERVER_DIR            - Server files directory
#         MINECRAFT_SERVER_BACKUP_DIR     - Backups directory
#         MINECRAFT_SERVER_JAR            - Server jar filename
#         MINECRAFT_SERVER_MEM_MAX        - Max mem to allocate, in MiB
#         MINECRAFT_SERVER_IN_PIPE        - Directory for server input pipe
#         MINECRAFT_SERVER_BORG_PASS_SRC  - Borg backup repo source
#                 For now this is expected to be a file containing only the
#                 passphrase text.
#         MINECRAFT_SERVER_ARGS           - (Array) Server jar arguments

# Include guard
[[ -n "${MINECRAFT_SERVER_COMMON_VARS}" ]] && return

export MINECRAFT_SERVER_COMMON_VARS=true

server_dir="${MINECRAFT_SERVER_DIR:-/srv/minecraft}"
server_backup_dir="${MINECRAFT_SERVER_BACKUP_DIR:-${server_dir}/backup}"
server_jar="${MINECRAFT_SERVER_JAR:-${server_dir}/fabric-server-launch.jar}"
server_mem_max="${MINECRAFT_SERVER_MEM_MAX:-12288}" # 12GiB good max for me
server_in_pipe="${MINECRAFT_SERVER_IN_PIPE:-/tmp/minecraft_server_in}"
server_borg_pass_src="${MINECRAFT_SERVER_BORG_PASS_SRC:-${server_dir}/borg_pass}"

server_args="${MINECRAFT_SERVER_ARGS}"
if [[ -z ${server_args} ]]; then
        server_args=( \
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
