# Handoff (curto): Hyprland/Omarchy do mancato

Histórico completo e fatos técnicos: [docs/HISTORICO.md](docs/HISTORICO.md). Ideias e estados: [ideias.md](ideias.md). Mapa do código: `graphify-out/GRAPH_REPORT.md` (consulte com `graphify query`).

**Sistema:** Omarchy 4.0, Hyprland 0.56.2 (config Lua), Quickshell, notebook eDP-1 espelhado em HDMI-A-1, foot. Usuário fala português, quer respostas curtas, decisões pequenas tomadas por você, mockup antes de mudança visual, commits pequenos sem atribuição de IA. Repositório **público**.

## Estado (13/11/2026)
- Aplicado: animações, gestos, barra no topo com chips, tema por pintura (`painting-theme`), fastfetch, dock e painel de controle próprios, overview próprio (`SUPER+grave`), cantos 12 px, GTK/Nautilus seguem a pintura.
- Contorno ativo: layout padrão **dwindle**, `SUPER+L` desligado (crash do 0.56.2 ao desmontar a rolagem). Só vale após reiniciar a sessão.
- Não verificado: ver [ideias/005-verificar-pendentes.md](ideias/005-verificar-pendentes.md).

## Armadilhas essenciais
- Nunca rodar `painting-theme next` direto do app Claude; use `systemd-run --user --collect -p KillMode=process painting-theme next`.
- Commons limita pedidos rápidos (≥ 2,5 s); Met e Art Institute têm anti-bot: não contornar.
- Mudança em QML de plugin exige `omarchy restart shell`; mexer em `looknfeel.lua` recarrega o Hyprland.
- Não editar `/usr/share/omarchy/`; tudo em `~/.config` e `~/.local`.

## Ao retomar
1. `graphify query "<pergunta>"` antes de abrir arquivos.
2. `systemctl --user is-active painting-theme.service`, `painting-theme status`, `hyprctl configerrors`.
3. Mudança visual: mockup, backup, validar, commit pequeno.
