# syntax=docker/dockerfile:1

FROM alpine:3.20.2

LABEL MAINTAINER=engbadr@outlook.com

ENV DUID=1001 \
    DGID=1001 \
    DUSER="ssh-user" \
    DGROUP="ssh-user" \
    DHOME="/home/ssh-user" \
    SSH_PORT=2222

ENV SSH_HOST_KEY_DIR="${DHOME}/.ssh/ssh_host_keys" \
    SSH_AUTH_SOCK="${DHOME}/.ssh/ssh-agent.sock" \
    SSH_PRIVATE_KEYS_DIR="${DHOME}/.ssh/private" \
    LC_ALL="en_US.UTF-8" \
    LANG="en_US.UTF-8" \
    LANGUAGE="en_US.UTF-8" \
    S6_STAGE2_HOOK="/init-hook"

RUN apk update && \
    apk add \
      s6-overlay \
      tzdata musl-locales nano shadow \
      openssh \
      gnupg \
      pass \
      inotify-tools

# Copy S6 configurations
COPY --chmod=755 root/ /

# Create SSH user
RUN addgroup -g ${DGID} ${DGROUP} && \
    adduser -D -h ${DHOME} -G ${DGROUP} -u ${DUID} -s /bin/bash ${DUSER}

EXPOSE ${SSH_PORT:-2222}

# if openssh server is disabled, healthcheck will always fail
HEALTHCHECK --start-period=10s \
            --start-interval=10s \
            --interval=60s \
            CMD \
            nc -z localhost ${SSH_PORT:-2222}

ENTRYPOINT ["/init"]
