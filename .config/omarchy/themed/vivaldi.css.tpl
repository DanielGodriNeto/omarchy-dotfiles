/* Vivaldi UI colors from the active Omarchy theme (CSS mod). Rendered on every theme
   change and copied to ~/.config/vivaldi-mods/omarchy.css by hooks/theme-set.d/35-sync-vivaldi-theme.
   One-time setup in Vivaldi: vivaldi://flags -> "Allow for using CSS modifications" on, then
   Settings > Appearance > Custom UI Modifications -> choose ~/.config/vivaldi-mods and restart. */
:root {
  --colorBg: {{ background }} !important;
  --colorWindowBg: {{ mix background foreground 4% }} !important;
  --colorFg: {{ foreground }} !important;
  --colorHighlightBg: {{ accent }} !important;
  --colorAccentBg: {{ mix background foreground 14% }} !important;
}
