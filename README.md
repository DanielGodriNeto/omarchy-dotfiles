# Omarchy Dotfiles

Personal [Omarchy](https://omarchy.org) desktop customizations on top of the stock config: a persistent btop + cliamp widget setup, top bar rework, Spotify/radio source switching, a wallpaper vignette effect, Spicetify theming, and a few Hyprland tweaks.

Paths mirror `$HOME` — copy the relevant files into place, or symlink them in.

## What's here

- **`.config/hypr/bindings.lua`** — personal keybind overrides: widget toggle (`Super+Shift+V`), music source toggle (`Super+Shift+T`), wallpaper effect toggle (`Super+Shift+Z`), desktop peek (`Super+D`).
- **`.config/hypr/autostart.lua`** — launches the btop/cliamp widgets and the wallpaper-effect watcher on start.
- **`.config/hypr/looknfeel.lua`** — smaller gaps, window rounding, dim-inactive, blur, fluid animations and the scrolling layout.
- **`.config/omarchy/bar/modules/`** — custom top bar QML modules: `apps-pill.qml`, `Pill.qml`, `system-pill.qml` (combined CPU/temp/RAM), `workspace-windows.qml` (per-window tick marks), `media-spectrum.qml` (live audio spectrum via `cava`).
- **`.config/omarchy/shell.json`** — bar layout wiring the modules above into the Quickshell bar.
- **`.local/bin/painting-theme`**, **`painting-theme-fetch`**, **`fastfetch-art`** + `.config/omarchy/bar/modules/painting.qml`, `.config/omarchy/extensions/omarchy-menu.jsonc`, `.config/systemd/user/painting-theme.service`, `.local/share/painting-theme/shim/` — tema por pintura: wallpaper e cores do sistema a partir de uma pintura de natureza (domínio público), botão e menu na barra, troca ao ligar, ao acordar e por tempo, e o fastfetch com a pintura. O acervo de imagens não está no git, só a lista em `.local/share/fastfetch-art/`.
- **`.config/hypr/input.lua`** — gestos do touchpad (3 dedos: workspace; 4 dedos: layout em rolagem).
- **`.config/omarchy/plugins/mancato.dock/`** — clone do plugin `omarchy.dock` do Omarchy que mostra a dock em qualquer layout (não só em workspaces flutuantes), com auto-ocultar. Código derivado do Omarchy (MIT, © David Heinemeier Hansson); o clone não recebe as atualizações do original.
- **`.config/omarchy/plugins/mancato.control-center/`** + **`.local/bin/control-center-state`** — painel de controle na barra (Wi-Fi, Bluetooth, luz noturna, energia, volume, brilho), feito com o kit `qs.Ui` do shell.
- **`.local/bin/fastfetch-fit`** — fastfetch adaptativo ao tamanho do terminal; as cores seguem o acento do tema ativo.
- **`.config/omarchy/themed/shell.toml.tpl`** — override do template de estilo do shell (menus, popups, notificações), derivado do template do Omarchy (MIT); segue as cores do tema ativo.
- **`.config/omarchy/plugins/mancato.bar/`** — clone do plugin `omarchy.bar` do Omarchy com a barra em "ilhas" (fundo transparente, cada grupo de widgets numa ilha com margem). Código derivado do Omarchy (MIT, © David Heinemeier Hansson); o clone não recebe as atualizações da barra original. Para voltar ao padrão, remova `"id"` de `bar` no `shell.json` e rode `omarchy restart shell`.
- **`system/plymouth-pintura/`** — tema de boot (Plymouth) com a pintura atual escurecida e o acento do tema. `build.sh` gera em `~/.cache` sem root; `install.sh` precisa de `sudo` e deve ser rodado num terminal próprio. É uma foto da pintura do momento do `build.sh`, não troca sozinho.
- **`.config/starship.toml`** — prompt re-themed to match the active palette.
- **`.local/bin/omarchy-toggle-widgets`** — focuses/unfocuses the dedicated widget workspace.
- **`.local/bin/omarchy-cliamp-toggle-provider`** / **`omarchy-widget-cliamp-launch`** — switch the cliamp desktop widget between Spotify and a local radio playlist.
- **`.local/bin/omarchy-wallpaper-effect`**, **`-toggle`**, **`-watch`** — applies/reapplies a vignette effect on the current wallpaper, watching for theme/wallpaper changes.
- **`.local/bin/omarchy-peek-desktop`** — parks open windows in a hidden workspace to peek at the desktop, then restores them.
- **`.local/bin/omarchy-ac-idle-watcher`** — suppresses idle-lock while on AC power, restores it on battery.
- **`.local/bin/omarchy-spicetify-sync`** — generates a Spicetify color theme from the active Omarchy `colors.toml`.

## Notes

- The widget/bar layout was originally built to match the preview of the `cyberpunk-edgerunners` community theme (credit: [`Johnyyd/omarchy-cyberpunk-edgerunners-theme`](https://github.com/Johnyyd/omarchy-cyberpunk-edgerunners-theme)) — that theme itself isn't included here since it's a separate, separately-licensed project.
- These are the personal-override files only, not a full Omarchy config — Omarchy's own defaults (loaded via `hyprland.lua`) aren't duplicated here.

Para continuar a personalização em outra sessão, leia [HANDOFF.md](HANDOFF.md).
