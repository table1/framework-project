#!/bin/bash
# Framework setup script with optional arguments
# Usage: ./setup.sh [project_name] [type] [use_renv] [attach_defaults]
# Example: ./setup.sh "My Project" project n y

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Default values
PROJECT_NAME="${1:-MyProject}"
TYPE="${2:-project}"
USE_RENV="${3:-n}"
ATTACH_DEFAULTS="${4:-y}"

# Convert y/n to TRUE/FALSE for R
USE_RENV_R=$([ "$USE_RENV" = "y" ] && echo "TRUE" || echo "FALSE")
ATTACH_DEFAULTS_R=$([ "$ATTACH_DEFAULTS" = "y" ] && echo "TRUE" || echo "FALSE")

echo -e "${BLUE}════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  Framework Project Setup${NC}"
echo -e "${BLUE}════════════════════════════════════════════════════${NC}"
echo ""
echo -e "${YELLOW}Configuration:${NC}"
echo -e "  Project name: ${GREEN}$PROJECT_NAME${NC}"
echo -e "  Type: ${GREEN}$TYPE${NC}"
echo -e "  renv: ${GREEN}$([ "$USE_RENV" = "y" ] && echo "enabled" || echo "disabled")${NC}"
echo -e "  Auto-load packages: ${GREEN}$([ "$ATTACH_DEFAULTS" = "y" ] && echo "yes" || echo "no")${NC}"
echo ""
echo -e "${BLUE}Initializing...${NC}"
echo ""

# Check if Framework is installed, if not install it
R --quiet --no-save --slave <<'RCODE' 2>&1 | grep -v "^>" | grep -v "^+" | grep -v "^$" | grep -v "^ *$"
if (!requireNamespace('framework', quietly = TRUE)) {
  cat('Installing Framework package...\n')
  if (!requireNamespace('devtools', quietly = TRUE)) {
    install.packages('devtools', repos = 'https://cloud.r-project.org')
  }
  devtools::install_github('table1/framework')
}

framework::init(
  project_name = '$PROJECT_NAME',
  type = '$TYPE',
  use_renv = $USE_RENV_R,
  attach_defaults = $ATTACH_DEFAULTS_R
)
RCODE

echo ""
echo -e "${GREEN}✓ Setup complete!${NC}"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo "  1. Start R in this directory"
echo "  2. Run: library(framework); scaffold()"
echo "  3. Start analyzing!"
