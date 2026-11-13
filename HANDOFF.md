# Handoff: personalização do Hyprland/Omarchy

Ponto de partida para continuar a personalização em outra sessão. Escrito em 12/11/2026, atualizado em 13/11/2026.
Sistema: Omarchy 4.0 (Arch + Hyprland 0.56.2, config em **Lua**), shell Quickshell (`omarchy-shell`), notebook com eDP-1 espelhado em HDMI-A-1, terminal foot (imagens em sixel).

## Objetivo do usuário

Deixar o desktop mais bonito e profissional, com a fluidez do NixOS e do macOS, sem sair do Hyprland e sem quebrar as atualizações do Omarchy. Prefere decisões pequenas tomadas por mim, recomendações curtas e respostas em português. Sem atribuição de IA em commits.

## O que está aplicado

| Item | Onde | Observação |
|---|---|---|
| Animações fluidas (curva única, 180–320 ms, slide entre workspaces) | `.config/hypr/looknfeel.lua` | estavam desligadas antes |
| Layout em rolagem (colunas, estilo Niri) | `.config/hypr/looknfeel.lua` | `SUPER+L` alterna para dwindle por workspace |
| Gestos: 3 dedos trocam workspace, 4 dedos deslizam as colunas | `.config/hypr/input.lua` | |
| Barra no topo, transparente, com chips (`Pill.qml`) | `.config/omarchy/shell.json` | `bar.position = "top"` |
| **Tema por pintura** (wallpaper + cores do sistema a partir de uma pintura) | `.local/bin/painting-theme` | tema de usuário `pintura` em `~/.config/omarchy/themes/pintura/`, gerado a cada troca |
| Botão na barra: clique esquerdo troca, direito abre o menu, hover mostra o nome | `.config/omarchy/bar/modules/painting.qml` | |
| Menu "Pintura do tema" (trocar, escolher numa galeria, auto, ao ligar, ao acordar, intervalo) | `.config/omarchy/extensions/omarchy-menu.jsonc` | também via `SUPER+SPACE` |
| Troca automática: ao ligar, ao acordar da suspensão e por tempo (padrão 3 h, mínimo 5 min entre trocas) | `.config/systemd/user/painting-theme.service` | roda `painting-theme daemon` |
| Miniatura da pintura atual na tela de temas (`CTRL+SHIFT+SUPER+ESPAÇO`) | `preview.png` do tema `pintura` | gerado em `apply()` |
| fastfetch com pintura no lugar do logo, escolhida pela cor do tema | `.local/bin/fastfetch-art` | chamado pela função `fastfetch` do `.bashrc` |
| Cores do fastfetch seguem o tema (títulos e barras no acento, chaves neutras, ANSI do tema) | `.local/bin/fastfetch-fit` | lê `~/.local/state/omarchy/current/theme/colors.toml`; sem as chaves, volta às cores antigas |
| Modo por horário do dia (noite/manhã/tarde/entardecer = quartis de luminosidade) | `painting-theme` + `.local/share/fastfetch-art/lum.json` | opção `by_time` (ligada), item no menu da Pintura; troca ao mudar de faixa; `painting-theme lum` recalcula |
| Dock em qualquer layout, auto-ocultar embaixo | `.config/omarchy/plugins/mancato.dock/` | clone de `omarchy.dock` sem a regra "só flutuante"; `omarchy-dock autohide on/off` |
| Painel de controle (Wi-Fi, Bluetooth, luz noturna, energia, volume, brilho) | `.config/omarchy/plugins/mancato.control-center/` + `.local/bin/control-center-state` | botão na barra, lado direito |
| Pastas/ícones (Yaru) e acento do GTK seguem o acento da pintura | `painting-theme` (`icon_and_accent`) | grava `icons.theme` no tema; `gsettings accent-color` |
| Compatibilidade com o peek desktop (`SUPER+D`) | shim + vigia em `painting-theme` | veja "Peek" abaixo |

## Como o tema por pintura funciona

