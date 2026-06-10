#!/usr/bin/env bash
# generate_adapted_patch.sh — Generate adapted patch and README from current changes
# Usage: generate_adapted_patch.sh <target_dir> <original_patch_name> <target_version_id> [output_dir]
#
# Example: generate_adapted_patch.sh /path/to/frocksdb 0001_autumn frocksdb-6.20.3 /path/to/output
#
# Produces:
#   0001_autumn_frocksdb-6.20.3.patch
#   0001_autumn_frocksdb-6.20.3.README

set -euo pipefail

TARGET_DIR="$1"
ORIGINAL_PATCH_NAME="$2"
TARGET_VERSION_ID="$3"
OUTPUT_DIR="${4:-$(dirname "$TARGET_DIR")}"

ADAPTED_NAME="${ORIGINAL_PATCH_NAME}_${TARGET_VERSION_ID}"
PATCH_FILE="${OUTPUT_DIR}/${ADAPTED_NAME}.patch"
README_FILE="${OUTPUT_DIR}/${ADAPTED_NAME}.README"

cd "$TARGET_DIR"

# Generate patch from current changes
echo "Generating adapted patch: $PATCH_FILE"

# Check if git repo
if git rev-parse --git-dir > /dev/null 2>&1; then
    # Stage all changes
    git add -A

    # Generate diff
    git diff --cached > "$PATCH_FILE"

    # Clear staging area
    git reset HEAD > /dev/null 2>&1 || true
else
    echo "Warning: Not a git repo. Cannot generate diff automatically."
    echo "You will need to generate the patch manually."
    echo "" > "$PATCH_FILE"
fi

# Check if patch file has content
if [ ! -s "$PATCH_FILE" ]; then
    echo "Warning: Patch file is empty (no changes detected or not a git repo)"
fi

echo "Patch written to: $PATCH_FILE"
echo ""

# Generate README template
cat > "$README_FILE" << HEREDOC
# ${ADAPTED_NAME}.patch Usage Instructions

## Source
Based on ${ORIGINAL_PATCH_NAME} from the source version, adapted for ${TARGET_VERSION_ID}

## Target Version
${TARGET_VERSION_ID}

## How to Apply
\`\`\`bash
cd ${TARGET_VERSION_ID}/
git apply --check ${ADAPTED_NAME}.patch   # Dry-run check first
git apply ${ADAPTED_NAME}.patch           # Apply the patch
\`\`\`

## Dependencies
- Prerequisite patches: (fill in during porting)
- Dependent patches: (fill in during porting)

## Modification Summary
(fill in during porting — list key changes made)

## Differences from Original Patch
(fill in during porting — what was adapted and why)

HEREDOC

echo "README written to: $README_FILE"
echo ""
echo "Done. Please update the README with porting details."
