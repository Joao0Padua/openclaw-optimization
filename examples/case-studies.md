# OpenClaw — Casos de Uso Reais

Levantamento de implementações documentadas pela comunidade e casos práticos verificados.

Organizado por complexidade e setor. Cada caso inclui contexto, o que foi automatizado, como foi implementado e os resultados reportados.

---

## Índice

- [Complexidade Baixa](#complexidade-baixa)
  - [Marketing Digital — Relatórios Automáticos](#1-agência-de-marketing-digital--relatórios-automáticos)
  - [Consultora — Email, CRM e Agenda](#2-consultora--email-crm-e-agenda)
  - [Clínica Médica — Lembretes e FAQs](#3-clínica-médica--lembretes-e-faqs)
  - [E-commerce — Suporte e Stock](#4-e-commerce--suporte-e-stock)
  - [Imobiliária — Triagem de Leads](#5-imobiliária--triagem-de-leads)
  - [Freelancer — Gestão de Projetos e Faturação](#6-freelancer--gestão-de-projetos-e-faturação)
- [Complexidade Média](#complexidade-média)
  - [Negociação de Fornecedores](#7-negociação-autónoma-de-fornecedores)
  - [Monitorização Competitiva](#8-monitorização-competitiva-contínua)
  - [Onboarding de Clientes](#9-onboarding-de-clientes-multi-step)
  - [Desenvolvimento — CI/CD e Code Review](#10-desenvolvimento--cicd-e-code-review-automático)
- [Complexidade Alta](#complexidade-alta)
  - [Equipa Multi-Agente SEO](#11-equipa-multi-agente-de-conteúdo-seo)
  - [Suporte ao Cliente Escalável](#12-suporte-ao-cliente-com-escalamento-inteligente)
  - [Pesquisa e Relatórios de Inteligência](#13-pesquisa-e-relatórios-de-inteligência-de-mercado)

---

## Complexidade Baixa

Automações single-agent, sem dependências externas complexas. Setup em horas, retorno imediato.

---

### 1. Agência de Marketing Digital — Relatórios Automáticos

**Contexto:** Agência com 3 gestores de conta e 12 clientes ativos. Cada gestor passava 2h/dia a compilar métricas manualmente a partir de Google Analytics, Meta Ads e LinkedIn.

**Problema:** Dados em 3 plataformas diferentes, compilação manual em Excel, erros frequentes, relatórios enviados com 1-2 dias de atraso, clientes a pedir updates por WhatsApp constantemente.

**Solução implementada:**

```
Toda segunda-feira às 8h:
1. Recolhe dados de Google Analytics (sessões, conversões, bounce rate)
2. Recolhe dados de Meta Ads (impressões, cliques, CTR, custo/conversão)
3. Recolhe dados de LinkedIn Ads (mesmas métricas)
4. Compila num relatório PDF com as métricas da semana anterior
5. Compara com semana anterior — se alguma métrica desce >20%, inclui aviso em destaque
6. Sugere 2 ações corretivas para métricas em queda
7. Envia por email para o cliente com assunto "Relatório Semanal — [data]"
8. Envia resumo de 3 linhas ao gestor via Slack
```

**Tools usadas:** `web_fetch` (APIs das plataformas), `message` (email + Slack), `cron` (agendamento)

**Resultado:** 2h/dia por gestor → 15 minutos de revisão. Relatórios pontuais. Clientes mais satisfeitos. Gestores libertados para trabalho estratégico.

---

### 2. Consultora — Email, CRM e Agenda

**Contexto:** Consultor independente com 8 clientes ativos. 3-4h/semana em admin: responder emails repetitivos, agendar reuniões, enviar follow-ups, atualizar CRM.

**Solução implementada em 3 partes:**

**Parte A — Email inteligente**
```
Às 9h, lê inbox. Para cada email não lido:
- Categoriza: urgente / follow-up / informativo / spam
- Para emails de clientes conhecidos: rascunha resposta para o consultor aprovar
- Para FAQs (orçamentos, disponibilidade, processo): responde automaticamente
- Envia resumo diário ao consultor: "3 emails respondidos, 2 aguardam aprovação tua"
```

**Parte B — Agendamento**
```
Quando cliente envia "quero marcar reunião":
1. Verifica calendário do consultor
2. Propõe 3 slots disponíveis na semana seguinte (respeitando horário de trabalho)
3. Confirma escolha do cliente
4. Cria evento com link Zoom
5. Envia confirmação a ambos com agenda da reunião
```

**Parte C — Follow-up automático**
```
Todos os dias às 18h:
1. Verifica propostas enviadas sem resposta há mais de 5 dias
2. Envia follow-up personalizado a cada prospect
3. Regista data do follow-up no CRM
4. Se não houver resposta após segundo follow-up: alerta o consultor
```

**Tools usadas:** `web_fetch` (Gmail API, Calendly/Google Calendar, HubSpot), `message`, `cron`

**Resultado:** 3-4h/semana → 30 minutos de revisão. ~14h/mês recuperadas para trabalho faturável.

---

### 3. Clínica Médica — Lembretes e FAQs

**Contexto:** Clínica com 2 médicos e 1 secretária. 40% do tempo da secretária era gasto em lembretes de consultas por telefone e resposta a perguntas frequentes via WhatsApp.

**Solução implementada:**

```
LEMBRETE DE CONSULTA:
Às 18h do dia anterior, para cada consulta do dia seguinte:
1. Envia WhatsApp ao paciente: "Lembrete: consulta amanhã às [hora] com Dr.[nome] em [local]"
2. Aguarda confirmação por 2 horas
3. Se "não posso": cancela, contacta próximo da lista de espera, notifica secretária
4. Às 9h: envia resumo de confirmações/cancelamentos à secretária

FAQS AUTOMÁTICAS (24/7):
Responde automaticamente a:
- Horário de funcionamento
- Localização e estacionamento
- Seguros aceites
- Como marcar/cancelar
- Preços de consulta
Qualquer pergunta fora deste âmbito → encaminha para secretária com contexto
```

**Resultado por semana:**
- Lembretes: zero chamadas manuais, faltas reduzidas 65%
- FAQs: -80% das mensagens à secretária
- Secretária libertada de 12h/semana de tarefas repetitivas

---

### 4. E-commerce — Suporte e Stock

**Contexto:** Loja online com 200+ SKUs. Dono passava 1-2h/dia a verificar stock, responder dúvidas no chat e compilar vendas.

**Automações implementadas:**

```
STOCK (a cada 6h):
Verifica inventário. Se produto desce abaixo do mínimo definido:
→ Envia WhatsApp: "Stock de [produto] em mínimo (5 unidades). Fazer pedido ao fornecedor?"
→ Aguarda confirmação para criar pedido de compra

SUPORTE 24/7 (em tempo real):
Responde automaticamente a:
- Estado da encomenda (integração com plataforma)
- Prazo de entrega estimado
- Política de devoluções
- Especificações de produto
Casos complexos ou reclamações → escalados ao dono via Slack com contexto completo

RELATÓRIO DIÁRIO (às 20h):
- Vendas do dia (total e por produto)
- Produto mais vendido
- Encomendas pendentes de envio
- Receita acumulada do mês vs objetivo
- Reviews negativas com sugestão de resposta

MONITORIZAÇÃO DE REVIEWS:
Reviews negativas (≤3 estrelas) em qualquer plataforma:
→ Alerta imediato ao dono com review completa e sugestão de resposta
→ O dono aprova ou edita antes de publicar
```

**Resultado:** Dono libertado de 10h/semana. Suporte disponível 24/7. Tempo de resposta: de horas para segundos.

---

### 5. Imobiliária — Triagem de Leads

**Contexto:** Agência com 4 consultores. Volume alto de leads inbound via Idealista e Imovirtual. Triagem manual consumia 2-3h/dia por consultor.

**Solução implementada:**

```
TRIAGEM DE LEADS (em tempo real):
Para cada lead novo nos portais:
1. Lê perfil: orçamento declarado, zona de interesse, tipologia pretendida
2. Qualifica com base em critérios definidos (ex: orçamento >€200k, zona X ou Y, T2 ou T3)
3. Se qualificado: distribui ao consultor com menor carga atual + briefing completo
4. Se fora do perfil: responde automaticamente com imóveis alternativos disponíveis

AGENDAMENTO DE VISITAS:
Lead qualificado recebe:
"Temos imóveis que correspondem ao seu perfil. O nosso consultor [nome] tem disponibilidade
para [slot 1], [slot 2] ou [slot 3]. Qual prefere?"
→ Confirmado: cria evento no calendário do consultor + envia confirmação ao cliente

FOLLOW-UP PÓS-VISITA:
48h após cada visita:
"Como correu a visita? Ficou com alguma dúvida sobre o imóvel?"
Se resposta positiva → passa para o consultor com contexto
Se negativa → pergunta o que faltou, sugere alternativas

FICHA DO IMÓVEL:
Consultor envia fotos + notas brutas pelo Telegram
→ Agente gera ficha completa formatada para publicação nos portais
```

**Resultado:** -10h/semana por consultor em triagem. Conversão de leads melhorou 30% (resposta mais rápida e personalizada). Fichas de imóveis produzidas em 2 minutos.

---

### 6. Freelancer — Gestão de Projetos e Faturação

**Contexto:** Designer freelancer com 5-6 projetos simultâneos. Perdia tempo a rastrear horas, enviar faturas e fazer follow-up de pagamentos.

**Solução implementada:**

```
TRACKING DE HORAS:
Freelancer envia via WhatsApp: "Trabalhei 3h no projeto X hoje"
→ Agente regista em spreadsheet com data, projeto e horas
→ Todos os dias às 18h: envia resumo "Hoje: 5.5h. Esta semana: 22h."

FATURA AUTOMÁTICA:
No último dia do mês (ou quando freelancer pede):
1. Agrega horas por projeto
2. Aplica tarifa definida por cliente
3. Gera PDF de fatura com template definido
4. Envia por email ao cliente

FOLLOW-UP DE PAGAMENTO:
Se fatura não for paga em 15 dias:
→ Envia lembrete educado ao cliente
→ Aos 30 dias: lembrete mais direto com freelancer em CC
→ Freelancer é alertado para tomar ação manual

BRIEFING SEMANAL:
Às segundas de manhã, envia ao freelancer:
- Deadlines desta semana por projeto
- Horas registadas vs estimadas por projeto
- Faturas pendentes de pagamento
```

**Resultado:** Horas de admin em faturação de 3h/semana → 20 minutos. Zero faturas esquecidas. Follow-ups automáticos recuperaram pagamentos em atraso sistematicamente.

---

## Complexidade Média

Múltiplas fases sequenciais, comunicação com partes externas, lógica condicional, checkpoints humanos.

---

### 7. Negociação Autónoma de Fornecedores

**Contexto:** Freelancer a renovar equipamento fotográfico (caso documentado na comunidade; um caso equivalente envolveu a compra de uma viatura com €4.200 de poupança via negociação entre dealers).

**Fluxo de execução:**

```
FASE 1 — PESQUISA (automática):
1. Pesquisa fornecedores que vendem o equipamento definido
2. Compila lista com preços, condições e contactos
3. Envia relatório ao utilizador para aprovação da lista

[CHECKPOINT HUMANO: utilizador aprova lista de fornecedores]

FASE 2 — CONTACTO INICIAL (automático):
Para cada fornecedor aprovado:
1. Envia email de pedido de cotação com especificações precisas
2. Regista data e prazo máximo de resposta (48h)
3. Se não responder em 48h: envia follow-up automático

FASE 3 — NEGOCIAÇÃO CRUZADA (automático):
Com cotações recebidas:
1. Para cada fornecedor: "Recebi proposta de €X de fornecedor Y. Consegue melhorar?"
2. Regista todas as contra-propostas e timestamps
3. Faz máximo 2 rondas de negociação

FASE 4 — DECISÃO (com humano):
Apresenta relatório: tabela comparativa com preço, condições, prazo, reputação
[CHECKPOINT HUMANO: utilizador escolhe fornecedor]
→ Agente formaliza a encomenda via email
```

**O que torna este caso "média complexidade":**
- Múltiplas fases com dependências
- Comunicação com várias partes externas
- Lógica condicional (follow-up se não responder)
- Execução assíncrona ao longo de vários dias
- Checkpoints humanos obrigatórios entre fases

**Resultado típico:** Poupança de 8-15% no preço final. Sem horas gastas em chamadas e emails repetitivos.

---

### 8. Monitorização Competitiva Contínua

**Contexto:** Startup SaaS a acompanhar 5 concorrentes. Equipa de produto queria saber imediatamente sobre novos features, mudanças de preço e movimentos de mercado.

**Solução implementada:**

```
HEARTBEAT DIÁRIO (às 7h):
Para cada concorrente na lista:
1. Verifica site (página de features, pricing, blog)
2. Verifica LinkedIn da empresa (posts recentes, contratações, anúncios)
3. Verifica Product Hunt (lançamentos recentes)
4. Verifica Reddit (menções nos últimos 7 dias)

ALERTAS EM TEMPO REAL:
Se detetada alteração relevante (novo feature, mudança de preço, grande anúncio):
→ Alerta imediato via Slack: "#competitive-intel — [concorrente] fez X"
→ Inclui: o que mudou, impacto potencial, sugestão de resposta

RELATÓRIO SEMANAL (sextas às 17h):
- Sumário de movimentos de cada concorrente
- Novos players no mercado
- Tendências de menções online
- Recomendações para a equipa de produto

MONITORIZAÇÃO DE PREÇOS:
Se concorrente mudar preço: alerta imediato ao CEO com comparação antes/depois
```

**Resultado:** Equipa de produto reage a movimentos da concorrência em horas, não semanas. Tomada de decisão mais informada sobre roadmap.

---

### 9. Onboarding de Clientes Multi-Step

**Contexto:** Agência de serviços digitais. Onboarding de cada cliente novo envolvia 8-10 passos manuais ao longo de 5-7 dias. Com 3-4 clientes novos/mês, consumia ~4h por cliente.

**Fluxo automatizado:**

```
DIA 1 — Após contrato assinado:
1. Cria pasta do cliente no Drive com estrutura padrão
2. Cria projeto no gestor de projetos (Notion/ClickUp)
3. Envia email de boas-vindas com próximos passos
4. Agenda kickoff call (propõe 3 slots ao cliente)
5. Cria canal Slack dedicado ao cliente

DIA 2 — Após kickoff confirmado:
1. Envia questionário de onboarding via formulário
2. Adiciona cliente a ferramentas necessárias (Analytics, Ads Manager, etc.)
3. Envia guia de acesso a todos os sistemas

DIA 3 (ou após respostas do questionário):
1. Lê respostas do questionário
2. Gera briefing inicial do projeto com base nas respostas
3. Partilha briefing com equipa interna para validação

DIA 5:
1. Envia ao cliente: "Estamos prontos para começar. Aqui está o plano das próximas 2 semanas."
2. Cria primeiras tarefas no gestor de projetos
3. Envia relatório de onboarding completo ao diretor da conta
```

**Resultado:** 4h por cliente → 45 minutos de supervisão. Experiência do cliente mais consistente. Erros por omissão eliminados.

---

### 10. Desenvolvimento — CI/CD e Code Review Automático

**Contexto:** Equipa de 4 devs. PRs ficavam abertos dias sem review. Bugs de regressão chegavam à produção porque o processo de QA era manual e lento.

**Solução implementada:**

```
QUANDO NOVO PR É ABERTO:
1. Lê diff do PR
2. Executa análise: testes em falta, potenciais bugs, violações de code style
3. Comenta no PR com findings específicos (não opiniões gerais)
4. Atribui reviewer com base em quem conhece o código (histórico de commits)
5. Notifica reviewer via Slack: "PR #42 aguarda tua review — estimativa: 20 min"

MONITORIZAÇÃO DE CI:
Se pipeline falhar:
1. Lê logs de erro
2. Identifica causa provável
3. Comenta no PR: "CI falhou. Causa provável: [X]. Tentativa de fix: [Y]"
4. Alerta o autor via Slack

RELEASE NOTES AUTOMÁTICAS:
Quando tag de release é criada:
1. Agrega commits desde última release
2. Categoriza: features, fixes, breaking changes
3. Gera release notes formatadas
4. Publica no GitHub Releases + canal Slack #releases

MONITORIZAÇÃO DE PRODUÇÃO:
Monitora error rates e latência. Se métrica sair do intervalo normal:
→ Alerta imediato ao on-call: "Error rate em 3.2% (normal: <0.5%). PR #38 foi o último deploy."
```

**Resultado:** Tempo médio de review de 3 dias → 4 horas. Bugs em produção reduzidos 60%. Release notes deixaram de ser omitidas.

---

## Complexidade Alta

Múltiplos agentes com papéis distintos, comunicação entre agentes, integrações externas complexas, execução autónoma multi-dia.

---

### 11. Equipa Multi-Agente de Conteúdo SEO

**Contexto:** Startup SaaS criou equipa de 3 agentes OpenClaw especializados para produzir, otimizar e publicar conteúdo SEO de forma autónoma — do trend research ao artigo publicado.

**Arquitetura:**

```
AGENTE INVESTIGADOR (corre às 7h via cron)
Modelo: Claude Haiku (custo baixo, tarefa estruturada)
→ Monitoriza Reddit, Hacker News, Twitter/X
→ Pesquisa keywords em ascensão com volume e competição
→ Analisa top 5 resultados para os melhores keywords
→ Produz briefing: tópico, keyword principal, ângulo diferenciador, estrutura sugerida
→ Envia briefing ao Agente Editor via sistema de ficheiros

AGENTE EDITOR (ativado pelo briefing)
Modelo: Claude Sonnet (tarefa criativa e complexa)
→ Lê briefing do Investigador
→ Pesquisa fontes adicionais para enriquecer o conteúdo
→ Redige artigo de 1500-2000 palavras com estrutura SEO
→ Inclui meta title, meta description, H1-H3, FAQ, CTA
→ Envia draft ao Agente Publisher

AGENTE PUBLISHER (aguarda aprovação humana)
Modelo: Claude Haiku
→ Recebe draft do Editor
→ Envia ao humano via Telegram: "Artigo pronto: '[título]' — 1847 palavras. Aprovar?"
→ Opções: [Aprovar] [Editar] [Rejeitar]
→ Se aprovado: publica no CMS via API com slug, categoria e tags corretas
→ Envia confirmação: "Publicado em [URL]"
```

**Fluxo completo:**

```
07:00 — Investigador analisa tendências
07:15 — Briefing enviado ao Editor
07:15 — Editor começa a redigir
07:45 — Draft enviado ao Publisher
07:45 — Publisher notifica humano no Telegram
08:10 — Humano aprova
08:11 — Artigo publicado
Tempo humano investido: 2 minutos
```

**O que torna este caso "alta complexidade":**
- 3 agentes autónomos com papéis distintos e comunicação entre si
- Lógica de ramificação (aprovação, edição, rejeição geram fluxos diferentes)
- Integração com APIs externas: CMS, plataformas sociais, ferramentas SEO
- Execução autónoma diária via cron
- Memória partilhada (o que foi publicado, rejeitado, está em curso)
- Checkpoint humano obrigatório antes de publicar

**Resultado reportado:** 5 artigos SEO/semana com 2 minutos de supervisão humana por artigo. Aumento de tráfego orgânico visível em 3-4 meses. Custo total: ~€15-30/mês em API.

---

### 12. Suporte ao Cliente com Escalamento Inteligente

**Contexto:** SaaS B2B com 500 clientes. Equipa de suporte de 2 pessoas recebia 80-120 tickets/dia. 70% eram repetitivos e resolvíveis com documentação existente.

**Arquitetura:**

```
AGENTE TRIAGEM (sempre ativo)
→ Lê tickets novos em tempo real (Intercom/Zendesk via API)
→ Classifica: simples (responde) / complexo (escala) / bug (cria issue)
→ Para tickets simples: responde com base em knowledge base + documentação
→ Para tickets complexos: resume o problema, sugere resposta, escala para humano
→ Para bugs: cria issue no GitHub com reprodução steps, labels e prioridade sugerida

AGENTE KNOWLEDGE BASE (corre semanalmente)
→ Analisa tickets da semana anterior
→ Identifica perguntas sem resposta na knowledge base
→ Gera rascunhos de novos artigos para as lacunas identificadas
→ Alerta o gestor de produto: "3 artigos novos para rever"

AGENTE PROATIVO (corre diariamente)
→ Identifica clientes que abriram 3+ tickets no último mês
→ Envia mensagem proativa: "Notei que têm tido algumas questões sobre X. Posso ajudar?"
→ Clientes com plano enterprise → alerta para customer success fazer check-in

ESCALAMENTO INTELIGENTE:
Se ticket contiver palavras como "cancelar", "contrato", "reembolso":
→ Escala imediatamente para humano sénior com prioridade máxima
→ Inclui histórico completo do cliente e valor do contrato
```

**Resultado:** 2 pessoas de suporte conseguem gerir 120 tickets/dia com qualidade. Tempo médio de resposta de 4h → 8 minutos para tickets simples. Satisfação do cliente (CSAT) subiu de 72% para 89%.

---

### 13. Pesquisa e Relatórios de Inteligência de Mercado

**Contexto:** Fundo de investimento a acompanhar 50 empresas de portfolio e 200 empresas de watchlist. Equipa de 3 analistas passava 20h/semana em pesquisa e compilação de relatórios.

**Solução implementada:**

```
MONITORIZAÇÃO CONTÍNUA (heartbeat a cada 2h):
Para cada empresa na lista:
→ Verifica: notícias recentes, comunicados de imprensa, filings regulatórios
→ Verifica: LinkedIn (contratações sénior, demissões, novos produtos)
→ Verifica: Glassdoor (tendências de avaliação de empregados)
→ Verifica: GitHub (atividade de repositórios públicos, contratações de eng)

ALERTAS IMEDIATOS:
Eventos de alta importância (funding round, saída de CEO, acquisition, IPO):
→ Alerta imediato via Slack ao partner responsável
→ Resume o evento, impacto potencial no portfolio/watchlist, ações sugeridas

RELATÓRIO SEMANAL POR EMPRESA:
Todos os domingos às 20h, para cada empresa relevante:
→ Sumário da semana (highlights, riscos, oportunidades)
→ Métricas de atividade (job postings como proxy de crescimento, web traffic, etc.)
→ Sentiment analysis de menções públicas
→ Comparação com semana anterior

RELATÓRIO MENSAL CONSOLIDADO:
Primeiro dia do mês:
→ Portfolio review: cada empresa com score de saúde (verde/amarelo/vermelho)
→ Watchlist highlights: top 5 empresas com mais momentum
→ Alertas de risco: empresas com sinais preocupantes
→ Gera PDF formatado pronto para meeting do board

DEEP DIVE ON DEMAND:
Analista envia mensagem: "Faz um deep dive na empresa X"
→ Agente passa 30 minutos a recolher informação de todas as fontes disponíveis
→ Produz relatório de 5 páginas: história, produto, equipa, financeiros estimados, competidores, riscos
```

**Resultado:** 20h/semana de pesquisa → 3h de revisão e aprovação de relatórios. Cobertura alargada de 50 para 250 empresas com a mesma equipa. Zero empresas importantes passam despercebidas.

---

## Notas sobre Implementação

### O que têm em comum todos os casos bem-sucedidos

**1. Começaram simples.** Nenhum arrancou com multi-agentes. O caso 11 (SEO multi-agente) começou como um único agente que escrevia artigos. Só depois de estável é que foi dividido em 3 agentes especializados.

**2. Checkpoints humanos explícitos.** Os casos de complexidade média e alta têm sempre pontos onde o humano aprova antes de continuar. Autonomia total sem supervisão é o caminho mais rápido para erros caros.

**3. Falha visível.** Todos os casos têm um mecanismo para dizer "não consegui" em vez de falhar silenciosamente. Um agente que falha sem avisar é pior do que não ter agente nenhum.

**4. Modelos certos para cada tarefa.** Heartbeats e tarefas de classificação correm em modelos baratos (Haiku, GPT-5 Nano, Ollama local). Só tarefas criativas ou de raciocínio complexo usam modelos premium.

**5. Supervisão nos primeiros dias.** Todos correram em modo supervisionado durante pelo menos uma semana antes de ficarem 24/7.

### Sinais de que um processo é bom candidato para automação

- Repetitivo e previsível (mesmas etapas toda semana)
- Baseado em dados estruturados (emails, APIs, formulários)
- Com critérios claros de sucesso e falha
- Onde o erro tem custo baixo ou é reversível
- Onde velocidade de execução melhora o resultado

### Processos que ainda não fazem sentido automatizar

- Decisões estratégicas com ambiguidade alta
- Conversas de venda complexas e relacionais
- Negociações com muitas variáveis não estruturadas
- Tudo o que requer julgamento ético situacional

---

## Recursos

- **Guia completo:** [`../guide.md`](../guide.md)
- **Configuração:** [`sanitized-config.json`](sanitized-config.json)
- **Segurança:** [`security-guide.md`](security-guide.md)
- **ClawHub (marketplace de skills):** https://clawhub.biz
- **Documentação oficial:** https://docs.openclaw.ai
