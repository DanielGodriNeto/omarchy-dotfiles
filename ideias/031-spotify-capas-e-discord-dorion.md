# Spotify com capas e Discord leve (Dorion)

- **Estado:** Feito (Spotify precisa de reinício do app; tema do Dorion depende de escolha única na interface)
- **Origem:** pedido do usuário (13/11/2026)

## Spotify
- O tema "Text" do spicetify esconde imagens por variáveis em `~/.config/spicetify/Themes/text/user.css`. Mudei para `block`: `--display-coverart-image`, `--display-tracklist-image` e `--display-header-image` (as de cartão e barra lateral já eram `block`). Backup `user.css.bak.*` ao lado. Aplicado com `spicetify apply`; o app aberto só mostra depois de fechar e abrir.
- Este arquivo não é versionado (fica em `~/.config/spicetify`): se o tema for reinstalado, repetir a troca.

## Claude Desktop
- Mantido o app oficial. Já roda **nativo no Wayland** (`hyprctl clients`: `xwayland = false`).

## Discord: Dorion
- Cliente em Rust/Tauri com o Chromium do sistema (`cef`, 364 MB). Instalado de `dorion-bin` 7.0.1 (AUR; RPM oficial do GitHub com sha256 conferido, sem scripts de instalação). Comando: `Dorion`; config em `~/.config/dorion`.
- **Roda via XWayland** (`xwayland = true`): o Dorion rejeita `--ozone-platform` e `GDK_BACKEND=wayland` não muda o CEF. Com escala 1 não faz diferença visível. Se o nativo importar, o caminho é Vesktop ou o Discord oficial com flags de Ozone (ambos Electron, mais pesados).
- Compartilhar tela no Wayland não confirmado. Voz marcada como suportada pelo projeto. Imagens externas e fontes de temas não carregam fora do Windows.
- Dock: o pino `Discord` (webapp no Brave) foi trocado por `Dorion` em `dock.pinned`. O `.desktop` do webapp continua em `~/.local/share/applications/Discord.desktop` (pode ser apagado).
- Tema de cores: `themed/dorion.theme.css.tpl` + hook `40-sync-dorion-theme` copiam `omarchy.theme.css` para `~/.config/dorion/themes/`. **Escolher "Omarchy" uma vez** em Dorion → Configurações → Temas. Nomes de variáveis do Discord (antigos e novos) cobertos; o resultado visual **não foi visto** (precisa de login).
