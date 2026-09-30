# sandboxes-elixir

Elixir, Erlang/OTP and Hex in a Docker Sandbox, ready for Mix and Phoenix projects.

```sh
cd my-elixir-project
sbx run claude --template ghcr.io/groguelon/sandboxes-elixir:claude-code-minimal
```

Add `.sbx/` to your project's `.gitignore`.

## Contents

Everything in [sandboxes-erlang](../erlang/README.md), plus:

| | |
|---|---|
| Elixir | Precompiled build for the image's OTP major version, installed globally with mise |
| Hex, rebar3 | Installed for Mix with `mix local.hex` and `mix local.rebar` |
| `inotify-tools` | File watching for Phoenix live reload and tools such as `mix_test_watch` |

## Environment

| Variable | Value | Why |
|---|---|---|
| `MIX_DEPS_PATH` | `.sbx/deps` | Keep the sandbox's dependencies apart from the host's `deps/` |
| `MIX_BUILD_ROOT` | `.sbx/_build` | Keep the sandbox's build output apart from the host's `_build/` |
| `MIX_XDG` | `true` | Mix uses `~/.config` and `~/.local/share` |
| `HEX_HOME` | `~/.local/share/hex` | Hex cache, shared by every project and worktree |
| `MIX_OS_DEPS_COMPILE_PARTITION_COUNT` | half the CPUs | Compile dependencies in parallel; set at shell start from `nproc` |

## Other versions

A project pinning other versions in `.tool-versions` gets them installed by mise on first use. Elixir versions must name the OTP major they were built for:

```sh
printf 'erlang 28.3.1\nelixir 1.19.5-otp-28\n' > .tool-versions
mise install
mix local.hex --force && mix local.rebar --force
```

## Build arguments

| Argument | Default | |
|---|---|---|
| `ERLANG_VERSION` | `29.1.1` | Selects the parent image and the Elixir build's OTP major |
| `ERLANG_IMAGE` | `ghcr.io/groguelon/sandboxes-erlang:${ERLANG_VERSION}-claude-code-minimal` | CI pins it to a digest |
| `ELIXIR_VERSION` | `1.20.4` | Must have a build for the OTP major on [builds.hex.pm](https://builds.hex.pm/builds/elixir/builds.txt) |

```sh
docker buildx build images/elixir --build-arg ELIXIR_VERSION=1.20.4 -t sandboxes-elixir
```

## Tags

- `claude-code-minimal`: latest build
- `<elixir>-claude-code-minimal`: e.g. `1.20.4-claude-code-minimal`
- `<elixir>-erlang-<otp>-claude-code-minimal`: e.g. `1.20.4-erlang-29.1.1-claude-code-minimal`
- `<elixir>-erlang-<otp>-mise-<mise>-claude-code-minimal`: e.g. `1.20.4-erlang-29.1.1-mise-2026.9.18-claude-code-minimal`

## Kit examples

v2 mixins apply directly on top of this template. See [Extending with Kits v2](../../README.md#extending-with-kits-v2) for the kit layout.

### Phoenix dev server

Publishes port 4000 to the host and tells the agent how to serve on it.

`phoenix/spec.yaml`:

```yaml
schemaVersion: "2"
kind: mixin
name: phoenix
displayName: Phoenix
description: Publishes the Phoenix dev server port to the host
requires:
  agent: claude

ports:
  - container: 4000
    name: phoenix

agentInstructions:
  content: |
    Port 4000 is published to the host. Start the server with
    `mix phx.server`. Phoenix listens on 127.0.0.1 by default; set
    `http: [ip: {0, 0, 0, 0}, port: 4000]` in config/dev.exs so the
    host can reach it.
```

`sbx` allocates a random host port on `127.0.0.1`. Pin it with `sbx ports --publish 4000:4000`.

### IEx defaults

Ships an `.iex.exs` into the home directory. Files under `files/home/` are copied to `/home/agent/`, overwriting existing ones.

```text
iex/
├── spec.yaml
└── files/
    └── home/
        └── .iex.exs
```

`iex/spec.yaml`:

```yaml
schemaVersion: "2"
kind: mixin
name: iex
displayName: IEx defaults
description: Larger IEx history and full inspect output
requires:
  agent: claude
```

`iex/files/home/.iex.exs`:

```elixir
IEx.configure(
  history_size: 1_000,
  inspect: [limit: :infinity, pretty: true]
)
```

### Running them

```sh
sbx run claude --template ghcr.io/groguelon/sandboxes-elixir:claude-code-minimal \
  --kit ./phoenix \
  --kit ./iex
```
