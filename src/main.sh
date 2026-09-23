#!/bin/bash

set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
lang_dir="$script_dir/../lang"

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

available_langs=()
for f in "$lang_dir"/*.yaml; do
    available_langs+=("$(basename "$f" .yaml)")
done

echo "Available languages:"
for l in "${available_langs[@]}"; do
    echo "* $l"
done
read -rp "Language: " language

lang_file="$lang_dir/$language.yaml"

if [[ ! -f "$lang_file" ]]; then
    echo "Error: no template for '$language'" >&2
    exit 1
fi

while IFS= read -r dir; do
    mkdir -p "$repo_path/$dir"
done < <(yq -r '.dirs // [] | .[]' "$lang_file")

while IFS= read -r file; do
    mkdir -p "$repo_path/$(dirname "$file")"
    yq -r --arg f "$file" '.files[$f]' "$lang_file" > "$repo_path/$file"
done < <(yq -r '.files // {} | keys[]' "$lang_file")

echo "Generated $language project structure in $repo_path"
