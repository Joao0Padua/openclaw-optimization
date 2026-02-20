# OpenClaw Config Example - Usage Guide

This sanitized config shows the key settings referenced in the [OpenClaw guide](../guide.md).

## Quick Start

1. Copy `sanitized-config.json` to `~/.openclaw/openclaw.json`
2. Replace all `YOUR_*` placeholders with real values
3. Run `openclaw doctor --fix` to validate
4. Run `openclaw security audit --deep` to check for issues

## Key Sections Explained

### Model Configuration (`agents.defaults.model`)

**The coordinator vs worker pattern:**
- Keep expensive models (Opus, Sonnet) out of the `primary` slot
- Use capable but cheap models as your default
- Strong models go in `fallbacks` or pinned to specific agents

**Why this matters:**
Expensive defaults = burned quotas on routine work. Cheap defaults with scoped fallbacks = predictable costs.

### Memory Search (`memorySearch`)

Uses cheap embeddings (`text-embedding-3-small`) to search your memory files.

```json
"memorySearch": {
  "sources": ["memory", "sessions"],
  "experimental": { "sessionMemory": true },
  "provider": "openai",
  "model": "text-embedding-3-small"
}
```

**Cost comparison:**
- Thousands of searches: ~$0.10
- Using premium models for the same: $5-10+

### Context Pruning (`contextPruning`)

```json
"contextPruning": {
  "mode": "cache-ttl",
  "ttl": "6h",
  "keepLastAssistants": 3
}
```

**`cache-ttl` mode:**
- Keeps prompt cache valid for 6 hours
- Automatically drops old messages when cache expires
- `keepLastAssistants: 3` preserves recent continuity

**Why TTL matters:**
Without this, you'll hit token limits faster and pay for re-processing the same context repeatedly.

### Compaction (`compaction.memoryFlush`)

```json
"compaction": {
  "mode": "default",
  "memoryFlush": {
    "enabled": true,
    "softThresholdTokens": 40000,
    "prompt": "Distill this session to memory/YYYY-MM-DD.md. Focus on decisions, state changes, lessons, blockers. If nothing worth storing: NO_FLUSH",
    "systemPrompt": "Extract only what is worth remembering. No fluff."
  }
}
```

**What it does:**
When context hits `softThresholdTokens` (40k), the agent distills the session into `memory/YYYY-MM-DD.md`.

**The prompt matters:**
The flush prompt tells the agent *what* to remember. Focus on decisions, state changes, and lessons, not routine exchanges.

**When it writes `NO_FLUSH`:**
If nothing worth storing happened, the agent skips the write. No clutter.

### Prompt Caching

Prompt caching is the highest-leverage optimisation available and it requires zero configuration changes — just awareness of how it works.

**How it works:** The first time you send content to the model, you pay full price. Within the same session, subsequent calls that include the same content at the top of the prompt get a **90% discount** on that cached portion.

**What to keep stable (cache-friendly):**
- Your system prompt / AGENTS.md
- User profile
- Core reference documents

**What breaks the cache:**
- Editing your system prompt mid-session
- Adding timestamps or dynamic values to the stable parts of context
- Changing the order of blocks in the prompt

**Practical impact:** In an active working session with 20-30 API calls where 80% of each call is your stable system context, prompt caching can cut the total cost of that session by 50-70%.

**No config needed** — caching is automatic when the API supports it (Anthropic, OpenAI). The only thing to do is structure your context so the stable parts come first and don't change.

### Heartbeat Model (`heartbeat.model`)

**Use Ollama if you have it running, otherwise the cheapest API model available.**

With Ollama running locally on the VPS, heartbeats cost nothing. If you're not running Ollama, use GPT-5 Nano or equivalent.

Heartbeats run often but do simple checks (read a file, check a condition). No reason to burn premium models here.

Example costs:
- Ollama local (Llama 8B): $0.00 per heartbeat
- GPT-5 Nano: ~$0.0001 per heartbeat
- Claude Sonnet: ~$0.005 per heartbeat

At 48 heartbeats/day, that's $0.005/day vs $0.24/day.

### Concurrency Limits

```json
"maxConcurrent": 4,
"subagents": {
  "maxConcurrent": 8
}
```

**Why this matters:**
Prevents one bad task from spawning 50 retries and burning your quota in minutes.

### Security: Gateway Binding

```json
"gateway": {
  "bind": "loopback"
}
```

**Critical:** This binds the gateway to `127.0.0.1` (localhost only), not `0.0.0.0` (all interfaces).

