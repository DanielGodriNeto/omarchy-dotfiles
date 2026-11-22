# Full charge button (battery popup)

A button in the battery popup that charges to 100% once and then goes back to the normal charge limit (80%) by itself.

## Parts
| Part | Where | What it does |
|---|---|---|
| Button | `.config/omarchy/plugins/mancato.power/Panel.qml` (marked "Full charge" and `fullChargeProc`) | Clone of `omarchy.power` with the button. Calls `systemctl start/stop --no-block battery-full-charge.service`. Hidden when the service is not installed or on battery. |
| Service | `battery-full-charge.service` -> `/etc/systemd/system/` | Runs the script; `ExecStopPost` always writes the normal limit (80) back. |
| Script | `battery-full-charge` -> `/usr/local/bin/` | Writes 100 to `/sys/class/power_supply/BAT0/charge_control_end_threshold`, waits until status is Full, capacity is 100, AC is unplugged, or 8 h pass, then exits. |
| Polkit rule | `50-battery-full-charge.rules.tpl` -> `/etc/polkit-1/rules.d/` | Lets your user start/stop only that one unit with no password. Nothing else gets permission. |
| Bar wiring | `shell.json` uses `"id": "mancato.power"` instead of `omarchy.power`; `mancato.menu/MenuModel.js` reads `mancato.power`; tooltip in `mancato.bar/BarTooltips.js` | Makes the clone replace the stock widget. |

## Install (own terminal, asks sudo)
`bash system/battery-full-charge/install.sh`, then `omarchy restart shell`.
The 80% limit itself is set by `/etc/tmpfiles.d/battery-charge-limit.conf` (`w /sys/class/power_supply/BAT0/charge_control_end_threshold - - - - 80`).

## How it behaves
1. Press the button (shown only on AC): limit goes to 100, button turns active ("Charging to 100% - tap to cancel").
2. Reverts to 80 when the battery is full, when the charger is unplugged, after 8 h, if you press the button again, or if the service stops for any reason (`ExecStopPost`).
3. A reboot also resets to 80 (tmpfiles).

## Porting to a new Omarchy version
The clone does not receive upstream updates. To port:
1. Copy the new `/usr/share/omarchy/shell/plugins/panels/power/{Panel.qml,Model.js}` over the clone.
2. Re-apply the changes listed in `Panel.qml` of the old clone (search "fullCharge" and `mancato.power`): rename `moduleName`, `ipcTarget`, the `ShellIpc target`; add the 3 properties, the `fullChargeProc` / `fullChargeActionProc` Processes, `toggleFullCharge()`, the `refresh()` line, and the "Full charge" Column after the profile picker.
3. Keep `omarchy.clonedFrom: "omarchy.power"` in `manifest.json`; run `omarchy restart shell`.
4. Check the Button component props still exist (`iconText`, `text`, `active`, `bordered`) in `/usr/share/omarchy/shell/Ui/`.
Other laptops: the sysfs path (`BAT0`, `AC0`) and the threshold file must exist; `install.sh` refuses if the threshold file is missing.

## Remove
`sudo rm /usr/local/bin/battery-full-charge /etc/systemd/system/battery-full-charge.service /etc/polkit-1/rules.d/50-battery-full-charge.rules && sudo systemctl daemon-reload`, set `"id": "omarchy.power"` back in `shell.json`.
