#!/usr/bin/env bash
#
# Set up this dotfiles repo on macOS, Arch, or Debian-family Linux.
# Safe to re-run. Real files at a link destination are moved to <dest>.bak.
#
# Ends by exec'ing a login zsh, so the new config is live in the same terminal.
#
#   ./install.sh                    install, link, verify, hand off to zsh
#   DRY_RUN=1 ./install.sh          print what would happen, change nothing
#   DOTFILES_PM=apt ./install.sh    force a package manager (for testing)
#   NO_EXEC=1 ./install.sh          do the work but don't hand off to zsh

set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DRY_RUN="${DRY_RUN:-0}"
NO_EXEC="${NO_EXEC:-0}"
PROBLEMS=""

log()     { printf '  %s\n' "$*"; }
problem() { PROBLEMS="${PROBLEMS}  - $*"$'\n'; }

# Returns 0 even on failure, so `set -e` can't abort the run. One step failing
# should cost that step and nothing else.
run() {
  if [ "$DRY_RUN" = 1 ]; then
    printf '  [dry-run] %s\n' "$*"
    return 0
  fi
  "$@" || problem "failed: $*"
  return 0
}

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
#
# On PATH counts as installed, whatever put it there -- the package database
# only knows its own installs, so a source build or `go install` reads as
# missing. Names that aren't binary names fall through to the db query.
pkg_installed() {
  command -v "$1" >/dev/null 2>&1 && return 0
  case "$PM" in
    brew)   brew list --formula "$1" >/dev/null 2>&1 ;;
    pacman) pacman -Qi "$1" >/dev/null 2>&1 ;;
    apt)    dpkg-query -W -f='${db:Status-Status}' "$1" 2>/dev/null | grep -q '^installed$' ;;
  esac
}

# `apt-get install a b c` is one transaction: a single name the repos don't
# carry and nothing in the list installs. So screen names before batching them.
pkg_available() {
  case "$PM" in
    brew)   brew info --formula "$1" >/dev/null 2>&1 ;;
    pacman) pacman -Si "$1" >/dev/null 2>&1 ;;
    apt)    apt-cache show "$1" >/dev/null 2>&1 ;;
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
  # Before pkg_available reads them -- empty lists make everything look missing.
  if [ "$PM" = apt ]; then
    run sudo apt-get update
  fi

  WANTED=""
  for p in $TO_INSTALL; do
    if [ "$DRY_RUN" = 1 ] || pkg_available "$p"; then
      WANTED="$WANTED $p"
    else
      problem "$p: not available from $PM on this system; install it yourself"
    fi
  done

  if [ -n "$WANTED" ]; then
    # shellcheck disable=SC2086  # word splitting is intended here
    run $INSTALL $WANTED
  fi
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

# --- login shell ------------------------------------------------------------

# Not in packages.txt: macOS ships zsh already, and listing it there would mean
# `brew install zsh` -- a second copy shadowing the working one.
if ! command -v zsh >/dev/null 2>&1; then
  # shellcheck disable=SC2086  # word splitting is intended here
  run $INSTALL zsh
fi

ZSH_BIN="$(command -v zsh || true)"

if [ -z "$ZSH_BIN" ]; then
  problem "zsh not found, even after trying to install it"
else
  # Not $SHELL -- it describes whatever launched this process, so it still
  # reports the old shell right after a chsh.
  case "$OS" in
    macos) LOGIN_SHELL="$(dscl . -read "/Users/$USER" UserShell 2>/dev/null | awk 'NR==1 {print $2}')" ;;
    linux) LOGIN_SHELL="$(getent passwd "$USER" 2>/dev/null | cut -d: -f7)" ;;
  esac
  LOGIN_SHELL="${LOGIN_SHELL:-${SHELL:-}}"

  if [ "$LOGIN_SHELL" = "$ZSH_BIN" ]; then
    log "ok    login shell $ZSH_BIN"
  else
    # chsh rejects any shell absent from /etc/shells. Package-managed zsh adds
    # itself; a brew or hand-built one does not.
    if ! grep -qxF "$ZSH_BIN" /etc/shells 2>/dev/null; then
      log "adding $ZSH_BIN to /etc/shells (sudo)"
      run sudo sh -c "printf '%s\n' \"\$1\" >> /etc/shells" sh "$ZSH_BIN"
    fi
    log "shell ${LOGIN_SHELL:-unknown} -> $ZSH_BIN (may prompt for your password)"
    run chsh -s "$ZSH_BIN"
  fi
fi

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
fi

# --- hand off to zsh --------------------------------------------------------

# A bash child can't source zshrc into its caller, so replace this process with
# a login zsh instead.
if [ "$DRY_RUN" = 1 ]; then
  log "[dry-run] exec ${ZSH_BIN:-zsh} -l"
elif [ "$NO_EXEC" != 1 ] && [ -n "${ZSH_BIN:-}" ] && [ -t 0 ] && [ -t 1 ]; then
  log "starting zsh"
  exec "$ZSH_BIN" -l  # never returns; nothing below this runs
fi

# Only reached without a hand-off, where the exit code still matters.
[ -z "$PROBLEMS" ] || exit 1