1. **Acervo:** ~500 pinturas de natureza (Wikimedia Commons, artistas com mais de 70 anos de morte). As imagens **não** estão no git. Estão no git só a lista (`index.jsonl`), os metadados de resolução (`meta.json`) e a exclusão curada (`exclude.txt`: retratos, interiores, molduras, desenhos em P&B). Para recriar: `painting-theme-fetch` (baixa as miniaturas de 640 px, devagar).
2. **Elegíveis para wallpaper:** largura ≥ 1500 px e proporção ≥ 1,25 (181 pinturas). O wallpaper é sempre 16:9 cheio com corte central, nunca com barras, e leva um degradê escuro no topo para o texto da barra transparente continuar legível.
3. **Paleta:** `build_palette()` tira da pintura o matiz dominante (acento, fundo, textos) e aproxima as cores ANSI do que existe na pintura. Escreve `colors.toml` e roda `omarchy theme set pintura`, que repinta barra, terminal, bordas, btop, bloqueio etc.
4. **Troca rápida:** depois de cada troca, `prefetch` já baixa e corta a próxima em segundo plano (`~/.cache/painting-theme/next.jpg`). `painting-theme next` leva ~0,3 s.
5. **Config:** `~/.config/painting-theme/config.json` (`enabled`, `interval_min`, `on_boot`, `on_wake`, `min_gap_min`). Estado em `~/.local/state/painting-theme/state.json`.
6. **Comandos:** `next`, `pick <arquivo>`, `choose` (galeria do Omarchy), `status`, `config [chave valor]`, `daemon`, `meta` (recalcula metadados), `prefetch`.

### Peek desktop (SUPER+D)

O `omarchy theme set` recarrega o Hyprland (reload explícito **e** reload automático ao mudar os arquivos do tema), e isso derrubava o peek. Solução em `apply()`: se `omarchy-peek-desktop.json` existe, desliga `misc.disable_autoreload` via `hyprctl eval`, usa o shim `.local/share/painting-theme/shim/omarchy-restart-hyprctl` (adia o reload) e deixa um `flush-reload` esperando o peek acabar. Um `peek-guard` por eventos do socket2 é a rede de segurança. Troca automática durante o peek espera o fim dele.

## Armadilhas já conhecidas

- **Nunca testar `painting-theme next` direto de dentro do app Claude.** O app roda com `no_new_privs`, o `sudo` falha, o Omarchy cai no `pkexec` e aparece "Theme not applied everywhere / omarchy-theme-set-browser failed". É só artefato do teste. Use `systemd-run --user --collect -p KillMode=process painting-theme next` (sem `KillMode=process` o systemd mata as etapas em segundo plano do `theme set`).
- **Commons limita pedidos rápidos** (HTML no lugar de JSON). Use ≥ 2,5 s entre chamadas de API e 0,7 s entre downloads. Met Museum e Art Institute estão atrás de proteção anti-bot: não contornar.
- **hyprexpo (overview) não serve:** saiu do repositório oficial e não é mantido para o 0.56. Não compilar plugin de fonte duvidosa.
- `shell.json` é recarregado ao salvar, mas um módulo QML novo só aparece depois de `omarchy restart shell`.
- Não editar nada em `/usr/share/omarchy/`; tudo em `~/.config` ou `~/.local`.
- A revisão do acervo foi por miniaturas: pode haver uma pintura que não seja natureza. Para tirar, acrescente o arquivo (ex.: `123.jpg`) em `exclude.txt`.

## Verificado em 13/11/2026

- **Troca ao acordar:** suspensão real (`s2idle`, ~2 s) seguida de troca automática ~6 s depois ("trocando pintura (acordou)" no journal do serviço). Tema, política de cor do Chromium e `theme-set.log` ficaram corretos. Só testei suspensão curta. A troca espera ~8 s após acordar (rede e shell voltarem) e respeita `min_gap_min` (5 min).
- **Troca por tempo:** rodou sozinha às 07:13, sem erro.

## Não verificado

- Clique no botão, menu da barra e a galeria `choose` não foram vistos funcionando na tela (só os comandos).
- Tela de bloqueio e notificações seguem o tema por contrato (`shell.toml`), mas não foram conferidas visualmente.
- A miniatura do tema "Pintura" no carrossel `CTRL+SHIFT+SUPER+ESPAÇO` foi gerada, mas não a vi no carrossel.

## Ideias para continuar (por prioridade)

