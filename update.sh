#!/usr/bin/env bash
set -euo pipefail

upstream_repo="SimoHypers/limusic"
release_api="https://api.github.com/repos/${upstream_repo}/releases/latest"
asset_name=""

api_headers=(
  -H "Accept: application/vnd.github+json"
  -H "X-GitHub-Api-Version: 2022-11-28"
)
if [[ -n "${GITHUB_TOKEN:-}" ]]; then
  api_headers+=( -H "Authorization: Bearer ${GITHUB_TOKEN}" )
fi

release_json="$(curl -fsSL "${api_headers[@]}" "$release_api")"
tag="$(jq -er '.tag_name' <<<"$release_json")"
version="${tag#v}"
asset_name="limusic_${version}_amd64.AppImage"

asset_url="$(
  jq -er --arg asset "$asset_name" \
    '.assets[] | select(.name == $asset) | .browser_download_url' \
    <<<"$release_json"
)"

digest="$(
  jq -r --arg asset "$asset_name" \
    '.assets[] | select(.name == $asset) | .digest // empty' \
    <<<"$release_json"
)"
digest="${digest#sha256:}"

if [[ -z "$digest" ]]; then
  temp_dir="$(mktemp -d)"
  trap 'rm -rf "$temp_dir"' EXIT
  curl -fsSL "$asset_url" -o "$temp_dir/$asset_name"
  digest="$(sha256sum "$temp_dir/$asset_name" | awk '{ print $1 }')"
fi

sri_hash="$(nix hash convert --hash-algo sha256 --to sri "$digest")"

sed -i -E "s/version = \"[^\"]+\";/version = \"${version}\";/" package.nix
sed -i -E 's|hash = "sha256-[^"]+";|hash = "REPLACE_HASH";|' package.nix
sed -i "s|REPLACE_HASH|$sri_hash|" package.nix

printf '%s\n' "$version"
