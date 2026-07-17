#!/usr/bin/env bash

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

PUID="${PUID:-1000}"
PGID="${PGID:-1000}"

# root only
if [ "$(id -u)" = "0" ]; then
  if [ "$(id -u minecraft)" != "$PUID" ] || [ "$(id -g minecraft)" != "$PGID" ]; then
    echo "Aligning 'minecraft' user to PUID=$PUID PGID=$PGID..."
    groupmod -o -g "$PGID" minecraft
    usermod -o -u "$PUID" minecraft
  fi
  chown minecraft:minecraft /data
  echo "Dropping from root to minecraft (uid=$PUID gid=$PGID)..."
  exec gosu minecraft:minecraft "$0" "$@"
fi

cd /data

if [[ ! "${EULA:-false}" =~ ^([tT][rR][uU][eE]|[yY][eE][sS]|1)$ ]]; then
  echo "ERROR: You must accept the Minecraft EULA (https://aka.ms/MinecraftEULA) by setting -e EULA=true." >&2
  exit 1
fi
echo "eula=true" >/data/eula.txt

"$SCRIPT_DIR/write-server-properties.sh"
"$SCRIPT_DIR/download-paper.sh"
"$SCRIPT_DIR/download-plugins.sh"
mapfile -t JVM_FLAGS < <("$SCRIPT_DIR/aikar-flags.sh")

if [ -n "${EXTRA_JAVA_ARGS:-}" ]; then
  EXTRA=(${EXTRA_JAVA_ARGS})
  JVM_FLAGS+=("${EXTRA[@]}")
fi

echo "Starting Paper with ${MEMORY:-4G} heap (Aikar's flags)..."
echo "Java: $(java -version 2>&1 | head -n1)"

exec java "${JVM_FLAGS[@]}" -jar /data/paper.jar --nogui
