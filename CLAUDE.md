# omarchy-dotfiles: regras de trabalho

Repositório PÚBLICO de personalizações do Omarchy/Hyprland (caminhos espelham o `$HOME`). Usuário: fala português, quer respostas curtas e decisões pequenas tomadas por você.

## Regras invioláveis
- Nunca rode `painting-theme next` (nem `omarchy theme set`) direto do app Claude: ele roda com `no_new_privs`, o `sudo` falha e aparece um aviso falso do navegador. Use `systemd-run --user --collect -p KillMode=process painting-theme next`.
- Wikimedia Commons: espaçar chamadas de API em 2,5 s ou mais. Met Museum e Art Institute têm anti-bot: não contornar.
- Nunca edite `/usr/share/omarchy/`; tudo vai em `~/.config` e `~/.local`. Faça backup antes de editar arquivo vivo.
- Plugin QML novo ou alterado exige `omarchy restart shell`. Salvar `looknfeel.lua`, `input.lua` ou `bindings.lua` recarrega o Hyprland.
- **Nunca ative o layout `scrolling` nem alterne layouts de workspace** (inclui `omarchy hyprland workspace layout default scrolling` e as opções de layout do menu do Omarchy: elas fazem todo workspace novo abrir em rolagem e quebram o tiling em divisões): o Hyprland 0.56.2 crasha ao desmontá-lo (padrão agora é dwindle). Religar só após atualizar para 0.57+.
- Repositório público: sem segredos, tokens, e-mail ou caminhos privados; escaneie o diff antes de cada commit. Commits pequenos, sem atribuição de IA.
- Mudança visual: mockup primeiro, depois aplicar com backup, validar (`hyprctl configerrors`) e só então commitar.

## Como buscar (nesta ordem)
1. `docs/MAPA.md` (gerado): "onde fica X" por arquivo.
2. `rg --hidden -g '!.git' -g '!graphify-out'` para literais (função, atalho, comando, chave de config). **`--hidden` é obrigatório:** quase tudo mora em `.config/` e `.local/`, e o `rg` puro não entra em pastas ocultas (acha só README e docs).
3. `graphify query "<pergunta>"` só para relações e visão geral. É **pista, nunca prova**: fora da amostra acerta cerca de metade (`docs/graph/AVALIACAO.md`). `scripts/graph-verify.py` confere a camada semântica contra o código (sem LLM).
4. Leia o arquivo-fonte antes de editar ou afirmar qualquer coisa.

## Fonte da verdade
Código > `HANDOFF.md` (estado atual e ponteiros) > grafo (derivado, descartável). Um clone novo funciona só com `rg`; o grafo é opcional: `uv tool install graphifyy==0.9.108`, depois `scripts/install-hooks.sh` e `scripts/graph-refresh.sh`. O hook de pós-commit nunca bloqueia o commit (roda em segundo plano, só AST); a camada semântica por LLM é sob demanda (arquivo `graphify-out/STALE-SEMANTIC`).

## Subagentes
- **Haiku:** só leitura, busca e logs; única escrita permitida é atualizar o grafo e `docs/MAPA.md`.
- **Sonnet:** implementa.
- **Verificador** (subagente separado): roda checagens executáveis e cita a saída: `luac -p` nos `.lua`, `python3 -m py_compile`, `jq empty` nos `.json`, `systemd-analyze verify --user` no `.service`, `scripts/graph-test.sh`. Confere também que cada arquivo citado no `HANDOFF.md` existe e que a linha "Verificado no commit" bate com o HEAD.

## Escritor, crítico e melhoria
- **Escritor** (Sonnet) implementa. **Crítico** é um subagente separado, com contexto novo (`critic` para planos, `reviewer` para diffs): recebe só os requisitos originais e o diff, nunca o raciocínio do escritor. Reporta apenas problemas de severidade média ou alta de correção, requisito ou segurança, cada um com evidência executável (saída de comando ou linha do arquivo) e correção de uma linha; sem elogio nem estilo. O escritor corrige e o verificador reexecuta.
- Limite: 1 rodada (2 se houver problema alto); para quando não houver achado médio ou alto. Só ative quando o diff tocar 3 ou mais arquivos ou algo de risco (config do Hyprland, `painting-theme`, hooks, `shell.json`, qualquer coisa que vá ao GitHub). Mudança trivial dispensa.
- Crítico acha falhas de lógica e requisito; verificador roda checagens automáticas. Um não substitui o outro.

## Continuidade
Uma tarefa por conversa. Ao terminar, atualize o `HANDOFF.md` (curto) e `ideias.md` (cada ideia em `ideias/NNN-slug.md`; subagentes não apagam ideias, só mudam o estado). Histórico completo: `docs/HISTORICO.md`.
