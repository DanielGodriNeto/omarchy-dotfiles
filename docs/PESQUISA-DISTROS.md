# Pesquisa: ideias de distros e rices para o Omarchy/Hyprland

Log vivo, escrito durante a pesquisa (ideia 019). Objetivo: manter o Hyprland e puxar o visual para macOS-like, fluido e clean.

**Já existe (não repetir):** barra em ilhas, dock, painel de controle com tiles, overview (SUPER+grave), expose, cantos de 12 px, cantos ativos, histórico de notificações, modo foco, tema por pintura, GTK/Nautilus Yaru, Plymouth, relógio no desktop.

**Regra de leitura:** [verificado: fonte] = visto no código ou doc oficial; [não verificado] = conhecimento de fundo, conferir antes de agir.

## Estado da pesquisa
| Frente | Escopo | Estado |
|---|---|---|
| A | elementary OS, Deepin, COSMIC, Zorin | relatório recebido (parâmetros do lado Hyprland não conferidos) |
| B | end-4, Caelestia, Noctalia e outros rices | relatório recebido (parcial: 4 rices pela web) |
| C | launcher, Quick Look, plugins, ícones, cursores, fontes, lock/login, GNOME/KDE/Bazzite/NixOS | relatório recebido (parcial: SDDM/greeter não pesquisado) |

## Achados

### Frente C: componentes avulsos (13/11/2026)
Nada foi instalado. Ordenado por impacto vs esforço; risco entre parênteses.

| Item | O que é | Como | Estado |
|---|---|---|---|
| Vicinae | Launcher estilo Raycast/Spotlight (apps, arquivos, clipboard, snippets, extensões) | AUR `vicinae-bin`; GPL-3, v0.30.0 de 07/nov/2026, usa QtLayerShell [verificado: github.com/vicinaehq/vicinae/releases] | Feito (ideia 021). SUPER+SPACE segue como menu do Omarchy; o Walker NÃO existe no 4.0 (correção, ver ideia 021) (baixo) |
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

### Frente A: elementary OS, Deepin, COSMIC, Zorin (13/11/2026)
Fontes: código clonado de gala, dock, notifications, stylesheet (elementary), control-center (Deepin), cosmic-comp, e blogs oficiais para Zorin. Valores do lado Hyprland (nomes de opções, `speed` em décimos de segundo) vêm de memória e **precisam ser conferidos na 0.56.2** [não verificado].

**O que o usuário já tem e conta como ajuste fino, não novidade:** sombra, rounding 12, curva `fluid`, `popin 94%`.

#### elementary OS (código verificado)
| Item | Valores | Fonte |
|---|---|---|
| Abrir janela | escala x 0.01 → 1 e y 0.1 → 1, fade, easeOutExpo, 200 ms; popin atual (94%) é bem mais tímido: testar 60-70% | gala `WindowManager.vala:1001-1004` |
| Fechar janela | escala 0.8 + fade, linear, 195 ms | `WindowManager.vala:1087-1090` |
| Minimizar | easeInExpo 200 ms (para o ícone da dock; sem equivalente nativo no Hyprland) | `WindowManager.vala:949-974` |
| Durações gerais | open 350, close 195, hide 200, snap 250, workspace 400 | gala `lib/Constants.vala:20-35` |
| Dock: pressionar | escala 0.92, 250 ms, `cubic-bezier(0.4,0,0.2,1)` | dock `data/Application.css:119-122` |
| Dock: drop | escala 1.1, 300 ms, `cubic-bezier(0.4,3,0.2,1)` (mola) | `Application.css:135-138` |
| Dock: lançar app | sobe 0.5× o ícone em 200 ms, desce em 600 ms com `OutBounce`, repete enquanto abre | dock `Launcher.vala:172-196` |
| Dock: ação negada | shake horizontal de 70 ms | `Launcher.vala:198-207` |
| Receita de vidro | fundo alpha 0.8, raio 9, brilho inset 1 px (topo 0.6, base 0.4), sombras `0 1px 3px .2` e `0 3px 9px .3`; `.reduce-transparency` troca por opaco | `Application.css:6-29` |
| Notificações | hover pausa o timer e mostra o fechar; swipe dispensa; blur atrás; entrada com `EASE_OUT_BACK` | notifications `AbstractBubble.vala:122-183`, gala `NotificationStack.vala:139` |
| OSD | mesmo balão: ícone 48 px + barra 258 px, 2 s | notifications `Confirmation.vala:25-57` |
| Dock inteligente | esconde após 500 ms; 8.1 põe workspaces na dock e pontinhos por workspace | gala `HideTracker.vala:10-11`, blog 8.1 |
| Hot corners | 600 ms entre disparos; opção de manter ativos em fullscreen | gala `HotCorner.vala:44`, blog 8.1 |
| Multitasking | animação 250 ms, ícone 64 px, arrastar para cima fecha, 400 ms de hover troca de workspace | gala `MultitaskingView.vala:25`, `WindowClone.vala:18-22` |
| Sem fonte | Quick Look, sons, tela de boas-vindas | [não verificado] |

