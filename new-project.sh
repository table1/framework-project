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
  # Read author info if not already set
  if [ -z "$FW_AUTHOR_NAME" ]; then
    FW_AUTHOR_NAME=$(grep "^FW_AUTHOR_NAME=" "$FRAMEWORK_RC" 2>/dev/null | cut -d'=' -f2 | tr -d '"')
  fi
  if [ -z "$FW_AUTHOR_EMAIL" ]; then
    FW_AUTHOR_EMAIL=$(grep "^FW_AUTHOR_EMAIL=" "$FRAMEWORK_RC" 2>/dev/null | cut -d'=' -f2 | tr -d '"')
  fi
  if [ -z "$FW_AUTHOR_AFFILIATION" ]; then
    FW_AUTHOR_AFFILIATION=$(grep "^FW_AUTHOR_AFFILIATION=" "$FRAMEWORK_RC" 2>/dev/null | cut -d'=' -f2 | tr -d '"')
  fi
  if [ -z "$FW_DEFAULT_FORMAT" ]; then
    FW_DEFAULT_FORMAT=$(grep "^FW_DEFAULT_FORMAT=" "$FRAMEWORK_RC" 2>/dev/null | cut -d'=' -f2 | tr -d '"')
  fi

  # Read IDE/AI preferences only if not already set (from framework-global)
  if [ -z "$FW_IDES" ]; then
    FW_IDES=$(grep "^FW_IDES=" "$FRAMEWORK_RC" 2>/dev/null | cut -d'=' -f2 | tr -d '"')
  fi
  if [ -z "$FW_AI_SUPPORT" ]; then
    FW_AI_SUPPORT=$(grep "^FW_AI_SUPPORT=" "$FRAMEWORK_RC" 2>/dev/null | cut -d'=' -f2 | tr -d '"')
  fi
  if [ -z "$FW_AI_ASSISTANTS" ]; then
    FW_AI_ASSISTANTS=$(grep "^FW_AI_ASSISTANTS=" "$FRAMEWORK_RC" 2>/dev/null | cut -d'=' -f2 | tr -d '"')
  fi
  if [ -z "$FW_AI_CANONICAL_DEFAULT" ]; then
    FW_AI_CANONICAL_DEFAULT=$(grep "^FW_AI_CANONICAL_DEFAULT=" "$FRAMEWORK_RC" 2>/dev/null | cut -d'=' -f2 | tr -d '"')
  fi
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

# IDE preferences
echo -e "${YELLOW}Which IDE/editor will you use for this project?${NC}"
echo "  1. Positron / VS Code"
echo "  2. RStudio"
echo "  3. Both"
echo "  4. Neither (other editor)"
echo ""

# Set default based on global FW_IDES or default to option 1 (vscode)
IDE_DEFAULT=1
if [ "$FW_IDES" = "rstudio" ]; then
  IDE_DEFAULT=2
elif [ "$FW_IDES" = "rstudio,vscode" ] || [ "$FW_IDES" = "vscode,rstudio" ]; then
  IDE_DEFAULT=3
elif [ "$FW_IDES" = "none" ]; then
  IDE_DEFAULT=4
fi

echo -en "${YELLOW}Choose IDE (1-4) [$IDE_DEFAULT]:${NC} "
eval "$READ_CMD IDE_CHOICE"

# Use default if empty
if [ -z "$IDE_CHOICE" ]; then
  IDE_CHOICE="$IDE_DEFAULT"
fi

case "$IDE_CHOICE" in
  1) PROJECT_IDES="vscode" ;;
  2) PROJECT_IDES="rstudio" ;;
  3) PROJECT_IDES="rstudio,vscode" ;;
  4) PROJECT_IDES="none" ;;
  *) PROJECT_IDES="$FW_IDES" ;;  # Fallback to global default
esac

echo ""

# AI assistant preferences
echo -e "${YELLOW}Create AI assistant instruction files for this project?${NC}"
echo "These files provide context about Framework conventions to AI coding assistants."
echo "You can easily update them with important context specific to your project."
echo ""

# Set default based on global FW_AI_SUPPORT
AI_DEFAULT="y"
if [ "$FW_AI_SUPPORT" = "never" ]; then
  AI_DEFAULT="n"
fi

echo -en "${YELLOW}Enable AI assistant support? (y/n) [$AI_DEFAULT]:${NC} "
eval "$READ_CMD AI_RESPONSE"

# Use default if empty
if [ -z "$AI_RESPONSE" ]; then
  AI_RESPONSE="$AI_DEFAULT"
fi

if [ "$AI_RESPONSE" = "n" ] || [ "$AI_RESPONSE" = "N" ]; then
  PROJECT_AI_SUPPORT="never"
  PROJECT_AI_ASSISTANTS=""