**Check it:**
```bash
netstat -an | grep 18789 | grep LISTEN
# You want: 127.0.0.1:18789
# NOT: 0.0.0.0:18789
```

If you see `0.0.0.0`, your gateway is exposed to the network. Fix it immediately.

### Logging (`logging.redactSensitive`)

```json
"logging": {
  "redactSensitive": "tools"
}
```

Redacts sensitive data (API keys, tokens) from tool output in logs.

**Options:**
- `"off"` - no redaction (dangerous)
- `"tools"` - redact tool output only (recommended)
- `"all"` - aggressive redaction (can make debugging harder)

### Custom Model Providers (NVIDIA NIM example)

You can add custom providers like NVIDIA NIM to access additional models:

```json
"models": {
  "mode": "merge",
  "providers": {
    "nvidia-nim": {
      "baseUrl": "https://integrate.api.nvidia.com/v1",
      "api": "openai",
      "models": [
        {
          "id": "nvidia/moonshotai/kimi-k2.5",
          "name": "Kimi K2.5 (NVIDIA NIM)",
          "reasoning": false,
          "input": ["text"],
          "cost": {
            "input": 0,
            "output": 0
          },
          "contextWindow": 256000,
          "maxTokens": 8192
        }
      ]
    }
  }
}
```

**Rate limits:** NVIDIA NIM free tier has 40 RPM limit. Use sparingly or as fallback.

**Auth:** Set `NVIDIA_API_KEY` in environment or credentials directory.

## File Structure

Your workspace should look like this:

```
~/.openclaw/
├── openclaw.json          # Main config (this file, sanitized)
├── credentials/           # API keys (chmod 600)
│   ├── openrouter
│   ├── anthropic
│   └── synthetic
└── workspace/             # Your working directory
    ├── AGENTS.md
    ├── SOUL.md
    ├── USER.md
    ├── TOOLS.md
    ├── HEARTBEAT.md
    ├── memory/
    │   ├── 2026-02-07.md
    │   └── ...
    └── skills/
        └── your-skills/
```

## Security Checklist

Before running OpenClaw in production:

```bash
# 1. Validate config
openclaw doctor --fix

# 2. Security audit
openclaw security audit --deep

# 3. Lock down permissions
chmod 700 ~/.openclaw
chmod 600 ~/.openclaw/openclaw.json
chmod 700 ~/.openclaw/credentials

# 4. Verify localhost binding
netstat -an | grep 18789 | grep LISTEN

# 5. Check for exposed secrets
grep -r "sk-" ~/.openclaw/  # Should find nothing in logs
```

## Common Mistakes

**1. Leaving expensive models as default**
- Opus/Sonnet in `primary` = quota burnout
- Move them to fallbacks or agent-specific configs

**2. No context pruning**
- Token usage climbs, costs spiral
- Add `contextPruning` with `cache-ttl`

**3. Gateway exposed to network**
- `bind: "0.0.0.0"` = anyone can access your agent
- Always use `bind: "loopback"` unless you know what you're doing

**4. No concurrency limits**
- One stuck task spawns 50 retries
- Set `maxConcurrent` to something sane (4-8)

**5. Skipping security audit**
- Run `openclaw security audit --deep` after every config change
- Address critical issues immediately

## Next Steps

1. Set up your channels (Telegram, Discord, etc.)
2. Configure role-specific agents (monitor, researcher, communicator)
3. Add skills to `workspace/skills/`
4. Set up heartbeat checks in `HEARTBEAT.md`
5. Test in a local session before enabling 24/7 mode

## Resources

- **Full guide:** See [`guide.md`](../guide.md) in the repository root
- **Official docs:** https://docs.openclaw.ai
- **GitHub issues:** https://github.com/openclaw/openclaw/issues
- **Discord community:** https://discord.com/invite/clawd
- **Skill directory:** https://clawhub.com

## Cost Tracking

After you're running, check usage regularly:

```bash
# Check quotas (optional script)
check-quotas

# Monitor costs in provider dashboards
# - OpenRouter: https://openrouter.ai/activity
# - Anthropic: https://console.anthropic.com/settings/usage
# - OpenAI: https://platform.openai.com/usage
```

**Optional:** See [check-quotas.sh](../check-quotas.sh) for a script that checks quota usage across providers.

Target: $45-50/month for moderate usage (main session + occasional subagents).

If costs climb above $100/month, check for:
- Expensive model in default config
- Runaway agent retries (no concurrency limits)
- Memory flush running too often
- Heartbeat using premium model