#### Deepin (código do control-center + docs)
- Hover na dock mostra preview da janela [verificado: docs openEuler DDE]. Ver item 4 da frente B (mesma ideia, via `ScreencopyView`).
- Slider global de opacidade de 25 a 100 (piso de 25% por legibilidade) e seletor visual de raio 0/6/12/18 com cards [verificado: `WindowEffectPage.qml:61-217`]. Vira tiles no painel de controle que reescrevem raio e alpha de uma vez.
- Busca dentro do painel de controle [verificado: `SearchBar.qml`].
- "Magic Lamp" é do kwin e só aparece em X11: **descartado**. "Treeland 40% mais fluido": marketing sem baseline.

#### COSMIC (cosmic-comp, código verificado)
- **Sombra de janela:** softness 25, offset (0,5), preto alpha 0.45 no escuro; janela inativa ×0.75; sem sombra quando maximizada; raio da janela = raio do tema + 4 [verificado: `shadow.rs:84-97`, `window.rs:420-470`]. Só config.
- **Vidro opcional por superfície** (janelas, painel, dock, menus) com chave "reduzir transparência" (COSMIC 1.3) [web, fonte secundária]. Houve flicker com janela maximizada e hotplug de monitor: cuidado com blur em layer-shell.
- **Shake de erro:** 320 ms, 10 px, 3 ciclos com envelope decrescente [verificado: `floating/mod.rs:57-58`]. Serve para senha errada na tela de bloqueio.
- **Tabela de tempos única:** 200 ms com easeInOutCubic em tiling, workspaces e fullscreen [verificado: `shell/mod.rs:128`]. Uma curva só evita sensação de colcha de retalhos.
- Barra "sempre esconder" e mixer de volume por app (COSMIC 1.3/1.6) [web, detalhe não verificado].

#### Zorin (só web)
- **Presets de "Estilo"** em um clique (posição/tamanho da dock, barra, densidade, raio, vidro) gravados em JSON; 12 layouts no Pro [verificado: blog Zorin 18]. O "estilo macOS" tem uma única fonte [não verificado].
- Popup de layouts de tiling (atalho abre 4-6 layouts aplicados via `hyprctl dispatch`).

#### Ranking da frente A (impacto / esforço)
1. Receita de sombra COSMIC + elementary (config, ~5 min).
2. Curvas e tempos de janela (config, ~15 min): easeOutExpo na abertura, uma curva só.
3. Micro-interações da dock: press 0.92, drop com mola, bounce de lançamento (QML, 1-2 h).
4. Vidro opcional + "reduzir transparência" (QML + layerrule, 1-3 h).
5. Notificações com hover-pausa, swipe e OSD unificado (QML, 2-4 h).
6. Shake de erro no lock/busca (QML, ~20 min).
7. Preview de janela no hover da dock (médio; coincide com frente B item 4).
8. Tiles de raio e opacidade no painel (baixo); presets de estilo (médio).

Fraco: minimizar para a dock (sem nativo), Quick Look e sons (sem fonte).

**Limites:** blur do cosmic-comp não extraído; notícias de 2026 vêm de agregadores via busca (Phoronix deu 403); nada dos repositórios foi executado.

## Síntese: ordem sugerida para aplicar
Reversíveis e só de config, testar primeiro: (1) `rounding_power` 2.5-3, (2) sombra COSMIC, (3) curvas de janela elementary/COSMIC. Depois QML: (4) micro-interações da dock, (5) magnificação + preview na dock, (6) shake de erro. Pacotes: (7) Vicinae, (8) LocalSend, (9) Sushi. Maiores: (10) lock macOS, (11) notificações com swipe, (12) vidro opcional. Qualquer mudança visual segue a regra do projeto: mockup, backup, `hyprctl configerrors`, commit pequeno.
