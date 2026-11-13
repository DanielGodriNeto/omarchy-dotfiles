#!/bin/bash
# Gera (como usuário, sem root) o tema Plymouth "pintura" em ~/.cache/plymouth-pintura:
# a pintura atual escurecida como fundo + logo e barra na cor de acento.
set -euo pipefail
src=/usr/share/plymouth/themes/omarchy
out=${XDG_CACHE_HOME:-$HOME/.cache}/plymouth-pintura
wall=$(readlink -f "$HOME/.local/state/omarchy/current/background" 2>/dev/null || true)
[[ -f $wall ]] || { echo "wallpaper atual não encontrado" >&2; exit 1; }
accent=$(sed -n 's/^accent *= *"\(#[0-9a-fA-F]\{6\}\)".*/\1/p' "$HOME/.config/omarchy/themes/pintura/colors.toml" | head -1)
bg=$(sed -n 's/^dark_background *= *"\(#[0-9a-fA-F]\{6\}\)".*/\1/p' "$HOME/.config/omarchy/themes/pintura/colors.toml" | head -1)
: "${accent:?}" "${bg:?}"

rm -rf "$out"; mkdir -p "$out"
cp "$src"/{bullet,entry,lock,progress_box}.png "$out"/
# fundo: pintura cobrindo 1920x1080, escurecida (35%) e levemente desfocada
magick "$wall" -resize 1920x1080^ -gravity center -extent 1920x1080 -blur 0x3 -fill "$bg" -colorize 65% "$out/bg.png"
# logo e barra na cor de acento (preserva o canal alfa)
magick "$src/logo.png" -fill "$accent" -colorize 100 -channel A -evaluate set 100% +channel "$src/logo.png" -compose CopyOpacity -composite "$out/logo.png"
magick "$src/progress_bar.png" -fill "$accent" -colorize 100 "$out/progress_bar.png"

# script: mesmo comportamento do tema omarchy + sprite de fundo
r=$(printf '%d' 0x${bg:1:2}); g=$(printf '%d' 0x${bg:3:2}); b=$(printf '%d' 0x${bg:5:2})
rf=$(awk "BEGIN{printf \"%.3f\",$r/255}"); gf=$(awk "BEGIN{printf \"%.3f\",$g/255}"); bf=$(awk "BEGIN{printf \"%.3f\",$b/255}")
sed -e "s/^Window.SetBackgroundTopColor.*/Window.SetBackgroundTopColor($rf, $gf, $bf);/" \
    -e "s/^Window.SetBackgroundBottomColor.*/Window.SetBackgroundBottomColor($rf, $gf, $bf);/" \
    -e 's#^layout();$#bg.image = Image("bg.png");\nbg.sprite = Sprite();\nbg.sprite.SetZ(-100);\nbg.sprite.SetImage(bg.image.Scale(Window.GetWidth(), Window.GetHeight()));\nlayout();#' \
    "$src/omarchy.script" > "$out/pintura.script"
sed -e 's/^Name=.*/Name=Pintura/' -e 's/^Description=.*/Description=Pintura atual escurecida./' \
    -e 's#themes/omarchy#themes/pintura#g' -e 's#omarchy.script#pintura.script#' "$src/omarchy.plymouth" > "$out/pintura.plymouth"
echo "Gerado em $out"
