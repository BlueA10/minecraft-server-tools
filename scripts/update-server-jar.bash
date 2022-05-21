#!/usr/bin/env bash
set -e

version=1.18.2

echo "Checking Paper builds for Minecraft ${version}..."

build=$(curl -X 'GET' \
        'https://papermc.io/api/v2/projects/paper/versions/'"${version}" \
        -H 'accept: application/json' | jq .builds[-1])

echo "Newest build for Minecraft ${version} is ${build}"

echo "Downloading Paper build ${build} for Minecraft ${version}..."

local_jar='/srv/minecraft/paper-server.jar'

curl -X 'GET' \
        'https://papermc.io/api/v2/projects/paper/versions/'"${version}"'/builds/'"${build}"'/downloads/paper-'"${version}"'-'"${build}"'.jar' \
        -H 'accept: application/json' \
        -o "${local_jar}"

echo "Paper server jar updated."
