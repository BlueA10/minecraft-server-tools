#!/usr/bin/env bash

set -e

webhook_url_src="$(dirname "$(realpath "${0}")")/.webhook_url"

curl \
        -H "Content-Type: application/json" \
        -d '{"username": "'"${USER}@${HOSTNAME}"'", "content": "'"${*}"'"}' \
        "$(< webhook_url_src)"

exit 0
