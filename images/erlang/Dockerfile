# syntax=docker/dockerfile:1

ARG MISE_IMAGE=ghcr.io/groguelon/sandboxes-mise:claude-code-minimal

FROM ${MISE_IMAGE}

LABEL org.opencontainers.image.source=https://github.com/groguelon/sandboxes

ARG DEBIAN_FRONTEND=noninteractive

USER root

# Toolchain to build NIFs and git dependencies, plus the libraries the precompiled OTP links against.
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      autoconf automake build-essential git libtool \
      libssl3t64 libncurses6 libstdc++6 && \
    rm -rf /var/lib/apt/lists/*

USER agent

ARG ERLANG_VERSION=29.1.1

ENV MISE_ERLANG_PRECOMPILED_OS=ubuntu-26.04 \
    REBAR_BASE_DIR=".sbx/_build"

RUN mise use -g "erlang@${ERLANG_VERSION}"

ARG REBAR3_VERSION=3.27.1

RUN curl -fsSL "https://github.com/erlang/rebar3/releases/download/${REBAR3_VERSION}/rebar3" \
      -o /home/agent/.local/bin/rebar3 && \
    chmod 0755 /home/agent/.local/bin/rebar3 && \
    rebar3 version
