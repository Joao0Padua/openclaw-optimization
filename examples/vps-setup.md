# Running OpenClaw on a VPS

A practical setup guide for running OpenClaw on a VPS with Ollama for local heartbeats and Tailscale for secure remote access.

---

## What You'll End Up With

- OpenClaw running 24/7 on a VPS
- Ollama + Llama 8B handling heartbeats and routine tasks at zero API cost
- All heavy work routed to Claude Haiku/Sonnet via API
- Accessible only through Tailscale (no open ports)
- SSH over Tailscale (no exposed port 22)
- Systemd service for automatic startup and restarts

---

## VPS Provider Comparison

| Provider | Plan | Price/mês | RAM | CPU | Storage | Nota |
|---|---|---|---|---|---|---|
| **Hostinger** | KVM 2 | $6.99 | 8 GB | 2 vCPU | 100 GB NVMe | **Recomendado** — template Ollama pré-instalado |
| **Hostinger** | KVM 3 | $12.99 | 16 GB | 4 vCPU | 200 GB NVMe | Para Llama 8B confortável + margem |
| **Hetzner** | CX23 | ~$6 | 4 GB | 2 vCPU | 40 GB SSD | Boa alternativa, sem template Ollama |
| **Vultr** | Regular | $2.50+ | 512 MB+ | 1 vCPU | NVMe | Só OpenClaw, sem Ollama |
| **DigitalOcean** | Basic | $4+ | 1 GB+ | 1 vCPU | SSD | Developer-friendly |

**Hostinger KVM 2 é a recomendação** por uma razão: tem um template Ubuntu 24.04 com Ollama + Llama 3 + Open WebUI pré-instalados. Seleccionas no painel ao criar o VPS — zero configuração manual do Ollama.

**Nota de RAM para Ollama:**
- KVM 2 (8 GB): OS (~1.5 GB) + OpenClaw (~0.5 GB) + Llama 8B Q4 (~5 GB) = ~7 GB. Funciona, mas sem margem.
- KVM 3 (16 GB): Llama 8B confortável com espaço para picos de carga. Recomendado se o budget permitir.

**GPU cloud (Vast.ai, RunPod) não faz sentido para uso 24/7:** uma RTX 4090 custa ~$288/mês contínuos. Para heartbeats e tarefas de rotina, Llama 8B em CPU a $6.99/mês é a escolha racional.

---

## Modelo de Custos com Esta Arquitectura

| Item | Custo/mês |
|---|---|
| Hostinger KVM 2 | $6.99 |
| Ollama + Llama 8B Q4 (heartbeats + rotina) | $0 |
| Claude Haiku API (tarefas moderadas) | ~$5–10 |
| Claude Sonnet API (tarefas complexas) | ~$2–5 |
| **Total** | **~$14–22** |

Comparado com só API cloud sem VPS: $50–200+/mês dependendo do volume.

---

## 1. Provision the VPS

### Opção A — Hostinger (recomendado)

