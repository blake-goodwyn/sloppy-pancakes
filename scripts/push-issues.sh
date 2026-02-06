#!/bin/bash
# Script to push GitHub issues from markdown files
# Usage: ./scripts/push-issues.sh <milestone> <file|--all> [--dry-run] [--force]

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_NOTES_DIR="$SCRIPT_DIR/../docs/03-build-notes"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Parse arguments
MILESTONE=""
TARGET=""
DRY_RUN=false
FORCE=false

while [[ $# -gt 0 ]]; do
  case $1 in
    --dry-run)
      DRY_RUN=true
      shift
      ;;
    --force)
      FORCE=true
      shift
      ;;
    --all)
      TARGET="--all"
      shift
      ;;
    -h|--help)
      echo "Usage: $0 <milestone> <file|--all> [--dry-run] [--force]"
      echo ""
      echo "Arguments:"
      echo "  milestone    Milestone directory name (e.g., m0, m1)"
      echo "  file         Specific issue file to push (e.g., 01-project-structure.md)"
      echo "  --all        Push all issues in the milestone directory"
      echo ""
      echo "Options:"
      echo "  --dry-run    Preview actions without creating issues"
      echo "  --force      Push even if github_issue is already set"
      echo "  -h, --help   Show this help message"
      exit 0
      ;;
    *)
      if [ -z "$MILESTONE" ]; then
        MILESTONE="$1"
      elif [ -z "$TARGET" ]; then
        TARGET="$1"
      fi
      shift
      ;;
  esac
done

# Validate arguments
if [ -z "$MILESTONE" ] || [ -z "$TARGET" ]; then
  echo -e "${RED}Error: Missing required arguments${NC}"
  echo "Usage: $0 <milestone> <file|--all> [--dry-run] [--force]"
  exit 1
fi

MILESTONE_DIR="$BUILD_NOTES_DIR/$MILESTONE"

if [ ! -d "$MILESTONE_DIR" ]; then
  echo -e "${RED}Error: Milestone directory not found: $MILESTONE_DIR${NC}"
  exit 1
fi

# Function to parse YAML frontmatter
parse_frontmatter() {
  local file="$1"
  local field="$2"

  # Extract frontmatter between --- markers
  local frontmatter=$(sed -n '/^---$/,/^---$/p' "$file" | sed '1d;$d')

  case "$field" in
    title)
      echo "$frontmatter" | grep -E '^title:' | sed 's/^title:[[:space:]]*//' | sed 's/^["'"'"']\(.*\)["'"'"']$/\1/'
      ;;
    labels)
      echo "$frontmatter" | grep -E '^labels:' | sed 's/^labels:[[:space:]]*//' | \
        sed 's/\[//g' | sed 's/\]//g' | sed 's/"//g' | sed "s/'//g" | tr -d ' '
      ;;
    github_issue)
      echo "$frontmatter" | grep -E '^github_issue:' | sed 's/^github_issue:[[:space:]]*//'
      ;;
  esac
}

# Function to get issue body (everything after frontmatter)
get_issue_body() {
  local file="$1"
  sed -n '/^---$/,/^---$/!p' "$file" | tail -n +2
}

# Function to check if issue exists by title
check_issue_exists() {
  local title="$1"
  local milestone_title="$2"

  local existing=$(gh issue list --milestone "$milestone_title" --search "in:title $title" --json title --jq '.[].title' 2>/dev/null | grep -F "$title" | head -n 1 || true)

  if [ -n "$existing" ]; then
    echo "exists"
  else
    echo ""
  fi
}

