# syntax=docker/dockerfile:1

ARG JAVA_VERSION=25
FROM eclipse-temurin:${JAVA_VERSION}-jre-jammy

ARG JAVA_VERSION=25
ENV IMAGE_JAVA_VERSION=${JAVA_VERSION}

LABEL org.opencontainers.image.title="minecraft-server" org.opencontainers.image.description="PaperMC server with Aikar's flags, Geyser, Floodgate, Hurricane and GeyserSkinManager downloaded at container start."

RUN apt-get update && apt-get install -y --no-install-recommends curl jq ca-certificates gosu tini && rm -rf /var/lib/apt/lists/*

RUN groupadd -g 1000 minecraft && useradd -u 1000 -g 1000 -m -d /home/minecraft -s /usr/sbin/nologin minecraft

WORKDIR /data
RUN chown -R minecraft:minecraft /data

COPY --chmod=755 scripts/*.sh /usr/local/bin/

VOLUME ["/data"]

EXPOSE 25565/tcp 19132/udp

HEALTHCHECK --interval=30s --timeout=5s --start-period=120s --retries=5 CMD /usr/local/bin/healthcheck.sh

ENTRYPOINT ["/usr/bin/tini", "--", "/usr/local/bin/entrypoint.sh"]
