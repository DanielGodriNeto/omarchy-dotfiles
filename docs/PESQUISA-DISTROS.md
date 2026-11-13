# Pesquisa: ideias de distros e rices para o Omarchy/Hyprland

Log vivo, escrito durante a pesquisa (ideia 019). Objetivo: manter o Hyprland e puxar o visual para macOS-like, fluido e clean.

**Já existe (não repetir):** barra em ilhas, dock, painel de controle com tiles, overview (SUPER+grave), expose, cantos de 12 px, cantos ativos, histórico de notificações, modo foco, tema por pintura, GTK/Nautilus Yaru, Plymouth, relógio no desktop.

**Regra de leitura:** [verificado: fonte] = visto no código ou doc oficial; [não verificado] = conhecimento de fundo, conferir antes de agir.

## Estado da pesquisa
| Frente | Escopo | Estado |
|---|---|---|
| A | elementary OS, Deepin, COSMIC, Zorin | em andamento |
| B | end-4, Caelestia, Noctalia e outros rices | relatório recebido (parcial: 4 rices pela web) |
| C | launcher, Quick Look, plugins, ícones, cursores, fontes, lock/login, GNOME/KDE/Bazzite/NixOS | relatório recebido (parcial: SDDM/greeter não pesquisado) |

## Achados

### Frente C: componentes avulsos (13/11/2026)
Nada foi instalado. Ordenado por impacto vs esforço; risco entre parênteses.

| Item | O que é | Como | Estado |
|---|---|---|---|
| Vicinae | Launcher estilo Raycast/Spotlight (apps, arquivos, clipboard, snippets, extensões) | AUR `vicinae-bin`; GPL-3, v0.30.0 de 07/nov/2026, usa QtLayerShell [verificado: github.com/vicinaehq/vicinae/releases] | Candidato forte. Conflita com Walker no atalho; o menu do Omarchy depende do Walker, então não remover (baixo) |
| LocalSend | "AirDrop" na LAN, criptografado | AUR/pacman `localsend` 1.18.x [verificado: aur.archlinux.org/packages/localsend] | Candidato forte. Abre porta na LAN, conferir firewall (porta não verificada) (baixo) |
| Sushi | Quick Look: espaço no Nautilus mostra preview | `sushi` 51 (GTK4), em extra-testing [verificado: archlinux.org/packages/extra-testing/x86_64/sushi] | Funcionar fora de sessão GNOME [não verificado] (baixo/médio) |
| Gestos de trackpad | 3/4 dedos para workspaces, estilo Mission Control | `hl.gesture(...)` no Lua, sem instalar [verificado: wiki.hypr.land 0.56 Gestures] | Já é a ideia 015 (pendente). Há relato de float/fullscreen com defeito no 0.55.2 |
| Hyprlock macOS | Relógio grande, blur do wallpaper, campo de senha arredondado | Só editar `hyprlock.conf`; não mexer na autenticação, testar com TTY de recuperação | Alto impacto, baixo esforço (baixo) |
| Cursores | `capitaine-cursors` (LGPLv3, repo extra) ou WhiteSur-cursors (GPLv3) | `pacman -S capitaine-cursors` [verificado: archlinux.org/packages/extra/any/capitaine-cursors] | Impacto médio (baixo) |
| Fonte | Inter ou Geist no lugar da SF Pro (SF Pro não é livre) | `inter-font`; Geist pacote [não verificado] | Inter em fonte de sistema serve; o veto do CLAUDE.md global vale para web (baixo) |
| Sons | Sons de notificação/volume/login via libcanberra | `sound-theme-freedesktop` não tem login/logout; disparar `canberra-gtk-play` no autostart | Médio (baixo); `ocean-sound-theme` [não verificado] |
| Accent color manual | Seletor único de acento para GTK, Qt, bordas e shell | Ideia de UX sobre o tema por pintura | [não verificado] |
| Notificações agrupadas | Agrupar por app, expandir, limpar | Reimplementar no shell QML; referências: elementary-notifications, Caelestia | Esforço alto |
| Ícones WhiteSur/MacTahoe/Colloid | Ícones estilo macOS | Script upstream (vinceliuice) ou AUR | Conflita com Yaru no Nautilus; avaliar só para dock/launcher (baixo, reversível por `gsettings`) |
| Kvantum + tema Qt | Apps Qt com a mesma estética | `kvantum` 1.1.5 + WhiteSur-kde | Impacto baixo/médio; AUR defasado desde 02/2025 |
| Motion blur / glow (0.56) | Blur de movimento e brilho na janela focada | Opções no Lua [secundário: Phoronix] | Relato de lentidão (issue 15494); custo de GPU |

Já feito pelo usuário (não repetir): night light (`hyprsunset.conf` existe), clipboard history (Walker, Super+Ctrl+V).

**Descartados:** hyprexpo (removido do repo oficial hyprland-plugins [verificado]); Hyprspace (relato de problema com Lua no 0.55.2, e o overview próprio já existe); Hyprbars (plugin C++ no compositor, risco alto de derrubar a sessão a cada upgrade); MacTahoe/WhiteSur/Colloid GTK (ganho marginal sobre o Yaru atual e sobrescrevem `gtk-4.0`); Rofi/wofi.

