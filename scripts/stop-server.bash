#!/usr/bin/env bash

# stop-server.bash
# To be run to stop a currently running minecraft server

# Exit on any errors
set -e

# shellcheck source=./common_functions.bash
. "$(dirname "$(realpath "${0}")")/common_functions.bash"

# Issue server stop command
server_cmd_wait 'stop' 'Closing Thread Pool'

# Clean up
# Using systemd which handles the temp dir
#rm -rf "${server_tmp_dir}"

exit 0
