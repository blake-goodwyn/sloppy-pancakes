#!/usr/bin/env python3
"""
Issue Workflow Helper Script

This script helps you work through issues one-by-one following the issue-workflow.md plan.
It finds the next open issue, helps set up branches, and guides you through the workflow.

Usage:
    python scripts/workflow/next-issue.py [--milestone M1] [--list] [--start ISSUE_NUMBER]
"""

import argparse
import json
import os
import re
import subprocess
import sys
from pathlib import Path
from typing import Optional, Dict, List, Tuple

# Colors for terminal output
class Colors:
    RED = '\033[91m'
    GREEN = '\033[92m'
    YELLOW = '\033[93m'
    BLUE = '\033[94m'
    MAGENTA = '\033[95m'
    CYAN = '\033[96m'
    RESET = '\033[0m'
    BOLD = '\033[1m'

def print_colored(text: str, color: str = Colors.RESET):
    """Print colored text."""
    print(f"{color}{text}{Colors.RESET}")

def run_cmd(cmd: List[str], check: bool = True, capture: bool = False) -> Optional[str]:
    """Run a shell command."""
    try:
        result = subprocess.run(
            cmd,
            check=check,
            capture_output=capture,
            text=True
        )
        return result.stdout.strip() if capture else None
    except subprocess.CalledProcessError as e:
        if not check:
            return None
        print_colored(f"Error running command: {' '.join(cmd)}", Colors.RED)
        print_colored(f"Error: {e.stderr if hasattr(e, 'stderr') else str(e)}", Colors.RED)
        sys.exit(1)

def check_gh_cli() -> bool:
    """Check if GitHub CLI is installed and authenticated."""
    try:
        result = subprocess.run(
            ["gh", "--version"],
            capture_output=True,
            text=True,
            check=False
        )
        return result.returncode == 0
    except FileNotFoundError:
        return False

def get_current_branch() -> str:
    """Get the current git branch."""
    return run_cmd(["git", "branch", "--show-current"], capture=True) or ""

def get_milestone_issues(milestone: str) -> List[Dict]:
    """Get all issues for a milestone from GitHub."""
    if not check_gh_cli():
        return []

    try:
        # Get milestone title from _milestone.md
        milestone_file = Path(f"docs/03-build-notes/{milestone}/_milestone.md")
        if not milestone_file.exists():
            return []

        # Parse milestone title from frontmatter
        content = milestone_file.read_text()
        match = re.search(r'title:\s*["\'](.+?)["\']', content)
        if not match:
            return []

        milestone_title = match.group(1)

        # Query GitHub for issues
        cmd = [
            "gh", "issue", "list",
            "--milestone", milestone_title,
            "--json", "number,title,state,labels",
            "--limit", "100"
        ]
        output = run_cmd(cmd, capture=True, check=False)
        if not output:
            return []

        if output:
            issues = json.loads(output)
            return issues
        return []
    except (json.JSONDecodeError, subprocess.CalledProcessError, FileNotFoundError) as e:
        # Silently fail - GitHub CLI might not be available
        return []

def parse_issue_file(file_path: Path) -> Optional[Dict]:
    """Parse an issue markdown file and extract metadata."""
    if not file_path.exists():
        return None

    content = file_path.read_text()

    # Extract frontmatter
    frontmatter_match = re.search(r'^---\s*\n(.*?)\n---', content, re.DOTALL)
    if not frontmatter_match:
        return None

    frontmatter = frontmatter_match.group(1)

    # Parse fields
    title_match = re.search(r'^title:\s*["\'](.+?)["\']', frontmatter, re.MULTILINE)
    labels_match = re.search(r'^labels:\s*\[(.*?)\]', frontmatter, re.DOTALL)
    github_issue_match = re.search(r'^github_issue:\s*(\d+)', frontmatter, re.MULTILINE)

    # Extract body (everything after frontmatter)
    body = content[frontmatter_match.end():].strip()

    # Extract acceptance criteria
    ac_match = re.search(r'##\s+Acceptance\s+Criteria\s*\n(.*?)(?=\n##|\Z)', body, re.DOTALL | re.IGNORECASE)
    acceptance_criteria = []
    if ac_match:
        criteria_text = ac_match.group(1)
        # Find checkbox items
        criteria = re.findall(r'^[-*]\s+\[([ x])\]\s+(.+)$', criteria_text, re.MULTILINE)
        acceptance_criteria = [{"done": c[0].strip() == "x", "text": c[1].strip()} for c in criteria]

    return {
        "title": title_match.group(1) if title_match else "",
        "labels": labels_match.group(1) if labels_match else "",
        "github_issue": int(github_issue_match.group(1)) if github_issue_match else None,
        "body": body,
        "acceptance_criteria": acceptance_criteria,
        "file": file_path.name
    }

