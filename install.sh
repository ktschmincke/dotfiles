#!/usr/bin/env bash
#
# Set up this dotfiles repo on macOS, Arch, or Debian-family Linux.
# Safe to re-run. Real files at a link destination are moved to <dest>.bak.
#
#   ./install.sh                    install packages, link configs, verify
#   DRY_RUN=1 ./install.sh          print what would happen, change nothing
#   DOTFILES_PM=apt ./install.sh    force a package manager (for testing)

set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DRY_RUN="${DRY_RUN:-0}"
PROBLEMS=""

log()     { printf '  %s\n' "$*"; }
problem() { PROBLEMS="${PROBLEMS}  - $*"$'\n'; }
run()     { if [ "$DRY_RUN" = 1 ]; then printf '  [dry-run] %s\n' "$*"; else "$@"; fi; }

# --- detect os and package manager ------------------------------------------

case "$(uname -s)" in
  Darwin) OS=macos; CANDIDATES="brew" ;;
  Linux)  OS=linux; CANDIDATES="pacman apt" ;;
  *) echo "unsupported OS: $(uname -s)" >&2; exit 1 ;;
esac

PM="${DOTFILES_PM:-}"
if [ -z "$PM" ]; then
  for c in $CANDIDATES; do
    if command -v "$c" >/dev/null 2>&1; then PM="$c"; break; fi
  done
fi

case "$PM" in
  brew)   INSTALL="brew install" ;;
  pacman) INSTALL="sudo pacman -S --needed --noconfirm" ;;
  apt)    INSTALL="sudo apt-get install -y" ;;
  *)
    echo "No supported package manager found (need brew, pacman, or apt)." >&2
    echo "Install these by hand, then re-run to link configs:" >&2
    grep -vE '^\s*(#|$)' "$REPO/packages.txt" | sed 's/^/  /' >&2
    exit 1
    ;;
esac

log "os=$OS  package-manager=$PM"

# --- packages ---------------------------------------------------------------

# Install only what is missing -- plain `brew install` upgrades an outdated
# package, and upgrading should stay a deliberate act.
pkg_installed() {
  case "$PM" in
    brew)   brew list --formula "$1" >/dev/null 2>&1 ;;
    pacman) pacman -Qi "$1" >/dev/null 2>&1 ;;
    apt)    dpkg-query -W -f='${db:Status-Status}' "$1" 2>/dev/null | grep -q '^installed$' ;;
  esac
}

TO_INSTALL=""
while read -r p _ || [ -n "$p" ]; do
  case "$p" in ''|\#*) continue ;; esac
  pkg_installed "$p" || TO_INSTALL="$TO_INSTALL $p"
done < "$REPO/packages.txt"

if [ -z "$TO_INSTALL" ]; then
  log "ok    all packages present"
else
  if [ "$PM" = apt ]; then
    run sudo apt-get update
  fi
  # shellcheck disable=SC2086  # word splitting is intended here
  run $INSTALL $TO_INSTALL
fi

# --- symlinks ---------------------------------------------------------------

while read -r src dest os || [ -n "$src" ]; do
  case "$src" in ''|\#*) continue ;; esac
  [ "$os" = any ] || [ "$os" = "$OS" ] || continue

  target="$REPO/$src"
  dest="${dest/#\~/$HOME}"

  if [ ! -e "$target" ]; then problem "missing in repo: $src"; continue; fi

  parent="$(dirname "$dest")"
  [ -d "$parent" ] || run mkdir -p "$parent"

  if [ -L "$dest" ]; then
    [ "$(readlink "$dest")" = "$target" ] && { log "ok    $dest"; continue; }
    run rm "$dest"
  elif [ -e "$dest" ]; then
    run mv "$dest" "$dest.bak"
    log "moved $dest -> $dest.bak"
  fi

  run ln -s "$target" "$dest"
  log "link  $dest"
done < <(grep -vE '^\s*(#|$)' "$REPO/links.conf")

# --- tpm (a git clone, not a package) ---------------------------------------

TPM="$HOME/.tmux/plugins/tpm"
if [ -d "$TPM" ]; then
  log "ok    tpm"
else
  run git clone --depth 1 https://github.com/tmux-plugins/tpm "$TPM"
fi

# --- verify only: these are owned by their own version managers -------------

for tool in node go cc; do
  command -v "$tool" >/dev/null 2>&1 || problem "$tool not found (install separately)"
done

if command -v nvim >/dev/null 2>&1; then
  V="$(nvim --version | sed -n '1s/^NVIM v\([0-9]*\.[0-9]*\).*/\1/p')"
  if [ -z "$V" ]; then
    problem "could not parse 'nvim --version'; verify it is >= 0.12 yourself"
  elif [ "${V%.*}" -eq 0 ] && [ "${V#*.}" -lt 12 ]; then
    problem "nvim $V is too old; the treesitter config needs >= 0.12
    nvim-treesitter main requires 0.12 and master does not support it.
    Get a build from https://github.com/neovim/neovim/releases"
  fi
fi

# --- pointers to the things this repo deliberately does not manage ----------

[ -n "$PROBLEMS" ] || log "done"

cat <<'NOTES'

Not managed by this repo:
  project env vars      <project>/.envrc, loaded by direnv.
                        Run `direnv allow` once per checkout.
  aliases / functions   ~/.zshrc.local, sourced at the end of zshrc.
                        For commands that need no `cd`, prefer a script plus
                        `PATH_add bin` in .envrc so it exists only in the project.
NOTES

# --- report -----------------------------------------------------------------

if [ -n "$PROBLEMS" ]; then
  printf '\nNeeds attention:\n%s' "$PROBLEMS"
  exit 1
fi
