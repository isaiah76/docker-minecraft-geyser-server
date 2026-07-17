#!/usr/bin/env bash

# downloads geyser-spigot, floodgate, hurricane and geyser skin manager
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

PLUGIN_DIR="/data/plugins"
GEYSER_API="https://download.geysermc.org/v2/projects"
mkdir -p "$PLUGIN_DIR"

if [[ "${GEYSER_ENABLED:-true}" =~ ^([tT][rR][uU][eE]|[yY][eE][sS]|1)$ ]]; then
  if [ ! -f "$PLUGIN_DIR/Geyser-Spigot.jar" ]; then
    echo "Downloading Geyser-Spigot.jar..."
    curl -fsSL --retry 3 -H "User-Agent: $UA" -o "$PLUGIN_DIR/Geyser-Spigot.jar.tmp" "$GEYSER_API/geyser/versions/latest/builds/latest/downloads/spigot"
    mv "$PLUGIN_DIR/Geyser-Spigot.jar.tmp" "$PLUGIN_DIR/Geyser-Spigot.jar"
    echo "Geyser-Spigot.jar installed."
  else
    echo "Geyser-Spigot.jar already present, skipping (delete it and restart to pull the latest build)."
  fi
else
  echo "GEYSER_ENABLED is false, skipping Geyser."
fi

if [[ "${FLOODGATE_ENABLED:-true}" =~ ^([tT][rR][uU][eE]|[yY][eE][sS]|1)$ ]]; then
  if [ ! -f "$PLUGIN_DIR/floodgate-spigot.jar" ]; then
    echo "Downloading floodgate-spigot.jar..."
    curl -fsSL --retry 3 -H "User-Agent: $UA" -o "$PLUGIN_DIR/floodgate-spigot.jar.tmp" "$GEYSER_API/floodgate/versions/latest/builds/latest/downloads/spigot"
    mv "$PLUGIN_DIR/floodgate-spigot.jar.tmp" "$PLUGIN_DIR/floodgate-spigot.jar"
    echo "floodgate-spigot.jar installed."
  else
    echo "floodgate-spigot.jar already present, skipping."
  fi
else
  echo "FLOODGATE_ENABLED is false, skipping Floodgate."
fi

if [[ "${HURRICANE_ENABLED:-true}" =~ ^([tT][rR][uU][eE]|[yY][eE][sS]|1)$ ]]; then
  if [ ! -f "$PLUGIN_DIR/Hurricane.jar" ]; then
    echo "Downloading Hurricane.jar..."
    if curl -fsSL --retry 3 -H "User-Agent: $UA" -o "$PLUGIN_DIR/Hurricane.jar.tmp" "$GEYSER_API/hurricane/versions/latest/builds/latest/downloads/spigot"; then
      mv "$PLUGIN_DIR/Hurricane.jar.tmp" "$PLUGIN_DIR/Hurricane.jar"
      echo "Hurricane.jar installed."
    else
      echo "WARN: GeyserMC downloads API had no build for Hurricane, falling back to GitHub releases." >&2
      rm -f "$PLUGIN_DIR/Hurricane.jar.tmp"

      url=$(curl -fsSL --retry 3 -H "User-Agent: $UA" -H "Accept: application/vnd.github+json" "https://api.github.com/repos/GeyserMC/Hurricane/releases/latest" | jq -r '.assets[] | select(.name | test("\\.jar$"; "i")) | .browser_download_url' | head -n1)
      if [ -n "$url" ] && [ "$url" != "null" ]; then
        curl -fsSL --retry 3 -H "User-Agent: $UA" -o "$PLUGIN_DIR/Hurricane.jar.tmp" "$url"
        mv "$PLUGIN_DIR/Hurricane.jar.tmp" "$PLUGIN_DIR/Hurricane.jar"
        echo "Hurricane.jar installed."
      else
        echo "WARN: Could not find a release asset in GeyserMC/Hurricane. Skipping." >&2
      fi
    fi
  else
    echo "Hurricane.jar already present, skipping."
  fi
else
  echo "HURRICANE_ENABLED is false, skipping Hurricane."
fi

if [[ "${SKIN_MANAGER_ENABLED:-true}" =~ ^([tT][rR][uU][eE]|[yY][eE][sS]|1)$ ]]; then
  if [ ! -f "$PLUGIN_DIR/GeyserSkinManager-Spigot.jar" ]; then
    echo "Downloading GeyserSkinManager-Spigot.jar..."
    url=$(curl -fsSL --retry 3 -H "User-Agent: $UA" -H "Accept: application/vnd.github+json" "https://api.github.com/repos/Camotoy/GeyserSkinManager/releases/latest" | jq -r '.assets[] | select(.name | test("spigot.*\\.jar$"; "i")) | .browser_download_url' | head -n1)

    if [ -n "$url" ] && [ "$url" != "null" ]; then
      curl -fsSL --retry 3 -H "User-Agent: $UA" -o "$PLUGIN_DIR/GeyserSkinManager-Spigot.jar.tmp" "$url"
      mv "$PLUGIN_DIR/GeyserSkinManager-Spigot.jar.tmp" "$PLUGIN_DIR/GeyserSkinManager-Spigot.jar"
      echo "GeyserSkinManager-Spigot.jar installed."
    else
      echo "WARN: Could not find a release asset in Camotoy/GeyserSkinManager. Skipping." >&2
    fi
  else
    echo "GeyserSkinManager-Spigot.jar already present, skipping."
  fi
else
  echo "SKIN_MANAGER_ENABLED is false, skipping GeyserSkinManager."
fi
