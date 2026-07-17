#!/usr/bin/env bash

set -euo pipefail
PORT="${SERVER_PORT:-25565}"

(exec 3<>"/dev/tcp/127.0.0.1/$PORT") 2>/dev/null && exit 0
exit 1
