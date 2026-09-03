# Copia as configuracoes atuais da maquina para dentro deste repositorio.
# Uso: powershell -ExecutionPolicy Bypass -File .\backup.ps1

$ErrorActionPreference = "Stop"
$repo = $PSScriptRoot
$userDir = Join-Path $env:APPDATA "Code\User"

Copy-Item (Join-Path $userDir "settings.json") (Join-Path $repo "settings.json") -Force
Write-Host "settings.json atualizado."

$kb = Join-Path $userDir "keybindings.json"
if (Test-Path $kb) {
    Copy-Item $kb (Join-Path $repo "keybindings.json") -Force
    Write-Host "keybindings.json atualizado."
}

$snip = Join-Path $userDir "snippets"
if ((Test-Path $snip) -and (Get-ChildItem $snip -File -ErrorAction SilentlyContinue)) {
    Copy-Item $snip $repo -Recurse -Force
    Write-Host "snippets atualizados."
}

# UTF-8 sem BOM: Out-File -Encoding utf8 no PowerShell 5.1 adiciona BOM
$exts = code --list-extensions
$utf8NoBom = New-Object System.Text.UTF8Encoding $false
[System.IO.File]::WriteAllLines((Join-Path $repo "extensions.txt"), $exts, $utf8NoBom)
Write-Host "extensions.txt atualizado."

Write-Host "`nAgora rode: git add -A; git commit -m 'update settings'; git push"
