#!/usr/bin/env bash

# start.sh
# Starts minecraft server, replacing itself with the server process

# Exit on any errors
set -e

# shellcheck source=./common_vars.sh
. "$(dirname "$(realpath "${0}")")/common_vars.sh"
# shellcheck source=./common_functions.sh
. "$(dirname "$(realpath "${0}")")/common_functions.sh"

# Use max between 80% available and specified amount
server_mem_auto="$(awk '/MemAvailable/ { printf "%i\n", $2*0.8/1024 }' /proc/meminfo)"
if [[ ${server_mem_auto} -lt ${server_mem_max} ]]; then
        server_mem="${server_mem_auto}"
else
        server_mem="${server_mem_max}"
fi
echo "Using ${server_mem}M memory for server."

echo "Checking for named pipe at ${server_in_pipe} and creating if neccesary."
if ! [[ -p ${server_in_pipe} ]]; then
        [[ -e ${server_in_pipe} ]] && rm "${server_in_pipe}"
        mkfifo "${server_in_pipe}"
fi

echo "Launching server jar..."
bash -c \
        "cd ${server_dir} && \
                tail -f --pid="'$$'" ${server_in_pipe} | \
                exec java \
                        -Xms${server_mem}M \
                        -Xmx${server_mem}M \
                        ${server_args[*]} \
                        -jar ${server_jar} --nogui"
java_exit=$?

echo "Server jar has exited."
echo "Cleaning up named pipe file."
rm "${server_in_pipe}"

exit ${java_exit}
