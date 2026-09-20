-- Extra autostart processes.
-- o.launch_on_start("my-service")

-- Desktop widgets: btop + cliamp run persistently on workspace 9 (routed
-- there by the window rules in hyprland.lua) and are a keypress away with
-- Super+Shift+V.
-- cliamp launches via omarchy-widget-cliamp-launch, which reads
-- ~/.local/state/omarchy/cliamp-provider to start in Spotify mode (via its
-- bundled go-librespot integration; needs `cliamp setup` run once to link a
-- Spotify Premium account) or the local radio playlist. Switch between them
-- with Super+Shift+T (see hypr/bindings.lua).
o.launch_on_start("omarchy-launch-terminal --app-id=omarchy-widget-btop --title='Widgets: btop' -- btop")
o.launch_on_start("omarchy-launch-terminal --app-id=omarchy-widget-cliamp --title='Widgets: cliamp' -- omarchy-widget-cliamp-launch")

-- Wallpaper vignette effect: re-applies whenever the background/theme
-- changes. Toggle on/off with Super+Shift+Z (see hypr/bindings.lua).
o.launch_on_start("omarchy-wallpaper-effect-watch")
