# Janelas sólidas, transparentes ou vidro no painel de controle

- **Estado:** Feito (aplicado em 13/11/2026; os três modos testados por comando, o clique no painel não)
- **Origem:** pesquisa (ideia 019, COSMIC 1.3 "vidro opcional" e "reduzir transparência" do elementary), escolha do assistente como próximo item
- **Resumo:** linha "Janelas" no painel de controle com três botões: **Sólidas** (sem transparência, também alivia a iGPU), **Transparentes** (o padrão do Omarchy, como estava) e **Vidro** (transparência com blur). Usa o ajuste que o próprio Omarchy já tem: `omarchy-hyprland-window-transparency [opaque|transparent|glassy]`, que grava um arquivo de toggle em `~/.local/state/omarchy/toggles/hypr/` e recarrega o Hyprland.

## Notas
- `Panel.qml` do `mancato.control-center`: `windowModes`, `setWindowMode`, `stepWindowMode`, linha nova depois de "Cantos" (cursor do teclado 8). `control-center-state` ganhou o campo `windows`.
- Verificado: o painel mostra a linha com "Transparentes" marcado; por comando, `glassy`, `opaque` e `transparent` trocaram o estado sem erro de configuração e o estado voltou a `transparent`.
- Não mexe na barra: ela já usa o estilo próprio (fundo `none` em `omarchy bar background`). Para a barra em vidro há `omarchy bar background glassy`, ainda não ligado ao painel.
- Backup do painel anterior: `~/.config/omarchy/plugin-backups/Panel.qml.bak.windows.*`.
