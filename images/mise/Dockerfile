# syntax=docker/dockerfile:1

ARG BASE_IMAGE=docker.io/docker/sandbox-templates:claude-code-minimal

FROM ${BASE_IMAGE}

LABEL org.opencontainers.image.source=https://github.com/groguelon/sandboxes

ARG DEBIAN_FRONTEND=noninteractive

ENV LANG=C.UTF-8 LC_ALL=C.UTF-8 TZ=Etc/UTC \
    PATH="/home/agent/.local/bin:/home/agent/.local/share/mise/shims:${PATH}"

USER root

RUN apt-get update && apt-get dist-upgrade -y && \
    apt-get install -y --no-install-recommends \
      build-essential curl ca-certificates direnv git unzip \
      libssl3t64 libncurses6 libstdc++6 zlib1g && \
    rm -rf /var/lib/apt/lists/* && \
    printf '%s\n' 'eval "$(mise activate bash)"' 'eval "$(direnv hook bash)"' >> /home/agent/.bashrc

ARG MISE_VERSION

RUN mise_version="${MISE_VERSION:-$(curl -fsSL https://mise.jdx.dev/VERSION)}" && \
    curl -fsSL https://mise.run -o /tmp/mise-install.sh && \
    MISE_VERSION="v${mise_version#v}" MISE_INSTALL_PATH=/home/agent/.local/bin/mise sh /tmp/mise-install.sh && \
    rm /tmp/mise-install.sh && \
    chown -R agent:agent /home/agent/.local

USER agent
