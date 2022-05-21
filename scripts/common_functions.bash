#!/usr/bin/env bash
# server_functions.bash
# Primarily intended to be sourced by other scripts
# Provides functions to use for communicating with the game server

# Include guard
[[ -n "${MINECRAFT_SERVER_COMMON_FUNCTIONS}" ]] && return
MINECRAFT_SERVER_COMMON_FUNCTIONS=true

# shellcheck source=./common_vars.bash
. "$(dirname "$(realpath "${0}")")/common_vars.bash"

# Sends argument(s) to server to run as a command
server_cmd() { echo "${@}" >"${server_in_pipe}"; }

# Two args: 1st is command to run, second is string to check for
# Sends the command to the server and then waits for a match to the string to
# appear in the server's output
server_cmd_wait() {
        local catch_pipe="${server_tmp_dir}/catch_pipe-$$"
        [[ -e ${catch_pipe} ]] && rm -f "${catch_pipe}"
        mkfifo "${catch_pipe}"

        #journalctl --unit=minecraft-server \
        #        --follow --lines=0 --output=cat --quiet >"${catch_pipe}" &
        tail -F -n 0 "${server_dir}/logs/latest.log" >"${catch_pipe}" &

        logger_pid=$!

        # Have grep start checking for the string now, and close on first match
        grep -m 1 -E '^\[.*\]: '"${2}" <"${catch_pipe}" &

        grep_pid=$!

        server_cmd "${1}"

        wait "${grep_pid}"

        # If grep closed, match was found. Start cleaning up
        kill "${logger_pid}"

        rm "${catch_pipe}"

        return 0
}
