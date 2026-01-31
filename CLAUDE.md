# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a LaTeX-based resume management system that maintains multiple job-specific resume versions (General, Backend, MLE, Infra, Experiment) with automated versioning and archiving. The build system creates date-stamped PDFs and maintains symlinks to latest versions.

## Build System

### Local Development (macOS with MiKTeX)

Build all resume types:
```bash
make
```

Build specific resume type:
```bash
make General    # or Backend, MLE, Infra, Experiment
```

Clean temporary build artifacts:
```bash
make clean
```

The build script (`build.sh`) expects MiKTeX installed at `$HOME/bin` in PATH. It:
1. Compiles `main.tex` in each folder using `pdflatex`
2. Creates date-stamped PDFs in `<folder_lower>-resume-rendered-archive/`
3. Updates symlink `kausik-<folder_lower>-resume-latest.pdf` to point to the latest version

### GitHub Actions

The workflow `.github/workflows/build-resumes.yml` is manually triggered via `workflow_dispatch` and:
- Builds all resume types in parallel using a matrix strategy
- Creates a GitHub release with all PDFs renamed to `-latest.pdf` format
- Uses a custom lightweight Docker image (`ghcr.io/kausik-a/resume-builder:latest`)
  - Based on Debian slim with only required LaTeX packages
  - Pre-installed exiftool for metadata embedding
  - ~500MB vs 8+ GB for full TeXLive image
  - Reduces container initialization time from ~103s to ~20-30s

### Custom Docker Image

The custom Docker image is defined in `Dockerfile` and automatically built by `.github/workflows/build-docker-image.yml`:
- Triggers on changes to Dockerfile or manually
- Builds and pushes to GitHub Container Registry (ghcr.io)
- Includes: texlive-latex-base, texlive-latex-extra, texlive-fonts-recommended, exiftool, git
- Tagged as `latest` and with commit SHA

## Architecture

### Directory Structure

Each resume type folder (General/, Backend/, MLE/, Infra/, Experiment/) contains:
- `main.tex` - Resume content with job-specific experience and projects
- `resume.cls` - Shared LaTeX class file defining document structure and styling
- `<folder_lower>-resume-rendered-archive/` - Archive of date-stamped PDF versions
- `kausik-<folder_lower>-resume-latest.pdf` - Symlink to latest PDF (relative path)
- `.tmp/` - Temporary build artifacts (gitignored)

### Build Output Naming

The build system uses lowercase folder names for all file paths and archives:
- Archive directory: `general-resume-rendered-archive/` (not `General-resume-rendered-archive/`)
- PDF naming: `kausik-general-2026-01-31.pdf` (lowercase)
- Symlink naming: `kausik-general-resume-latest.pdf` (lowercase)

This convention is enforced in `build.sh:24` via `tr '[:upper:]' '[:lower:]'` and must be maintained in GitHub Actions matrix configuration.

### Resume Class File (`resume.cls`)

The custom LaTeX class defines:
- `\name{}` and `\address{}` commands for header
- `rSection{}` environment for major sections (Work Experience, Education, etc.)
- `rSubsection{}` environment for structured entries (not actively used in current resume)
- Sans-serif font for name, serif for body
- Custom horizontal rule styling with `\Vhrulefill`

## Resume Content Guidelines

### Structure Pattern

All `main.tex` files follow this structure:
1. Document class and geometry setup
2. Name and contact info (email, GitHub, LinkedIn, location)
3. Work Experience section (reverse chronological)
4. Technical Skills section (tabular format)
5. Education section
6. Projects section

### LaTeX Formatting

- Use `\small` before each job entry to maintain compact spacing
- Use `itemize` with `[itemsep=-7pt,topsep=-3pt]` for bullet points
- Use `\href[pdfnewwindow=true]{url}{text}` for clickable links
- Use `\textbf{}` for emphasis within bullets
- Use `\sl` for date ranges aligned right with `\hfill`

### Content Tailoring

Each resume type emphasizes different skills and experience:
- **General**: Balanced overview of all skills
- **Backend**: Focus on distributed systems, APIs, infrastructure
- **MLE**: Emphasize ML/AI projects, data pipelines, model development
- **Infra**: Highlight cloud platforms, DevOps, observability, Kubernetes
- **Experiment**: Testing ground for ATS optimization techniques

## Modifying Resumes

When editing resume content:
1. Edit the specific `main.tex` file in the target folder
2. Build locally to verify PDF output: `make <FolderName>`
3. Check both the archived PDF and symlink are created correctly
4. The `resume.cls` file is shared across all folders - changes affect all resume types

## Version Control

- All date-stamped PDFs in archive directories are committed to git
- Symlinks are tracked in git (pointing to relative paths in archives)
- `.tmp/` directories are gitignored
- The README.md contains permanent GitHub raw links to latest versions in archive directories

## GitHub Release System

The Actions workflow creates releases with individual PDF download links. The release body template uses repository-relative URLs like:
```
https://github.com/${{ github.repository }}/releases/download/latest/kausik-general-latest.pdf
```

This allows permanent links that always point to the most recent build.