1. Conferir os "não verificados" acima, principalmente a miniatura no carrossel e uma suspensão longa (horas).
2. ~~Cores do fastfetch~~ feito. 3. ~~Modo por horário~~ feito.
4. Pílula flutuante de verdade para a barra: não há opção nativa; só via QML próprio (`Pill.qml` já dá o formato por widget).
5. ~~Dock e central de controle~~ feitos (plugins próprios). Faltam: apps fixados na dock (`dock.pinned`), "Não perturbe" no painel, restilizar a dock.
6. ~~Pastas/ícones~~ feito.
7. Tela de login/Plymouth com a pintura atual.
8. Um overview de workspaces próprio (QML no shell) já que o hyprexpo está descartado.

## Como instalar do zero

Os caminhos espelham o `$HOME` (veja o README). Depois de copiar os arquivos:

```bash
~/.local/bin/painting-theme-fetch           # baixa as miniaturas do acervo
systemctl --user daemon-reload
systemctl --user enable --now painting-theme.service
omarchy restart shell                       # carrega o módulo painting.qml
systemd-run --user --collect -p KillMode=process painting-theme next
```

Depende de `magick` (ImageMagick), `jq`, `curl`, `python3` e do `dbus-monitor`.

---

# Anexo: contexto completo da sessão (para quem continua)

## Como o usuário trabalha (preferências observadas)

- Fala português e pede o resultado "da forma mais preguiçosa possível": quer que eu planeje, ordene e execute, como um CEO que só decide. Respostas curtas e diretas.
- **Fluxo preferido:** pesquisar primeiro (subagentes: haiku para ler a máquina, sonnet para pesquisar na web), depois **mockups** das opções, o usuário escolhe, só então aplicar. Os mockups foram feitos como widgets visuais no chat (não estão neste repositório); a direção está descrita abaixo.
- **Aprovou** os itens 1–6 da lista de propostas (pílula/dock, rolagem, overview, tema por pintura, bloqueio/notificações, gesto de 3 dedos) e depois pediu os ajustes de comportamento do tema por pintura. Aprova rápido com "pode aplicar".
- **Regras globais dele** (CLAUDE.md): sem atribuição de IA em commits/PRs; perguntar antes de criar repositório, ramo, ou publicar algo grande; não mexer em `.env*`, `.github/`, Dockerfiles, lockfiles; escanear o diff por segredos antes de commitar; "pronto" só depois de rodar uma verificação de verdade. Este repositório é **público**.
- Reclamações que viraram requisitos: a troca não pode demorar; a imagem tem que **sempre** preencher a tela; durante o `SUPER+D` nada pode aparecer nem por milissegundos; o acervo é **só natureza**.

## Direção visual escolhida (dos mockups)

Estrutura do macOS (barra flutuante em pílula, dock centralizado, cantos de 12 px, vidro fosco discreto, launcher tipo Spotlight, painel de controle com tiles) com a paleta calma do NixOS (grafite com **um único acento azul-gelo**, ex.: `#8bc9eb` do tema `lumon`). Animações curtas com uma curva só. Com o tema por pintura, o acento passa a vir da pintura.

## Status das 6 propostas

| # | Proposta | Estado |
|---|---|---|
| 1 | Pílula flutuante + dock | **Parcial.** Barra movida para o topo (transparente, widgets em chips via `Pill.qml`). Não existe opção nativa de pílula flutuante com margem (só via QML próprio). Dock é o nativo do Omarchy (`dock.pinned`/`autohide`), sem mudanças. |
| 2 | Layout em rolagem | Feito |
| 3 | Overview de workspaces | **Rejeitado.** hyprexpo saiu do repositório oficial e não é mantido para o 0.56 |
| 4 | Wallpaper das pinturas + tema | Feito e ampliado (seção "Tema por pintura") |
| 5 | Bloqueio/notificações no mesmo visual | Vêm do `shell.toml` do tema; não conferido visualmente |
| 6 | Gesto de 3 dedos | Feito |

## Pergunta em aberto

O usuário pediu "coloca na tela de temas ctrl+shift+super+espaço". Esse atalho já abre o **seletor de temas** (carrossel de miniaturas), onde não dá para pôr controles. Interpretei como "o tema Pintura deve aparecer ali com miniatura" (gerado: `preview.png`). Se ele quis que o atalho abra o **menu da pintura**, basta `o.rebind("SUPER + SHIFT + CTRL + SPACE", "Pintura", { menu = "pintura" })` em `bindings.lua`. Perguntar.

