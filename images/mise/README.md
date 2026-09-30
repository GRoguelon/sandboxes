# sandboxes-mise

The base of the chain: Docker's `claude-code-minimal` sandbox template with [mise](https://mise.jdx.dev) to install language toolchains.

```sh
sbx run claude --template ghcr.io/groguelon/sandboxes-mise:claude-code-minimal
```

Use it directly when you want to pick your own tools with mise, or as a base for your own images. For Erlang or Elixir, use [sandboxes-erlang](../erlang/README.md) or [sandboxes-elixir](../elixir/README.md) instead.

## Contents

| | |
|---|---|
| Base | `docker/sandbox-templates:claude-code-minimal` (Ubuntu 26.04, Claude Code, git, curl, jq, make, gh…) |
| Packages | `ca-certificates`, `curl`, `direnv`, plus a full `apt-get dist-upgrade` |
| mise | `/home/agent/.local/bin/mise` |

## Environment

| Variable | Value | Why |
|---|---|---|
| `PATH` | prepends `~/.local/bin` and `~/.local/share/mise/shims` | Tools resolve through mise shims, including in the agent's non-interactive shells |
| `LANG`, `LC_ALL` | `C.UTF-8` | UTF-8 locale; Elixir warns without one |
| `TZ` | `Etc/UTC` | |
| `DISABLE_TELEMETRY` | `1` | Opt out of Claude Code telemetry |
| `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC` | `1` | Keep Claude Code's egress to what it needs |

Interactive shells also run `mise activate` and the `direnv` hook from `~/.bashrc`.

## Using mise in the sandbox

```sh
mise use node@lts   # install a tool for the current project
mise install        # install what .tool-versions / mise.toml ask for
mise trust          # required once before mise reads a project's mise.toml
```

## Build arguments

| Argument | Default | |
|---|---|---|
| `BASE_IMAGE` | `docker.io/docker/sandbox-templates:claude-code-minimal` | CI pins it to a digest |
| `MISE_VERSION` | latest release | With or without the leading `v` |

```sh
docker buildx build images/mise --build-arg MISE_VERSION=2026.9.18 -t sandboxes-mise
```

## Tags

- `claude-code-minimal`: latest build
- `<mise>-claude-code-minimal`: e.g. `2026.9.18-claude-code-minimal`

## Kit example: Node.js

A v2 mixin that installs Node.js with mise when the sandbox is created. It takes the version as a kit argument.

`node/spec.yaml`:

```yaml
schemaVersion: "2"
kind: mixin
name: node
displayName: Node.js
description: Installs Node.js with mise
requires:
  agent: claude

args:
  version:
    default: lts
    description: Node.js version, as accepted by mise
    pattern: '^(lts|latest|[0-9]+(\.[0-9]+){0,2})$'

permissions:
  network:
    allow:
      - nodejs.org
      - mise-versions.jdx.dev

setup:
  install:
    - command: "mise use -g node@${{ kit.args.version }}"
      user: "1000"
      description: Install Node.js
```

```sh
sbx run claude --template ghcr.io/groguelon/sandboxes-mise:claude-code-minimal \
  --kit ./node --kit-arg node.version=24
```

`setup.install` runs once, when the sandbox is created, as the `agent` user (`"1000"`); install commands default to root.
