-- Change the default Omarchy look'n'feel.

-- https://wiki.hypr.land/Configuring/Basics/Variables/#general
hl.config({
  general = {
    -- Smaller gaps between windows and screen edges.
    gaps_in = 2,
    gaps_out = 4,
  },
})

-- hl.config({
--   general = {
--     -- No gaps between windows or borders.
--     gaps_in = 0,
--     gaps_out = 0,
--     border_size = 0,
--
--     -- Change to niri-like side-scrolling layout.
--     layout = "scrolling",
--   },
-- })

-- https://wiki.hypr.land/Configuring/Basics/Variables/#decoration
hl.config({
  decoration = {
    rounding = 12,

    -- Dim unfocused windows (0.0 = no dim, 1.0 = fully dimmed).
    dim_inactive = true,
    dim_strength = 0.15,

    shadow = {
      enabled = true,
      range = 12,
      render_power = 3,
    },
  },
})

-- Blur is the priciest of these on the Iris Xe iGPU (no dGPU on this
-- machine). Bumped stronger than Hyprland's defaults; watch for GPU load
-- if this drags on this hardware. Noise stays up from the 0.0117 default
-- so the little bit of desktop that bleeds through window transparency
-- reads as grain/color, not detail.
hl.config({
  decoration = {
    blur = {
      enabled = true,
      size = 8,
      passes = 3,
      noise = 0.08,
      new_optimizations = true,
    },
  },
})

-- https://wiki.hypr.land/Configuring/Basics/Variables/#animations
-- Fluid, macOS-like motion: one soft ease-out curve, ~200-300ms, workspace slide.
hl.config({
  animations = {
    enabled = true,
  },
})

hl.curve("fluid", { type = "bezier", points = { { 0.22, 1 }, { 0.36, 1 } } })
hl.curve("fluidOut", { type = "bezier", points = { { 0.4, 0 }, { 0.6, 1 } } })

hl.animation({ leaf = "global", enabled = true, speed = 3, bezier = "fluid" })
hl.animation({ leaf = "windows", enabled = true, speed = 3, bezier = "fluid" })
hl.animation({ leaf = "windowsIn", enabled = true, speed = 2.6, bezier = "fluid", style = "popin 94%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 1.8, bezier = "fluidOut", style = "popin 94%" })
hl.animation({ leaf = "windowsMove", enabled = true, speed = 3, bezier = "fluid" })
hl.animation({ leaf = "border", enabled = true, speed = 3, bezier = "fluid" })
hl.animation({ leaf = "fade", enabled = true, speed = 2.4, bezier = "fluid" })
hl.animation({ leaf = "fadeSwitch", enabled = false })
hl.animation({ leaf = "layers", enabled = true, speed = 2.6, bezier = "fluid" })
hl.animation({ leaf = "layersIn", enabled = true, speed = 2.6, bezier = "fluid", style = "fade" })
hl.animation({ leaf = "layersOut", enabled = true, speed = 1.8, bezier = "fluidOut", style = "fade" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 3.2, bezier = "fluid", style = "slide" })

-- Layout padrao: dwindle. O layout em rolagem (colunas como no Niri) derruba o Hyprland 0.56.2 quando um
-- workspace sai dele (SIGSEGV em ~CScrollingFullscreenHandler, 13/11/2026). Para testar a rolagem,
-- troque para "scrolling" aqui, mas so depois de atualizar o Hyprland (0.57+).
hl.config({
  general = { layout = "dwindle" },
  scrolling = {
    column_width = 0.5,
    explicit_column_widths = "0.333, 0.5, 0.667, 1.0",
    focus_fit_method = 0,
  },
})

-- https://wiki.hypr.land/Configuring/Basics/Variables/#layout
-- hl.config({
--   layout = {
--     -- Avoid overly wide single-window layouts on wide screens.
--     single_window_aspect_ratio = { 1, 1 },
--   },
-- })

-- https://wiki.hypr.land/Configuring/Layouts/Scrolling-Layout/
-- hl.config({
--   scrolling = {
--     -- See only one column per screen instead of two.
--     column_width = 0.97,
--   },
-- })

-- Opt another application in to Omarchy's standard transparency.
-- Find its class with: hyprctl clients
-- o.transparent_window("my-app")
-- o.transparent_window("my-app", "0.9 0.85") -- Custom active/inactive opacity.
