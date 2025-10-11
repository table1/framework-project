#!/bin/bash
# Framework interactive setup script
# Works on macOS/Linux

echo "Starting Framework setup..."
R --interactive --no-save <<'EOF'
source("init.R")
EOF
