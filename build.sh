#!/usr/bin/env bash
# Build the site from the Google Doc. Output: _site/index.html
# Needs: curl, pandoc.
set -euo pipefail

cd "$(dirname "$0")"

# The Doc ID is not stored in this repository.
# GitHub Actions gets it from the GOOGLE_DOC_ID secret.
# On your own computer, put it in a file named .doc-id (git ignores that file).
DOC_ID="${DOC_ID:-$(cat .doc-id 2>/dev/null || true)}"
if [ -z "$DOC_ID" ]; then
  echo "Error: no Doc ID. Set DOC_ID or create a .doc-id file." >&2
  exit 1
fi
DOC_URL="https://docs.google.com/document/d/${DOC_ID}/export?format=md"

rm -rf _site
mkdir -p _site

# 1. Fetch the Doc as Markdown. The Doc must be shared as
#    "Anyone with the link can view", or Google sends a login page.
curl --fail --silent --show-error --location "$DOC_URL" -o _site/content.md

if ! head -n 1 _site/content.md | grep -q '^# '; then
  echo "Error: the Doc did not come back as Markdown that starts with a title." >&2
  echo "Check that the Doc is shared as 'Anyone with the link can view'" >&2
  echo "and that its first line uses the Title or Heading 1 style." >&2
  exit 1
fi

# 2. Clean up what the Google export adds: bold marks inside headings,
#    and spaces at the ends of lines (Markdown reads those as line breaks).
sed -E -i.bak -e '/^#{1,6} /s/\*\*//g' -e 's/[[:space:]]+$//' _site/content.md
rm _site/content.md.bak

# 3. Put the photo (photo.html) directly below the title.
{ head -n 1 _site/content.md; echo; cat photo.html; tail -n +2 _site/content.md; } > _site/content.tmp
mv _site/content.tmp _site/content.md

# 4. Page title = the first heading. Description = the first paragraph.
title=$(head -n 1 _site/content.md | sed -E 's/^# +//')
description=$(pandoc -f markdown -t plain --wrap=none _site/content.md \
  | awk 'NF { n++; if (n == 2) { print; exit } }')

# 5. Convert to HTML.
pandoc -f markdown -t html5 --wrap=none \
  --template=template.html \
  --metadata pagetitle="$title" \
  --metadata description="$description" \
  -o _site/index.html _site/content.md

rm _site/content.md
cp pico.classless.min.css style.css community-standup.jpg _site/
echo "Built _site/index.html"