# Function to get or create milestone
ensure_milestone() {
  local milestone_file="$MILESTONE_DIR/_milestone.md"

  if [ ! -f "$milestone_file" ]; then
    echo -e "${RED}Error: Milestone file not found: $milestone_file${NC}"
    exit 1
  fi

  local milestone_title=$(parse_frontmatter "$milestone_file" "title")
  local milestone_desc=$(get_issue_body "$milestone_file" | head -n 5 | tr '\n' ' ')

  if [ -z "$milestone_title" ]; then
    echo -e "${RED}Error: Could not parse milestone title from $milestone_file${NC}"
    exit 1
  fi

  echo -e "${BLUE}Milestone: $milestone_title${NC}" >&2

  local existing=$(gh api repos/:owner/:repo/milestones --jq ".[] | select(.title == \"$milestone_title\") | .number" 2>/dev/null | head -n 1)

  if [ -n "$existing" ]; then
    echo -e "${GREEN}  Milestone exists (number: $existing)${NC}" >&2
  else
    if [ "$DRY_RUN" = true ]; then
      echo -e "${YELLOW}  [DRY-RUN] Would create milestone: $milestone_title${NC}" >&2
    else
      echo -e "${YELLOW}  Creating milestone...${NC}" >&2
      gh api repos/:owner/:repo/milestones \
        -f title="$milestone_title" \
        -f state="open" \
        -f description="$milestone_desc" > /dev/null
      echo -e "${GREEN}  Milestone created${NC}" >&2
    fi
  fi

  echo "$milestone_title"
}

# Function to push a single issue
push_issue() {
  local file="$1"
  local milestone_title="$2"
  local filename=$(basename "$file")

  echo ""
  echo -e "${BLUE}Processing: $filename${NC}"

  local title=$(parse_frontmatter "$file" "title")
  local labels=$(parse_frontmatter "$file" "labels")
  local github_issue=$(parse_frontmatter "$file" "github_issue")

  if [ -z "$title" ]; then
    echo -e "${RED}  Error: Could not parse title from $file${NC}"
    return 1
  fi

  echo "  Title: $title"
  echo "  Labels: $labels"

  if [ -n "$github_issue" ] && [ "$FORCE" != true ]; then
    echo -e "${YELLOW}  Skipped: Already linked to issue #$github_issue (use --force to override)${NC}"
    return 0
  fi

  local exists=$(check_issue_exists "$title" "$milestone_title")
  if [ -n "$exists" ] && [ "$FORCE" != true ]; then
    echo -e "${YELLOW}  Skipped: Issue with this title already exists on GitHub${NC}"
    return 0
  fi

  local body=$(get_issue_body "$file")

  if [ "$DRY_RUN" = true ]; then
    echo -e "${YELLOW}  [DRY-RUN] Would create issue: $title${NC}"
    return 0
  fi

  echo -e "${GREEN}  Creating issue...${NC}"
  local issue_url=$(gh issue create \
    --title "$title" \
    --body "$body" \
    --label "$labels" \
    --milestone "$milestone_title")

  local issue_num=$(echo "$issue_url" | grep -oE '/issues/[0-9]+' | grep -oE '[0-9]+')

  if [ -n "$issue_num" ]; then
    echo -e "${GREEN}  Created: #$issue_num${NC}"
    echo "  URL: $issue_url"
  else
    echo -e "${RED}  Error: Failed to create issue${NC}"
    return 1
  fi
}

# Main execution
echo "========================================"
echo "GitHub Issues Push Script"
echo "========================================"
echo ""

if [ "$DRY_RUN" = true ]; then
  echo -e "${YELLOW}*** DRY-RUN MODE - No issues will be created ***${NC}"
  echo ""
fi

MILESTONE_TITLE=$(ensure_milestone)
echo ""

if [ "$TARGET" = "--all" ]; then
  FILES=$(find "$MILESTONE_DIR" -maxdepth 1 -name "*.md" ! -name "_milestone.md" | sort)
else
  if [ ! -f "$MILESTONE_DIR/$TARGET" ]; then
    echo -e "${RED}Error: File not found: $MILESTONE_DIR/$TARGET${NC}"
    exit 1
  fi
  FILES="$MILESTONE_DIR/$TARGET"
fi

FILE_COUNT=$(echo "$FILES" | wc -l | tr -d ' ')
echo "Found $FILE_COUNT issue file(s) to process"

CREATED=0
SKIPPED=0
ERRORS=0

for file in $FILES; do
  if push_issue "$file" "$MILESTONE_TITLE"; then
    if [ "$DRY_RUN" != true ]; then
      ((CREATED++)) || true
    fi
  else
    ((ERRORS++)) || true
  fi
done

echo ""
echo "========================================"
echo "Summary"
echo "========================================"
if [ "$DRY_RUN" = true ]; then
  echo -e "${YELLOW}DRY-RUN: No issues were created${NC}"
else
  echo "Processed: $FILE_COUNT file(s)"
fi
echo ""
echo "Done!"
