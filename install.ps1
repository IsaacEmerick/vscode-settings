# Restaura as configuracoes do VS Code nesta maquina.
# Uso: powershell -ExecutionPolicy Bypass -File .\install.ps1

$ErrorActionPreference = "Stop"
$repo = $PSScriptRoot
$userDir = Join-Path $env:APPDATA "Code\User"

if (-not (Test-Path $userDir)) {
    New-Item -ItemType Directory -Force -Path $userDir | Out-Null
}

# Backup do settings.json atual antes de sobrescrever
$target = Join-Path $userDir "settings.json"
if (Test-Path $target) {
    $stamp = Get-Date -Format "yyyyMMdd-HHmmss"
    Copy-Item $target "$target.bak-$stamp"
    Write-Host "Backup criado: settings.json.bak-$stamp"
}

Copy-Item (Join-Path $repo "settings.json") $target -Force
Write-Host "settings.json restaurado."

if (Test-Path (Join-Path $repo "keybindings.json")) {
    Copy-Item (Join-Path $repo "keybindings.json") (Join-Path $userDir "keybindings.json") -Force
    Write-Host "keybindings.json restaurado."
}

if (Test-Path (Join-Path $repo "snippets")) {
    Copy-Item (Join-Path $repo "snippets") $userDir -Recurse -Force
    Write-Host "snippets restaurados."
}

# Instala as extensoes
$extFile = Join-Path $repo "extensions.txt"
if (Test-Path $extFile) {
    Get-Content $extFile | Where-Object { $_.Trim() -ne "" } | ForEach-Object {
        Write-Host "Instalando $_ ..."
        code --install-extension $_ --force
    }
}

Write-Host "`nPronto. Reinicie o VS Code."
