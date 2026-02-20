# OpenClaw Optimization — Index

Documentação completa para implementar, configurar, optimizar e operar o OpenClaw de forma segura e económica.

**Versão:** 1.0 · **Actualizado:** Fevereiro 2026 · **Docs:** 10 ficheiros · **Total:** ~4.000 linhas

---

## Onde Começar

```
Novo no OpenClaw?
  → guide.md — lê a intro e o TL;DR

Queres instalar num VPS hoje?
  → examples/vps-deploy-script.md — script passo a passo, comandos copy-paste

Queres perceber os custos antes?
  → guide.md (secção "Where the money actually goes")
  → examples/config-example-guide.md

Precisas de inspiração para casos de uso?
  → examples/case-studies.md

Tens dúvidas sobre segurança?
  → examples/security-guide.md
```

---

## Documentos Principais

### [guide.md](guide.md)
**O guia central. Lê este primeiro.**

Cobre a filosofia de operação, os erros mais comuns, e todas as decisões de configuração importantes.

| Secção | O que cobre |
|---|---|
| The mistake most people make | Coordinator vs worker — porquê um modelo barato como default |
| Auto-mode and blind routing | Porquê routing explícito é melhor |
| Why strong models shouldn't be defaults | Rate limits, quotas e o custo invisível |
| Where the money actually goes | 3 camadas de custo: 60% overhead, 25% modelo errado, 15% trabalho real |
| → Layer 1: Invisible overhead | Ollama para heartbeats, context loading optimization |
| → Layer 2: Right model for the task | Haiku como default, escalar com critério |
| → Layer 3: Prompt caching | 90% de desconto em conteúdo estável |
| → Budget guardrails | Limites operacionais no system prompt |
| Don't buy hardware yet | Porquê não comprar Mac Studio logo no início |
| The reality of local models | Matemática real dos modelos locais vs cloud |
| The hype problem | Como evitar FOMO e configurar mais do que trabalhar |
| A Practical Rotating Heartbeat Pattern | Um heartbeat, múltiplos checks por cadência |
| Making memory explicit | context pruning, compaction, memory flush |
| Skills: build your own first | Riscos de skills de terceiros, como construir as tuas |
| Using Todoist for task visibility | Visibilidade do estado de tarefas em tempo real |
| Running on a VPS | Setup básico, Tailscale, custos |
| Prompt Injection Defense | Defesa contra conteúdo que tenta controlar o agente |
| What this costs me per month | ~$45–50/mês com uso moderado |

---

## Instalação e Configuração

### [examples/vps-deploy-script.md](examples/vps-deploy-script.md)
**Guia de implementação em script — comandos executáveis passo a passo**

O caminho mais directo do zero ao sistema a funcionar. Copy-paste de cada bloco de comandos.

| Parte | Conteúdo |
|---|---|
| Parte 0 | Escolha de VPS — Hostinger vs Hetzner vs Oracle Free Tier, preços, trade-offs |
| Parte 1 | Config base do servidor, utilizador dedicado |
| Parte 2 | Tailscale, SSH seguro, bloqueio de porta 22 |
| Parte 3 | Node.js 22 |
| Parte 4 | Ollama + Llama 3.1 8B, tabela de modelos, context window config |
| Parte 5 | OpenClaw install |
| Parte 6 | Credenciais, gateway token, `openclaw.json` completo, `AGENTS.md` |
| Parte 7 | Validação da config (`doctor --fix`, security audit) |
| Parte 8 | Systemd service com dependência Ollama |
| Parte 9 | Checklist de verificação com saídas esperadas |
| Parte 10 | Primeiro teste via Telegram |
| Parte 11 | Log rotation |
| Parte 12 | Manutenção, updates, troubleshooting |

### [examples/vps-setup.md](examples/vps-setup.md)
**Referência de configuração de VPS — mais conceptual, menos script**

Complementa o deploy script com explicações detalhadas sobre cada decisão.

| Secção | Conteúdo |
|---|---|
| VPS Provider Comparison | Tabela Hostinger / Hetzner / Vultr / DO com preços e RAM |
| Modelo de Custos | Breakdown $14–22/mês com Ollama |
| Ollama Setup | Context window config, teste de inferência, velocidade por hardware |
| Firewall (por provider) | Hostinger hPanel, Hetzner Cloud Console, Oracle Security List |
| Systemd service | Config completo com dependência no Ollama |
| Validation Workflow | 6 verificações pós-deploy |
| Log Rotation | journald config |
| Ongoing Maintenance | Updates, restart, monitorização |

