# Handoff (curto): Hyprland/Omarchy do mancato

**Verificado no commit `607be73` em 13/11/2026** (o verificador confere que o sha existe, que nenhum arquivo que não seja `.md` mudou desde ele e que todo caminho citado aqui existe).

Histórico completo e fatos técnicos: [docs/HISTORICO.md](docs/HISTORICO.md). Ideias e estados: [ideias.md](ideias.md). Mapa do código: `graphify-out/GRAPH_REPORT.md` (consulte com `graphify query`).

**Sistema:** Omarchy 4.0, Hyprland 0.56.2 (config Lua), Quickshell, notebook eDP-1 espelhado em HDMI-A-1, foot. Usuário fala português, quer respostas curtas, decisões pequenas tomadas por você, mockup antes de mudança visual, commits pequenos sem atribuição de IA. Repositório **público**.

## Estado (13/11/2026)
- Aplicado: animações, gestos, barra em ilhas flutuantes (plugin `mancato.bar`) com chips, tema por pintura (`painting-theme`), fastfetch, dock e painel de controle próprios, overview próprio (`SUPER+grave`), cantos 12 px, GTK/Nautilus seguem a pintura.
- Contorno ativo: layout padrão **dwindle**, `SUPER+L` desligado (crash do 0.56.2 ao desmontar a rolagem). Só vale após reiniciar a sessão.
- Não verificado: ver [ideias/005-verificar-pendentes.md](ideias/005-verificar-pendentes.md).
- Pendente do usuário: rodar `bash system/plymouth-pintura/build.sh && bash system/plymouth-pintura/install.sh` num terminal próprio e reiniciar.

## Armadilhas essenciais
Vivem em [CLAUDE.md](CLAUDE.md), seção "Regras invioláveis" (fonte única; leia antes de qualquer mudança).

## Ao retomar
1. Buscar: `docs/MAPA.md`, depois `rg`; `graphify query` só para relações (veja CLAUDE.md).
2. `systemctl --user is-active painting-theme.service`, `painting-theme status`, `hyprctl configerrors`.
3. Mudança visual: mockup, backup, validar, commit pequeno.
