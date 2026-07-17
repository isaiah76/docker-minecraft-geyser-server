#!/usr/bin/env bash

UA="minecraft-server/1.0 (+https://github.com/your-org/minecraft-server)"

JAVA_REQUIREMENTS='
0.0 16
1.18 17
1.20.5 21
26.0 25
'

version_gte() {
  [ "$1" = "$2" ] && return 0
  [ "$(printf '%s\n%s\n' "$2" "$1" | sort -V | tail -n1)" = "$1" ]
}

required_java_for_mc_version() {
  local mc_version="$1" line ver req result=16
  while read -r line; do
    [ -z "$line" ] && continue
    ver="${line%% *}"
    req="${line##* }"
    if version_gte "$mc_version" "$ver"; then
      result="$req"
    fi
  done <<<"$JAVA_REQUIREMENTS"
  printf '%s' "$result"
}

running_java_major() {
  local raw major
  raw=$(java -version 2>&1 | head -n1 | grep -oE '"[0-9]+(\.[0-9]+)?' | tr -d '"')
  major="${raw%%.*}"
  if [ "$major" = "1" ]; then
    major="${raw#*.}"
  fi
  printf '%s' "$major"
}

check_java_compatibility() {
  local mc_version="$1" required running
  required=$(required_java_for_mc_version "$mc_version")
  running=$(running_java_major)

  if [ -z "$running" ] || [ "$running" -lt "$required" ]; then
    echo "ERROR: Minecraft $mc_version needs Java $required+, but this image was built with Java ${running:-unknown}. Rebuild with: docker build --build-arg JAVA_VERSION=$required" >&2
    exit 1
  fi
  echo "Java compatibility OK: Minecraft $mc_version needs Java $required+, running Java $running."
}
