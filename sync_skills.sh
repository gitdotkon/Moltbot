#!/bin/bash

# Sync script for Moltbot skills to GitHub
# Usage: ./sync_skills.sh

REPO_DIR="/tmp/Moltbot"
SOURCE_DIR="/Users/kon/clawd"
MOLTBOOK_SOURCE="/Users/kon/clawd/moltbook-skill"

echo "🚀 Syncing skills to GitHub..."

# Pull latest from GitHub
cd "$REPO_DIR"
git pull origin main

# Copy skills
echo "📁 Copying skills..."
rm -rf "$REPO_DIR/skills"
mkdir -p "$REPO_DIR/skills"

cp -r "$SOURCE_DIR/skills/ppt-assistant" "$REPO_DIR/skills/"
cp -r "$SOURCE_DIR/skills/nano-pdf" "$REPO_DIR/skills/"
cp -r "$SOURCE_DIR/skills/github" "$REPO_DIR/skills/"
cp -r "$SOURCE_DIR/skills/coding-agent" "$REPO_DIR/skills/"
cp -r "$SOURCE_DIR/skills/social-trending" "$REPO_DIR/skills/"
cp -r "$SOURCE_DIR/skills/price-compare" "$REPO_DIR/skills/"
mkdir -p "$REPO_DIR/skills/moltbook"
cp "$MOLTBOOK_SOURCE/SKILL.md" "$REPO_DIR/skills/moltbook/"

# Commit and push
echo "📝 Committing changes..."
git add -A
git commit -m "Update skills - $(date '+%Y-%m-%d %H:%M:%S')"

echo "⬆️  Pushing to GitHub..."
git push origin main

echo "✅ Done!"