def find_next_issue(milestone: str) -> Optional[Tuple[Path, Dict]]:
    """Find the next open issue to work on."""
    milestone_dir = Path(f"docs/03-build-notes/{milestone}")
    if not milestone_dir.exists():
        print_colored(f"Error: Milestone directory not found: {milestone_dir}", Colors.RED)
        return None

    # Get GitHub issues to check which are open
    gh_issues = {issue["number"]: issue for issue in get_milestone_issues(milestone)}

    # Find all issue files (numbered files, excluding epic and milestone)
    issue_files = sorted([
        f for f in milestone_dir.glob("*.md")
        if f.name not in ["_milestone.md", "00-epic.md", "IMPLEMENTATION_PLAN.md"]
        and re.match(r'^\d+', f.name)
    ])

    for issue_file in issue_files:
        issue_data = parse_issue_file(issue_file)
        if not issue_data:
            continue

        # Check if issue is open on GitHub
        if issue_data["github_issue"]:
            gh_issue = gh_issues.get(issue_data["github_issue"])
            if gh_issue and gh_issue["state"] == "OPEN":
                return issue_file, issue_data
            # Skip closed issues
            elif gh_issue and gh_issue["state"] == "CLOSED":
                continue
        else:
            # If no GitHub issue number, assume it's not been created yet
            # This could be the next one to work on
            return issue_file, issue_data

    return None

def list_issues(milestone: str):
    """List all issues for a milestone."""
    milestone_dir = Path(f"docs/03-build-notes/{milestone}")
    if not milestone_dir.exists():
        print_colored(f"Error: Milestone directory not found: {milestone_dir}", Colors.RED)
        return

    gh_issues = {issue["number"]: issue for issue in get_milestone_issues(milestone)}

    issue_files = sorted([
        f for f in milestone_dir.glob("*.md")
        if f.name not in ["_milestone.md", "00-epic.md", "IMPLEMENTATION_PLAN.md"]
        and re.match(r'^\d+', f.name)
    ])

    print_colored(f"\n{'='*80}", Colors.BOLD)
    print_colored(f"Issues for Milestone {milestone.upper()}", Colors.BOLD)
    print_colored(f"{'='*80}\n", Colors.BOLD)

    for issue_file in issue_files:
        issue_data = parse_issue_file(issue_file)
        if not issue_data:
            continue

        status = "? Unknown"
        issue_num = ""

        if issue_data["github_issue"]:
            gh_issue = gh_issues.get(issue_data["github_issue"])
            if gh_issue:
                status = "Open" if gh_issue["state"] == "OPEN" else "Closed"
                issue_num = f"#{issue_data['github_issue']}"
            else:
                status = "Not found on GitHub"
                issue_num = f"#{issue_data['github_issue']}"
        else:
            status = "Not created"

        print_colored(f"{status:12} {issue_num:8} {issue_data['title']}", Colors.CYAN)
        print_colored(f"             File: {issue_file.name}\n", Colors.YELLOW)

