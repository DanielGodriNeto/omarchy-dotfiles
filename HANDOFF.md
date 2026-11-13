# Handoff: personalização do Hyprland/Omarchy

Ponto de partida para continuar a personalização em outra sessão. Escrito em 12/11/2026.
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

## Não verificado

- Clique no botão, menu da barra e a galeria `choose` não foram vistos funcionando na tela (só os comandos).
- Troca ao **acordar da suspensão** nunca foi testada com uma suspensão real.
- Tela de bloqueio e notificações seguem o tema por contrato (`shell.toml`), mas não foram conferidas visualmente.
- A miniatura do tema "Pintura" no carrossel `CTRL+SHIFT+SUPER+ESPAÇO` foi gerada, mas não a vi no carrossel.

## Ideias para continuar (por prioridade)

1. Conferir os "não verificados" acima, principalmente suspensão e a miniatura no carrossel.
2. Cores do texto do fastfetch seguirem o acento da pintura (hoje o `fastfetch-fit` usa cores fixas pêssego/azul).
3. Modo por horário do dia (pinturas claras de manhã, noturnas à noite) como opção do menu.
4. Pílula flutuante de verdade para a barra: não há opção nativa; só via QML próprio (`Pill.qml` já dá o formato por widget).
5. Estilo do dock (`dock.pinned`, `autohide` em `shell.json`) e visual da central de controle/launcher.
6. Cor de pastas do Nautilus e ícones (Yaru-*) acompanhando o acento da pintura.
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
