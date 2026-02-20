# OpenClaw Optimization

Practical patterns for running OpenClaw without burning quotas, buying unnecessary hardware, or spending more time configuring than working.

Not affiliated with OpenClaw. This is what worked after running it, breaking it, and doing that loop more times than necessary.

---

## Start Here

**[guide.md](guide.md)** — The main guide. Covers model routing, cost control, memory configuration, heartbeat patterns, task visibility, VPS setup, and prompt injection defense.

---

## Examples

Supporting files referenced from the guide.

| File | What it covers |
|---|---|
| [examples/sanitized-config.json](examples/sanitized-config.json) | Working config with secrets removed — use as a starting point |
| [examples/config-example-guide.md](examples/config-example-guide.md) | Explanation of every key config section |
| [examples/heartbeat-example.md](examples/heartbeat-example.md) | Rotating heartbeat pattern — one cheap check, multiple cadences |
| [examples/skill-builder-prompt.md](examples/skill-builder-prompt.md) | Prompt template for creating concise, maintainable skills |
| [examples/task-tracking-prompt.md](examples/task-tracking-prompt.md) | Wiring Todoist as source of truth for agent task state |
| [examples/vps-setup.md](examples/vps-setup.md) | VPS provider comparison, Ollama setup, Tailscale, systemd — full setup guide |
| [examples/security-patterns.md](examples/security-patterns.md) | AGENTS.md template, prompt injection patterns, security config |
| [examples/security-guide.md](examples/security-guide.md) | Guia de segurança exaustivo — threat model, rede, credenciais, tools, canais, Docker, incident response |
| [examples/case-studies.md](examples/case-studies.md) | 13 casos de uso reais organizados por setor e complexidade, com implementação detalhada |
| [examples/vps-deploy-script.md](examples/vps-deploy-script.md) | **Guia de implementação em script** — comandos executáveis passo a passo, do zero ao 24/7 |

---

## Scripts

| File | What it does |
|---|---|
| [check-quotas.sh](check-quotas.sh) | Checks API key validity and usage across OpenRouter, Anthropic, OpenAI |

```bash
# Run quota check
./check-quotas.sh
```

---

## Quick Reference

**Things that cause most of the pain:**
- Expensive model (`opus`, `sonnet`) in the default coordinator slot — burns quota on routine work
- No concurrency limits — one stuck task cascades into runaway retries
- Memory left at defaults — context lost constantly, looks like a model problem
- Heartbeat running on a premium model — costs 50x more than necessary
- Going 24/7 before understanding failure modes

**What to do instead:**
- Cheap model as default coordinator, strong models pinned to specific agents
- `maxConcurrent: 4` and `subagents.maxConcurrent: 8`
- Explicit memory config with `cache-ttl` pruning and `memoryFlush`
- Ollama local (Llama 8B) for heartbeats — zero API cost
- Run supervised for a few days before enabling always-on
- Structure context so stable parts come first — prompt caching gives 90% discount on cached content

---

## Official Resources

Always check these before trusting anything here — OpenClaw moves fast:

- [https://docs.openclaw.ai](https://docs.openclaw.ai)
- [https://docs.openclaw.ai/help/faq](https://docs.openclaw.ai/help/faq)
- [https://github.com/openclaw/openclaw/issues](https://github.com/openclaw/openclaw/issues)