**Atenção às regras do projeto:** o relatório sugere o layout `scrolling` e o gesto `scroll_move`. **Proibido no 0.56.2** (CLAUDE.md: crasha ao desmontar), só após Hyprland 0.57+. O relatório diz que o 0.57 já saiu, mas baseado só em manchete [parcial]. Conferir a versão instalada e a nota oficial antes de reabrir a ideia 008. Plugins de compositor precisam de rebuild com `hyprpm` no salto 0.56 → 0.57.

**Não verificado:** licença do MacTahoe, termos da SF Pro, porta do LocalSend, pacotes `ocean-sound-theme` e `ttf-geist` no Arch, SDDM/greeter, conteúdo dos PKGBUILDs do AUR (ler antes de instalar qualquer um).

**Resumo de inspiração por distro:** GNOME: gestos, accent color, Sushi, notificações agrupadas. KDE: Kvantum, sons, KRunner (coberto por Vicinae). COSMIC: pouco extraível sem portar Rust. Bazzite/NixOS: pouco aplicável ao visual. Mint/Ubuntu: sons Yaru.

### Frente B: rices de Hyprland/Quickshell (13/11/2026)
Fontes lidas: end-4/dots-hyprland, Caelestia, Noctalia (clones) e, pela web, MacShell, hyprland-dock, ekremx25/quickshell.

**Licenças (decide o método):** end-4 e Caelestia são GPL-3: ler a ideia e reescrever, nunca colar. **MacShell (0-ss/MacShell) é MIT, usa Lua + Hyprland 0.55+ + Quickshell 0.3, a mesma stack daqui:** melhor base para reaproveitar código (manter o aviso de copyright). hyprland-dock e ekremx25/quickshell: MIT. Noctalia: MIT, mas é C++ nativo (não QML): só referência de design.

**Restrição de hardware:** o `looknfeel.lua` já avisa que blur é caro na iGPU Iris Xe. Itens de blur, motion blur e shader "liquid glass" exigem teste de custo de GPU.

**Já existe aqui (conferido no `looknfeel.lua` e nos plugins):** blur com noise 0.08, `dim_inactive`, sombra, rounding 12, curva `fluid` com layers em fade, dock, cantos, relógio.

| # | Item | Esforço / impacto | Fonte [verificado] | Observação |
|---|---|---|---|---|
| 1 | Cantos squircle: `rounding_power = 2.5` (testar 2.8-3) | 1 linha / alto | end-4 `hypr/hyprland/general.lua:74` | Reversível. Em QML `Rectangle` não faz squircle nativo [não verificado] |
| 2 | Spotlight de verdade (SUPER+Space): apps, arquivos, calculadora, ações | médio / alto | Caelestia `modules/launcher/`, MacShell | Alternativa pronta: Vicinae (frente C) |
| 3 | Lock screen macOS: blur, relógio grande, animação, lock em processo separado | médio / alto | Caelestia `modules/lock/LockSurface.qml`, MacShell `MacLock/` (MIT) | Quickshell `WlSessionLock` + `PamContext`. Segurança: nunca logar a senha. Alternativa simples: hyprlock |
| 4 | Dock com magnificação por distância do ponteiro e preview de janela | médio / alto | hyprland-dock (MIT), MacShell `MacDock.qml` | A dock daqui não tem magnificação (grep sem resultado). Preview via `ScreencopyView` |
| 5 | Captura de tela com seletor de região e ações (copiar, OCR, gravar) | médio / médio-alto | end-4 `regionSelector/`, Caelestia `areapicker/` | OCR via tesseract é inferência [não verificado] |
| 6 | Alt+Tab com miniaturas | médio / médio | MacShell | Só existência confirmada |
| 7 | Clipboard visual com preview de imagem + seletor de emoji | baixo-médio / médio | MacShell, Caelestia `ClipWrapper.qml`, Noctalia `emoji.json` (MIT) | `cliphist` + `wl-copy` |
| 8 | Widgets de desktop (clima, calendário, player) | médio / médio | MacShell `MacWidgets.qml`, Caelestia `background/` | Relógio já existe |
| 9 | Visualizador de áudio (cava) | baixo / médio | Caelestia `Visualiser.qml` | GPL: reescrever |
| 10 | Blur afinado + layer rules com `ignore_alpha` | baixo / alto | end-4 `general.lua:77-93`, MacShell README | Valores: size 10, passes 3, vibrancy 0.5, contrast 0.89. Nome do campo `ignore_alpha` no Lua 0.56 [não verificado]. Testar custo na iGPU |
| 11 | Popout que funde barra e painel | médio-alto / médio | Caelestia `drawers/`, `bar/popouts/` | Pouco ganho sobre os cantos ativos |
| 12 | Liquid glass por shader | alto / alto, arriscado | MacShell `liquidglass.frag` | Layer-shell não acessa o fundo real; custo de GPU [não verificado] |
| 13 | Greeter coerente com o lock | alto / médio | Noctalia Greeter, DankMaterialShell (greetd) | Mexe em login: mudança de segurança, exigir aprovação e fallback |

Já cobertos pelo que existe: dim e sombra suave, curvas de layer (a `fluid` atual já é macOS-like; `popin 93%` do end-4 é detalhe).

**Parcialmente verificado** (só existência de arquivos): itens 6, 7, 9, 11, 12, 13. Nome atual do DankMaterialShell incerto (o fetch voltou "Dux Modular Shell"). Screenshots não foram vistas.

### Frente A (distros)
(aguardando relatório)
