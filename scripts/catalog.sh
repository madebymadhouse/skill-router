#!/usr/bin/env bash
# catalog.sh — emit a compact index of all installed skills
# Output: one line per skill: name | tags | description | triggers (tab-separated)
# Used by the router and by agents that need lean skill discovery.

SKILLS_DIR="${SKILLS_DIR:-$HOME/.claude/commands}"
QUERY="${1:-}"

skill_matches() {
  local line="$1"
  local query="$2"
  # Case-insensitive substring match across the whole line
  echo "$line" | grep -qi "$query"
}

emit_catalog() {
  for skill_dir in "$SKILLS_DIR"/*/; do
    local skill_name
    skill_name=$(basename "$skill_dir")
    local skill_file="$skill_dir/SKILL.md"
    [[ -f "$skill_file" ]] || continue

    # Extract frontmatter block (between first two --- lines)
    local fm
    fm=$(awk '/^---/{found++; if(found==2) exit} found==1{print}' "$skill_file")

    local description tags triggers
    description=$(echo "$fm" | grep '^description:' | sed 's/^description: *//' | tr -d '"')
    tags=$(echo "$fm" | grep '^tags:' | sed 's/^tags: *//')
    triggers=$(echo "$fm" | grep -A 20 '^triggers:' | grep '^ *-' | sed 's/^ *- *//' | tr '\n' ',' | sed 's/,$//')

    # Skip skills with no description (they can't be routed)
    [[ -z "$description" ]] && continue

    echo -e "${skill_name}\t${tags:-untagged}\t${description}\t${triggers}"
  done
}

if [[ -z "$QUERY" ]]; then
  emit_catalog
else
  # Filter catalog to skills matching the query
  while IFS=$'\t' read -r name tags desc trigs; do
    local_line="$name $tags $desc $trigs"
    if echo "$local_line" | grep -qi "$QUERY"; then
      echo -e "${name}\t${tags}\t${desc}\t${trigs}"
    fi
  done < <(emit_catalog)
fi
