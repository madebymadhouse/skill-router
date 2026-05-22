---
name: skill-router
description: Find the right skill for a task without loading all skill descriptions. Generates a compact catalog from skill tags and triggers, then scores matches against your query.
allowed-tools: Bash
tags: skill, meta, routing
triggers:
  - "which skill should I use"
  - "find a skill for"
  - "what skill handles"
  - "route this to a skill"
  - "list skills for"
  - "do I have a skill for"
---

# Skill Router

Semantic routing across the skill catalog.

## Step 1 — Route

```bash
bash ~/.claude/commands/skill-router/scripts/route.sh "$ARGUMENTS"
```

## Step 2 — Interpret

Present the ranked results. If score >= 6, the match is high-confidence. If score <= 3, tell the user no strong match was found and list the top candidates anyway.

## Step 3 — Load

Once the right skill is identified, invoke it via the Skill tool or tell the user the skill name.
