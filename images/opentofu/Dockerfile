# syntax=docker/dockerfile:1

ARG MISE_IMAGE=ghcr.io/groguelon/sandboxes-mise:claude-code-minimal

FROM ${MISE_IMAGE}

LABEL org.opencontainers.image.source=https://github.com/groguelon/sandboxes

ARG OPENTOFU_VERSION=1.13.0

ENV TF_DATA_DIR=".sbx/tofu" \
    TF_PLUGIN_CACHE_DIR="/home/agent/.cache/opentofu/plugins"

# The optional token only lifts GitHub API rate limits while mise resolves the release.
RUN --mount=type=secret,id=github_token,env=MISE_GITHUB_TOKEN \
    mkdir -p "${TF_PLUGIN_CACHE_DIR}" && \
    mise use -g "opentofu@${OPENTOFU_VERSION}" && \
    tofu version
