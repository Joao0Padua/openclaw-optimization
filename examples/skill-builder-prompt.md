# Skill Builder Prompt

A prompt template for asking the bot to create or refactor OpenClaw skills.

The goal is to prevent bloated, token-hungry skills. Without hard constraints, the bot produces 2,000-line files that eat half your context window on every activation.

This template follows the [AgentSkills specification](https://agentskills.io/) structure. You don't have to use that site, but the format is worth following because it keeps skills small, composable, and auditable.

---

## Prompt Template

```
Create a new OpenClaw skill with these hard constraints:

SKILL NAME: [name-in-kebab-case]
PURPOSE: [one sentence describing what this skill does]

INPUTS:
- [what the agent provides when calling this skill]

OUTPUTS:
- [what the skill returns or does]

HARD CONSTRAINTS:
- Maximum 150 lines total
- No inline documentation beyond what's needed to understand the logic
- No fallback chains or retry loops — fail explicitly
- No external dependencies beyond tools already available in OpenClaw
- No secrets or API keys inline — reference credentials by name only

STRUCTURE:
1. Trigger conditions (when does this skill activate, max 5 lines)
2. Core logic (what it actually does, max 100 lines)
3. Output format (what it returns, max 20 lines)
4. Failure behavior (what to do when it can't complete, max 10 lines)

DO NOT:
- Add error handling for every possible edge case
- Write comments explaining obvious behavior
- Create helper functions that are only called once
- Add configurability for things that don't need to vary
- Use more than 3 levels of nesting

Return only the skill file content. No explanation, no wrapper prose.
```

---

## Refactoring Prompt

Use this when an existing skill has grown too large:

```
Refactor the skill below to meet these constraints:
- Maximum 150 lines
- Remove all code that handles cases that haven't happened in production
- Remove all comments that restate what the code does
- Collapse any helper function called only once into its call site
- If the skill is doing more than one thing, split it — return two separate files

CURRENT SKILL:
[paste skill content here]

Return only the refactored file(s). No explanation.
```

---

## What Makes a Good Skill

**Single responsibility.** A skill that fetches email and parses it and creates tasks is three skills. Split it.

**Explicit failure.** A skill that silently does nothing when something goes wrong is worse than one that errors loudly. If the skill can't complete, it should say so.

**No state inside the skill.** Skills shouldn't track their own state between calls. If you need state, use a JSON file in your workspace and read/write it explicitly.

**Cheap to activate.** A skill prompt is injected into context every time it's relevant. A 1,500-line skill burns through your context window before the agent has done any work.

---

## Skill File Structure (AgentSkills format)

```markdown
# skill-name

## Trigger
[When this skill activates — 1-3 conditions max]

## Process
[Step-by-step: what the agent does. Numbered list. No prose.]

1. [Step]
2. [Step]
3. [Step]

## Output
[What the agent returns or produces]

## Failure
[What to do if the skill can't complete]
- If [condition]: [action]
- If [condition]: [action]
```

---

## Example: A Well-Scoped Skill

```markdown
# check-pr-status

## Trigger
When asked to check the status of open pull requests in a repository.

## Process
1. Run `gh pr list --state open --json number,title,statusCheckRollup`
2. Parse the JSON output
3. Filter to PRs where any check has state FAILURE or PENDING
4. Return a summary with PR number, title, and failing check names

## Output
List of open PRs with failing or pending CI checks.
If no PRs match, return: "No open PRs with failing checks."

## Failure
- If `gh` is not installed: report the missing dependency, stop
- If the API call fails: report the error message, stop
- Do not retry
```

This is 20 lines. It does one thing. It fails loudly. It costs almost nothing to activate.

---

## Resources

- **Full guide:** See [`../guide.md`](../guide.md)
- **AgentSkills spec:** https://agentskills.io
