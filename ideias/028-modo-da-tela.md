# Modo da tela externa (Espelhar, Estender, Só externa) no painel Display

- **Estado:** Feito (aplicado em 13/11/2026; testado com monitor virtual: espelhar e estender; **"Só externa" não testado de verdade**)
- **Origem:** pedido do usuário (13/11/2026): no menu do display, opções de espelhar etc. com ícones quando o HDMI está em uso.
- **Resumo:** o painel "Display" (ícone de tela na barra) ganhou a seção **MODO DA TELA** com três botões com ícone: Espelhar (󰍹), Estender (󰍺) e Só externa (󰹑). A seção só aparece com uma tela externa ativa; o botão do modo atual fica marcado. Navegação por teclado (setas) como nas escalas.

## Notas
- Painel clonado: `.config/omarchy/plugins/mancato.monitor/Panel.qml` (clone de `omarchy.monitor`; o original fica desativado em `shell.json`, backup `~/.config/omarchy/shell.json.bak.monitorclone.*`). Abrir por IPC: `omarchy-shell omarchy.monitor toggle`.
- Comando `.local/bin/display-mode [mirror|extend|external]`: grava `~/.config/omarchy/display-mode` e recarrega o Hyprland. `external` exige uma tela externa **física** (tamanho físico > 0) e usa `omarchy-hyprland-monitor-internal off`, que já tem as proteções do Omarchy; mirror/extend religam o notebook antes.
- `.config/hypr/monitors.lua` (agora versionado): a TV em `HDMI-A-1` espelha o notebook por padrão (como antes) ou estende quando o modo é `extend`. Sem o arquivo de modo, nada muda.
- Estado do painel vem de `omarchy-monitor-state` (lê o Hyprland de verdade), então o botão marcado reflete o que está ativo, qualquer que tenha sido a forma de configurar.
- **Efeito colateral do teste:** foi criado um monitor virtual chamado `HDMI-A-1` (`hyprctl output create headless`) que **não sai** com `hyprctl output remove` (um virtual com outro nome saiu normal). Ficou desativado (`disabled = true`) e some ao reiniciar a sessão do Hyprland. Antes de ligar a TV de verdade, sair e entrar na sessão (ou reiniciar): um fantasma com o mesmo nome do conector pode atrapalhar.
- Não testado com HDMI físico: troca para "Só externa", religar o notebook pelo modo mirror/extend, e se a TV mantém `mirror` ao conectar a quente.
- Se algo der errado com a tela: no terminal (TTY), `display-mode mirror` religa o notebook; ou `omarchy-hyprland-monitor-internal on`.
