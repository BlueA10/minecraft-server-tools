#!/usr/bin/env bash

# stop.sh
# To be run to stop a currently running minecraft server

# Exit on any errors
set -e

# shellcheck source=./common_functions.sh
. "$(dirname "$(realpath "${0}")")/common_functions.sh"

# Issue server stop command
server_cmd_wait 'stop' 'Closing Thread Pool'

# Clean up
rm -rf "${server_tmp_dir}"

exit 0
