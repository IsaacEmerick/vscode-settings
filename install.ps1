<#
.SYNOPSIS
    Restaura as configuracoes do VS Code nesta maquina.

.DESCRIPTION
    Sem parametros, pergunta o que voce quer importar (configuracoes,
    extensoes ou tudo) e permite escolher as extensoes uma a uma.

.EXAMPLE
    powershell -ExecutionPolicy Bypass -File .\install.ps1
    Modo interativo (pergunta o que importar).

.EXAMPLE
    powershell -ExecutionPolicy Bypass -File .\install.ps1 -All
    Importa tudo sem perguntar nada.

.EXAMPLE
    powershell -ExecutionPolicy Bypass -File .\install.ps1 -SettingsOnly
    Importa so as configuracoes.
#>
[CmdletBinding()]
param(
    [switch]$All,
    [switch]$SettingsOnly,
    [switch]$ExtensionsOnly
)

$ErrorActionPreference = "Stop"
$repo    = $PSScriptRoot
$userDir = Join-Path $env:APPDATA "Code\User"

function Write-Header($text) {
    Write-Host ""
    Write-Host $text -ForegroundColor Cyan
    Write-Host ("-" * $text.Length) -ForegroundColor DarkGray
}

# --------------------------------------------------------------------
# O que importar
# --------------------------------------------------------------------
$doSettings   = $false
$doExtensions = $false

if ($All)                { $doSettings = $true; $doExtensions = $true }
elseif ($SettingsOnly)   { $doSettings = $true }
elseif ($ExtensionsOnly) { $doExtensions = $true }
else {
    Write-Header "O que voce quer importar?"
    Write-Host "  [1] Apenas as configuracoes  (settings.json, keybindings, snippets)"
    Write-Host "  [2] Apenas as extensoes"
    Write-Host "  [3] Tudo"
    Write-Host "  [0] Cancelar"
    Write-Host ""

    do {
        $escolha = (Read-Host "Opcao").Trim()
    } while ($escolha -notmatch '^[0123]$')

    switch ($escolha) {
        "1" { $doSettings = $true }
        "2" { $doExtensions = $true }
        "3" { $doSettings = $true; $doExtensions = $true }
        "0" { Write-Host "`nCancelado. Nada foi alterado." -ForegroundColor Yellow; exit 0 }
    }
}

# --------------------------------------------------------------------
# Configuracoes
# --------------------------------------------------------------------
if ($doSettings) {
    Write-Header "Configuracoes"

    if (-not (Test-Path $userDir)) {
        New-Item -ItemType Directory -Force -Path $userDir | Out-Null
    }

    $target = Join-Path $userDir "settings.json"
    if (Test-Path $target) {
        $stamp = Get-Date -Format "yyyyMMdd-HHmmss"
        Copy-Item $target "$target.bak-$stamp"
        Write-Host "  Backup do settings.json atual -> settings.json.bak-$stamp" -ForegroundColor DarkGray
    }

    Copy-Item (Join-Path $repo "settings.json") $target -Force
    Write-Host "  settings.json restaurado." -ForegroundColor Green

    $kbSrc = Join-Path $repo "keybindings.json"
    if (Test-Path $kbSrc) {
        Copy-Item $kbSrc (Join-Path $userDir "keybindings.json") -Force
        Write-Host "  keybindings.json restaurado." -ForegroundColor Green
    }

    $snipSrc = Join-Path $repo "snippets"
    if (Test-Path $snipSrc) {
        Copy-Item $snipSrc $userDir -Recurse -Force
        Write-Host "  snippets restaurados." -ForegroundColor Green
    }
}

# --------------------------------------------------------------------
# Extensoes
# --------------------------------------------------------------------
if ($doExtensions) {
    Write-Header "Extensoes"

    if (-not (Get-Command code -ErrorAction SilentlyContinue)) {
        Write-Host "  O comando 'code' nao esta no PATH. Pulando as extensoes." -ForegroundColor Yellow
        Write-Host "  No VS Code: F1 > 'Shell Command: Install code command in PATH'" -ForegroundColor DarkGray
        $doExtensions = $false
    }
}

