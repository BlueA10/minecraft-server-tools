#!/usr/bin/env bash

set -e

discord_message="\`\`\`$(date -uIseconds): ${*}\`\`\`"

"$(dirname "$(realpath "${0}")")"/discord-webhook-arg.sh "${discord_message}"

exit 0