## Backups feitos nesta sessão (para desfazer)

- `~/.config/hypr/looknfeel.lua.bak.1794448018` (antes das animações), `…bak2.1794537574` (antes da rolagem)
- `~/.config/hypr/input.lua.bak.1794537581` (antes dos gestos)
- `~/.config/omarchy/shell.json.bak.1794537011` (barra embaixo), `…bak2.1794537510` (antes do botão da pintura)
- `~/.bashrc.bak-fastfetch-art` e `~/.config/fastfetch/logo.original.png` (logo antigo do fastfetch)
- `~/.local/state/painting-theme/painting-theme.bak` … `.bak5` (versões anteriores do script)
- Voltar ao tema anterior: `omarchy theme set last-horizon` (o usuário também usou `lumon` e `matte-black`; troca de tema com frequência).

## Fora do repositório (mudanças locais)

- `~/.bashrc` linha 20: a função `fastfetch` chama `fastfetch-art --quiet` antes do `fastfetch-fit`:
  `fastfetch() { if [ $# -eq 0 ] && command -v fastfetch-fit >/dev/null; then command -v fastfetch-art >/dev/null && fastfetch-art --quiet; fastfetch-fit; else command fastfetch "$@"; fi; }`
- `~/.config/fastfetch/logo.png` é gerado por `fastfetch-art` (uma pintura de 800×800 a cada execução; sixel no foot). `~/.local/bin/fastfetch-fit` é do usuário (escolhe o tamanho da imagem e das seções); não foi alterado.
- `~/.config/omarchy/themes/pintura/` é gerado (colors.toml, backgrounds, preview.png). Não commitar.

## Fatos técnicos descobertos (para não redescobrir)

**Hyprland 0.56 em Lua**
- Gestos: `hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })`; `action = "scroll_move"` desliza a faixa do layout em rolagem.
- Layout em rolagem: `general.layout = "scrolling"` + bloco `scrolling` (`column_width`, `explicit_column_widths`, `focus_fit_method`, `follow_focus`…). Binds via `hl.dsp.layout("move +col")` etc.
- `hyprctl keyword` **não funciona** em config Lua; use `hyprctl eval 'hl.config({ ... })'`.
- O Hyprland **recarrega sozinho** quando um arquivo da config muda (incluindo o `hyprland.lua` do tema); `misc.disable_autoreload` evita isso. O `omarchy theme set` também chama `omarchy-restart-hyprctl`.
- `hl.plugin.load` existe, mas chamar no topo da config pode travar a inicialização; hyprpm exige cpio, cmake, git, meson, gcc.

**Omarchy 4.0**
- Tema de usuário: `~/.config/omarchy/themes/<nome>/` com `colors.toml` + `backgrounds/`. O resto (terminal, btop, bordas, chromium, etc.) é gerado dos templates em `/usr/share/omarchy/default/themed/*.tpl`. Chaves do `colors.toml`: `accent`, `background`, `dark_background`, `darker_background`, `lighter_background`, `selection`, `muted`, `foreground` (+ `dark_/light_/bright_foreground`), `red…magenta`, `bright_*`, `orange`, `brown`, `active_border_color`, `active_tab_background`.
- Reaplicar o **mesmo** tema avança para o próximo wallpaper da pasta; por isso cada troca usa um nome de arquivo novo e apaga os antigos.
- `omarchy theme set` volta em ~0,2 s e deixa o resto (GTK, **política de cor do navegador via sudo sem senha**, editores…) num lote desanexado, que escreve em `~/.local/state/omarchy/theme-set.log`.
- Módulos de barra em QML: `~/.config/omarchy/bar/modules/<id>.qml` + `{ "id": "<id>", "type": "qml" }` no `shell.json`; recebem `bar`, `moduleName`, `settings`; `bar.run()`, `bar.showTooltip()`. Módulo novo exige `omarchy restart shell`. O `shell.json` recarrega ao salvar.
- Menu extensível por `~/.config/omarchy/extensions/omarchy-menu.jsonc` (ids pontilhados, `action`, `checked`, `aliases`); `omarchy menu summon <rota>`, `omarchy menu images <pasta>` (seletor de imagens).
- O carrossel de temas (`omarchy menu summon theme`) usa o `preview.png` de cada tema.
- O `omarchy-peek-desktop` (SUPER+D) troca para o workspace vazio `1901…` e grava `$XDG_RUNTIME_DIR/omarchy-peek-desktop.json`; o do usuário está neste repositório.
- Bloqueio e notificações leem `[lock]` e `[notifications]` do `shell.toml` do tema. A barra aceita `background`: `opaque|glassy|none` (o usuário usa `transparent: true`).
- `autostart.lua` do usuário roda `omarchy-wallpaper-effect-watch` (vinheta no wallpaper, refeita a cada mudança de fundo): **a interação com os wallpapers das pinturas não foi verificada**.

