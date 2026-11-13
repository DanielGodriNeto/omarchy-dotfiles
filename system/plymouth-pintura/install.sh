#!/bin/bash
# Instala o tema gerado por build.sh. Rode num terminal SEU (pede sudo):  bash install.sh
# Volta ao tema padrão com:  sudo plymouth-set-default-theme omarchy && sudo limine-mkinitcpio
set -euo pipefail
out=${XDG_CACHE_HOME:-$HOME/.cache}/plymouth-pintura
[[ -f $out/pintura.plymouth ]] || { echo "rode build.sh antes" >&2; exit 1; }
sudo install -d -m 755 /usr/share/plymouth/themes/pintura
sudo install -m 644 "$out"/* /usr/share/plymouth/themes/pintura/
sudo plymouth-set-default-theme pintura
if command -v limine-mkinitcpio >/dev/null; then sudo limine-mkinitcpio; else sudo mkinitcpio -P; fi
echo "Pronto. Reinicie para ver. Teste rápido sem reiniciar: sudo plymouthd --debug; sudo plymouth --show-splash"
