#!/usr/bin/env bash
# route.sh — given a task description, return ranked matching skills
# Usage: route.sh "deploy urchin docs to mintlify"
# Output: ranked list of skill names with match reason

SKILLS_DIR="${SKILLS_DIR:-$HOME/.claude/commands}"
QUERY="${*}"

if [[ -z "$QUERY" ]]; then
  echo "usage: route.sh <task description>" >&2
  exit 1
fi

CATALOG_SCRIPT="$(dirname "$0")/catalog.sh"

declare -A scores

while IFS=$'\t' read -r name tags desc trigs; do
  score=0

  # Score: tag match = 3 pts each
  IFS=',' read -ra tag_list <<< "$tags"
  for tag in "${tag_list[@]}"; do
    tag=$(echo "$tag" | tr -d ' ')
    if echo "$QUERY" | grep -qi "$tag"; then
      score=$((score + 3))
    fi
  done

  # Score: description keyword match = 2 pts
  for word in $QUERY; do
    [[ ${#word} -lt 4 ]] && continue
    if echo "$desc" | grep -qi "$word"; then
      score=$((score + 2))
    fi
  done

  # Score: trigger phrase match = 4 pts (highest — explicit trigger)
  IFS=',' read -ra trig_list <<< "$trigs"
  for trig in "${trig_list[@]}"; do
    if echo "$QUERY" | grep -qi "$(echo "$trig" | tr -d '"')"; then
      score=$((score + 4))
    fi
  done

  [[ $score -gt 0 ]] && scores["$name"]=$score
done < <(bash "$CATALOG_SCRIPT")

# Sort by score descending, emit top 5
for name in "${!scores[@]}"; do
  echo "${scores[$name]} $name"
done | sort -rn | head -5 | while read -r score name; do
  echo "[$score] $name"
done