else
  # Ask which assistants
  echo ""
  echo -e "${YELLOW}Which AI assistants do you use?${NC}"
  echo "  1. Claude Code"
  echo "  2. GitHub Copilot"
  echo "  3. AGENTS.md (OpenAI Codex and others)"
  echo "  4. All of the above"
  echo ""

  # Set default based on global FW_AI_ASSISTANTS or default to all
  ASSISTANTS_DEFAULT=4
  if [ "$FW_AI_ASSISTANTS" = "claude" ]; then
    ASSISTANTS_DEFAULT=1
  elif [ "$FW_AI_ASSISTANTS" = "copilot" ]; then
    ASSISTANTS_DEFAULT=2
  elif [ "$FW_AI_ASSISTANTS" = "agents" ]; then
    ASSISTANTS_DEFAULT=3
  fi

  echo -en "${YELLOW}Enter numbers (e.g., 1,3 or 4 for all) [$ASSISTANTS_DEFAULT]:${NC} "
  eval "$READ_CMD ASSISTANTS_SELECTION"

  # Use default if empty
  if [ -z "$ASSISTANTS_SELECTION" ]; then
    ASSISTANTS_SELECTION="$ASSISTANTS_DEFAULT"
  fi

  # Parse selection
  PROJECT_AI_ASSISTANTS=""
  if [ "$ASSISTANTS_SELECTION" = "4" ]; then
    PROJECT_AI_ASSISTANTS="claude,copilot,agents"
  else
    if echo "$ASSISTANTS_SELECTION" | grep -q "1"; then PROJECT_AI_ASSISTANTS="claude"; fi
    if echo "$ASSISTANTS_SELECTION" | grep -q "2"; then
      if [ -n "$PROJECT_AI_ASSISTANTS" ]; then PROJECT_AI_ASSISTANTS="$PROJECT_AI_ASSISTANTS,copilot"; else PROJECT_AI_ASSISTANTS="copilot"; fi
    fi
    if echo "$ASSISTANTS_SELECTION" | grep -q "3"; then
      if [ -n "$PROJECT_AI_ASSISTANTS" ]; then PROJECT_AI_ASSISTANTS="$PROJECT_AI_ASSISTANTS,agents"; else PROJECT_AI_ASSISTANTS="agents"; fi
    fi
  fi

  if [ -z "$PROJECT_AI_ASSISTANTS" ]; then
    PROJECT_AI_ASSISTANTS="claude"  # Default to Claude if nothing selected
  fi

  PROJECT_AI_SUPPORT="yes"
fi

echo ""

