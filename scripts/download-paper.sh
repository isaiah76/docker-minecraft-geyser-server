#!/usr/bin/env bash

# downloads and auto updates papermc jar
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

API="https://fill.papermc.io/v3"
PROJECT="paper"
JAR_PATH="/data/paper.jar"
VERSION_FILE="/data/.paper_source"

echo "Resolving Paper version (MC_VERSION=${MC_VERSION:-latest})..."

if [ "${MC_VERSION:-latest}" = "latest" ]; then
  echo "Scanning API for the newest version with ${PAPER_CHANNEL:-STABLE} builds..."
  versions=$(curl -fsSL --retry 3 -H "User-Agent: $UA" "$API/projects/$PROJECT" | jq -r '.versions[][]')
  version=""
  for v in $versions; do
    builds_count=$(curl -fsSL --retry 3 -H "User-Agent: $UA" "$API/projects/$PROJECT/versions/$v/builds" | jq -r --arg ch "${PAPER_CHANNEL:-STABLE}" '[.[] | select(.channel == $ch)] | length')
    if [ -n "$builds_count" ] && [ "$builds_count" -gt 0 ]; then
      version="$v"
      echo "Success: Found stable builds for Minecraft $version."
      break
    fi
  done
else
  version="$MC_VERSION"
fi

if [ -z "${version:-}" ] || [ "$version" = "null" ]; then
  echo "ERROR: Could not resolve a Minecraft version from the API that has stable builds." >&2
  exit 1
fi

check_java_compatibility "$version"

builds_json="$(curl -fsSL --retry 3 -H "User-Agent: $UA" "$API/projects/$PROJECT/versions/$version/builds")"
if [ -z "$builds_json" ] || [ "$builds_json" = "[]" ]; then
  echo "ERROR: No Paper builds found for Minecraft version '$version'." >&2
  exit 1
fi

if [ -n "${PAPER_BUILD:-}" ] && [ "${PAPER_BUILD}" != "latest" ]; then
  url=$(printf '%s' "$builds_json" | jq -r --arg b "$PAPER_BUILD" \
    '.[] | select((.id|tostring) == $b) | .downloads."server:default".url // empty')
  if [ -z "$url" ]; then
    echo "ERROR: Paper build '$PAPER_BUILD' not found for Minecraft version '$version'." >&2
    exit 1
  fi
else
  url=$(printf '%s' "$builds_json" | jq -r --arg ch "${PAPER_CHANNEL:-STABLE}" \
    'first(.[] | select(.channel == $ch) | .downloads."server:default".url) // empty')
  if [ -z "$url" ]; then
    echo "ERROR: No build on channel '${PAPER_CHANNEL:-STABLE}' for Minecraft version '$version'." >&2
    exit 1
  fi
fi

cache_key="$version|${PAPER_BUILD:-latest}|${PAPER_CHANNEL:-STABLE}|$url"

if [ -f "$JAR_PATH" ] && [ -f "$VERSION_FILE" ] && [ "$(cat "$VERSION_FILE")" = "$cache_key" ]; then
  echo "Paper $version already downloaded and up to date, skipping."
  exit 0
fi

echo "Downloading Paper $version from $url"
curl -fsSL --retry 3 -H "User-Agent: $UA" -o "$JAR_PATH.tmp" "$url"
mv "$JAR_PATH.tmp" "$JAR_PATH"
printf '%s' "$cache_key" >"$VERSION_FILE"
echo "Paper $version downloaded to $JAR_PATH"