**Ambiente**
- O app Claude roda com `no_new_privs`: nada de `sudo`/`pkexec` de dentro dele (veja "Armadilhas"). O `systemctl --user` e o `systemd-run --user` funcionam.
- Notebook com Intel Iris Xe (sem GPU dedicada): blur forte custa GPU; eDP-1 espelhado em HDMI-A-1; teclado/touchpad padrão.
- Terminal em uso: foot (sixel). Existe config do Ghostty, mas ele não está instalado.

## Como ampliar ou curar o acervo

- **API:** `https://commons.wikimedia.org/w/api.php` com `generator=categorymembers`, `gcmtype=file`, `gcmlimit=16`, `prop=imageinfo`, `iiprop=url|mime|extmetadata`, `iiextmetadatafilter=LicenseShortName`, `iiurlwidth=640`; filtrar `mime == image/jpeg` e licença `^(Public domain|PD|CC0)`. User-Agent próprio e **sem dados pessoais**. Espaçar ≥ 2,5 s (senão volta HTML).
- **Categorias que funcionaram:** Hudson River School, Bierstadt, Church, Cole, Cropsey, Gifford, Constable, Turner, Friedrich, Monet (várias), Sisley, Pissarro, Van Gogh, Cézanne (paisagens), Aivazovsky, Shishkin, Levitan, Hokusai, Boudin, Whistler, Hodler, Gallen-Kallela, Signac, Homer, Waugh, Kuhnert, Richards, Korovin, Emily Carr, Gauguin, Daubigny, Corot, Courbet, Ruisdael, Hobbema, Claude Lorrain, John Martin, Samuel Palmer, Calame, Halonen, Tom Thomson, Thomas Moran, "Paintings of sunrises/twilights/trees/rivers/outside flowers", "19th/18th/17th-century paintings of sunsets", "Autumn landscape paintings", "Winter landscape paintings", "Paintings of lakes".
- **Vieram vazias:** Hiroshige, Segantini, Dahl, Balke, Kuindzhi, Ryder, Fitz Henry Lane, Savrasov, Polenov, Millet, Danby, Munch, Böcklin, Corinth, Astrup, Maufra, Cross, "Thirty-six Views of Mount Fuji", "Starry Night", "Paintings of glaciers".
- **Bloqueados por anti-bot (não contornar):** Met Museum (API nova `v1.1/search` ainda responde, mas `objects/<id>` bloqueou após pedidos paralelos) e Art Institute of Chicago.
- **Curadoria:** categorias de artista misturam retratos, interiores, molduras, desenhos em P&B e fotos de museu. Revisar com miniaturas rotuladas: `magick montage -font /usr/share/fonts/liberation/LiberationSans-Regular.ttf -pointsize 13 -fill white -label '%t' <arquivos> -geometry 150x105+3+3 -tile 8x6 -background '#222' folha.png`, e anotar os rótulos ruins em `exclude.txt`. Depois `painting-theme meta` para os metadados de resolução (lotes de 40, 4 s entre lotes).
- **Números:** `index.jsonl` tem 660 linhas (algumas sem arquivo baixado), `exclude.txt` ~190, 181 elegíveis para wallpaper (largura ≥ 1500, proporção ≥ 1,25), ~500 de natureza no total para o fastfetch.
- **Licenças:** só artistas mortos há mais de 70 anos; nas obras de 12/11 em diante a licença do arquivo foi filtrada pela API; nas primeiras 367 não foi conferida arquivo a arquivo.

