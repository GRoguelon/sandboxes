# syntax=docker/dockerfile:1

ARG ERLANG_VERSION=29.1.1
ARG ERLANG_IMAGE=ghcr.io/groguelon/sandboxes-erlang:${ERLANG_VERSION}-claude-code-minimal

FROM ${ERLANG_IMAGE}

LABEL org.opencontainers.image.source=https://github.com/groguelon/sandboxes

ARG ERLANG_VERSION
ARG ELIXIR_VERSION=1.20.4

ENV MIX_XDG=true \
    HEX_HOME="/home/agent/.local/share/hex" \
    MIX_DEPS_PATH=".sbx/deps" \
    MIX_BUILD_ROOT=".sbx/_build"

USER root

RUN apt-get update && apt-get install -y --no-install-recommends inotify-tools && \
    rm -rf /var/lib/apt/lists/* && \
    echo 'export MIX_OS_DEPS_COMPILE_PARTITION_COUNT=$(( $(nproc) / 2 ))' >> /etc/sandbox-persistent.sh

USER agent

RUN mise use -g "elixir@${ELIXIR_VERSION}-otp-${ERLANG_VERSION%%.*}" && \
    mix local.hex --force && mix local.rebar --force
