# Custom lightweight LaTeX + exiftool image for resume builds
# This image is ~500MB vs texlive/texlive:latest which is 8+ GB

FROM debian:bookworm-slim

# Install required packages in a single layer to minimize image size
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    # Core LaTeX packages
    texlive-latex-base \
    texlive-latex-extra \
    texlive-fonts-recommended \
    texlive-fonts-extra \
    # For PDF metadata manipulation
    libimage-exiftool-perl \
    # Git for commit hash extraction
    git \
    # SSL certificates for HTTPS git operations
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /workspace

# Add metadata
LABEL org.opencontainers.image.source="https://github.com/Kausik-A/Resume"
LABEL org.opencontainers.image.description="Lightweight LaTeX environment for resume PDF builds"
LABEL org.opencontainers.image.licenses="MIT"
