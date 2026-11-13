# omarchy-dotfiles: regras de trabalho

## Grafo (graphify) primeiro
- `graphify-out/GRAPH_REPORT.md` e `graphify-out/graph.json` são o mapa do repo. Antes de ler arquivos, consulte:
  `graphify query "<pergunta>"`, `graphify path "A" "B"`, `graphify explain "<nó>"`.
- Só abra o arquivo-fonte depois que o grafo apontar qual (use `source_location`). Não releia o HANDOFF.md inteiro: consulte o grafo.
- `graphify-out/` é ignorado pelo git (local). Se estiver ausente ou velho: `graphify update .` (ou `/graphify . --update`).
- Depois de mudar arquivos, atualize o grafo (incremental, barato).

## Custo e contexto
- Tarefas simples/mecânicas (busca, logs, typo, formatação, atualizar o grafo): subagente Haiku.
- Código com julgamento: Sonnet. Design/arquitetura: modelo principal.
- Um subagente Haiku "bibliotecário" mantém o grafo atualizado durante o trabalho; ao final, uma verificação confere que grafo, HANDOFF.md e código estão coesos.
- Uma tarefa por conversa: ao terminar um assunto, sugerir novo chat e deixar o resumo no HANDOFF.md (curto).
- Avisar o usuário quando o uso (`/usage`) estiver alto e propor delegar mais a Haiku.
