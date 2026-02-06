#!/bin/bash
# Milestone-Dev Boilerplate Setup Script
# Replaces {{TOKEN}} placeholders with your project values

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}╔══════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  Milestone-Dev Boilerplate Setup                 ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════════╝${NC}"
echo ""

# Accept arguments or prompt interactively
if [ $# -ge 6 ]; then
  PROJECT_NAME="$1"
  PROJECT_SLUG="$2"
  PROJECT_SLUG_HYPHEN="$3"
  OWNER_NAME="$4"
  OWNER_EMAIL="$5"
  GITHUB_ORG_REPO="$6"
else
  echo -e "${YELLOW}Enter your project details:${NC}"
  echo ""
  read -p "Project name (human-readable, e.g., 'My Platform'): " PROJECT_NAME
  read -p "Project slug (snake_case, e.g., 'my_platform'): " PROJECT_SLUG
  read -p "Project slug hyphen (kebab-case, e.g., 'my-platform'): " PROJECT_SLUG_HYPHEN
  read -p "Owner name (git author, e.g., 'Blake'): " OWNER_NAME
  read -p "Owner email (git email, e.g., 'blake@example.com'): " OWNER_EMAIL
  read -p "GitHub org/repo (e.g., 'myorg/my-platform'): " GITHUB_ORG_REPO
fi

echo ""
echo -e "${BLUE}Configuration:${NC}"
echo "  PROJECT_NAME:        $PROJECT_NAME"
echo "  PROJECT_SLUG:        $PROJECT_SLUG"
echo "  PROJECT_SLUG_HYPHEN: $PROJECT_SLUG_HYPHEN"
echo "  OWNER_NAME:          $OWNER_NAME"
echo "  OWNER_EMAIL:         $OWNER_EMAIL"
echo "  GITHUB_ORG_REPO:     $GITHUB_ORG_REPO"
echo ""

read -p "Proceed with these values? (y/n): " CONFIRM
if [ "$CONFIRM" != "y" ] && [ "$CONFIRM" != "Y" ]; then
  echo -e "${RED}Aborted.${NC}"
  exit 1
fi

echo ""
echo -e "${GREEN}Replacing tokens...${NC}"

# Find all files (excluding .git, node_modules, and setup scripts themselves)
FILES=$(find . -type f \
  -not -path './.git/*' \
  -not -path './node_modules/*' \
  -not -name 'setup.sh' \
  -not -name 'setup.ps1' \
  | sort)

REPLACED=0

for file in $FILES; do
  if grep -q '{{' "$file" 2>/dev/null; then
    sed -i.bak \
      -e "s|{{PROJECT_NAME}}|${PROJECT_NAME}|g" \
      -e "s|{{PROJECT_SLUG}}|${PROJECT_SLUG}|g" \
      -e "s|{{PROJECT_SLUG_HYPHEN}}|${PROJECT_SLUG_HYPHEN}|g" \
      -e "s|{{OWNER_NAME}}|${OWNER_NAME}|g" \
      -e "s|{{OWNER_EMAIL}}|${OWNER_EMAIL}|g" \
      -e "s|{{GITHUB_ORG_REPO}}|${GITHUB_ORG_REPO}|g" \
      "$file"
    rm -f "${file}.bak"
    echo -e "  ${GREEN}✓${NC} $file"
    ((REPLACED++))
  fi
done

echo ""
echo -e "${GREEN}Replaced tokens in $REPLACED file(s).${NC}"

# Self-delete setup scripts
echo ""
echo -e "${YELLOW}Cleaning up setup scripts...${NC}"
rm -f setup.sh setup.ps1
echo -e "  ${GREEN}✓${NC} Removed setup.sh"
echo -e "  ${GREEN}✓${NC} Removed setup.ps1"

# Configure git
echo ""
echo -e "${YELLOW}Configuring git...${NC}"
git config user.name "$OWNER_NAME"
git config user.email "$OWNER_EMAIL"
echo -e "  ${GREEN}✓${NC} Set git user.name to $OWNER_NAME"
echo -e "  ${GREEN}✓${NC} Set git user.email to $OWNER_EMAIL"

echo ""
echo -e "${GREEN}╔══════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║  Setup Complete!                                 ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${BLUE}Next steps:${NC}"
echo "  1. Review and customize CLAUDE.md (tech stack, patterns, commands)"
echo "  2. Create your first milestone branch:"
echo "     git checkout -b milestone/m0-project-bootstrap main"
echo "  3. Run the example milestone:"
echo "     /run-milestone m0"
echo "  4. Or create a new milestone:"
echo "     /create-milestone m1"
echo ""
echo -e "${BLUE}Available Claude Code skills:${NC}"
echo "  /interview           - Explore requirements and edge cases"
echo "  /create-milestone    - Generate milestone documentation"
echo "  /plan-review         - Review plans before execution"
echo "  /run-milestone       - Automated milestone development"
echo "  /pr-review           - Automated code review"
echo ""
