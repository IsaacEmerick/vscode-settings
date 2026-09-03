# VS Code Settings

Backup das minhas configuracoes do VS Code (Windows).

## Conteudo

| Arquivo | Descricao |
|---|---|
| `settings.json` | Configuracoes do usuario |
| `extensions.txt` | Lista de extensoes instaladas |
| `extensions-notes.json` | Descricao de cada extensao (usada no modo de selecao) |
| `install.ps1` | Restaura em uma maquina nova, perguntando o que importar |
| `backup.ps1` | Atualiza este repo com as configs atuais |

## Restaurar em uma maquina nova

Requer VS Code instalado e o comando `code` disponivel no PATH.

```powershell
git clone https://github.com/IsaacEmerick/vscode-settings.git
cd vscode-settings
powershell -ExecutionPolicy Bypass -File .\install.ps1
```

O script pergunta o que voce quer importar:

```
O que voce quer importar?
  [1] Apenas as configuracoes  (settings.json, keybindings, snippets)
  [2] Apenas as extensoes
  [3] Tudo
  [0] Cancelar
```

Se escolher importar extensoes, ele pergunta de novo:

```
  [1] Instalar todas as N que faltam
  [2] Escolher uma a uma
  [0] Pular as extensoes
```

No modo "uma a uma", cada extensao aparece com uma descricao curta e voce
responde `s` (sim), `n` (nao), `a` (sim para todas as restantes) ou `q` (parar).
Extensoes ja instaladas na maquina sao ignoradas automaticamente.

A marca `[*]` indica extensoes que o `settings.json` referencia diretamente
(tema, icones, formatter). Sem elas, algumas configuracoes nao terao efeito.

Antes de sobrescrever, o script faz backup do `settings.json` existente
como `settings.json.bak-<data>`.

### Sem perguntas (modo automatico)

```powershell
powershell -ExecutionPolicy Bypass -File .\install.ps1 -All             # tudo
powershell -ExecutionPolicy Bypass -File .\install.ps1 -SettingsOnly    # so configs
powershell -ExecutionPolicy Bypass -File .\install.ps1 -ExtensionsOnly  # so extensoes
```

## Atualizar o backup

```powershell
powershell -ExecutionPolicy Bypass -File .\backup.ps1
git add -A
git commit -m "update settings"
git push
```

O `backup.ps1` regenera o `extensions.txt` mas nao mexe no
`extensions-notes.json` — as descricoes sao mantidas a mao. Ao adicionar uma
extensao nova, inclua a descricao dela nesse arquivo se quiser que apareca no
modo de selecao (e opcional; sem descricao, aparece so o id).

## Onde ficam os arquivos no Windows

```
%APPDATA%\Code\User\settings.json
%APPDATA%\Code\User\keybindings.json
%APPDATA%\Code\User\snippets\
```

Dados locais e sensiveis (`globalStorage\`, `workspaceStorage\`, `*.vscdb`)
ficam de fora pelo `.gitignore` — e onde extensoes guardam tokens e sessoes.

## Fonte

O `settings.json` usa **JetBrains Mono** / **JetBrainsMono Nerd Font**.
Instale antes de restaurar: https://www.nerdfonts.com/font-downloads