## Mapa de arquivos (repositório → `$HOME`)

`.local/bin/painting-theme` (núcleo), `painting-theme-fetch`, `fastfetch-art`; `.config/omarchy/bar/modules/painting.qml`; `.config/omarchy/extensions/omarchy-menu.jsonc`; `.config/systemd/user/painting-theme.service`; `.local/share/painting-theme/shim/omarchy-restart-hyprctl`; `.local/share/fastfetch-art/{index.jsonl,exclude.txt,meta.json}`; `.config/hypr/{looknfeel,input}.lua`; `.config/omarchy/shell.json`.

## Ao retomar

1. Ler este arquivo inteiro e `git log` do repositório.
2. Antes de mexer: `systemctl --user is-active painting-theme.service`, `painting-theme status`, `hyprctl configerrors`.
3. Testar trocas só com `systemd-run --user --collect -p KillMode=process painting-theme next`.
4. Para qualquer mudança visual nova: **mockup primeiro**, depois aplicar com backup, validar (`hyprctl reload` + `hyprctl configerrors`) e commitar em commits pequenos (sem atribuição de IA).

## Sessão de 13/11/2026: decisões e fatos novos

- Atalho `Ctrl+Shift+Super+Espaço`: decidido manter como carrossel de temas (o tema Pintura aparece nele).
- O Omarchy **não tem** central de controle; o painel é um plugin nosso (`Panel` + `KeyboardPanel` do kit `qs.Ui`).
- A dock nativa só aparece em workspaces flutuantes (`DockWindow.qml`, `shown`). Para alterar, **clonar** com `omarchy plugin clone omarchy.dock` (sobrevive às atualizações); não editar `/usr/share/omarchy/`. O clone reescreveu `shell.json`.
- `omarchy theme set` lê `icons.theme` do tema (nome de variante Yaru) e define o ícone do GNOME; o acento do GTK (`accent-color`) não é tocado pelo Omarchy, então o `painting-theme` o define.
- O `colors.toml` do tema **ativo** fica em `~/.local/state/omarchy/current/theme/`, não em `~/.config/omarchy/`.
- Plugins em `~/.config/omarchy/plugins/` recarregam ao salvar; `omarchy plugin enable <id> right` põe o widget na barra; `omarchy-shell <id> open|close` abre o painel por IPC.
- Screenshot para conferir visual: `grim -o eDP-1 arquivo.png`.
- Backups novos: `~/.config/omarchy/shell.json.bak3.*`, `~/.local/state/painting-theme/painting-theme.bak6` e `.bak7`, `~/.local/bin/fastfetch-fit.bak.*`.

## Verificado na tela em 13/11 (sessão de conferência)

- **Painel de controle:** abre ao lado do relógio (está na seção `centerEnd` do `shell.json`, não na direita), com tiles de Wi-Fi, Bluetooth, luz noturna e energia e sliders de volume e brilho, nas cores da pintura. Abrir por IPC (`omarchy-shell shell summon mancato.control-center`) funciona. Os cliques nos tiles e sliders **não** foram testados.
- **Dock:** aparece ao levar o ponteiro à borda inferior (auto-ocultar funciona), mostrando o botão de apps, o terminal e o Claude.
- **Menu "Pintura do tema":** os 7 itens abrem. Os nomes longos eram cortados e escondiam o ✓ do que está ligado; foram encurtados (Automático, Ao ligar o PC, Ao acordar, Por horário), e agora o ✓ aparece.
- **Modo por horário:** a lógica foi conferida offline para 5 horas do dia (noite 0,16–0,36, entardecer 0,36–0,46, tarde 0,46–0,52, manhã 0,52–0,78 de luminosidade; ~46 pinturas por faixa). Só a manhã tinha sido vista numa troca real.
- **Carrossel `Ctrl+Shift+Super+Espaço`:** o tema Pintura aparece em foco com a pintura atual como miniatura.

## Rodada de 4 sessões paralelas (13/11): o que entrou

