# HEARTBEAT.md Example

This example shows a rotating heartbeat pattern where a single heartbeat runs different checks based on cadence instead of firing everything at once.

## Prompt Template for Your Agent

Copy and customize this prompt to have your agent build a rotating heartbeat system:

```
Build a rotating heartbeat check system for HEARTBEAT.md:

Create these checks with their cadences:
- Email: every 30 min (9 AM - 9 PM only)
- Calendar: every 2 hours (8 AM - 10 PM only)
- Tasks: every 30 min (anytime)
- Git: every 24 hours (anytime)
- System: every 24 hours (3 AM only)

Create heartbeat-state.json to track last run timestamps.

On each heartbeat:
1. Read state file
2. Calculate which check is most overdue (respect time windows)
3. Run that check
4. Update timestamp in state file
5. Report only if check finds something actionable
6. Return HEARTBEAT_OK if nothing needs attention

Check implementations:
- Email: Check [your email service] for new messages from authorized senders
- Calendar: Check [your calendar] for events in next 24-48h
- Tasks: Check [your task manager] for stalled/blocked work
- Git: Check workspace for uncommitted changes
- System: Check for failed cron jobs and error logs

Adapt these to my specific services and tools.
```

## Example HEARTBEAT.md Structure

```markdown
# HEARTBEAT.md

## Cadence-Based Checks

Read `heartbeat-state.json`. Run whichever check is most overdue.

**Cadences:**
- Email: every 30 min (9 AM - 9 PM)
- Calendar: every 2 hours (8 AM - 10 PM)
- Tasks: every 30 min (anytime)
- Git: every 24 hours (anytime)
- System: every 24 hours (3 AM only)

**Process:**
1. Load timestamps from heartbeat-state.json
2. Calculate which check is most overdue (considering time windows)
3. Run that check
4. Update timestamp
5. Report if actionable, otherwise HEARTBEAT_OK

---

## Email Check

Check [your email service] for new messages.

**Report ONLY if:**
- New email from authorized sender
- Contains actionable request

**Update:** email timestamp in state file

---

## Calendar Check

Check [your calendar] for upcoming events.

**Report ONLY if:**
- Event starting in <2 hours
- New event since last check

**Update:** calendar timestamp in state file

---

## Task Check

Check [your task manager] for work status.

**Report ONLY if:**
- Tasks stalled >24h
- Blocked tasks need attention

**Update:** tasks timestamp in state file

---

## Git Check

Check workspace git status.

**Report ONLY if:**
- Uncommitted changes exist
- Unpushed commits found

**Update:** git timestamp in state file

---

## System Check

Check for system issues.

**Report ONLY if:**
- Failed cron jobs found
- Recent errors in logs

**Update:** system timestamp in state file
```

## Example State File

```json
{
  "lastChecks": {
    "email": 1703275200000,
    "calendar": 1703260800000,
    "tasks": 1703270000000,
    "git": 1703250000000,
    "system": 1703240000000
  }
}
```

## Benefits

- **Single heartbeat, multiple checks** - Simpler than managing separate cron jobs
- **Spreads load** - Checks run when overdue, not all at once
- **Cost-efficient** - One cheap model does routing
- **Debuggable** - State file shows when each check last ran
- **Adaptive** - Most overdue runs first

## Customization

**Adjust cadences:**
- High-priority: 15-30 min
- Medium-priority: 1-2 hours
- Low-priority: 6-24 hours

**Set time windows:**
- Email/Calendar: Waking hours only
- System checks: Overnight when quiet
- Git: Anytime

**Replace check types:**
- Email → RSS feeds, webhooks
- Calendar → project deadlines
- Tasks → CI/CD status
- Git → backup status
- System → service health

## Alternative: Separate Cron Jobs

If you prefer explicit scheduling:

```javascript
// Email check: every 30 min, 9 AM - 9 PM
cron({
  action: "add",
  job: {
    schedule: { kind: "cron", expr: "*/30 9-21 * * *" },
    payload: { kind: "agentTurn", message: "Check email" }
  }
})

// Git check: daily at 3 AM
cron({
  action: "add",
  job: {
    schedule: { kind: "cron", expr: "0 3 * * *" },
    payload: { kind: "agentTurn", message: "Check git status" }
  }
})
```

Rotating heartbeat is better for frequent checks and cost optimization. Separate cron is better for precise timing.
