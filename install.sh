#!/bin/bash
# Framework one-liner installer
# Usage: curl -fsSL https://raw.githubusercontent.com/table1/framework-project/main/install.sh | bash -s my-project

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Detect if stdin is a terminal (for interactive mode)
if [ -t 0 ]; then
  # Running interactively (e.g., ./install.sh)
  READ_CMD="read -r"
else
  # Being piped (e.g., curl | bash) - redirect input from terminal
  READ_CMD="read -r </dev/tty"
fi

# Config file location
FRAMEWORK_RC="$HOME/.frameworkrc"

# Load existing config if it exists
if [ -f "$FRAMEWORK_RC" ]; then
  # shellcheck source=/dev/null
  source "$FRAMEWORK_RC"
fi

echo -e "${BLUE}════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  Framework Project Installer${NC}"
echo -e "${BLUE}════════════════════════════════════════════════════${NC}"
echo ""

# Author information (stored in ~/.frameworkrc)
if [ -z "$FW_AUTHOR_NAME" ]; then
  echo -e "${YELLOW}First-time setup: Author information${NC}"
  echo ""
  echo -en "${YELLOW}Your name:${NC} "
  eval "$READ_CMD FW_AUTHOR_NAME"

  echo -en "${YELLOW}Your email (optional):${NC} "
  eval "$READ_CMD FW_AUTHOR_EMAIL"

  echo -en "${YELLOW}Your affiliation (optional):${NC} "
  eval "$READ_CMD FW_AUTHOR_AFFILIATION"

  # Save to config file
  {
    echo "# Framework configuration"
    echo "# Edit this file to update your default author information"
    echo "FW_AUTHOR_NAME=\"$FW_AUTHOR_NAME\""
    echo "FW_AUTHOR_EMAIL=\"$FW_AUTHOR_EMAIL\""
    echo "FW_AUTHOR_AFFILIATION=\"$FW_AUTHOR_AFFILIATION\""
  } > "$FRAMEWORK_RC"

  echo ""
  echo -e "${GREEN}✓ Saved to $FRAMEWORK_RC${NC}"
  echo ""
else
  echo -e "${GREEN}Using author: $FW_AUTHOR_NAME${NC}"
  echo ""
fi

# Get project name from argument or prompt
PROJECT_NAME="${1}"

if [ -z "$PROJECT_NAME" ]; then
  while [ -z "$PROJECT_NAME" ]; do
    echo -en "${YELLOW}Project name:${NC} "
    eval "$READ_CMD PROJECT_NAME"
    if [ -z "$PROJECT_NAME" ]; then
      echo -e "${RED}Project name cannot be empty. Please try again.${NC}"
    fi
  done
fi

echo ""

# Slugify project name for default directory
# Convert to lowercase, replace spaces/special chars with hyphens, remove consecutive hyphens
PROJECT_SLUG=$(echo "$PROJECT_NAME" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9-]/-/g' | sed 's/--*/-/g' | sed 's/^-//' | sed 's/-$//')

# Get directory name (defaults to slugified project name)
echo -en "${YELLOW}Directory name [$PROJECT_SLUG]:${NC} "
eval "$READ_CMD PROJECT_DIR"

if [ -z "$PROJECT_DIR" ]; then
  PROJECT_DIR="$PROJECT_SLUG"
fi

echo ""

# Project type
echo -e "${YELLOW}Project types:${NC}"
echo "  1. project (default) - Full-featured data analysis"
echo "  2. course - Teaching materials"
echo "  3. presentation - Single talk"
echo ""
echo -en "${YELLOW}Choose type (1-3) [1]:${NC} "
eval "$READ_CMD TYPE_CHOICE"

case "$TYPE_CHOICE" in
  2) PROJECT_TYPE="course" ;;
  3) PROJECT_TYPE="presentation" ;;
  *) PROJECT_TYPE="project" ;;
esac

echo ""

# renv
echo -e "${YELLOW}Enable renv for reproducibility? (y/n) [n]:${NC} "
eval "$READ_CMD USE_RENV_INPUT"
USE_RENV_INPUT=$(echo "$USE_RENV_INPUT" | tr '[:upper:]' '[:lower:]')

if [ "$USE_RENV_INPUT" = "y" ] || [ "$USE_RENV_INPUT" = "yes" ]; then
  USE_RENV="TRUE"
else
  USE_RENV="FALSE"
fi

echo ""
echo -e "${BLUE}────────────────────────────────────────────────────${NC}"
echo -e "${YELLOW}Project name:${NC} ${GREEN}$PROJECT_NAME${NC}"
echo -e "${YELLOW}Directory:${NC} ${GREEN}$PROJECT_DIR${NC}"
echo -e "${YELLOW}Type:${NC} ${GREEN}$PROJECT_TYPE${NC}"
echo -e "${YELLOW}renv:${NC} ${GREEN}$([ "$USE_RENV" = "TRUE" ] && echo "enabled" || echo "disabled")${NC}"
echo -e "${BLUE}────────────────────────────────────────────────────${NC}"
echo ""

# Check if directory already exists
if [ -d "$PROJECT_DIR" ]; then
  echo -e "${RED}Error: Directory '$PROJECT_DIR' already exists${NC}"
  exit 1
fi

# Clone the repository
echo -e "${BLUE}Cloning framework-project template...${NC}"
git clone --quiet https://github.com/table1/framework-project "$PROJECT_DIR"

# Navigate into directory
cd "$PROJECT_DIR"

# Remove .git directory
rm -rf .git

# Run setup by calling init.R with environment variables
echo ""
echo -e "${BLUE}Initializing project...${NC}"
echo ""

# Export variables for init.R to read
export FW_PROJECT_NAME="$PROJECT_NAME"
export FW_PROJECT_TYPE="$PROJECT_TYPE"
export FW_USE_RENV="$USE_RENV"
export FW_AUTHOR_NAME="$FW_AUTHOR_NAME"
export FW_AUTHOR_EMAIL="$FW_AUTHOR_EMAIL"
export FW_AUTHOR_AFFILIATION="$FW_AUTHOR_AFFILIATION"
export FW_NON_INTERACTIVE="true"

# Run init.R
R --quiet --no-save --slave < init.R

echo ""
echo -e "${GREEN}✓ Project '$PROJECT_NAME' created successfully!${NC}"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo -e "  ${GREEN}cd \"$PROJECT_DIR\"${NC}"
echo -e "  ${GREEN}R${NC}"
echo ""
echo "Then in R:"
echo -e "  ${GREEN}library(framework)${NC}"
echo -e "  ${GREEN}scaffold()${NC}"
echo ""
echo -e "${BLUE}ℹ${NC}  For project types, renv, and other options, see README.md"
