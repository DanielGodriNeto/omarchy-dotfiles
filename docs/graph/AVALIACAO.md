# Avaliação do grafo (13/11/2026)

6 perguntas de resposta conhecida em `scripts/graph-test.sh` (`graphify query ... --budget 700`).

| Momento | Placar | Observação |
|---|---|---|
| Só código Python/QML + HANDOFF | 3/6 | errou Não perturbar, atalho do overview e serviço systemd: Lua, `.service`, `.jsonc`, `.toml`, `.tpl` não estavam no grafo |
| Com a configuração coberta (`docs/graph/semantic.json`) | 6/6 | nós de bindings, serviço, menu e Panel.qml adicionados |

**A/B com `rg`:** com a palavra-chave certa, `rg` respondeu as 6 perguntas (1 a 14 linhas, menos de 1 KB cada). O grafo ajuda a ligar vocabulários diferentes (Não perturbar a `silencing`), mas depende de a camada semântica estar atualizada.

**Conclusão:** o grafo é complemento (relações e visão geral), não a primeira consulta; use `docs/MAPA.md` e `rg` antes. Os 6/6 foram obtidos com nós escritos para essas perguntas: não generaliza sozinho para perguntas novas.
