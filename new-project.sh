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

echo -e "${BLUE}"
cat << 'EOF'
▗▄▄▄▖▗▄▄▖  ▗▄▖ ▗▖  ▗▖▗▄▄▄▖▗▖ ▗▖ ▗▄▖ ▗▄▄▖ ▗▖ ▗▖
▐▌   ▐▌ ▐▌▐▌ ▐▌▐▛▚▞▜▌▐▌   ▐▌ ▐▌▐▌ ▐▌▐▌ ▐▌▐▌▗▞▘
▐▛▀▀▘▐▛▀▚▖▐▛▀▜▌▐▌  ▐▌▐▛▀▀▘▐▌ ▐▌▐▌ ▐▌▐▛▀▚▖▐▛▚▖
▐▌   ▐▌ ▐▌▐▌ ▐▌▐▌  ▐▌▐▙▄▄▖▐▙█▟▌▝▚▄▞▘▐▌ ▐▌▐▌ ▐▌
EOF
echo -e "${NC}"
echo -e "${BLUE}════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  Project Installer${NC}"
echo -e "${BLUE}════════════════════════════════════════════════════${NC}"
echo ""

# Author information (stored in ~/.frameworkrc)
if [ -z "$FW_AUTHOR_NAME" ]; then
  echo -e "${YELLOW}First-time setup: Author information${NC}"
  echo ""
  echo -en "${YELLOW}Your name (optional):${NC} "
  eval "$READ_CMD FW_AUTHOR_NAME"

  echo -en "${YELLOW}Your email (optional):${NC} "
  eval "$READ_CMD FW_AUTHOR_EMAIL"

  echo -en "${YELLOW}Your affiliation (optional):${NC} "
  eval "$READ_CMD FW_AUTHOR_AFFILIATION"

  echo ""
  echo -e "${YELLOW}Default notebook format:${NC}"
  echo "  1. Quarto (.qmd) - recommended"
  echo "  2. RMarkdown (.Rmd)"
  echo ""
  echo -en "${YELLOW}Choose format (1-2) [1]:${NC} "
  eval "$READ_CMD FORMAT_CHOICE"

  case "$FORMAT_CHOICE" in
    2) FW_DEFAULT_FORMAT="rmarkdown" ;;
    *) FW_DEFAULT_FORMAT="quarto" ;;
  esac

  # Save to config file
  {
    echo "# Framework configuration"
    echo "# Edit this file to update your default author information"
    echo "FW_AUTHOR_NAME=\"$FW_AUTHOR_NAME\""
    echo "FW_AUTHOR_EMAIL=\"$FW_AUTHOR_EMAIL\""
    echo "FW_AUTHOR_AFFILIATION=\"$FW_AUTHOR_AFFILIATION\""
    echo "FW_DEFAULT_FORMAT=\"$FW_DEFAULT_FORMAT\""
  } > "$FRAMEWORK_RC"

  echo ""
  echo -e "${GREEN}✓ Saved to $FRAMEWORK_RC${NC}"
  echo ""
else
  echo -e "${GREEN}Using author: $FW_AUTHOR_NAME${NC}"
  echo ""
fi

# Get directory name from argument or prompt
PROJECT_DIR="${1}"

if [ -z "$PROJECT_DIR" ]; then
  while [ -z "$PROJECT_DIR" ] || [ -d "$PROJECT_DIR" ]; do
    echo -en "${YELLOW}Directory name:${NC} "
    eval "$READ_CMD PROJECT_DIR"
    if [ -z "$PROJECT_DIR" ]; then
      echo -e "${RED}Directory name cannot be empty. Please try again.${NC}"
    elif [ -d "$PROJECT_DIR" ]; then
      echo -e "${RED}Error: Directory '$PROJECT_DIR' already exists. Choose a different name.${NC}"
      PROJECT_DIR=""  # Reset to prompt again
    fi
  done
else
  # Check argument immediately
  if [ -d "$PROJECT_DIR" ]; then
    echo -e "${RED}Error: Directory '$PROJECT_DIR' already exists${NC}"
    exit 1
  fi
fi

echo ""

# Convert directory name to title case as default project name
# Remove hyphens/underscores, capitalize each word
PROJECT_NAME_DEFAULT=$(echo "$PROJECT_DIR" | sed 's/[-_]/ /g' | awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) tolower(substr($i,2));}1')

# Get project name (the human-readable title)
echo -en "${YELLOW}Project name [$PROJECT_NAME_DEFAULT]:${NC} "
eval "$READ_CMD PROJECT_NAME"

if [ -z "$PROJECT_NAME" ]; then
  PROJECT_NAME="$PROJECT_NAME_DEFAULT"
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

# Default notebook format
echo -e "${YELLOW}Default notebook format:${NC}"
echo "  1. Quarto (.qmd) - recommended"
echo "  2. RMarkdown (.Rmd)"
echo ""
echo -en "${YELLOW}Choose format (1-2) [1]:${NC} "
eval "$READ_CMD FORMAT_CHOICE"

case "$FORMAT_CHOICE" in
  2) PROJECT_DEFAULT_FORMAT="rmarkdown" ;;
  *) PROJECT_DEFAULT_FORMAT="quarto" ;;
esac

echo ""

# git
echo -e "${YELLOW}Initialize git repository? (y/n) [y]:${NC} "
eval "$READ_CMD USE_GIT_INPUT"
USE_GIT_INPUT=$(echo "$USE_GIT_INPUT" | tr '[:upper:]' '[:lower:]')

if [ "$USE_GIT_INPUT" = "n" ] || [ "$USE_GIT_INPUT" = "no" ]; then
  USE_GIT="FALSE"
else
  USE_GIT="TRUE"
fi

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
echo -e "${YELLOW}git:${NC} ${GREEN}$([ "$USE_GIT" = "TRUE" ] && echo "enabled" || echo "disabled")${NC}"
echo -e "${YELLOW}renv:${NC} ${GREEN}$([ "$USE_RENV" = "TRUE" ] && echo "enabled" || echo "disabled")${NC}"
echo -e "${BLUE}────────────────────────────────────────────────────${NC}"
echo ""

# Clone the repository
echo -e "${BLUE}Cloning framework-project template...${NC}"
git clone --quiet https://github.com/table1/framework-project "$PROJECT_DIR"

# Navigate into directory
cd "$PROJECT_DIR"

# Remove .git directory
rm -rf .git

# Clean up development files
rm -f CLAUDE.md .styler.R new-project.sh

# Run setup by calling init.R with environment variables
echo ""
echo -e "${BLUE}Initializing project...${NC}"
echo ""

# Export variables for init.R to read
export FW_PROJECT_NAME="$PROJECT_NAME"
export FW_PROJECT_TYPE="$PROJECT_TYPE"
export FW_USE_GIT="$USE_GIT"
export FW_USE_RENV="$USE_RENV"
export FW_AUTHOR_NAME="$FW_AUTHOR_NAME"
export FW_AUTHOR_EMAIL="$FW_AUTHOR_EMAIL"
export FW_AUTHOR_AFFILIATION="$FW_AUTHOR_AFFILIATION"
export FW_DEFAULT_FORMAT="$PROJECT_DEFAULT_FORMAT"
export FW_NON_INTERACTIVE="true"

# Pass through FW_DEV_MODE and FW_DEV_PATH if set
if [ -n "$FW_DEV_MODE" ]; then
  printf "${YELLOW}ℹ  Dev mode: Using local framework from %s${NC}\n" "$FW_DEV_PATH"
  export FW_DEV_MODE="$FW_DEV_MODE"
  export FW_DEV_PATH="$FW_DEV_PATH"
fi

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
