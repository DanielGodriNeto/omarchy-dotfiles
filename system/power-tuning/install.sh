#!/bin/bash
# Installs the CPU power cap and battery charge limit (persist across boots). Own terminal, asks sudo:  bash install.sh
# Undo: sudo rm /etc/tmpfiles.d/{cpu-power-cap,battery-charge-limit}.conf and rewrite 50000000 / 55000000 / 100 to the sysfs files.
set -euo pipefail
here=$(cd "$(dirname "$0")" && pwd)
sudo install -m 644 "$here/cpu-power-cap.conf" "$here/battery-charge-limit.conf" /etc/tmpfiles.d/
sudo systemd-tmpfiles --create /etc/tmpfiles.d/cpu-power-cap.conf /etc/tmpfiles.d/battery-charge-limit.conf
echo "PL1=$(cat /sys/class/powercap/intel-rapl:0/constraint_0_power_limit_uw) PL2=$(cat /sys/class/powercap/intel-rapl:0/constraint_1_power_limit_uw) charge limit=$(cat /sys/class/power_supply/BAT0/charge_control_end_threshold)"
