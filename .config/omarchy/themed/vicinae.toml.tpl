# Vicinae launcher theme. Rendered by omarchy-theme-set-templates on every theme
# change (so it follows the painting) and applied by hooks/theme-set.d/30-sync-vicinae-theme.
# Only the core colors are set; Vicinae derives the rest from them.

[meta]
name = "Omarchy"
description = "Follows the active Omarchy theme"
variant = "{{ mode }}"
inherits = "vicinae-{{ mode }}"

[colors.core]
accent = "{{ accent }}"
accent_foreground = "{{ background }}"
background = "{{ background }}"
foreground = "{{ foreground }}"
secondary_background = "{{ mix background foreground 7% }}"
border = "{{ mix background foreground 16% }}"

[colors.text]
muted = "{{ mix background foreground 60% }}"
placeholder = "{{ mix background foreground 40% }}"
selection = { background = "{{ selection }}", foreground = "{{ bright_foreground }}" }

[colors.accents]
blue = "{{ blue }}"
green = "{{ green }}"
magenta = "{{ magenta }}"
orange = "{{ orange }}"
red = "{{ red }}"
yellow = "{{ yellow }}"
cyan = "{{ cyan }}"
purple = "{{ magenta }}"
