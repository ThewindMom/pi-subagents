#!/usr/bin/env bash
set -euo pipefail

# Sync this fork with upstream (origin) using MERGE (not rebase).
# Assumes:
#   origin = upstream (nicobailon/pi-subagents)
#   fork   = your fork (ThewindMom/pi-subagents)
#
# Usage:
#   ./scripts/sync-upstream-merge.sh

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

if ! git rev-parse --git-dir >/dev/null 2>&1; then
  echo "Not a git repository: $repo_root" >&2
  exit 1
fi

if ! git remote get-url origin >/dev/null 2>&1; then
  echo "Missing remote: origin" >&2
  exit 1
fi
if ! git remote get-url fork >/dev/null 2>&1; then
  echo "Missing remote: fork" >&2
  exit 1
fi

# Ensure we're on main
if [ -n "$(git status --porcelain)" ]; then
  echo "Working tree is dirty. Commit/stash first." >&2
  git status --porcelain >&2 || true
  exit 1
fi

git fetch origin

git checkout main
# Make sure local main matches fork/main (your canonical branch)
git pull --ff-only fork main

# Merge upstream changes (creates a merge commit if needed)
if git merge --no-edit origin/main; then
  :
else
  echo "Merge failed. Resolve conflicts, then run:" >&2
  echo "  git add <files> && git commit" >&2
  echo "  git push fork main" >&2
  exit 1
fi

git push fork main

echo ""
echo "Synced. Current HEAD:" 
echo "  $(git rev-parse HEAD)"
