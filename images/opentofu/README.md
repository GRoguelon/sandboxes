# sandboxes-opentofu

[OpenTofu](https://opentofu.org) in a Docker Sandbox, for infrastructure-as-code work with Claude Code.

```sh
cd my-infrastructure
sbx run claude --template ghcr.io/groguelon/sandboxes-opentofu:claude-code-minimal
```

Add `.sbx/` to your project's `.gitignore`.

## Contents

Everything in [sandboxes-mise](../mise/README.md), plus:

| | |
|---|---|
| OpenTofu | `tofu`, installed globally with mise from the official release |

## Environment

| Variable | Value | Why |
|---|---|---|
| `TF_DATA_DIR` | `.sbx/tofu` | Keep the sandbox's working data (providers, modules, backend settings) apart from the host's `.terraform/` |
| `TF_PLUGIN_CACHE_DIR` | `~/.cache/opentofu/plugins` | Download each provider once, shared by every project and worktree |

Because of `TF_DATA_DIR`, run `tofu init` once in the sandbox even if the project is already initialized on the host.

## Lock file across platforms

`.terraform.lock.hcl` records provider checksums per platform. If the host and the sandbox differ (a Mac and Linux, for example), record every platform you use so that `tofu init` succeeds on both:

```sh
tofu providers lock \
  -platform=linux_amd64 \
  -platform=linux_arm64 \
  -platform=darwin_arm64
```

## Other versions

A project pinning another version in `.tool-versions` or `mise.toml` gets it installed by mise on first use:

```sh
echo "opentofu 1.12.3" > .tool-versions
mise install
```

More tools are one command away, for example `mise use tflint`.

## Build arguments

| Argument | Default | |
|---|---|---|
| `MISE_IMAGE` | `ghcr.io/groguelon/sandboxes-mise:claude-code-minimal` | CI pins it to a digest |
| `OPENTOFU_VERSION` | `1.13.0` | Without the leading `v` |

The build accepts an optional `github_token` secret, used only to avoid GitHub API rate limits while mise resolves the release:

```sh
docker buildx build images/opentofu \
  --secret id=github_token,env=GITHUB_TOKEN \
  -t sandboxes-opentofu
```

## Tags

- `claude-code-minimal`: latest build
- `<opentofu>-claude-code-minimal`: e.g. `1.13.0-claude-code-minimal`
- `<opentofu>-mise-<mise>-claude-code-minimal`: e.g. `1.13.0-mise-2026.9.18-claude-code-minimal`

## Kit example

A v2 mixin that opens the OpenTofu registry and provider downloads, and asks the agent to plan before changing anything. See [Extending with Kits v2](../../README.md#extending-with-kits-v2) for the kit layout.

`opentofu/spec.yaml`:

```yaml
schemaVersion: "2"
kind: mixin
name: opentofu
displayName: OpenTofu
description: Registry access and safe-apply guidance for OpenTofu
requires:
  agent: claude

permissions:
  network:
    allow:
      - registry.opentofu.org              # provider and module registry
      - github.com                         # provider releases, module sources
      - release-assets.githubusercontent.com
      - objects.githubusercontent.com

agentInstructions:
  content: |
    Use `tofu` (OpenTofu), not `terraform`. Run `tofu fmt` and
    `tofu validate` after edits and `tofu plan` to review changes. Never run
    `tofu apply`, `tofu destroy` or `tofu state` commands that change state
    without explicit approval.
```

```sh
sbx run claude --template ghcr.io/groguelon/sandboxes-opentofu:claude-code-minimal --kit ./opentofu
```

Cloud provider APIs (AWS, GCP, Azure…) are separate hosts: allow them in the kit or with `sbx policy allow network`, and supply credentials through [sbx credentials](https://docs.docker.com/ai/sandboxes/configuration/credentials/) rather than files in the workspace.
