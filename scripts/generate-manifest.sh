#!/bin/bash
# Generates manifest.yaml from recipe files
# Run this from the repo root: ./scripts/generate-manifest.sh

set -e

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
MANIFEST="$REPO_ROOT/manifest.yaml"

# Collect all recipe files (sorted for deterministic ordering)
RECIPE_FILES=$(find "$REPO_ROOT" -path "$REPO_ROOT/scripts" -prune -o -name "*.yaml" -type f -print 2>/dev/null | \
  grep -v "manifest.yaml" | \
  sort)

# Compute checksum from all recipe file contents
CHECKSUM=$(echo "$RECIPE_FILES" | xargs cat 2>/dev/null | shasum -a 256 | cut -d' ' -f1)

echo "# Auto-generated manifest - do not edit manually" > "$MANIFEST"
echo "# Generated: $(date -u +"%Y-%m-%dT%H:%M:%SZ")" >> "$MANIFEST"
echo "" >> "$MANIFEST"
echo "checksum: $CHECKSUM" >> "$MANIFEST"
echo "" >> "$MANIFEST"
echo "recipes:" >> "$MANIFEST"

# List all recipe files by relative path
for recipe_file in $RECIPE_FILES; do
  # Get path relative to repo root
  relative_path="${recipe_file#$REPO_ROOT/}"
  echo "  - $relative_path" >> "$MANIFEST"
done

echo "" >> "$MANIFEST"
echo "Generated $MANIFEST"
