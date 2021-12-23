#!/usr/bin/env bash

# start.sh
# Starts minecraft server, replacing itself with the server process

# Exit on any errors
set -e

# shellcheck source=./common_vars.sh
. "$(dirname "$(realpath "${0}")")/common_vars.sh"
# shellcheck source=./common_functions.sh
. "$(dirname "$(realpath "${0}")")/common_functions.sh"

echo "Running as user ${USER}"

# Create tmp dir if non-existent
! [[ -d ${server_tmp_dir} ]] && mkdir --parents "${server_tmp_dir}"

# Use max between ~80% available and specified amount
# (72% x 1.1 for 10% overhead is ~80%)
server_mem_auto="$(awk '/MemAvailable/ { printf "%i\n", $2*0.72/1024 }' /proc/meminfo)"
if [[ ${server_mem_auto} -lt ${server_mem_max} ]]; then
        server_mem="${server_mem_auto}"
else
        server_mem="${server_mem_max}"
fi
echo "Using ${server_mem}M memory for server."

# Append appropriate memory args for java to server_args array
server_args+=("-Xms${server_mem}M" "-Xmx${server_mem}M")

echo "Checking for named pipe at ${server_in_pipe} and creating if neccesary."
if ! [[ -p ${server_in_pipe} ]]; then
        [[ -e ${server_in_pipe} ]] && rm "${server_in_pipe}"
        mkfifo "${server_in_pipe}"
fi

echo "Launching server jar..."
bash -c "cd ${server_dir} && \
        tail -f --pid="'$$'" ${server_in_pipe} | \
        exec java \
                ${server_args[*]} \
                -jar ${server_jar} --nogui" &
# In case I think of a use for this later
server_pid=$!

# While server is starting, monitor for it to complete startup
server_cmd_wait 'say Server is up.' '\[Server\] Server is up\.'
systemd-notify --ready --status="Minecraft server is up" --pid="${server_pid}"
disown "${server_pid}"

exit
