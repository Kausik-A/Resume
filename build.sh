#!/bin/bash
set -euo pipefail

export PATH="$HOME/bin:$PATH"

# Configuration
NAME="kausik"
DATE=$(date +%Y-%m-%d)

# Get git commit hash with dirty flag if needed
GIT_HASH=$(git rev-parse --short HEAD 2>/dev/null || echo "unknown")
if ! git diff --quiet 2>/dev/null || ! git diff --cached --quiet 2>/dev/null; then
    GIT_HASH="${GIT_HASH}-dirty"
fi

# Validate folder argument
FOLDER="$1"
if [ -z "$FOLDER" ]; then
    echo "Error: No folder specified"
    echo "Usage: ./build.sh <folder-name>"
    echo "Available folders: General, Backend, MLE, Infra"
    exit 1
fi

if [ ! -d "$FOLDER" ]; then
    echo "Error: Folder '$FOLDER' does not exist"
    exit 1
fi

# Convert folder name to lowercase for filenames
FOLDER_LOWER=$(echo "$FOLDER" | tr '[:upper:]' '[:lower:]')

# Set up paths
ARCHIVE_DIR="${FOLDER}/${FOLDER_LOWER}-resume-rendered-archive"

# Build filenames
OUTPUT_NAME="${ARCHIVE_DIR}/${NAME}-${FOLDER_LOWER}-${DATE}.pdf"
LATEST_NAME="${FOLDER}/${NAME}-${FOLDER_LOWER}-resume-latest.pdf"

# Create directories if they don't exist
mkdir -p "${FOLDER}/.tmp"
mkdir -p "$ARCHIVE_DIR"

# Build PDF
cd "$FOLDER" || exit 1
pdflatex -interaction=nonstopmode -output-directory=.tmp main.tex || true
cd .. || exit 1

# Verify PDF was generated
if [ ! -f "${FOLDER}/.tmp/main.pdf" ]; then
    echo "Error: pdflatex failed to produce output PDF for $FOLDER"
    exit 1
fi

# Copy to archive with date-stamped name
cp "${FOLDER}/.tmp/main.pdf" "$OUTPUT_NAME"

# Embed git commit hash in PDF metadata
if command -v exiftool &> /dev/null; then
    exiftool -q -overwrite_original \
        -Subject="git:${GIT_HASH}" \
        -Keywords="commit-${GIT_HASH}" \
        -Author="Kausik Amancherla" \
        "$OUTPUT_NAME"
    echo "Embedded git hash: ${GIT_HASH}"
else
    echo "Warning: exiftool not found. Skipping metadata embedding."
    echo "Install with: brew install exiftool"
fi

# Create/update symlink to latest version (relative path)
cd "$FOLDER" || exit 1
ln -sf "${FOLDER_LOWER}-resume-rendered-archive/$(basename "$OUTPUT_NAME")" "$(basename "$LATEST_NAME")"
cd .. || exit 1

echo "Built: $OUTPUT_NAME"
echo "Latest: $LATEST_NAME -> $OUTPUT_NAME"
