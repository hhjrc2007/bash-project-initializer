#!/bin/bash

set -euo pipefail

read -rp "Repository name: " repo_name
read -rp "Location (parent directory): " repo_location

repo_path="${repo_location%/}/${repo_name}"

if [[ -e "$repo_path" ]]; then
    echo "Error: $repo_path already exists" >&2
    exit 1
fi

mkdir -p "$repo_path"
git init "$repo_path"

echo "Initialized empty repository at $repo_path"