if ($doExtensions) {
    $extFile = Join-Path $repo "extensions.txt"
    $todas = @(Get-Content $extFile | ForEach-Object { $_.Trim() } | Where-Object { $_ -ne "" -and -not $_.StartsWith("#") })

    # Descricoes opcionais (extensions-notes.json)
    $notes = $null
    $notesFile = Join-Path $repo "extensions-notes.json"
    if (Test-Path $notesFile) {
        try { $notes = Get-Content $notesFile -Raw -Encoding UTF8 | ConvertFrom-Json } catch { $notes = $null }
    }

    function Format-Ext($id) {
        $linha = $id
        if ($null -ne $notes) {
            $p = $notes.PSObject.Properties[$id]
            if ($p) {
                if ($p.Value.desc)     { $linha = "$linha  -  $($p.Value.desc)" }
                if ($p.Value.required) { $linha = "$linha  [*]" }
            }
        }
        return $linha
    }

    # O que ja existe nesta maquina
    $instaladas = @(code --list-extensions)
    $pendentes  = @($todas | Where-Object { $instaladas -notcontains $_ })
    $jaTem      = $todas.Count - $pendentes.Count

    Write-Host "  Repositorio: $($todas.Count)  |  ja instaladas aqui: $jaTem  |  faltando: $($pendentes.Count)"

    if ($pendentes.Count -eq 0) {
        Write-Host "  Nada a instalar." -ForegroundColor Green
    }
    else {
        $escolhidas = @()

        if ($All -or $ExtensionsOnly) {
            $escolhidas = $pendentes
        }
        else {
            Write-Host ""
            Write-Host "  [1] Instalar todas as $($pendentes.Count) que faltam"
            Write-Host "  [2] Escolher uma a uma"
            Write-Host "  [0] Pular as extensoes"
            Write-Host ""

            do {
                $modo = (Read-Host "Opcao").Trim()
            } while ($modo -notmatch '^[012]$')

            if ($modo -eq "1") {
                $escolhidas = $pendentes
            }
            elseif ($modo -eq "2") {
                Write-Host ""
                Write-Host "  s = sim   n = nao   a = sim para todas as restantes   q = parar aqui" -ForegroundColor DarkGray
                Write-Host "  [*] = o settings.json depende dela (tema, icones ou formatter)" -ForegroundColor DarkGray
                Write-Host ""

                $i = 0
                $restoTodas = $false
                foreach ($ext in $pendentes) {
                    $i++
                    if ($restoTodas) { $escolhidas += $ext; continue }

                    Write-Host ""
                    Write-Host "  [$i/$($pendentes.Count)] $(Format-Ext $ext)"
                    do {
                        $r = (Read-Host "        instalar? (s/n/a/q)").Trim().ToLower()
                        if ($r -eq "") { $r = "n" }
                    } while ($r -notmatch '^[snaq]$')

                    if ($r -eq "s")     { $escolhidas += $ext }
                    elseif ($r -eq "a") { $escolhidas += $ext; $restoTodas = $true }
                    elseif ($r -eq "q") { break }
                }
            }
        }

        if ($escolhidas.Count -eq 0) {
            Write-Host ""
            Write-Host "  Nenhuma extensao selecionada." -ForegroundColor Yellow
        }
        else {
            Write-Host ""
            Write-Host "  Vou instalar $($escolhidas.Count):" -ForegroundColor Cyan
            $escolhidas | ForEach-Object { Write-Host "    - $(Format-Ext $_)" }
            Write-Host ""

            $ok = $true
            if (-not ($All -or $ExtensionsOnly)) {
                $c = (Read-Host "Confirmar? (S/n)").Trim().ToLower()
                if ($c -eq "n") { $ok = $false }
            }

            if (-not $ok) {
                Write-Host "  Extensoes puladas." -ForegroundColor Yellow
            }
            else {
                $sucesso = 0
                $falhas  = @()
                foreach ($ext in $escolhidas) {
                    Write-Host "  Instalando $ext ..." -ForegroundColor DarkGray
                    code --install-extension $ext --force | Out-Null
                    if ($LASTEXITCODE -eq 0) { $sucesso++ } else { $falhas += $ext }
                }
                Write-Host "  $sucesso instaladas." -ForegroundColor Green
                if ($falhas.Count -gt 0) {
                    Write-Host "  Falharam ($($falhas.Count)):" -ForegroundColor Red
                    $falhas | ForEach-Object { Write-Host "    - $_" -ForegroundColor Red }
                }
            }
        }
    }
}

Write-Host ""
Write-Host "Pronto. Reinicie o VS Code." -ForegroundColor Green
