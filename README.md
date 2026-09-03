# VS Code Settings

Backup das minhas configuracoes do VS Code (Windows).

## Conteudo

| Arquivo | Descricao |
|---|---|
| `settings.json` | Configuracoes do usuario |
| `extensions.txt` | Lista de extensoes instaladas |
| `install.ps1` | Restaura tudo em uma maquina nova |
| `backup.ps1` | Atualiza este repo com as configs atuais |

## Restaurar em uma maquina nova

Requer VS Code instalado e o comando `code` disponivel no PATH.

```powershell
git clone https://github.com/SEU-USUARIO/vscode-settings.git
cd vscode-settings
powershell -ExecutionPolicy Bypass -File .\install.ps1
```

O script faz backup do `settings.json` existente antes de sobrescrever.

## Atualizar o backup

```powershell
powershell -ExecutionPolicy Bypass -File .\backup.ps1
git add -A
git commit -m "update settings"
git push
```

## Onde ficam os arquivos no Windows

```
%APPDATA%\Code\User\settings.json
%APPDATA%\Code\User\keybindings.json
%APPDATA%\Code\User\snippets\
```

## Fonte

O `settings.json` usa **JetBrains Mono** / **JetBrainsMono Nerd Font**.
Instale antes de restaurar: https://www.nerdfonts.com/font-downloads