def start_issue(milestone: str, issue_number: Optional[int] = None):
    """Start working on an issue."""
    # Find the issue
    if issue_number:
        # Find by GitHub issue number
        gh_issues = {issue["number"]: issue for issue in get_milestone_issues(milestone)}
        if issue_number not in gh_issues:
            print_colored(f"Error: Issue #{issue_number} not found in milestone", Colors.RED)
            return

        # Find the corresponding file
        milestone_dir = Path(f"docs/03-build-notes/{milestone}")
        issue_files = sorted([
            f for f in milestone_dir.glob("*.md")
            if f.name not in ["_milestone.md", "00-epic.md", "IMPLEMENTATION_PLAN.md"]
        ])

        issue_file = None
        for f in issue_files:
            issue_data = parse_issue_file(f)
            if issue_data and issue_data.get("github_issue") == issue_number:
                issue_file = f
                break

        if not issue_file:
            print_colored(f"Error: Could not find file for issue #{issue_number}", Colors.RED)
            return
    else:
        # Find next open issue
        result = find_next_issue(milestone)
        if not result:
            print_colored("No open issues found!", Colors.YELLOW)
            return
        issue_file, issue_data = result

    issue_data = parse_issue_file(issue_file)
    if not issue_data:
        print_colored(f"Error: Could not parse issue file: {issue_file}", Colors.RED)
        return

    print_colored(f"\n{'='*80}", Colors.BOLD)
    print_colored(f"Starting Work on Issue", Colors.BOLD)
    print_colored(f"{'='*80}\n", Colors.BOLD)

    print_colored(f"Title: {issue_data['title']}", Colors.CYAN)
    if issue_data['github_issue']:
        print_colored(f"Issue: #{issue_data['github_issue']}", Colors.CYAN)
    print_colored(f"File: {issue_file.name}\n", Colors.YELLOW)

    # Check current branch
    current_branch = get_current_branch()
    print_colored(f"Current branch: {current_branch}", Colors.BLUE)

    # Determine milestone branch
    milestone_branch = f"milestone/{milestone}"

    # Check if we need to switch branches
    if not current_branch.startswith("milestone/") and not current_branch.startswith("feat/"):
        print_colored(f"\nYou're not on a milestone or feature branch.", Colors.YELLOW)
        print_colored(f"Expected milestone branch: {milestone_branch}", Colors.YELLOW)
        response = input(f"\nSwitch to {milestone_branch}? (y/n): ").strip().lower()
        if response == 'y':
            run_cmd(["git", "checkout", milestone_branch])
            run_cmd(["git", "pull", "origin", milestone_branch])
            current_branch = milestone_branch

    # Determine if we need a feature branch
    print_colored(f"\n{'='*80}", Colors.BOLD)
    print_colored("Branch Strategy", Colors.BOLD)
    print_colored(f"{'='*80}\n", Colors.BOLD)

    # Check issue size from IMPLEMENTATION_PLAN.md
    plan_file = Path(f"docs/03-build-notes/{milestone}/IMPLEMENTATION_PLAN.md")
    needs_feature_branch = True  # Default to feature branch for safety

    if plan_file.exists():
        content = plan_file.read_text()
        # Look for issue in the plan
        issue_num = issue_data.get('github_issue')
        if issue_num:
            pattern = rf'#\s*{issue_num}[^\|]*\|[^\|]*\|[^\|]*\|[^\|]*\|[^\|]*\|\s*([^\|]+)'
            match = re.search(pattern, content)
            if match:
                size = match.group(1).strip().lower()
                if "small" in size or "direct on milestone" in size.lower():
                    needs_feature_branch = False

    if needs_feature_branch:
        # Create feature branch name
        issue_short = issue_file.stem.replace("-", "_")
        if issue_data['github_issue']:
            branch_name = f"feat/{milestone}-{issue_data['github_issue']}-{issue_short}"
        else:
            branch_name = f"feat/{milestone}-{issue_short}"

        print_colored(f"Recommended: Create feature branch", Colors.GREEN)
        print_colored(f"Branch name: {branch_name}", Colors.CYAN)

        if current_branch != branch_name:
            response = input(f"\nCreate and switch to {branch_name}? (y/n): ").strip().lower()
            if response == 'y':
                run_cmd(["git", "checkout", "-b", branch_name])
                print_colored(f"Created and switched to {branch_name}", Colors.GREEN)
    else:
        print_colored(f"Recommended: Work directly on milestone branch", Colors.GREEN)
        print_colored(f"Branch: {milestone_branch}", Colors.CYAN)

    # Show acceptance criteria
    if issue_data.get('acceptance_criteria'):
        print_colored(f"\n{'='*80}", Colors.BOLD)
        print_colored("Acceptance Criteria", Colors.BOLD)
        print_colored(f"{'='*80}\n", Colors.BOLD)
        for i, ac in enumerate(issue_data['acceptance_criteria'], 1):
            status = "[x]" if ac['done'] else "[ ]"
            print_colored(f"{status} {i}. {ac['text']}", Colors.CYAN)

    # Show next steps
    print_colored(f"\n{'='*80}", Colors.BOLD)
    print_colored("Next Steps", Colors.BOLD)
    print_colored(f"{'='*80}\n", Colors.BOLD)

    steps = [
        "1. Review the issue file and IMPLEMENTATION_PLAN.md",
        "2. Implement the changes with tests",
        "3. Run tests: pytest tests/",
        "4. Run linter: ruff check src/",
        "5. Commit with: git commit -m 'feat(m{n}): Description\n\nCloses #XX'",
        "6. Push and create draft PR: gh pr create --draft",
        "7. Update PR continuously as you work",
        "8. Mark ready for review when acceptance criteria are met"
    ]

    for step in steps:
        print_colored(f"  {step}", Colors.YELLOW)

    print_colored(f"\n{'='*80}\n", Colors.BOLD)

def main():
    parser = argparse.ArgumentParser(
        description="Issue Workflow Helper - Work through issues one-by-one"
    )
    parser.add_argument(
        "--milestone",
        default="m1",
        help="Milestone to work on (default: m1)"
    )
    parser.add_argument(
        "--list",
        action="store_true",
        help="List all issues for the milestone"
    )
    parser.add_argument(
        "--start",
        type=int,
        help="Start working on a specific issue number"
    )

    args = parser.parse_args()

    if args.list:
        list_issues(args.milestone)
    else:
        start_issue(args.milestone, args.start)

if __name__ == "__main__":
    main()
