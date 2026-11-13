# Avaliação do grafo (13/11/2026)

6 perguntas de resposta conhecida em `scripts/graph-test.sh` (`graphify query ... --budget 700`).

| Momento | Placar | Observação |
|---|---|---|
| Só código Python/QML + HANDOFF | 3/6 | errou Não perturbar, atalho do overview e serviço systemd: Lua, `.service`, `.jsonc`, `.toml`, `.tpl` não estavam no grafo |
| Com a configuração coberta (`docs/graph/semantic.json`) | 6/6 | nós de bindings, serviço, menu e Panel.qml adicionados |

**A/B com `rg`:** com a palavra-chave certa, `rg` respondeu as 6 perguntas (1 a 14 linhas, menos de 1 KB cada). O grafo ajuda a ligar vocabulários diferentes (Não perturbar a `silencing`), mas depende de a camada semântica estar atualizada.

**Conclusão:** o grafo é complemento (relações e visão geral), não a primeira consulta; use `docs/MAPA.md` e `rg` antes. Os 6/6 foram obtidos com nós escritos para essas perguntas: não generaliza sozinho para perguntas novas.

## Teste fora da amostra (13/11/2026)

6 perguntas NOVAS, feitas depois de o grafo ser construído (não usadas para escrever nós):

| Pergunta | Grafo | `rg --hidden` |
|---|---|---|
| onde é definido o raio dos cantos das janelas | falhou | `looknfeel.lua` |
| qual script gera o `preview.png` do tema | ok | `painting-theme` |
| como a dock lê o `shell.json` | ok | `Dock.qml` |
| o que impede o Spotify de fechar a cada troca | falhou | `omarchy-spicetify-sync` |
| onde se desliga o `Super+Alt+L` | ok | `bindings.lua` |
| como o painel descobre o volume | falhou | `control-center-state` |

**Grafo 3/6 fora da amostra (6/6 dentro, mas com nós escritos para o teste); `rg --hidden` 6/6.** Sem `--hidden` o `rg` não acha nada fora dos documentos, porque o código está em `.config/` e `.local/`. Conclusão: busca literal primeiro; o grafo serve para relações.

