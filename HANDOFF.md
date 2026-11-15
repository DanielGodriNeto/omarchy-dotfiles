# Handoff (curto): Hyprland/Omarchy do mancato

**Verificado no commit `00e962b` em 15/11/2026** (o verificador confere que o sha existe, que nenhum arquivo que não seja `.md` mudou desde ele e que todo caminho citado aqui existe).

Histórico completo e fatos técnicos: [docs/HISTORICO.md](docs/HISTORICO.md). Ideias e estados: [ideias.md](ideias.md). Mapa do código: `graphify-out/GRAPH_REPORT.md` (consulte com `graphify query`).

**Sistema:** Omarchy 4.0, Hyprland 0.56.2 (config Lua), Quickshell, notebook eDP-1 espelhado em HDMI-A-1, foot. Usuário fala português, quer respostas curtas, decisões pequenas tomadas por você, mockup antes de mudança visual, commits pequenos sem atribuição de IA. Repositório **público**.

## Estado (13/11/2026)
- Aplicado: animações, gestos, barra em ilhas flutuantes (plugin `mancato.bar`) com chips, tema por pintura (`painting-theme`), fastfetch, dock e painel de controle próprios, overview próprio (`SUPER+grave`), cantos 12 px, GTK/Nautilus seguem a pintura.
- Contorno ativo: layout padrão **dwindle**, `SUPER+L` desligado (crash do 0.56.2 ao desmontar a rolagem). Só vale após reiniciar a sessão.
- Não verificado: ver [ideias/005-verificar-pendentes.md](ideias/005-verificar-pendentes.md).
- Plymouth Pintura instalado (foto do momento; atualizar = `system/plymouth-pintura/build.sh` + `install.sh` com sudo).
- Feitos (13/11, 015 e 016 feitos em 14/11): cantos ativos, expose (SUPER+SHIFT+grave), histórico de notificações (SUPER+ALT+N), relógio/legenda no desktop, `focus-mode` (SUPER+ALT+Z). Pendentes: 015 (gestos), 016 (vinheta).

- Pesquisa de distros/rices (ideia 019) concluída em [docs/PESQUISA-DISTROS.md](docs/PESQUISA-DISTROS.md) (ranking no fim). Licenças: end-4 e Caelestia são GPL-3 (só reescrever); MacShell é MIT.
- **Aplicado da pesquisa (ideias 020-029):** squircle/sombra/curvas (`looknfeel.lua`), Vicinae em `SUPER+R` (tema sincronizado por hook), dock com press/bounce/zoom/preview de janela/bolinha que acompanha, notificações com swipe, tooltips na barra (`BarTooltips.js`), menu SUPER+SPACE clonado com atalhos em teclas e explicações (`mancato.menu`, atalhos gerados por `scripts/menu-shortcuts.py`), painel de controle com linhas Cantos (`corner-radius`) e Janelas, painel Display clonado com Modo da tela (`display-mode`).
- **Falta o usuário ver com o mouse real** (não dava para testar por script): zoom e preview da dock, swipe das notificações, tooltips, cliques das linhas do painel. Não testado com HDMI físico: modo "Só externa".
- **Cuidados:** plugin QML alterado exige `omarchy restart shell`; clones (`mancato.menu`, `mancato.monitor`, `mancato.dock`, `mancato.notifications`, `mancato.bar`) não recebem updates do original. Um monitor virtual `HDMI-A-1` do teste de 13/11 fica até reiniciar a sessão do Hyprland: reiniciar a sessão antes de ligar a TV. Rodar `python3 -I scripts/menu-shortcuts.py` após atualizar o Omarchy.

- Pintura: painel no clique esquerdo do botão da barra (`mancato.painting`): Gostei (1 clique) / Não gostei (com motivos) alimentam `~/.config/painting-theme/taste.json`; 30% dos sorteios exploram. Acervo com ~1267 pinturas (`painting-theme-discover` amplia, depois `meta`, `lum`, `features`).

- **Lago de carpas (15/11, ideia 036):** plugin `mancato.lake` (ver `.config/omarchy/plugins/mancato.lake/README.md`). Carpas na GPU (`cells.frag`, `lake.frag`, 16 carpas, 12 esquemas de cor) vistas só por terminais foot (`foot.ini` com `alpha=0.62`, sem blur por regra em `hyprland.lua`). Modo Performance mostra em todos; nos outros, só em terminal parado no prompt (`lake-term-state`). Clique esquerdo (bind não consumidor em `bindings.lua`) gera onda. **Falta o usuário ver:** clique normal ainda funciona, fastfetch no terminal, carpas se movendo. Gestos: 3 dedos para cima abre o overview; troca de workspace invertida (`workspace_swipe_invert=false`). Widgets do workspace 9: ideia 035 (depois).
- **Cuidados do lago:** `.frag` alterado exige recompilar com `qsb` (comando no README do plugin) e `omarchy restart shell` (o recarregamento a quente não vale).

## Armadilhas essenciais
Vivem em [CLAUDE.md](CLAUDE.md), seção "Regras invioláveis" (fonte única; leia antes de qualquer mudança).

## Ao retomar
1. Buscar: `docs/MAPA.md`, depois `rg`; `graphify query` só para relações (veja CLAUDE.md).
2. `systemctl --user is-active painting-theme.service`, `painting-theme status`, `hyprctl configerrors`.
3. Mudança visual: mockup, backup, validar, commit pequeno.
