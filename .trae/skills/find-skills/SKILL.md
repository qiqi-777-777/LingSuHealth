---
name: "find-skills"
description: "Helps discover and install skills from the open agent skills ecosystem. Invoke when users ask for a skill, tool, or specialized capability."
---

# Find Skills

This skill helps discover and install skills from the open agent skills ecosystem.

## When to Use This Skill

Use this skill when the user:
- Asks how to do a task that might have an existing skill
- Says “find a skill for X” or “is there a skill for X”
- Asks for a specialized capability
- Wants to extend agent capabilities
- Asks for tools, templates, or workflows
- Mentions needing help in a specific domain

## What is the Skills CLI

The Skills CLI (npx skills) is the package manager for the open agent skills ecosystem.

Key commands:
- npx skills find [query]
- npx skills add <package>
- npx skills check
- npx skills update

Browse skills at:
https://skills.sh/

## How to Help Users Find Skills

### Step 1: Understand What They Need

Identify:
- The domain
- The specific task
- Whether a common skill likely exists

### Step 2: Search for Skills

Run:

```
npx skills find [query]
```

Examples:
- react performance
- pr review
- changelog

### Step 3: Present Options

Provide:
- Skill name and description
- Install command
- Link to skills.sh

### Step 4: Offer to Install

```
npx skills add <owner/repo@skill> -g -y
```

## If No Skills Are Found

- Acknowledge no matches
- Offer to help directly
- Suggest creating a skill with:

```
npx skills init my-skill
```
