# Power tuning (ASUS laptop, i3-1315U)

Why: the laptop turned itself off while gaming (Roblox via Sober). Cause: 50/55 W CPU limits on a 15 W chip, plus the profile being forced to `performance`.

1. `cpu-power-cap.conf`: PL1 25 W / PL2 28 W. Result in a 20 min game: 73 C average, no throttling (was 80-92 C).
2. `battery-charge-limit.conf`: charge to 80% only. The one-tap exception is `../battery-full-charge/`.
3. Not in the repo (per-machine state): `omarchy-powerprofiles-set ac balanced` (otherwise `omarchy-powerprofiles-watcher` resets AC to `performance`), and Sober `enable_gamemode: false` in `~/.var/app/org.vinegarhq.Sober/config/sober/config.json` (gamemode forces performance).
4. `.local/bin/game-mode on [power-saver|balanced] | off | status`: stops voxtype and cava and sets a cooler profile.

Install: `bash system/power-tuning/install.sh` (sudo, own terminal). Tune: edit the numbers (microwatts) and rerun.
