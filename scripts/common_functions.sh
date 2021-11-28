# server_functions.sh
# Primarily intended to be sourced by other scripts
# Provides functions to use for communicating with the game server

# Include guard
[[ -n "${MINECRAFT_SERVER_COMMON_FUNCTIONS}" ]] && return

export MINECRAFT_SERVER_COMMON_FUNCTIONS=true

# shellcheck source=./common_vars.sh
. "$(dirname "$(realpath "${0}")")/common_vars.sh"

# Sends argument(s) to server to run as a command
server_cmd() { echo "${@}" >"${server_in_pipe}"; }

# Two args: 1st is command to run, second is string to check for
# Sends the command to the server and then waits for a match to the string to
# appear in the server's output
server_cmd_wait() {
        # Setup named pipe
        local catch_pipe="./catch_pipe"
        mkfifo "${catch_pipe}"

        # Start piping logs to catch_pipe in background
        journalctl --unit=minecraft-server \
                --follow --lines=0 --output=cat --quiet >"${catch_pipe}" &

        # Stores last backgrounded process's PID (journalctl)
        logger_pid=$!

        # Have grep start checking for the string now, and close on first match
        grep -m 1 -E '^\[[[:digit:]]{2}(:[[:digit:]]{2}){2}\] '"${2}" <"${catch_pipe}" &

        # Stores grep's PID
        grep_pid=$!

        # Run passed in command
        server_cmd "${1}"

        # Wait on grep to close
        wait "${grep_pid}"

        # If grep closed, match was found. Start cleaning up
        # Kill journalctl
        kill "${logger_pid}"

        # Delete named pipe
        rm "${catch_pipe}"

        # Done?
        return 0
}
