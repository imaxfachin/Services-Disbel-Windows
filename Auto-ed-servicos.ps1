# -----------------------------------------------------------
# Script PowerShell AUTOMÁTICO
# Tuning consciente de serviços Windows 10/11
# Executar como Administrador
#
# Exemplos:
# .\servicos.ps1 -acao desativar
# .\servicos.ps1 -acao ativar
# shutdown /r /t 5
# -----------------------------------------------------------
param (
    [Parameter(Mandatory = $true)]
    [ValidateSet("ativar","desativar")]
    [string]$acao
)
# -----------------------------------------------------------
# Verificação de privilégio administrativo
# -----------------------------------------------------------
if (-not ([Security.Principal.WindowsPrincipal] `
    [Security.Principal.WindowsIdentity]::GetCurrent()
).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "X    - Execute este [script] como Administrador."
    exit 1
}
# -----------------------------------------------------------
# Log simples (auditoria básica)
# -----------------------------------------------------------
$LogFile = "$env:ProgramData\servicos_tuning.log"

function Log {
    param ($msg)
    "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - $msg" |
        Out-File -Append -FilePath $LogFile -Encoding UTF8
}
$RebootNeeded = $false
# -----------------------------------------------------------
# Memory Compression (Windows)
# -----------------------------------------------------------
$mm = Get-MMAgent

Write-Host "--   - Memory Compression atual: $($mm.MemoryCompression)"
Log ">> INFO - Memory Compression atual: $($mm.MemoryCompression)"

if ($acao -eq "desativar" -and $mm.MemoryCompression -eq $true) {
    Disable-MMAgent -MemoryCompression -ErrorAction SilentlyContinue
    Write-Host "OK   - Memory Compression desativada (reboot necessário)"
    Log ">> [OK]   - Memory Compression desativada"
    $RebootNeeded = $true
}
elseif ($acao -eq "ativar" -and $mm.MemoryCompression -eq $false) {
    Enable-MMAgent -MemoryCompression -ErrorAction SilentlyContinue
    Write-Host "OK   - Memory Compression ativada (reboot necessário)"
    Log ">> [OK]   - Memory Compression ativada"
    $RebootNeeded = $true
}
else {
    Write-Host "--   - Nenhuma alteração necessária na Memory Compression"
    Log ">> INFO - Nenhuma alteração necessária na Memory Compression"
}
# -----------------------------------------------------------
# Lista de serviços
# Comentários servem apenas como documentação
# -----------------------------------------------------------
$Servicos = @(
    "SessionEnv",               # Área de Trabalho Remota (RDP) – NÃO desativar se usa acesso remoto
    "WpcMonSvc",                # Controle dos Pais (Family Safety)
    "DiagTrack",                # Telemetria / Experiência do Usuário (Microsoft)
    "PrintNotify",              # Notificações de impressora
    "workfolderssvc",           # Pastas de Trabalho (Work Folders)
    "SCPolicySvc",              # Política de acesso a Cartão Inteligente
    "RemoteRegistry",           # Acesso remoto ao Registro do Windows
    "XblGameSave",              # Sincronização de jogos da Xbox Live
    "XboxNetApiSvc",            # Serviços de rede da Xbox Live
    "XboxGipSvc",               # Gerenciamento de acessórios Xbox (controle/gamepad)
    "WbioSrvc",                 # Biometria do Windows (Windows Hello)
    "ScDeviceEnum",             # Enumeração de dispositivos de Cartão Inteligente
    "lfsvc",                    # Serviço de Localização (geolocalização)
    "WerSvc",                   # Relatórios de Erro do Windows
    "SmsRouter",                # Roteador de mensagens SMS
    "SensorService",            # Sensores do dispositivo (luz, rotação, etc.)
    "PhoneSvc",                 # Telefonia
    "TapiSrv",                  # API de Telefonia (TAPI)
    "Spooler",                  # Serviço de Impressão (Spooler)
    "RetailDemo",               # Modo de Demonstração de Varejo
    "AssignedAccessManagerSvc", # Acesso Atribuído (modo quiosque)
    "WalletService",            # Carteira digital / Microsoft Wallet
    "MapsBroker",               # Mapas offline do Windows
    "Fax",                      # Serviço de Fax (legado)
    "diagsvc",                  # Diagnostic Execution Service
    "SharedAccess",             # ICS antigo (firewall legado)
    "TabletInputService",       # Teclado virtual / caneta / touch
    "MixedRealityOpenXRSvc",    # Windows Mixed Reality (VR)
    "SEMgrSvc",                 # Payments / NFC / Secure Element
    "AJRouter"                  # AllJoyn Router Service (IoT)
)
# -----------------------------------------------------------
# Execução
# -----------------------------------------------------------
Write-Host "-----------------------------------------"
Write-Host " TUNING DE SERVIÇOS WINDOWS ($acao)"
Write-Host "-----------------------------------------`n"
Log "Início da execução - Ação: $acao"
foreach ($svc in $Servicos) {
    $serv = Get-Service -Name $svc -ErrorAction SilentlyContinue
    if (-not $serv) {
        Write-Host "--   - $svc não existe"
        Log ">>   - $svc não existe"
        continue
    }
    try {
        if ($acao -eq "desativar") {

            if ($serv.Status -ne "Stopped") {
                Stop-Service -Name $svc -Force -ErrorAction SilentlyContinue
            }
            Set-Service -Name $svc -StartupType Disabled -ErrorAction SilentlyContinue
            Write-Host "OK   - $svc desativado"
            Log ">> [OK]   - $svc desativado"
        }
        else {
            Set-Service -Name $svc -StartupType Automatic -ErrorAction SilentlyContinue
            if ($serv.Status -ne "Running") {
                Start-Service -Name $svc -ErrorAction SilentlyContinue
            }
            Write-Host "OK   - $svc ativado"
            Log ">> [OK]   - $svc ativado"
        }
    }
    catch {
        Write-Host "X    - Falha em $svc"
        Log ">> [X]    - Falha em $svc"
    }
}
# -----------------------------------------------------------
# Uptime do sistema
# -----------------------------------------------------------
$uptime = (Get-Date) - (Get-CimInstance Win32_OperatingSystem).LastBootUpTime
$uptimeFmt = "{0} dias, {1} horas, {2} minutos" -f $uptime.Days, $uptime.Hours, $uptime.Minutes

Write-Host "`n--   - Uptime do sistema: $uptimeFmt"
Log ">> INFO - Uptime do sistema: $uptimeFmt"

if ($RebootNeeded) {
    Write-Host "`n- Deseja Reiniciar Agora? (S/N): " -NoNewline
    $resp = Read-Host

    if ($resp -match '^[Ss]$') {
        Write-Host ">> Reiniciando o Sistema..."
        Log ">> Reboot [iniciado] pelo [usuário]"
        Restart-Computer -Force
    }
    else {
        Write-Host ">> Reinicialização ignorada. Saindo..."
        Log ">> Reboot [ignorado] pelo [usuário]"
        exit 0
    }
}
Write-Host "`nProcesso Finalizado."
Log ">> Processo Finalizado"
