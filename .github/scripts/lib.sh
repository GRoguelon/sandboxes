# Helpers shared by the image workflows. Source it from a bash step.

# Namespace of the index annotations recording the versions baked into an image.
ANNOTATION_NS=io.github.groguelon.sandboxes

# Latest mise release, without the leading "v".
latest_mise() {
  curl -fsSL https://mise.jdx.dev/VERSION | sed 's/^v//'
}

# Latest OTP release with a precompiled Ubuntu 26.04 build for both amd64 and arm64.
latest_erlang() {
  local arch
  for arch in amd64 arm64; do
    curl -fsSL "https://builds.hex.pm/builds/otp/${arch}/ubuntu-26.04/builds.txt" |
      awk '{ print $1 }' | grep -E '^OTP-[0-9]+(\.[0-9]+)*$' | sed 's/^OTP-//'
  done | sort -V | uniq -d | tail -n 1
}

# Latest rebar3 release. Needs GH_TOKEN to avoid anonymous API rate limits.
latest_rebar3() {
  gh api repos/erlang/rebar3/releases/latest --jq .tag_name
}

# Latest OpenTofu release, without the leading "v". Needs GH_TOKEN.
latest_opentofu() {
  gh api repos/opentofu/opentofu/releases/latest --jq '.tag_name | ltrimstr("v")'
}

# Latest Elixir release with a precompiled build for the given OTP major version.
latest_elixir() {
  curl -fsSL https://builds.hex.pm/builds/elixir/builds.txt |
    awk '{ print $1 }' | grep -E "^v[0-9]+\.[0-9]+\.[0-9]+-otp-$1\$" |
    sed -E 's/^v//; s/-otp-.*$//' | sort -V | tail -n 1
}

# Digest of the multi-platform index an image reference points to.
index_digest() {
  docker buildx imagetools inspect "$1" --format '{{json .Manifest}}' | jq -r .digest
}

# Value of an index annotation; empty when the image or the annotation is missing.
index_annotation() {
  { docker buildx imagetools inspect "$1" --raw 2>/dev/null || true; } |
    jq -r --arg key "$2" '.annotations[$key] // empty'
}

# Writes a (possibly multi-line) step output.
set_output() {
  { echo "$1<<__EOF__"; printf '%s\n' "$2"; echo "__EOF__"; } >> "$GITHUB_OUTPUT"
}

# Decides whether to rebuild and writes the step summary.
# Usage: decide IMAGE_REF FORCE "LABEL|PUBLISHED|LATEST"...
decide() {
  local image=$1 force=$2 build=$2 row label current latest
  shift 2
  {
    echo "### ${image}"
    echo
    echo "| | Published | Latest |"
    echo "|---|---|---|"
  } >> "$GITHUB_STEP_SUMMARY"
  for row in "$@"; do
    IFS="|" read -r label current latest <<< "$row"
    [[ "$current" == "$latest" ]] || build=true
    echo "| ${label} | \`${current:--}\` | \`${latest}\` |" >> "$GITHUB_STEP_SUMMARY"
  done
  printf '\nForced: %s. Build: **%s**\n' "$force" "$build" >> "$GITHUB_STEP_SUMMARY"
  set_output build "$build"
}
