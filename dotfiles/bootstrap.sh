#!/usr/bin/env bash
#
# KENL Dotfiles Bootstrap Script
# Intent-driven dotfiles installation with ATOM trail tracking
#
# Usage:
#   ./bootstrap.sh [--profile PROFILE] [--platform PLATFORM] [--force] [--backup-existing]
#
# Examples:
#   ./bootstrap.sh --profile gaming-focused
#   ./bootstrap.sh --profile amd-ryzen5-5600h-vega --backup-existing
#   ./bootstrap.sh --force --platform linux
#

set -euo pipefail

# ============================================================================
# Configuration
# ============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_ROOT="$SCRIPT_DIR"
KENL_ROOT="${KENL_ROOT:-$HOME/.kenl}"
ATOM_TRAIL_FILE="$DOTFILES_ROOT/.atom-trail.log"
SAGE_CONFIG="$DOTFILES_ROOT/.sage-dotfiles.yaml"
BACKUP_DIR="$DOTFILES_ROOT/backups"

# Defaults
PROFILE="${PROFILE:-minimal}"
PLATFORM="${PLATFORM:-auto}"
FORCE=false
BACKUP_EXISTING=false

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# ============================================================================
# Helper Functions
# ============================================================================

log_info() {
  echo -e "${BLUE}[INFO]${NC} $*"
}

log_success() {
  echo -e "${GREEN}[SUCCESS]${NC} $*"
}

log_warn() {
  echo -e "${YELLOW}[WARN]${NC} $*"
}

log_error() {
  echo -e "${RED}[ERROR]${NC} $*"
}

atom_trail() {
  local atom_type="$1"
  local action="$2"
  local intent="${3:-}"

  local timestamp=$(date +%Y%m%d)
  local counter=$(grep -c "ATOM-$atom_type-$timestamp" "$ATOM_TRAIL_FILE" 2>/dev/null || echo 0)
  counter=$((counter + 1))
  counter=$(printf "%03d" $counter)

  local atom_tag="ATOM-$atom_type-$timestamp-$counter"
  local entry="$atom_tag: $action"

  if [[ -n "$intent" ]]; then
    entry="$entry (intent: $intent)"
  fi

  echo "$entry" >> "$ATOM_TRAIL_FILE"
  log_info "ATOM trail: $entry"
}

