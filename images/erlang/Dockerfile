# syntax=docker/dockerfile:1

ARG MISE_IMAGE=ghcr.io/groguelon/sandboxes-mise:claude-code-minimal

FROM ${MISE_IMAGE}

LABEL org.opencontainers.image.source=https://github.com/groguelon/sandboxes

ARG ERLANG_VERSION=29.1.1

ENV MISE_ERLANG_PRECOMPILED_OS=ubuntu-26.04 \
    REBAR_BASE_DIR=".sbx/_build"

RUN mise use -g "erlang@${ERLANG_VERSION}"
