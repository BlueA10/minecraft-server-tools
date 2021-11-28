#!/usr/bin/env bash

set -e

webhook_url_src="./webhook_url"

curl \
        -H "Content-Type: application/json" \
        -d '{"username": "'"${USER}@${HOSTNAME}"'", "content": "'"${*}"'"}' \
        "$(< webhook_url)"

exit 0
