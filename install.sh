#!/usr/bin/env bash

set -e

TARGET=""
MODE="copy"

while [[ "$#" -gt 0 ]]; do
    case $1 in
        --target) TARGET="$2"; shift ;;
        --mode) MODE="$2"; shift ;;
        *) echo "Unknown parameter passed: $1"; exit 1 ;;
    esac
    shift
done

if [ -z "$TARGET" ]; then
    echo "Usage: $0 --target <directory> [--mode copy|symlink]"
    echo "Example: $0 --target .opencode"
    exit 1
fi

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_DIR=$(realpath "$TARGET" 2>/dev/null || echo "$REPO_ROOT/$TARGET")

mkdir -p "$TARGET_DIR/skills" "$TARGET_DIR/commands" "$TARGET_DIR/agent"

echo "Installing ARC-7 to $TARGET_DIR (Mode: $MODE)..."

if [ "$MODE" = "symlink" ]; then
    ln -sfn "$REPO_ROOT/skills/ARC-7" "$TARGET_DIR/skills/ARC-7"
    ln -sfn "$REPO_ROOT/commands/ARC-7.md" "$TARGET_DIR/commands/ARC-7.md"
    ln -sfn "$REPO_ROOT/agents/ARC-7" "$TARGET_DIR/agent/ARC-7"
    echo "✅ Symlinked ARC-7 to $TARGET_DIR"
else
    cp -r "$REPO_ROOT/skills/ARC-7" "$TARGET_DIR/skills/"
    cp "$REPO_ROOT/commands/ARC-7.md" "$TARGET_DIR/commands/"
    cp -r "$REPO_ROOT/agents/ARC-7" "$TARGET_DIR/agent/"
    echo "✅ Copied ARC-7 to $TARGET_DIR"
fi

echo ""
echo "Next steps:"
echo "  1. Open model-mappings.json, find your provider, and copy the agent mapping into your opencode.json."
echo "  2. Restart your agent tool to load the /ARC-7 command."
