#!/bin/bash

export PATH="$HOME/bin:$PATH"

# Configuration
NAME="kausik"
DATE=$(date +%Y-%m-%d)

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
pdflatex -interaction=nonstopmode -output-directory=.tmp main.tex
cd .. || exit 1

# Copy to archive with date-stamped name
cp "${FOLDER}/.tmp/main.pdf" "$OUTPUT_NAME"

# Create/update symlink to latest version (relative path)
cd "$FOLDER" || exit 1
ln -sf "${FOLDER_LOWER}-resume-rendered-archive/$(basename "$OUTPUT_NAME")" "$(basename "$LATEST_NAME")"
cd .. || exit 1

echo "Built: $OUTPUT_NAME"
echo "Latest: $LATEST_NAME -> $OUTPUT_NAME"
