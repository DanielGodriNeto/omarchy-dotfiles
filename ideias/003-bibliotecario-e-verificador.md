# Haiku mantém o grafo e outro subagente verifica coesão

- **Estado:** Feito em parte: hook automático faz o AST; falta rodar o verificador no fim de cada rodada
- **Origem:** pedido do usuário ou HANDOFF antigo (13/11/2026)
- **Resumo:** O grafo é atualizado pelo hook (sem LLM). Haiku só reextrai QML/.md quando scripts/graph-refresh.sh avisar STALE-SEMANTIC. Um subagente separado confere no fim que nada importante se perdeu.

## Notas
(atualize aqui: decisões, commits, o que falta)