### [examples/sanitized-config.json](examples/sanitized-config.json)
**Config de referência completo com todos os providers e secções configuradas.**

Inclui: Ollama provider (heartbeat local), Synthetic, fallback chain, memory search, context pruning, compaction, concurrency limits, canais (Telegram, Discord, Slack), gateway com Tailscale.

Substitui os placeholders `<YOUR_*>` pelas tuas credenciais reais.

### [examples/config-example-guide.md](examples/config-example-guide.md)
**Explicação secção a secção do `sanitized-config.json`**

Para cada bloco de config: o que faz, porquê importa, o que acontece sem ele.

| Secção explicada | Insight principal |
|---|---|
| Model Configuration | Coordinator vs worker pattern |
| Memory Search | `text-embedding-3-small` — milhares de searches por <$0.10 |
| Context Pruning | `cache-ttl` evita re-processar contexto já pago |
| Compaction / memoryFlush | Flush automático a 40k tokens → ficheiro diário de memória |
| **Prompt Caching** | 90% desconto em conteúdo estável — zero config, só awareness |
| **Heartbeat Model** | Ollama local = $0; GPT-5 Nano = ~$0.0001/heartbeat |
| Concurrency Limits | `maxConcurrent: 4` previne cascata de retries |
| Gateway Binding | `loopback` vs `0.0.0.0` — diferença crítica |
| Logging | `redactSensitive: "tools"` — keys fora dos logs |
| Custom Providers | NVIDIA NIM como exemplo de provider externo |

---

## Operação e Automação

### [examples/heartbeat-example.md](examples/heartbeat-example.md)
**Padrão de heartbeat rotativo — um agente, múltiplos checks, por cadência**

Em vez de cron jobs separados, um único heartbeat decide qual check está mais em atraso e executa-o.

| Secção | Conteúdo |
|---|---|
| Prompt Template | Como pedir ao agente para construir o sistema |
| HEARTBEAT.md Structure | Template completo com 5 checks (email, calendário, tasks, git, sistema) |
| State File Format | `heartbeat-state.json` com timestamps de última execução |
| Customization | Cadências, janelas horárias, substituição de checks |
| Alternative: Separate Cron Jobs | Quando cron separado faz mais sentido |

### [examples/task-tracking-prompt.md](examples/task-tracking-prompt.md)
**Todoist como source of truth para o estado de tarefas do agente**

Resolve o problema de visibilidade: saber o que o agente está a fazer, o que terminou e o que ficou bloqueado.

| Secção | Conteúdo |
|---|---|
| Prompt Template | Setup completo do sistema de tracking |
| Ciclo de vida da tarefa | create → update → complete / blocked / needs-input |
| State File Format | Mapeamento task IDs internos → Todoist IDs |
| Labels a criar | in-progress, blocked, needs-input, stalled |
| Heartbeat de Reconciliação | Detecção de tarefas paradas há >2h |

### [examples/skill-builder-prompt.md](examples/skill-builder-prompt.md)
**Como pedir ao agente para criar ou refatorar skills — com hard constraints**

Sem constraints explícitas, o agente produz skills de 2.000 linhas que consomem metade do context window na activação.

| Secção | Conteúdo |
|---|---|
| Prompt Template | Estrutura com limites de linhas, proibições explícitas |
| Refactoring Prompt | Para skills existentes que cresceram demasiado |
| O que faz uma boa skill | Single responsibility, falha explícita, sem estado interno |
| Skill File Structure | Formato AgentSkills: Trigger → Process → Output → Failure |
| Exemplo completo | `check-pr-status` — 20 linhas, faz uma coisa, falha em voz alta |

---

## Segurança

### [examples/security-guide.md](examples/security-guide.md)
**Guia educativo exaustivo — threat model ao incident response**

O documento de segurança completo. Para quem quer perceber os riscos e tomar decisões informadas.

