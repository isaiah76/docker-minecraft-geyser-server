# Minecraft PaperMC Geyser Floodgate Docker Server

Easily setup your own self contained Docker image Minecraft server built for both AMD64 and ARM64.
Includes PaperMC, Geyser + Floodgate, Hurricane, and GeyserSkinManager

## Docker Usage

```bash
docker run -d --name minecraft-server -p 25565:25565 -p 19132:19132/udp -v ./data:/data -e EULA=true -e MEMORY=4G minecraft-server
```

Build it first if you haven't:

```bash
docker build -t minecraft-server .
```

Or with Compose (recommended):

Requires `.env`

```bash
cp .env.example .env
```

Build and start the server

```bash
docker compose up -d
```

Check the logs (optional)

```bash
docker compose logs -f
```

## Choosing a Minecraft version

Set your `MC_VERSION` in the `.env`

```bash
MC_VERSION=latest      # default: whatever Paper's newest stable version is
MC_VERSION=1.21.10     # or to a specific release
```

Note: Different Minecraft versions require different minimum Java versions (Java 16 for 1.17, 17 for 1.18+, 21 for 1.20.5+, and 25 for the current 26.x line)

**Want an image with an older Minecraft version?**

```bash
docker build --build-arg JAVA_VERSION=21 -t minecraft-server:java21 .
```

With compose set `JAVA_VERSION` in `.env` instead, then rebuild:

```bash
# in .env: JAVA_VERSION=21
docker compose up -d --build
```

## Multi-arch build (amd64 + arm64)

```bash
docker buildx create --use --name minecraft-server-builder 2>/dev/null || true
docker buildx build --platform linux/amd64,linux/arm64 -t your-dockerhub-user/minecraft-server:latest --push .
```

## Ports

| Port  | Protocol |                                      |
| ----- | -------- | ------------------------------------ |
| 25565 | TCP      | Java Edition clients                 |
| 19132 | UDP      | Bedrock Edition clients (via Geyser) |
| 25575 | TCP      | RCON (only if `ENABLE_RCON=true`)    |

Forward the matching ports on your router/firewall if you want either player base connecting from outside your LAN.

## Environment variables

See [`.env.example`](./.env.example) for the full list:

- **`MEMORY`** — default `4G`. Sets `-Xms`/`-Xmx` per Aikar's flags. Leave ~1-1.5GB headroom below your container's memory limit.
- **`MC_VERSION`** — default `latest`. Or a specific version
- **`PAPER_BUILD`** — default `latest`. Or a specific Paper build
- **`FORCE_UPDATE`** — default `false`. Redownloads Paper + all plugins next start
- **`GEYSER_ENABLED`** / **`FLOODGATE_ENABLED`** / **`HURRICANE_ENABLED`** / **`SKIN_MANAGER_ENABLED`** — default `true`, set to `false` if not needed.
- **`PUID`** / **`PGID`** — default `1000` / `1000`. UID/GID that owns the container, match your host user

`server.properties` variables (`SERVER_PORT`, `MOTD`, `DIFFICULTY`, `GAMEMODE`, `MAX_PLAYERS`, `ONLINE_MODE`, `WHITE_LIST`, `PVP`, `VIEW_DISTANCE`, etc.) are only applied **on first run**, once `server.properties` exists, edit it directly.

## Console access

```bash
docker attach minecraft-server     # ctrl+p then ctrl+q to detach without stopping the server
```

Or enable RCON (`ENABLE_RCON=true`, set `RCON_PASSWORD`) and use any RCON client/`mcrcon`.
