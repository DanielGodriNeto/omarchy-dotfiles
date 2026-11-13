# Opção do relógio nas pinturas e cores nos apps

- **Estado:** Em andamento (relógio feito; Spotify depende do terminal do usuário; Vivaldi precisa de 2 passos manuais; Claude Desktop e Discord dependem de decisão)
- **Origem:** pedido do usuário (13/11/2026)

## 1. Relógio do desktop ligável e desligável (feito)
- `.local/bin/desktop-clock [on|off|toggle]`: estado em `~/.config/omarchy/desktop-clock` (sem arquivo = ligado). `mancato.desktop/Desktop.qml` observa o arquivo; a legenda da pintura continua.
- Menu das pinturas: item **Relógio no desktop** (com ✓) em `.config/omarchy/extensions/omarchy-menu.jsonc`; painel da pintura (clique na barra): chip **Relógio no desktop** em `mancato.painting/Painting.qml`.
- Verificado numa área de trabalho vazia: ligado mostra o relógio, desligado some.

## 2. Compatibilidade de cores (auditoria de 13/11)
| App | Situação |
|---|---|
| Terminais, GTK/Nautilus, VS Code, Claude Code (CLI) | Já seguem (Omarchy). VS Code tema "Omarchy"; Claude Code `custom:omarchy`. |
| Chromium e Brave | Cor do navegador por política (`/etc/chromium` e `/etc/brave`, `#302617` = fundo atual). |
| Obsidian | Tema sincronizado no vault, mas **nunca estava selecionado**: ativei `cssTheme: "Omarchy"` em `appearance.json` (backup ao lado). |
| Spotify | **Estava com cores de 9/11**: o spicetify perdeu o backup após atualização do app (`Spotify version and backup version are mismatched`) e o `apply` falhava calado. Correção: reinstalar o pacote e `spicetify backup apply` (rodado no Terminal do usuário, pede sudo). Conferir depois: `grep spice-main /opt/spotify/Apps/xpui/colors.css` deve dar `#302617` (fundo atual). |
| Vivaldi | Novo: template `themed/vivaldi.css.tpl` e hook `35-sync-vivaldi-theme` geram `~/.config/vivaldi-mods/omarchy.css`. **Passos manuais, uma vez:** `vivaldi://flags` → "Allow for using CSS modifications" ligado; Configurações → Aparência → Modificações de UI → escolher `~/.config/vivaldi-mods`; reiniciar. **Não verificado** que as variáveis `--colorBg` etc. pintem a interface (a UI do Vivaldi calcula derivadas em JS). |
| Claude Desktop (Electron) | Sem tema externo no app oficial. Só existe o fork comunitário `claude-desktop-extra` (temas por CSS). Decisão do usuário: trocar para um fork de terceiros? |
| Discord (webapp no Brave) | Sem como pintar o conteúdo do webapp. Alternativa: Vesktop com CSS gerado do tema (recarga manual). Decisão do usuário. |
| Web apps (WhatsApp, YouTube...) no Brave | A barra de título usa o `theme_color` do próprio site; não automatizável. |
| Firefox/Zen, Telegram | Não instalados; existem extensão Omafox e `walogram` se vierem a ser usados. |

## Notas
- Pesquisa completa em duas frentes; relatórios no scratchpad da sessão (não versionados): Vivaldi (CSS mods, flag `vivaldi-css-mods`) e apps (Claude Desktop, Discord, Spotify).
- `spicetify apply` só funciona com o Spotify fechado; `omarchy-spicetify-sync` deixa um marcador se estiver aberto. Se aparecer de novo o erro de backup após atualizar o Spotify: reinstalar o pacote e `spicetify backup apply`.
