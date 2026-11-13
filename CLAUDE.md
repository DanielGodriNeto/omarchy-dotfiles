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

## Automação do grafo
- `scripts/graph-refresh.sh` reconstrói o grafo (AST sem LLM + camada semântica salva em `graphify-out/semantic.json`). O hook local `.git/hooks/post-commit` roda isso sozinho depois de cada commit.
- Se aparecer `graphify-out/STALE-SEMANTIC`, QML/.md mudaram: um subagente Haiku refaz a extração semântica (skill graphify, só dos arquivos mudados) e atualiza `semantic.json` e `semantic.sha`.
- **Verificação final:** um subagente separado (reviewer) confere no fim de cada rodada que grafo, `HANDOFF.md`, `ideias.md` e código estão coesos e que nada importante foi perdido.

## Memória do projeto
- `HANDOFF.md` é curto (estado atual). O histórico completo está em `docs/HISTORICO.md`.
- `ideias.md` é o log das ideias do usuário: cada ideia tem arquivo em `ideias/NNN-slug.md` com estado (Pendente, Em andamento, Bloqueado, Feito). Toda ideia nova entra ali; mudou o estado, atualize o arquivo e a tabela.
