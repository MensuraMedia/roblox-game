#!/bin/bash
# =============================================================================
# Roblox Game Publishing Script
# =============================================================================
# Builds the Rojo project and publishes to Roblox via Open Cloud API.
#
# Usage:
#   ./tools/publish.sh                    # Build and publish (update existing place)
#   ./tools/publish.sh --build-only       # Build .rbxl file only (no publish)
#   ./tools/publish.sh --create           # Create a NEW place (first-time publish)
#
# Prerequisites:
#   - .env file with ROBLOX_OPEN_CLOUD_API_KEY, ROBLOX_UNIVERSE_ID, ROBLOX_PLACE_ID
#   - Rojo installed and on PATH
#   - curl installed
#
# Security:
#   - API key is read from .env (gitignored, never committed)
#   - Key is never echoed or logged
# =============================================================================

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BUILD_DIR="$PROJECT_ROOT/build"
BUILD_FILE="$BUILD_DIR/game.rbxl"
ENV_FILE="$PROJECT_ROOT/.env"
ROJO_PROJECT="$PROJECT_ROOT/default.project.json"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info()  { echo -e "${BLUE}[INFO]${NC} $1"; }
log_ok()    { echo -e "${GREEN}[OK]${NC} $1"; }
log_warn()  { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Load .env file
load_env() {
    if [ ! -f "$ENV_FILE" ]; then
        log_error ".env file not found at $ENV_FILE"
        log_info "Create .env with: ROBLOX_OPEN_CLOUD_API_KEY, ROBLOX_UNIVERSE_ID, ROBLOX_PLACE_ID"
        exit 1
    fi
    set -a
    source "$ENV_FILE"
    set +a
    log_ok "Environment loaded from .env"
}

# Validate required environment variables
validate_env() {
    local missing=0
    if [ -z "${ROBLOX_OPEN_CLOUD_API_KEY:-}" ]; then
        log_error "ROBLOX_OPEN_CLOUD_API_KEY not set"
        missing=1
    fi
    if [ "$1" != "--build-only" ]; then
        if [ -z "${ROBLOX_UNIVERSE_ID:-}" ]; then
            log_error "ROBLOX_UNIVERSE_ID not set in .env"
            missing=1
        fi
        if [ -z "${ROBLOX_PLACE_ID:-}" ]; then
            log_error "ROBLOX_PLACE_ID not set in .env"
            missing=1
        fi
    fi
    if [ $missing -eq 1 ]; then
        exit 1
    fi
    log_ok "Environment validated"
}

# Build the Rojo project
build() {
    log_info "Building Rojo project..."
    mkdir -p "$BUILD_DIR"

    export PATH="$HOME/.cargo/bin:$PATH"

    rojo build "$ROJO_PROJECT" -o "$BUILD_FILE" 2>&1
    if [ $? -eq 0 ]; then
        local size=$(stat -c%s "$BUILD_FILE" 2>/dev/null || stat -f%z "$BUILD_FILE" 2>/dev/null || echo "unknown")
        log_ok "Build successful: $BUILD_FILE ($size bytes)"
    else
        log_error "Rojo build failed"
        exit 1
    fi
}

# Publish to Roblox (update existing place)
publish() {
    log_info "Publishing to Roblox..."
    log_info "Universe: $ROBLOX_UNIVERSE_ID | Place: $ROBLOX_PLACE_ID"

    local response
    response=$(curl -s -w "\n%{http_code}" \
        -X POST \
        "https://apis.roblox.com/universes/v1/${ROBLOX_UNIVERSE_ID}/places/${ROBLOX_PLACE_ID}/versions?versionType=Published" \
        -H "x-api-key: ${ROBLOX_OPEN_CLOUD_API_KEY}" \
        -H "Content-Type: application/octet-stream" \
        --data-binary "@${BUILD_FILE}" \
        2>&1)

    local http_code=$(echo "$response" | tail -1)
    local body=$(echo "$response" | head -n -1)

    if [ "$http_code" = "200" ]; then
        log_ok "Published successfully!"
        log_info "Response: $body"
    else
        log_error "Publish failed (HTTP $http_code)"
        log_error "Response: $body"
        exit 1
    fi
}

# Main
main() {
    echo "========================================="
    echo "  Roblox Game Publisher"
    echo "========================================="

    local mode="${1:---publish}"

    load_env

    case "$mode" in
        --build-only)
            validate_env "--build-only"
            build
            log_ok "Build complete. File at: $BUILD_FILE"
            ;;
        --create)
            validate_env "--publish"
            build
            log_warn "To create a new place, use Roblox Studio or the Creator Dashboard first."
            log_info "Then set ROBLOX_UNIVERSE_ID and ROBLOX_PLACE_ID in .env"
            log_info "After that, run: ./tools/publish.sh"
            ;;
        --publish|*)
            validate_env "--publish"
            build
            publish
            ;;
    esac

    echo "========================================="
    log_ok "Done!"
}

main "$@"
