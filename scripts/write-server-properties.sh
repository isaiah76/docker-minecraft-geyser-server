#!/usr/bin/env bash

# writes server.properties from env
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

PROPS="/data/server.properties"

if [ -f "$PROPS" ]; then
  echo "server.properties already exists, leaving it as is."
  exit 0
fi

echo "Writing initial server.properties..."

cat >"$PROPS" <<EOF
server-port=${SERVER_PORT:-25565}
motd=${MOTD:-A Paper Server with Geyser}
difficulty=${DIFFICULTY:-normal}
gamemode=${GAMEMODE:-survival}
max-players=${MAX_PLAYERS:-20}
online-mode=${ONLINE_MODE:-true}
white-list=${WHITE_LIST:-false}
pvp=${PVP:-true}
allow-flight=${ALLOW_FLIGHT:-false}
view-distance=${VIEW_DISTANCE:-10}
simulation-distance=${SIMULATION_DISTANCE:-10}
level-seed=${LEVEL_SEED:-}
level-name=${LEVEL_NAME:-world}
level-type=${LEVEL_TYPE:-minecraft\:normal}
spawn-protection=${SPAWN_PROTECTION:-0}
enable-rcon=${ENABLE_RCON:-false}
rcon.port=${RCON_PORT:-25575}
rcon.password=${RCON_PASSWORD:-}
enable-command-block=${ENABLE_COMMAND_BLOCK:-false}
EOF

echo "server.properties written."