# Git hooks configuration (only if git is enabled)
if [ "$USE_GIT" = "TRUE" ]; then
  echo -e "${YELLOW}Git Commit Hooks${NC}"
  echo "These hooks run automatically before each commit."
  echo ""

  # Ask about AI sync hook (only if AI support enabled)
  if [ "$PROJECT_AI_SUPPORT" = "yes" ]; then
    echo -en "${YELLOW}Sync AI assistant files before each commit? (y/n) [y]:${NC} "
    eval "$READ_CMD AI_SYNC_RESPONSE"

    # Use default if empty
    if [ -z "$AI_SYNC_RESPONSE" ]; then
      AI_SYNC_RESPONSE="y"
    fi

    if [ "$AI_SYNC_RESPONSE" = "y" ] || [ "$AI_SYNC_RESPONSE" = "Y" ]; then
      PROJECT_HOOK_AI_SYNC="TRUE"
    else
      PROJECT_HOOK_AI_SYNC="FALSE"
    fi
  else
    PROJECT_HOOK_AI_SYNC="FALSE"
  fi

  # Ask about data security hook
  echo -en "${YELLOW}Scan for secrets/credentials before each commit? (y/n) [y]:${NC} "
  eval "$READ_CMD SECURITY_RESPONSE"

  # Use default if empty
  if [ -z "$SECURITY_RESPONSE" ]; then
    SECURITY_RESPONSE="y"
  fi

  if [ "$SECURITY_RESPONSE" = "y" ] || [ "$SECURITY_RESPONSE" = "Y" ]; then
    PROJECT_HOOK_DATA_SECURITY="TRUE"
  else
    PROJECT_HOOK_DATA_SECURITY="FALSE"
  fi

  # Set hooks enabled flag
  if [ "$PROJECT_HOOK_AI_SYNC" = "TRUE" ] || [ "$PROJECT_HOOK_DATA_SECURITY" = "TRUE" ]; then
    PROJECT_HOOKS_ENABLED="TRUE"
  else
    PROJECT_HOOKS_ENABLED="FALSE"
  fi

  # If AI sync is enabled, determine canonical file
  if [ "$PROJECT_HOOK_AI_SYNC" = "TRUE" ] && [ "$PROJECT_AI_SUPPORT" = "yes" ]; then
    # Count how many assistants are enabled
    ASSISTANT_COUNT=0
    if echo "$PROJECT_AI_ASSISTANTS" | grep -q "agents"; then
      ASSISTANT_COUNT=$((ASSISTANT_COUNT + 1))
    fi
    if echo "$PROJECT_AI_ASSISTANTS" | grep -q "claude"; then
      ASSISTANT_COUNT=$((ASSISTANT_COUNT + 1))
    fi
    if echo "$PROJECT_AI_ASSISTANTS" | grep -q "copilot"; then
      ASSISTANT_COUNT=$((ASSISTANT_COUNT + 1))
    fi

    # If only one assistant, auto-select its file as canonical
    if [ "$ASSISTANT_COUNT" -eq 1 ]; then
      if echo "$PROJECT_AI_ASSISTANTS" | grep -q "agents"; then
        PROJECT_AI_CANONICAL="AGENTS.md"
      elif echo "$PROJECT_AI_ASSISTANTS" | grep -q "claude"; then
        PROJECT_AI_CANONICAL="CLAUDE.md"
      elif echo "$PROJECT_AI_ASSISTANTS" | grep -q "copilot"; then
        PROJECT_AI_CANONICAL=".github/copilot-instructions.md"
      fi
    else
      # Multiple assistants - ask which should be canonical
      echo ""
      echo -e "${YELLOW}Which AI file should be the canonical source?${NC}"
      echo "Other files will be synced from this one."
      echo ""

      # Build options based on selected assistants
      CANONICAL_OPTIONS=()
      CANONICAL_OPTION_NUM=1
      CANONICAL_DEFAULT_NUM=1

      if echo "$PROJECT_AI_ASSISTANTS" | grep -q "agents"; then
        echo "  ${CANONICAL_OPTION_NUM}. AGENTS.md (recommended - supports most assistants)"
        CANONICAL_OPTIONS[$CANONICAL_OPTION_NUM]="AGENTS.md"
        if [ "$FW_AI_CANONICAL_DEFAULT" = "AGENTS.md" ]; then
          CANONICAL_DEFAULT_NUM=$CANONICAL_OPTION_NUM
        fi
        CANONICAL_OPTION_NUM=$((CANONICAL_OPTION_NUM + 1))
      fi

      if echo "$PROJECT_AI_ASSISTANTS" | grep -q "claude"; then
        echo "  ${CANONICAL_OPTION_NUM}. CLAUDE.md"
        CANONICAL_OPTIONS[$CANONICAL_OPTION_NUM]="CLAUDE.md"
        if [ "$FW_AI_CANONICAL_DEFAULT" = "CLAUDE.md" ]; then
          CANONICAL_DEFAULT_NUM=$CANONICAL_OPTION_NUM
        fi
        CANONICAL_OPTION_NUM=$((CANONICAL_OPTION_NUM + 1))
      fi

      if echo "$PROJECT_AI_ASSISTANTS" | grep -q "copilot"; then
        echo "  ${CANONICAL_OPTION_NUM}. .github/copilot-instructions.md"
        CANONICAL_OPTIONS[$CANONICAL_OPTION_NUM]=".github/copilot-instructions.md"
        if [ "$FW_AI_CANONICAL_DEFAULT" = ".github/copilot-instructions.md" ]; then
          CANONICAL_DEFAULT_NUM=$CANONICAL_OPTION_NUM
        fi
        CANONICAL_OPTION_NUM=$((CANONICAL_OPTION_NUM + 1))
      fi

      echo ""
      echo -en "${YELLOW}Choose canonical file (1-$((CANONICAL_OPTION_NUM - 1))) [$CANONICAL_DEFAULT_NUM]:${NC} "
      eval "$READ_CMD CANONICAL_CHOICE"

      # Use default if empty
      if [ -z "$CANONICAL_CHOICE" ]; then
        CANONICAL_CHOICE="$CANONICAL_DEFAULT_NUM"
      fi

      PROJECT_AI_CANONICAL="${CANONICAL_OPTIONS[$CANONICAL_CHOICE]}"

      # Fallback to AGENTS.md if nothing selected
      if [ -z "$PROJECT_AI_CANONICAL" ]; then
        PROJECT_AI_CANONICAL="AGENTS.md"
      fi
    fi
  else
    PROJECT_AI_CANONICAL=""
  fi

  echo ""
else
  PROJECT_HOOKS_ENABLED="FALSE"
  PROJECT_HOOK_AI_SYNC="FALSE"
  PROJECT_HOOK_DATA_SECURITY="FALSE"
  PROJECT_AI_CANONICAL=""
fi

