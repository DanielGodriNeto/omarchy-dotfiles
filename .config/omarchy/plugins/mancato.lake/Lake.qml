import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Services.UPower
import QtQuick
import qs.Commons as Commons
import "Lake.js" as Sim

// One koi lake for the whole screen, drawn on the Bottom layer. Only the rectangles of foot windows
// are painted, so every terminal is a window into the same water. Performance power profile: every
// terminal shows it; otherwise only terminals sitting at an idle prompt do.
// The koi are rasterised into a small data image on the CPU; a fragment shader (lake.frag) turns it
// into ASCII on the GPU, along with the water net and the ripples.
Scope {
  id: root

  property var shell: null
  property var manifest: null

  readonly property bool perf: PowerProfiles.profile === PowerProfile.Performance
  // pid -> true when that terminal's shell is at the prompt (nothing running in front)
  property var idle: ({})
  property var wins: []
  property real simT: 0
  property vector4d rip0: Qt.vector4d(0, 0, 0, 0)
  property vector4d rip1: Qt.vector4d(0, 0, 0, 0)
  property vector4d rip2: Qt.vector4d(0, 0, 0, 0)
  property vector4d rip3: Qt.vector4d(0, 0, 0, 0)
  property int tick: 0
  property int fishCount: 0
  // lake-config: switch, mode (auto | idle | always), shoal, ripples
  property bool enabled: true
  property string mode: "auto"
  property bool ripplesOn: true
  readonly property string configPath: Quickshell.env("HOME") + "/.config/omarchy/lake.json"
  // Whether the lake shows in the terminal with this pid: always in "always", every terminal in
  // "auto" while on the Performance profile, otherwise only terminals sitting at the prompt.
  function wants(pid) {
    if (!enabled) return false
    if (mode === "always" || (mode === "auto" && perf)) return true
    return idle[String(pid)] !== false
  }
  readonly property bool needsIdleState: enabled && !(mode === "always" || (mode === "auto" && perf))

  function applyConfig(txt) {
    var c = {}
    try { c = JSON.parse(txt) } catch (e) {}
    enabled = c.enabled !== false
    mode = c.mode || "auto"
    ripplesOn = c.ripples !== false
    Sim.configure({ count: c.count || 16, speed: c.speed || 1, palette: c.palette || "mix" })
    fishCount = Sim.count()
  }

  FileView {
    path: root.configPath
    watchChanges: true
    printErrors: false
    onFileChanged: reload()
    onLoaded: root.applyConfig(text())
    onLoadFailed: root.applyConfig("{}")
  }

  function isTerm(cls) { return /(^|[.-])foot($|[.-])|terminal/i.test(cls || "") }

  function collect() {
    var out = [], tops = Hyprland.toplevels.values
    for (var i = 0; i < tops.length; i++) {
      var o = tops[i].lastIpcObject
      if (!o || !o.at || !o.size || o.hidden || o.mapped === false || !isTerm(o["class"])) continue
      out.push({ addr: o.address, pid: o.pid, ws: o.workspace ? o.workspace.id : -1, mon: o.monitor, x: o.at[0], y: o.at[1], w: o.size[0], h: o.size[1] })
    }
    wins = out
  }

  function pushRipples() {
    var r = Sim.ripples(), v = []
    for (var i = 0; i < 4; i++) v.push(i < r.length ? Qt.vector4d(r[i][0], r[i][1], r[i][2], 1) : Qt.vector4d(0, 0, 0, 0))
    rip0 = v[0]; rip1 = v[1]; rip2 = v[2]; rip3 = v[3]
  }

  Timer {
    interval: 300
    running: true
    repeat: true
    onTriggered: { Hyprland.refreshToplevels(); root.collect() }
  }

  // A click anywhere sends "mancato.lake click" (a non-consuming mouse bind in bindings.lua); if the
  // pointer is over a terminal that is showing the lake, that spot ripples and the koi scatter.
  function clickAt(x, y) {
    if (!ripplesOn) return
    var mons = Hyprland.monitors.values
    for (var i = 0; i < wins.length; i++) {
      var w = wins[i], active = -1, mx = 0, my = 0
      for (var m = 0; m < mons.length; m++) if (mons[m].id === w.mon) { active = mons[m].activeWorkspace ? mons[m].activeWorkspace.id : -1; mx = mons[m].x; my = mons[m].y }
      if (w.ws !== active || !wants(w.pid)) continue
      if (x >= w.x && x < w.x + w.w && y >= w.y && y < w.y + w.h) { Sim.addRipple(x - mx, y - my); pushRipples(); return }
    }
  }

  IpcHandler {
    target: "mancato.lake"
    function click(): void { if (!cursorProc.running) cursorProc.running = true }
  }

  Process {
    id: cursorProc
    command: ["hyprctl", "cursorpos", "-j"]
    stdout: StdioCollector {
      onStreamFinished: { try { var p = JSON.parse(text); root.clickAt(p.x, p.y) } catch (e) {} }
    }
  }

  Process {
    id: stateProc
    stdout: StdioCollector {
      onStreamFinished: { try { root.idle = JSON.parse(text) } catch (e) {} }
    }
  }

  Timer {
    interval: 1500
    running: root.wins.length > 0 && root.needsIdleState
    repeat: true
    onTriggered: {
      if (stateProc.running) return
      stateProc.command = ["lake-term-state"].concat(root.wins.map(function (w) { return String(w.pid) }))
      stateProc.running = true
    }
  }

  Component.onCompleted: {
    var s = Quickshell.screens[0]
    Sim.init(s ? s.width : 1920, s ? s.height : 1080, 16)
    fishCount = Sim.count()
  }

  Timer {
    interval: root.perf ? 70 : 100
    running: root.wins.length > 0 && root.enabled
    repeat: true
    onTriggered: { Sim.step(); root.simT = Sim.time(); root.pushRipples(); root.tick++ }
  }

  Variants {
    model: Quickshell.screens
    delegate: PanelWindow {
      id: win
      required property var modelData
      screen: modelData
      color: "transparent"
      exclusionMode: ExclusionMode.Ignore
      WlrLayershell.layer: WlrLayer.Bottom
      WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
      WlrLayershell.namespace: "mancato-lake"
      anchors { top: true; bottom: true; left: true; right: true }
      mask: Region {}

      readonly property var monitor: Hyprland.monitorFor(screen)
      readonly property int wsId: monitor && monitor.activeWorkspace ? monitor.activeWorkspace.id : -1
      readonly property real monX: monitor ? monitor.x : 0
      readonly property real monY: monitor ? monitor.y : 0
      readonly property var dim: Sim.size()
      readonly property string glyphs: " .:-=+*#%@oO0()/\\|~,'"

      // Koi spines, one row per fish, written on the CPU each tick.
      Canvas {
        id: fishCv
        width: 40
        height: 32
        renderTarget: Canvas.Image
        Connections { target: root; function onTickChanged() { fishCv.requestPaint() } }
        onPaint: {
          var ctx = getContext("2d"), t = Sim.fishTexels()
          ctx.clearRect(0, 0, width, height)
          for (var i = 0; i < t.length; i += 4) {
            ctx.fillStyle = "rgb(" + t[i + 2] + "," + t[i + 3] + ",0)"
            ctx.fillRect(t[i], t[i + 1], 1, 1)
          }
        }
      }
      ShaderEffectSource {
        id: fishSrc
        sourceItem: fishCv
        hideSource: true
        smooth: false
        live: true
        textureSize: Qt.size(40, 32)
      }
      // The GPU rasterises the koi into one pixel per character cell (three bands stacked).
      ShaderEffect {
        id: cellsFx
        width: win.dim.cols
        height: win.dim.rows * 3
        property variant fishTex: fishSrc
        property vector2d cellPx: Qt.vector2d(win.dim.cw, win.dim.ch)
        property vector2d grid: Qt.vector2d(win.dim.cols, win.dim.rows)
        property real time: root.simT
        property real nFish: root.fishCount
        property vector4d accent: Qt.vector4d(Commons.Color.accent.r, Commons.Color.accent.g, Commons.Color.accent.b, 1)
        fragmentShader: Qt.resolvedUrl("cells.frag.qsb")
      }
      ShaderEffectSource {
        id: dataSrc
        sourceItem: cellsFx
        hideSource: true
        smooth: false
        live: true
        textureSize: Qt.size(cellsFx.width, cellsFx.height)
      }

      // Glyph atlas: one cell per character, white on transparent, drawn once.
      Item {
        id: atlas
        width: win.glyphs.length * win.dim.cw
        height: win.dim.ch
        Repeater {
          model: win.glyphs.length
          delegate: Text {
            required property int index
            x: index * win.dim.cw
            width: win.dim.cw
            height: win.dim.ch
            text: win.glyphs.charAt(index)
            color: "white"
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 8
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
          }
        }
      }
      ShaderEffectSource {
        id: atlasSrc
        sourceItem: atlas
        hideSource: true
        smooth: false
        live: false
        textureSize: Qt.size(atlas.width, atlas.height)
        Component.onCompleted: scheduleUpdate()
        Timer { interval: 800; running: true; onTriggered: atlasSrc.scheduleUpdate() }
      }

      Repeater {
        model: root.wins
        delegate: ShaderEffect {
          id: fx
          required property var modelData
          readonly property bool onThis: modelData.ws === win.wsId && win.monitor && modelData.mon === win.monitor.id
          readonly property bool show: onThis && root.wants(modelData.pid)
          x: modelData.x - win.monX
          y: modelData.y - win.monY
          width: modelData.w
          height: modelData.h
          visible: show
          property variant dataTex: dataSrc
          property variant atlasTex: atlasSrc
          property vector2d origin: Qt.vector2d(x, y)
          property vector2d winSize: Qt.vector2d(width, height)
          property vector2d cellPx: Qt.vector2d(win.dim.cw, win.dim.ch)
          property vector2d grid: Qt.vector2d(win.dim.cols, win.dim.rows)
          property real time: root.simT
          property real alpha: 1
          property vector4d tint: Qt.vector4d(0.42, 0.68, 0.72, 1)
          property vector4d rip0: root.rip0
          property vector4d rip1: root.rip1
          property vector4d rip2: root.rip2
          property vector4d rip3: root.rip3
          fragmentShader: Qt.resolvedUrl("lake.frag.qsb")
        }
      }
    }
  }
}
