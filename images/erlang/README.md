# sandboxes-erlang

Erlang/OTP and rebar3 in a Docker Sandbox, with the toolchain to build NIFs.

```sh
cd my-erlang-project
sbx run claude --template ghcr.io/groguelon/sandboxes-erlang:claude-code-minimal
```

Add `.sbx/` to your project's `.gitignore`.

## Contents

Everything in [sandboxes-mise](../mise/README.md), plus:

| | |
|---|---|
| Erlang/OTP | Precompiled Ubuntu 26.04 build from [builds.hex.pm](https://builds.hex.pm), installed globally with mise |
| rebar3 | Official release, `/home/agent/.local/bin/rebar3` |
| Build tools | `build-essential`, `autoconf`, `automake`, `libtool`, `git` |
| Runtime libraries | `libssl3t64` (`crypto`, `ssl`), `libncurses6`, `libstdc++6` |

Not included: `libodbc2` (the `odbc` application), `libsctp1` (`gen_sctp`), Rust (Rustler NIFs). Install them with `apt-get` or mise if a project needs them.

## Environment

| Variable | Value | Why |
|---|---|---|
| `MISE_ERLANG_PRECOMPILED_OS` | `ubuntu-26.04` | Install precompiled OTP instead of compiling from source |
| `REBAR_BASE_DIR` | `.sbx/_build` | Keep the sandbox's build output apart from the host's `_build/` |

rebar3's package cache and global config stay in the home directory, shared by every project and worktree. erlang.mk projects keep their defaults (`deps/` and `.erlang.mk/` in the project).

## Other OTP versions

The image ships one global OTP. A project pinning another one in `.tool-versions` gets it installed by mise on first use:

```sh
echo "erlang 28.3.1" > .tool-versions
mise install
```

## Build arguments

| Argument | Default | |
|---|---|---|
| `MISE_IMAGE` | `ghcr.io/groguelon/sandboxes-mise:claude-code-minimal` | CI pins it to a digest |
| `ERLANG_VERSION` | `29.1.1` | Must have a precompiled Ubuntu 26.04 build |
| `REBAR3_VERSION` | `3.27.1` | A tag of [erlang/rebar3](https://github.com/erlang/rebar3/releases) |

```sh
docker buildx build images/erlang --build-arg ERLANG_VERSION=29.1.1 -t sandboxes-erlang
```

## Tags

- `claude-code-minimal`: latest build
- `<otp>-claude-code-minimal`: e.g. `29.1.1-claude-code-minimal`
- `<otp>-mise-<mise>-claude-code-minimal`: e.g. `29.1.1-mise-2026.9.18-claude-code-minimal`

## Kits

v2 mixins apply directly on top of this template:

```sh
sbx run claude --template ghcr.io/groguelon/sandboxes-erlang:claude-code-minimal --kit ./my-kit
```

See [Extending with Kits v2](../../README.md#extending-with-kits-v2) for the kit layout and a mixin granting Hex and GitHub access, which rebar3 needs for dependencies and plugins.