detect_platform() {
  if [[ "$PLATFORM" != "auto" ]]; then
    echo "$PLATFORM"
    return
  fi

  if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    echo "linux"
  elif [[ "$OSTYPE" == "darwin"* ]]; then
    echo "macos"
  elif [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" ]]; then
    echo "windows"
  elif grep -qi microsoft /proc/version 2>/dev/null; then
    echo "wsl2"
  else
    echo "unknown"
  fi
}

create_backup() {
  local backup_name="dotfiles-backup-$(date +%Y%m%d-%H%M%S).tar.gz"
  local backup_path="$BACKUP_DIR/$backup_name"

  mkdir -p "$BACKUP_DIR"

  log_info "Creating backup: $backup_name"

  # Backup current dotfiles if they exist
  local files_to_backup=()

  # Common dotfiles
  for file in .bashrc .bash_profile .bash_aliases .zshrc .gitconfig .vimrc .tmux.conf; do
    [[ -f "$HOME/$file" ]] && files_to_backup+=("$file")
  done

  # Config directories
  for dir in .config/MangoHud .config/gamescope .gnupg .ssh; do
    [[ -d "$HOME/$dir" ]] && files_to_backup+=("$dir")
  done

  if [[ ${#files_to_backup[@]} -gt 0 ]]; then
    tar -czf "$backup_path" -C "$HOME" "${files_to_backup[@]}" 2>/dev/null || true
    log_success "Backup created: $backup_path"
    atom_trail "BACKUP" "Created backup before bootstrap" "Safety rollback point"
  else
    log_warn "No existing dotfiles found to backup"
  fi
}

verify_profile() {
  local profile="$1"
  local profile_dir="$DOTFILES_ROOT/profiles/$profile"

  if [[ ! -d "$profile_dir" ]]; then
    log_error "Profile '$profile' not found in $profile_dir"
    return 1
  fi

  # Check for OWI metadata
  if [[ ! -f "$profile_dir/profile.yaml" ]]; then
    log_warn "Profile '$profile' missing OWI metadata (profile.yaml)"
  fi

  return 0
}

create_symlink() {
  local src="$1"
  local dest="$2"
  local intent="$3"

  # Check if destination already exists
  if [[ -e "$dest" || -L "$dest" ]]; then
    if [[ "$FORCE" == true ]]; then
      log_warn "Overwriting existing: $dest"
      rm -rf "$dest"
    elif [[ "$BACKUP_EXISTING" == true ]]; then
      local backup_name="$dest.backup-$(date +%Y%m%d-%H%M%S)"
      log_warn "Backing up existing: $dest → $backup_name"
      mv "$dest" "$backup_name"
    else
      log_warn "Skipping (already exists): $dest (use --force to overwrite)"
      return
    fi
  fi

  # Create parent directory if needed
  mkdir -p "$(dirname "$dest")"

  # Create symlink
  ln -sf "$src" "$dest"
  log_success "Symlinked: $dest → $src"

  atom_trail "CFG" "Created symlink: $dest → $src" "$intent"
}

apply_profile() {
  local profile="$1"
  local profile_dir="$DOTFILES_ROOT/profiles/$profile"

  log_info "Applying profile: $profile"

  # Verify profile exists
  verify_profile "$profile" || exit 1

  # Apply KENL layer configs
  for layer_dir in "$profile_dir"/kenl*; do
    [[ ! -d "$layer_dir" ]] && continue

    local layer_name=$(basename "$layer_dir")
    log_info "Applying $layer_name configs..."

    # Process each config file in the layer
    while IFS= read -r -d '' config_file; do
      local rel_path="${config_file#$layer_dir/}"
      local dest="$HOME/$rel_path"
      create_symlink "$config_file" "$dest" "Profile: $profile, Layer: $layer_name"
    done < <(find "$layer_dir" -type f -print0)
  done

  atom_trail "CFG" "Applied profile: $profile" "Bootstrap installation"
}

show_usage() {
  cat <<EOF
KENL Dotfiles Bootstrap Script

Usage:
  $0 [OPTIONS]

Options:
  --profile PROFILE       Profile to install (default: minimal)
                         Available: minimal, gaming-focused, dev-focused, full-stack,
                                   amd-ryzen5-5600h-vega
  --platform PLATFORM    Target platform (default: auto)
                         Options: linux, windows, wsl2, macos, auto
  --force                Overwrite existing dotfiles without asking
  --backup-existing      Backup existing dotfiles before overwriting
  --help                 Show this help message

Examples:
  $0 --profile gaming-focused
  $0 --profile amd-ryzen5-5600h-vega --backup-existing
  $0 --force --platform linux

Environment Variables:
  KENL_ROOT              KENL repository root (default: $HOME/.kenl)

EOF
}

# ============================================================================
# Main Script
# ============================================================================

main() {
  # Parse arguments
  while [[ $# -gt 0 ]]; do
    case $1 in
      --profile)
        PROFILE="$2"
        shift 2
        ;;
      --platform)
        PLATFORM="$2"
        shift 2
        ;;
      --force)
        FORCE=true
        shift
        ;;
      --backup-existing)
        BACKUP_EXISTING=true
        shift
        ;;
      --help)
        show_usage
        exit 0
        ;;
      *)
        log_error "Unknown option: $1"
        show_usage
        exit 1
        ;;
    esac
  done

  # Detect platform
  PLATFORM=$(detect_platform)
  log_info "Platform detected: $PLATFORM"

  # Initialize ATOM trail if doesn't exist
  if [[ ! -f "$ATOM_TRAIL_FILE" ]]; then
    touch "$ATOM_TRAIL_FILE"
    log_info "Initialized ATOM trail: $ATOM_TRAIL_FILE"
  fi

  # Pre-flight checks
  log_info "Running pre-flight checks..."

  # Verify SAGE config exists
  if [[ ! -f "$SAGE_CONFIG" ]]; then
    log_warn "SAGE config not found: $SAGE_CONFIG"
  fi

  # Create backup if requested
  if [[ "$BACKUP_EXISTING" == true ]]; then
    create_backup
  fi

  # Apply profile
  apply_profile "$PROFILE"

  # Post-installation
  log_info "Running post-installation steps..."

  # Source new dotfiles (if bash)
  if [[ -f "$HOME/.bashrc" && "$SHELL" == *"bash"* ]]; then
    log_info "Sourcing new .bashrc..."
    # shellcheck disable=SC1090
    source "$HOME/.bashrc" || true
  fi

  # Git commit if in git repo
  if [[ -d "$DOTFILES_ROOT/.git" ]]; then
    log_info "Creating git commit..."
    cd "$DOTFILES_ROOT"
    git add -A
    git commit -m "feat: bootstrap with profile $PROFILE

ATOM-CFG-$(date +%Y%m%d)-001" || log_warn "Git commit failed (possibly no changes)"
  fi

  # Success summary
  log_success "Bootstrap complete!"
  echo ""
  echo "Profile applied: $PROFILE"
  echo "ATOM trail: $ATOM_TRAIL_FILE"
  echo "Backups: $BACKUP_DIR"
  echo ""
  echo "Next steps:"
  echo "  1. Restart your shell or run: source ~/.bashrc"
  echo "  2. Verify configs: ./verify-dotfiles.sh"
  echo "  3. Test your setup (launch apps, run commands)"
  echo "  4. If issues arise, rollback: ./rollback.sh ATOM-CFG-$(date +%Y%m%d)-001"
  echo ""

  atom_trail "BOOTSTRAP" "Bootstrap complete with profile: $PROFILE" "Initial dotfiles setup"
}

# Run main function
main "$@"