| Frente | Resultado | Arquivos |
|---|---|---|
| Dock | Fundo arredondado nas cores do tema, ícone 40 px, ponto de app aberto, 8 apps fixados (foot, Nautilus, Chromium, VS Code, Obsidian, Claude, Spotify, Discord) | `.config/omarchy/plugins/mancato.dock/*`, `dock.pinned` no `shell.json` |
| Painel de controle | Tile "Não perturbar" (nativo: `omarchy-toggle-notification-silencing`, estado por `omarchy-shell notifications isDnd`), navegação por teclado, anel de foco no acento | `Panel.qml`, `.local/bin/control-center-state` |
| Menus e notificações | Override do template do shell: fundo elevado, bordas finas, espaçamento maior, fonte base 13 px. Vale para **todos** os temas | `.config/omarchy/themed/shell.toml.tpl` |
| GTK e Nautilus | `gtk.css` mínimo (acento e fundos da pintura) gerado a cada troca; Nautilus aberto repinta na hora | `write_gtk_css()` em `painting-theme` |

Fatos novos:
- **Plugin de terceiros não recebe `shellConfig` nem `appLibrary`.** Por isso `dock.pinned` nunca era lido e fixados não abriam. Solução: ler o `shell.json` com `FileView` no `Dock.qml` e declarar `"menu"` em `kinds` no manifest (libera o `appLibrary`).
- **Recarga automática não reaplica `Dock.qml`, `DockWindow.qml` nem um `Panel.qml` novo:** exige `omarchy restart shell` (pisca a barra por instantes).
- **O raio de canto dos popups e notificações não é chave do `shell.toml`:** o shell copia `decoration:rounding` do Hyprland (hoje 8, em `looknfeel.lua`). Cantos de 12–14 px só mudando esse arquivo; cuidado: mexer no `looknfeel.lua` dispara reload do Hyprland (veja o crash do layout em rolagem).
- `omarchy-theme-set-glass` também escreve em `~/.config/gtk-4.0/gtk.css` e pode conflitar com o symlink do hook `10-sync-gtk4-css`.
- `painting-theme` grava `~/.config/gtk-3.0/gtk.css` direto (único efeito fora do tema); apagar esse arquivo e `themes/pintura/gtk.css` desfaz.
- Backups: `~/.config/omarchy/plugin-backups/`, `~/.config/omarchy/shell.json.bak.dock.*`, `~/.local/state/cc-backups/`, `~/.local/bin/painting-theme.bak.1794572661`.

## Crash do Hyprland 0.56.2 (investigado em 13/11)

- **Evidência:** SIGSEGV às 08:38:58, na pilha `refreshProp → updateWorkspaceLayouts → ~CScrollingAlgorithm → ~CScrollingFullscreenHandler`: o próprio Hyprland derruba a sessão ao **desmontar** um layout em rolagem (ex.: tirar um workspace de rolagem para dwindle com `SUPER+L`). Sem quadros do plugin `hyprbars`. Sem relato igual no upstream; o 0.57.2 corrige outros crashes e um problema de tela cheia na rolagem, mas não confirmei este.
- **Estado:** o layout em rolagem continua como padrão; workspace 1 tem override para dwindle (arquivo em `~/.local/state/omarchy/workspace-layouts/`), workspaces 9 e `special:qconsole` estão em rolagem.
- **Contorno proposto e NÃO aplicado:** voltar `general.layout` para `dwindle` **sem recarregar** (desligar `misc.disable_autoreload` por `hyprctl eval`, editar `looknfeel.lua`, reiniciar a sessão), porque o reload desmontaria a rolagem dos workspaces 9 e `qconsole`. Alternativa: manter rolagem e evitar `SUPER+L`.

## Ainda não verificado (13/11)

- Cliques nos tiles e sliders do painel; arrastar apps na dock; pastas do Nautilus com a variante Yaru nova; troca real nas faixas tarde, entardecer e noite.
- Volume no painel em 0: é real (`wpctl` reporta 0,00), não um erro.
- **Possível crash do Hyprland 0.56.2 ao alternar o layout do workspace** (`SUPER+L`): o usuário trata disso em outra sessão (a atualização para o 0.57 ainda não chegou ao repositório do Arch). Como o layout em rolagem é o padrão, evitar `SUPER+L` até resolver. Não foi reproduzido por mim.
