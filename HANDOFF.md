# Handoff (curto): Hyprland/Omarchy do mancato

**Verificado no commit `607be73` em 13/11/2026** (o verificador confere que o sha existe, que nenhum arquivo que não seja `.md` mudou desde ele e que todo caminho citado aqui existe).

Histórico completo e fatos técnicos: [docs/HISTORICO.md](docs/HISTORICO.md). Ideias e estados: [ideias.md](ideias.md). Mapa do código: `graphify-out/GRAPH_REPORT.md` (consulte com `graphify query`).

**Sistema:** Omarchy 4.0, Hyprland 0.56.2 (config Lua), Quickshell, notebook eDP-1 espelhado em HDMI-A-1, foot. Usuário fala português, quer respostas curtas, decisões pequenas tomadas por você, mockup antes de mudança visual, commits pequenos sem atribuição de IA. Repositório **público**.

## Estado (13/11/2026)
- Aplicado: animações, gestos, barra em ilhas flutuantes (plugin `mancato.bar`) com chips, tema por pintura (`painting-theme`), fastfetch, dock e painel de controle próprios, overview próprio (`SUPER+grave`), cantos 12 px, GTK/Nautilus seguem a pintura.
- Contorno ativo: layout padrão **dwindle**, `SUPER+L` desligado (crash do 0.56.2 ao desmontar a rolagem). Só vale após reiniciar a sessão.
- Não verificado: ver [ideias/005-verificar-pendentes.md](ideias/005-verificar-pendentes.md).
- Plymouth Pintura instalado (foto do momento; atualizar = `system/plymouth-pintura/build.sh` + `install.sh` com sudo).
- Feitos (13/11): cantos ativos, expose (SUPER+SHIFT+grave), histórico de notificações (SUPER+ALT+N), relógio/legenda no desktop, `focus-mode` (SUPER+ALT+Z). Pendentes: 015 (gestos), 016 (vinheta).

- Pesquisa de distros/rices (ideia 019) concluída em [docs/PESQUISA-DISTROS.md](docs/PESQUISA-DISTROS.md): ranking e síntese de ordem de aplicação no fim do doc. Falta o usuário escolher; cada escolha vira ideia 020+. Parâmetros do lado Hyprland vieram de memória: conferir na 0.56.2 antes de aplicar. Licenças: end-4 e Caelestia são GPL-3 (só reescrever); MacShell é MIT.

- Pintura: painel no clique esquerdo do botão da barra (`mancato.painting`): Gostei (1 clique) / Não gostei (com motivos) alimentam `~/.config/painting-theme/taste.json`; 30% dos sorteios exploram. Acervo com ~1267 pinturas (`painting-theme-discover` amplia, depois `meta`, `lum`, `features`).

## Armadilhas essenciais
Vivem em [CLAUDE.md](CLAUDE.md), seção "Regras invioláveis" (fonte única; leia antes de qualquer mudança).

## Ao retomar
1. Buscar: `docs/MAPA.md`, depois `rg`; `graphify query` só para relações (veja CLAUDE.md).
2. `systemctl --user is-active painting-theme.service`, `painting-theme status`, `hyprctl configerrors`.
3. Mudança visual: mockup, backup, validar, commit pequeno.
