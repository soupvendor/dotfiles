#!/bin/sh
set -eu

cd "$(dirname "$0")"

command -v mise >/dev/null 2>&1 || curl https://mise.run | sh
export PATH="$HOME/.local/bin:$PATH"

# Running this script is the trust decision. Without it mise reads an untrusted
# config with its [dotfiles] section SILENTLY SKIPPED — tools install, no
# symlink is ever created, and nothing tells you why.
mise trust --all --quiet

# Identity must exist before the dotfiles phase renders git/config.tmpl
if [ ! -f mise.local.toml ]; then
    [ -n "${GIT_EMAIL:-}" ] || { printf 'Git email: '; read -r GIT_EMAIL; }
    [ -n "${GIT_NAME:-}" ] || { printf 'Git name: '; read -r GIT_NAME; }
    : >mise.local.toml
    mise trust --quiet mise.local.toml
    mise config set -f mise.local.toml vars.git_email "$GIT_EMAIL"
    mise config set -f mise.local.toml vars.git_name "$GIT_NAME"
fi

# Arguments pass straight through, so --dry-run, --only dotfiles, and
# --force-dotfiles all work with no flag parsing here.
mise bootstrap "$@"