echo -e "${BLUE}────────────────────────────────────────────────────${NC}"
echo -e "${YELLOW}Project name:${NC} ${GREEN}$PROJECT_NAME${NC}"
echo -e "${YELLOW}Directory:${NC} ${GREEN}$PROJECT_DIR${NC}"
echo -e "${YELLOW}Type:${NC} ${GREEN}$PROJECT_TYPE${NC}"
echo -e "${YELLOW}git:${NC} ${GREEN}$([ "$USE_GIT" = "TRUE" ] && echo "enabled" || echo "disabled")${NC}"
echo -e "${YELLOW}renv:${NC} ${GREEN}$([ "$USE_RENV" = "TRUE" ] && echo "enabled" || echo "disabled")${NC}"

# Display IDE selection
IDE_DISPLAY=""
case "$PROJECT_IDES" in
  vscode) IDE_DISPLAY="Positron / VS Code" ;;
  rstudio) IDE_DISPLAY="RStudio" ;;
  rstudio,vscode|vscode,rstudio) IDE_DISPLAY="Both" ;;
  none) IDE_DISPLAY="None" ;;
  *) IDE_DISPLAY="$PROJECT_IDES" ;;
esac
echo -e "${YELLOW}IDE:${NC} ${GREEN}$IDE_DISPLAY${NC}"

# Display AI assistant selection
if [ "$PROJECT_AI_SUPPORT" = "never" ]; then
  echo -e "${YELLOW}AI assistants:${NC} ${GREEN}disabled${NC}"
else
  AI_DISPLAY=""
  case "$PROJECT_AI_ASSISTANTS" in
    claude,copilot,agents|claude,agents,copilot|copilot,claude,agents|copilot,agents,claude|agents,claude,copilot|agents,copilot,claude)
      AI_DISPLAY="All (Claude, Copilot, AGENTS.md)"
      ;;
    claude) AI_DISPLAY="Claude Code" ;;
    copilot) AI_DISPLAY="GitHub Copilot" ;;
    agents) AI_DISPLAY="AGENTS.md" ;;
    *)
      # Handle comma-separated combinations
      AI_DISPLAY=$(echo "$PROJECT_AI_ASSISTANTS" | sed 's/claude/Claude/g; s/copilot/Copilot/g; s/agents/AGENTS.md/g; s/,/, /g')
      ;;
  esac
  echo -e "${YELLOW}AI assistants:${NC} ${GREEN}$AI_DISPLAY${NC}"
fi

# Display git hooks if git enabled
if [ "$USE_GIT" = "TRUE" ] && [ "$PROJECT_HOOKS_ENABLED" = "TRUE" ]; then
  HOOKS_DISPLAY=""
  if [ "$PROJECT_HOOK_AI_SYNC" = "TRUE" ] && [ "$PROJECT_HOOK_DATA_SECURITY" = "TRUE" ]; then
    HOOKS_DISPLAY="AI sync, Data security"
  elif [ "$PROJECT_HOOK_AI_SYNC" = "TRUE" ]; then
    HOOKS_DISPLAY="AI sync"
  elif [ "$PROJECT_HOOK_DATA_SECURITY" = "TRUE" ]; then
    HOOKS_DISPLAY="Data security"
  else
    HOOKS_DISPLAY="None"
  fi

  echo -e "${YELLOW}Git hooks:${NC} ${GREEN}$HOOKS_DISPLAY${NC}"

  if [ "$PROJECT_HOOK_AI_SYNC" = "TRUE" ] && [ -n "$PROJECT_AI_CANONICAL" ]; then
    echo -e "${YELLOW}AI canonical:${NC} ${GREEN}$PROJECT_AI_CANONICAL${NC}"
  fi
fi

echo -e "${BLUE}────────────────────────────────────────────────────${NC}"
echo ""

# Clone the repository
echo -e "${BLUE}Cloning framework-project template...${NC}"
git clone --quiet https://github.com/table1/framework-project "$PROJECT_DIR"

# Navigate into directory
cd "$PROJECT_DIR"

# Remove .git directory
rm -rf .git

# Clean up: remove installer script and maintainer files before git init
rm -f new-project.sh CLAUDE.md

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
export FW_IDES="$PROJECT_IDES"
export FW_AI_SUPPORT="$PROJECT_AI_SUPPORT"
export FW_AI_ASSISTANTS="$PROJECT_AI_ASSISTANTS"
export FW_HOOKS_ENABLED="$PROJECT_HOOKS_ENABLED"
export FW_HOOK_AI_SYNC="$PROJECT_HOOK_AI_SYNC"
export FW_HOOK_DATA_SECURITY="$PROJECT_HOOK_DATA_SECURITY"
export FW_AI_CANONICAL="$PROJECT_AI_CANONICAL"
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
