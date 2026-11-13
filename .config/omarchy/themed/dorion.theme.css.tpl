/**
 * @name Omarchy
 * @description Follows the active Omarchy theme (generated on every theme change)
 * @version 1.0.0
 * @author mancato
 */
:root,
.theme-dark,
.theme-light {
  /* Older variable names */
  --background-primary: {{ background }};
  --background-secondary: {{ mix background foreground 4% }};
  --background-secondary-alt: {{ mix background foreground 6% }};
  --background-tertiary: {{ mix background foreground 2% }};
  --background-floating: {{ mix background foreground 6% }};
  --background-modifier-hover: {{ mix background foreground 8% }};
  --background-modifier-selected: {{ mix background foreground 14% }};
  --text-normal: {{ foreground }};
  --text-muted: {{ mix background foreground 62% }};
  --header-primary: {{ foreground }};
  --header-secondary: {{ mix background foreground 70% }};
  --interactive-normal: {{ mix background foreground 75% }};
  --interactive-hover: {{ foreground }};
  --interactive-active: {{ foreground }};
  --channels-default: {{ mix background foreground 62% }};
  /* Newer variable names */
  --background-base-low: {{ mix background foreground 4% }};
  --background-base-lower: {{ background }};
  --background-base-lowest: {{ mix background foreground 2% }};
  --background-surface-high: {{ mix background foreground 8% }};
  --text-default: {{ foreground }};
  --text-strong: {{ bright_foreground }};
  --chat-background-default: {{ background }};
  /* Accent */
  --brand-experiment: {{ accent }};
  --brand-experiment-560: {{ accent }};
  --brand-500: {{ accent }};
  --text-link: {{ accent }};
}
