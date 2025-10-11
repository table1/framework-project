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

# Get project name from argument or prompt
PROJECT_NAME="${1}"

if [ -z "$PROJECT_NAME" ]; then
  echo -e "${YELLOW}Project name:${NC} "
  read -r PROJECT_NAME
  if [ -z "$PROJECT_NAME" ]; then
    echo -e "${RED}Error: Project name is required${NC}"
    exit 1
  fi
fi

echo -e "${BLUE}════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  Framework Project Installer${NC}"
echo -e "${BLUE}════════════════════════════════════════════════════${NC}"
echo ""
echo -e "${YELLOW}Creating project:${NC} ${GREEN}$PROJECT_NAME${NC}"
echo ""

# Check if directory already exists
if [ -d "$PROJECT_NAME" ]; then
  echo -e "${RED}Error: Directory '$PROJECT_NAME' already exists${NC}"
  exit 1
fi

# Clone the repository
echo -e "${BLUE}Cloning framework-project template...${NC}"
git clone --quiet https://github.com/table1/framework-project "$PROJECT_NAME"

# Navigate into directory
cd "$PROJECT_NAME"

# Remove .git directory
rm -rf .git

# Run setup
echo ""
echo -e "${BLUE}Running setup...${NC}"
echo ""
./setup.sh

echo ""
echo -e "${GREEN}✓ Project '$PROJECT_NAME' created successfully!${NC}"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo "  cd $PROJECT_NAME"
echo "  R"
echo "  > library(framework)"
echo "  > scaffold()"