| Secção | Conteúdo |
|---|---|
| 1. Modelo de Ameaça | O que podes perder, quem te ameaça, tipos de ataque |
| 2. Segurança de Rede | Gateway binding, Tailscale, token de autenticação, verificação |
| 3. Gestão de Credenciais | Estrutura de ficheiros, permissões, rotação, verificar leaks |
| 4. Permissões de Tools | Princípio do mínimo privilégio, perfis, sandboxing de exec |
| 5. Segurança de Canais | Telegram / Discord / Slack — allowlists, IDs vs usernames |
| 6. Defesa contra Prompt Injection | Vectores de ataque, AGENTS.md completo, web fetch allowlist |
| 7. Segurança de Skills | ClawHavoc (341 skills maliciosas), processo de vetting de 5 passos |
| 8. Segurança de Modelos e API | Dados que não devem entrar nos prompts, logging seguro, rate limiting |
| 9. Monitorização e Audit | O que monitorizar, alertas automáticos, audit log JSON |
| 10. Deployment em Docker | Dockerfile, Docker Compose com secrets via volumes, isolamento de rede |
| 11. Resposta a Incidentes | Sinais de comprometimento, procedimento de 6 passos |
| 12. Checklist Enterprise | 30+ verificações antes de ir a produção |

### [examples/security-patterns.md](examples/security-patterns.md)
**Referência rápida — AGENTS.md template + attack patterns + config**

Complementa o security-guide com os artefactos prontos a usar.

| Secção | Conteúdo |
|---|---|
| AGENTS.md Template | Pronto a copiar para `~/.openclaw/workspace/AGENTS.md` |
| Attack Patterns | 6 vectores documentados com exemplos reais |
| Security Configuration | Snippets de config para redacção, binding, web fetch allowlist |
| O que não ajuda | Filtros de texto, desactivar web fetch, falsa segurança |

---

## Casos de Uso

### [examples/case-studies.md](examples/case-studies.md)
**13 implementações documentadas com detalhe de execução e resultados**

Organizadas por complexidade crescente. Cada caso inclui: contexto, problema, solução implementada (com pseudo-código das instruções), tools usadas e resultado.

| Complexidade | Casos |
|---|---|
| **Baixa** (single-agent, setup em horas) | Marketing digital, Consultora, Clínica médica, E-commerce, Imobiliária, Freelancer |
| **Média** (multi-fase, checkpoints humanos) | Negociação de fornecedores, Monitorização competitiva, Onboarding de clientes, CI/CD e code review |
| **Alta** (multi-agente, execução autónoma) | Equipa SEO 3 agentes, Suporte ao cliente escalável, Inteligência de mercado |

---

## Scripts

### [check-quotas.sh](check-quotas.sh)
**Verifica quotas e validade de API keys em OpenRouter, Anthropic e OpenAI**

```bash
chmod +x check-quotas.sh
./check-quotas.sh           # output legível
./check-quotas.sh --json    # output JSON
```

---

## Estrutura de Ficheiros

```
openclaw_optimization/
├── INDEX.md                          ← este ficheiro
├── README.md                         ← entrada rápida ao projecto
├── guide.md                          ← guia principal
├── check-quotas.sh                   ← script de verificação de quotas
└── examples/
    │
    │   INSTALAÇÃO E CONFIG
    ├── vps-deploy-script.md          ← script passo a passo (começar aqui)
    ├── vps-setup.md                  ← referência de setup VPS + Ollama
    ├── sanitized-config.json         ← config completo de referência
    ├── config-example-guide.md       ← explicação de cada secção do config
    │
    │   OPERAÇÃO E AUTOMAÇÃO
    ├── heartbeat-example.md          ← padrão heartbeat rotativo
    ├── task-tracking-prompt.md       ← Todoist como source of truth
    ├── skill-builder-prompt.md       ← criar skills concisas e mantíveis
    │
    │   SEGURANÇA
    ├── security-guide.md             ← guia exaustivo (threat model → incident response)
    ├── security-patterns.md          ← AGENTS.md template + attack patterns
    │
    │   CASOS DE USO
    └── case-studies.md               ← 13 implementações reais com detalhe
```

---

## Recursos Oficiais

Verificar sempre antes de confiar em qualquer guia de terceiros — o OpenClaw muda frequentemente:

- **Docs:** [docs.openclaw.ai](https://docs.openclaw.ai)
- **FAQ:** [docs.openclaw.ai/help/faq](https://docs.openclaw.ai/help/faq)
- **Issues activos:** [github.com/openclaw/openclaw/issues](https://github.com/openclaw/openclaw/issues)
- **PRs recentes:** [github.com/openclaw/openclaw/pulls](https://github.com/openclaw/openclaw/pulls)
- **Ollama provider docs:** [docs.openclaw.ai/providers/ollama](https://docs.openclaw.ai/providers/ollama)
- **Skills marketplace:** [clawhub.biz](https://clawhub.biz)
