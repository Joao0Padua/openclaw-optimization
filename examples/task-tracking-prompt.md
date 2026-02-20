# Task Tracking with Todoist

A prompt template for building a Todoist-based task visibility system for OpenClaw.

The problem this solves: OpenClaw feels like a black box by default. You can't tell what it's doing, what finished, or what's stuck. Logs help but not enough. Wiring up a task manager as source of truth fixes this.

---

## Prerequisites

- A Todoist account (free tier is enough)
- A Todoist API token (Settings → Integrations → Developer → API token)
- The token stored in your OpenClaw credentials as `TODOIST_API_KEY`
- A dedicated project in Todoist for OpenClaw work

---

## Prompt Template: Initial Setup

Use this to have the agent build the task tracking system:

```
Set up Todoist as the source of truth for task state in OpenClaw.

TODOIST PROJECT: [your project name or ID]
TODOIST API KEY: referenced as TODOIST_API_KEY in credentials

Build a system where:

TASK LIFECYCLE:
1. When the agent starts a non-trivial task, create a Todoist task with:
   - Title: brief description of what's being done
   - Label: "in-progress"
   - Due: none (no artificial deadlines)

2. When a task completes successfully:
   - Mark the Todoist task as complete
   - Add a comment with a one-sentence summary of what was done

3. When a task fails or gets stuck:
   - Update the task label to "blocked"
   - Add a comment with the error or blocker
   - Assign the task to me (my Todoist user ID: [your user ID])
   - Do NOT retry automatically

4. When human input is required:
   - Update the task label to "needs-input"
   - Add a comment describing exactly what decision or information is needed
   - Assign to me

RECONCILIATION HEARTBEAT:
Every 30 minutes, run a lightweight check that:
1. Lists all open tasks labeled "in-progress" in the project
2. Checks if the corresponding agent work is still running
3. If a task has been "in-progress" for more than 2 hours with no update: mark as "stalled", add comment "No activity for 2+ hours", assign to me
4. Reports any stalled tasks via [your channel: Telegram/Discord/Slack]

TOOLS TO USE:
- Todoist REST API v2 (https://api.todoist.com/rest/v2/)
- Endpoints: tasks (GET/POST/PATCH/DELETE), comments (POST), labels (GET)

CONSTRAINTS:
- Use the API directly via web fetch — no external libraries
- Store task IDs in workspace/todoist-state.json mapped to agent task IDs
- If the API is unreachable, log locally and continue — don't fail the main task
- Maximum 3 API calls per task lifecycle event

Build this as a skill (skill: todoist-tracker) and a HEARTBEAT.md check.
Return both files.
```

---

## State File Format

The agent maintains a local state file to map internal task IDs to Todoist task IDs:

```json
{
  "tasks": {
    "agent-task-uuid-here": {
      "todoistId": "12345678",
      "title": "Refactor auth module",
      "status": "in-progress",
      "startedAt": "2026-02-19T10:30:00Z",
      "lastUpdatedAt": "2026-02-19T10:35:00Z"
    }
  }
}
```

Store this at `workspace/todoist-state.json`.

---

## Labels to Create in Todoist

Before running, create these labels in your Todoist account:

| Label | Color | Meaning |
|---|---|---|
| `in-progress` | Blue | Agent is actively working |
| `blocked` | Red | Hit an error or dependency |
| `needs-input` | Orange | Waiting on human decision |
| `stalled` | Yellow | No activity detected for 2+ hours |

---

## Heartbeat Check Template

Add this to your `HEARTBEAT.md`:

```markdown
## Todoist Reconciliation Check

Cadence: every 30 minutes (anytime)

1. Load workspace/todoist-state.json
2. For each task with status "in-progress":
   a. Check lastUpdatedAt — if more than 2 hours ago:
      - Update Todoist task: label → "stalled"
      - Add comment: "No activity detected for 2+ hours. Manual review needed."
      - Assign to user ID [your ID]
      - Update local state: status → "stalled"
3. Fetch all Todoist tasks in project with label "blocked" or "needs-input"
4. If any exist: send summary to [your notification channel]
5. Update reconciliation timestamp in heartbeat-state.json

Report ONLY if stalled or blocked tasks found. Otherwise: HEARTBEAT_OK
```

---

## What This Looks Like Day-to-Day

You open Todoist and see:

```
OpenClaw Project
├── ✅ Fetched weekly report (done, 9:15 AM)
├── 🔵 Analyzing PR #47 (in-progress, started 9:30 AM)
├── 🟠 Review draft email to team (needs-input)
└── 🔴 Sync contacts to CRM (blocked — API returned 403)
```

No log diving. No guessing. One place, current state.

---

## Resources

- **Full guide:** See [`../guide.md`](../guide.md)
- **Todoist API docs:** https://developer.todoist.com/rest/v2/
