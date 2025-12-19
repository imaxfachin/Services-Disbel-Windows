# Tuning Consciente de Serviços – Windows 10/11 (PowerShell)

Script PowerShell para **ativar ou desativar serviços do Windows 10/11 de forma controlada**, focando em desempenho, privacidade e redução de serviços desnecessários, **sem quebrar o sistema**.

Ideal para:
- Máquinas pessoais
- Ambientes técnicos
- Pós-instalação limpa
- Usuários que sabem o que estão fazendo 😉

---

## ⚠️ Avisos Importantes

- **Execute sempre como Administrador**
- Alguns serviços **não devem ser desativados** se você usa:
  - Área de Trabalho Remota (RDP)
  - Impressoras
  - Biometria / Windows Hello
- O script **não remove serviços**, apenas ajusta:
  - Status (Iniciado / Parado)
  - Tipo de inicialização (Automático / Desativado)

---

## 📌 O que o script faz

- Ativa ou desativa serviços pré-definidos do Windows
- Controla **Memory Compression** (MMAgent)
- Gera **log de auditoria simples**
- Mostra **uptime do sistema**
- Detecta se é necessário **reiniciar**
- Pergunta antes de reiniciar (sem reboot surpresa)

---

## ▶️ Como Executar

### 1️⃣ Abrir PowerShell como Administrador

Clique com o botão direito no PowerShell → **Executar como administrador**

Mova até o diretorio do seu Desktop (Area de Trabalho) do SEU user:

```powershell
C:\Users\Usuario\Desktop
```

Execute para Desativar:

```powershell
.\servicos.ps1 -acao desativar
```

Execute para Ativar:

```powershell
.\servicos.ps1 -acao ativar
```

Para reiniciar direto pelo PS:

```powershell
shutdown /r /t 5
```

---

### 2️⃣ (Opcional) Liberar execução de scripts

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
