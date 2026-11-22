#!/bin/bash
# Installs the full-charge service + polkit rule. Run in your own terminal (asks sudo):  bash install.sh
# Remove with:  sudo rm /usr/local/bin/battery-full-charge /etc/systemd/system/battery-full-charge.service /etc/polkit-1/rules.d/50-battery-full-charge.rules && sudo systemctl daemon-reload
set -euo pipefail
here=$(cd "$(dirname "$0")" && pwd)
[[ -e /sys/class/power_supply/BAT0/charge_control_end_threshold ]] || { echo "this laptop has no charge limit control" >&2; exit 1; }
sudo install -m 755 "$here/battery-full-charge" /usr/local/bin/battery-full-charge
sudo install -m 644 "$here/battery-full-charge.service" /etc/systemd/system/battery-full-charge.service
sed "s/@USER@/$USER/" "$here/50-battery-full-charge.rules.tpl" | sudo tee /etc/polkit-1/rules.d/50-battery-full-charge.rules >/dev/null
sudo chmod 644 /etc/polkit-1/rules.d/50-battery-full-charge.rules
sudo systemctl daemon-reload
echo "Installed. Test: systemctl start battery-full-charge.service (no password), then systemctl stop battery-full-charge.service"