Em [hostinger.com](https://hostinger.com/vps-hosting):

1. Cria um VPS **KVM 2** (8 GB RAM, 2 vCPU)
2. Em **OS/Template**, selecciona: `Ubuntu 24.04 com Ollama` (template oficial)
3. Escolhe a região mais próxima de ti
4. Adiciona a tua chave SSH pública

O Ollama e o Llama 3 ficam pré-instalados. Avança para o passo 3.

### Opção B — Hetzner

Em [hetzner.com](https://hetzner.com), cria um servidor:

- **Type:** CX23 (2 vCPU, 4 GB RAM, 40 GB SSD)
- **Image:** Ubuntu 24.04
- **Location:** O mais próximo de ti
- **SSH key:** Adiciona a tua chave pública

Precisarás de instalar o Ollama manualmente (passo 3B).

Once provisioned, note the public IP. You'll only need it for the initial setup — after Tailscale is configured, you can stop using it entirely.

---

## 2. Initial Server Setup

SSH in with the public IP:

```bash
ssh root@<your-server-ip>
```

Update packages and create a non-root user:

```bash
apt update && apt upgrade -y
adduser openclaw
usermod -aG sudo openclaw
```

---

## 3. Install Tailscale

On the VPS:

```bash
curl -fsSL https://tailscale.com/install.sh | sh
tailscale up --ssh=true --authkey=<your-tailscale-auth-key>
```

The `--ssh=true` flag enables Tailscale SSH, which lets you log into the server over your Tailscale network without using port 22.

Get your auth key from [login.tailscale.com/admin/settings/keys](https://login.tailscale.com/admin/settings/keys). Use a reusable key if you plan to set up multiple servers.

After running `tailscale up`, the server will appear in your Tailscale admin panel with a Tailscale IP (usually `100.x.x.x`).

**On your local machine**, make sure Tailscale is also installed and connected.

Test the Tailscale SSH connection:

```bash
ssh openclaw@<tailscale-ip>
```

If this works, you're done with the public IP.

---

## 4. Block Port 22 in Hetzner Firewall

In the Hetzner Cloud console:

1. Go to **Firewall** → Create Firewall
2. Add an inbound rule: **Block all** (delete the default SSH rule)
3. Assign the firewall to your server

From this point, all SSH access goes through Tailscale. The public IP is unreachable for SSH.

**Verify:**

```bash
# From outside your Tailscale network, this should time out
ssh root@<public-ip>
```

---

## 5. Install OpenClaw

Switch to the openclaw user:

```bash
su - openclaw
```

Install Node.js (if not already present):

```bash
curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -
sudo apt install -y nodejs
```

Install OpenClaw:

```bash
npm install -g openclaw
```

Verify:

```bash
openclaw --version
```

---

## 6. Install and Configure Ollama

Ollama é o que torna os heartbeats gratuitos. O agente usa o Llama 8B local para todas as tarefas de background — sem custo de API.

### Se escolheste Hostinger com template Ollama

O Ollama já está instalado. Verifica:

```bash
ollama list
# Deve mostrar llama3 ou equivalente já instalado
```

Se não tiver o modelo certo, faz pull:

```bash
ollama pull llama3.1:8b-instruct-q4_K_M
```

### Se instalares manualmente (Hetzner ou outro)

```bash
curl -fsSL https://ollama.ai/install.sh | sh

# Verifica que o serviço está a correr
systemctl status ollama

# Pull do modelo (5 GB — pode demorar alguns minutos)
ollama pull llama3.1:8b-instruct-q4_K_M
```

### Configuração crítica: Context Length

**Este passo é obrigatório.** O Ollama usa 4096 tokens por defeito. O OpenClaw precisa de mínimo 16k tokens para funcionar correctamente. Sem esta config, o Ollama falha silenciosamente.

```bash
# Edita o serviço do Ollama
sudo systemctl edit ollama

# Adiciona estas linhas no editor que abre:
[Service]
Environment="OLLAMA_CONTEXT_LENGTH=32768"

# Salva e reinicia
sudo systemctl daemon-reload
sudo systemctl restart ollama
```

Porquê 32k e não 16k? O system prompt + tool schemas do OpenClaw consomem ~6700 tokens de overhead. Com 32k ficam ~25k disponíveis para contexto real.

### Verificar que o Ollama está a responder

```bash
# Teste rápido
curl http://127.0.0.1:11434/api/tags
# Deve devolver JSON com o modelo listado

# Teste de inferência
ollama run llama3.1:8b-instruct-q4_K_M "responde só 'ok'"
```

### Velocidade de inferência esperada

| Hardware | Tokens/seg | Para OpenClaw |
|---|---|---|
| GPU RTX 4090 | ~100–150 | Fluido e interactivo |
| MacBook M1 Pro | ~30–60 | Excelente para local |
| VPS CPU 2 cores | ~5–15 | Aceitável para heartbeats |
| VPS CPU 4 cores | ~10–25 | Ok para rotina |

Para heartbeats (verificações simples de estado), 5-15 tokens/seg é completamente suficiente. A latência não importa quando o resultado demora 30-60 minutos a ser necessário.

---

## 7. Configure OpenClaw

Copy your config to the VPS. From your local machine:

```bash
scp ~/.openclaw/openclaw.json openclaw@<tailscale-ip>:~/.openclaw/openclaw.json
```

Or create it from scratch on the server using the [sanitized config](sanitized-config.json) as a starting point.

Set permissions:

```bash
chmod 700 ~/.openclaw
chmod 600 ~/.openclaw/openclaw.json
chmod 700 ~/.openclaw/credentials
chmod 600 ~/.openclaw/credentials/*
```

Copy your credentials:

```bash
scp -r ~/.openclaw/credentials/ openclaw@<tailscale-ip>:~/.openclaw/credentials/
```

Run the setup wizard to validate:

```bash
openclaw configure
openclaw doctor --fix
```

---

## 7. Set Up as a Systemd Service

Create the service file:

```bash
sudo tee /etc/systemd/system/openclaw.service > /dev/null <<EOF
[Unit]
Description=OpenClaw Agent
After=network-online.target tailscaled.service
Wants=network-online.target

[Service]
Type=simple
User=openclaw
WorkingDirectory=/home/openclaw
ExecStart=/usr/bin/openclaw start
Restart=on-failure
RestartSec=10
StandardOutput=journal
StandardError=journal
SyslogIdentifier=openclaw

[Install]
WantedBy=multi-user.target
EOF
```

Enable and start:

```bash
sudo systemctl daemon-reload
sudo systemctl enable openclaw
sudo systemctl start openclaw
```

Check status:

```bash
sudo systemctl status openclaw
journalctl -u openclaw -f
```

---

## 8. Validation Workflow

Before leaving it unattended:

```bash
# 1. Check OpenClaw is running
systemctl is-active openclaw

# 2. Verify gateway is bound to loopback only
ss -tlnp | grep 18789
# Expected: 127.0.0.1:18789 — NOT 0.0.0.0:18789

# 3. Confirm no secrets in logs
journalctl -u openclaw --since "1 hour ago" | grep -i "sk-\|api_key\|token"

# 4. Run security audit
openclaw security audit --deep

# 5. Send a test message through your configured channel
# (Telegram/Discord/Slack — verify the bot responds)

# 6. Check memory is writing correctly
ls -la ~/.openclaw/workspace/memory/
```

---

## 9. Log Rotation

OpenClaw logs through systemd journal, which has its own rotation. To limit journal size:

```bash
sudo tee /etc/systemd/journald.conf.d/openclaw.conf > /dev/null <<EOF
[Journal]
SystemMaxUse=500M
MaxFileSec=7day
EOF
sudo systemctl restart systemd-journald
```

---

## Ongoing Maintenance

**Check if the service is running:**
```bash
systemctl is-active openclaw
```

**Restart after a config change:**
```bash
sudo systemctl restart openclaw
```

**Update OpenClaw:**
```bash
npm install -g openclaw
sudo systemctl restart openclaw
```

**Monitor costs:**
Check provider dashboards weekly for the first month until you have a stable baseline.

---

## Resources

- **Full guide:** See [`../guide.md`](../guide.md)
- **Hetzner Cloud:** https://hetzner.com/cloud
- **Tailscale:** https://tailscale.com
- **OpenClaw docs:** https://docs.openclaw.ai
