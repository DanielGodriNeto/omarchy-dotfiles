import QtQuick
import Quickshell.Io
import Quickshell

// Custom bar module (bar.layout entry: { "id": "media-spectrum", "type": "qml" }).
// Live audio-spectrum bars next to the now-playing widget, driven by a
// system-wide `cava` instance (reads the default PipeWire sink's monitor,
// so it reacts to whatever is actually making sound - cliamp, a browser
// tab, anything - not just one specific app's MPRIS session). Config at
// ~/.config/cava/bar.conf outputs raw ASCII bar levels (0-100) on stdout.
Item {
  id: root

  property var bar
  property string moduleName
  property var settings

  property var bands: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
  readonly property real barMax: 100
  readonly property real barGap: 2
  readonly property real barWidth: 3
  readonly property real silenceThreshold: 3

  readonly property bool active: bands.some(function (v) { return v > root.silenceThreshold })

  function level(v) {
    // Square-root curve so quiet bands stay visible instead of flatlining.
    return Math.max(0, Math.min(1, Math.sqrt(Math.max(0, v) / barMax)))
  }

  visible: active
  implicitWidth: active ? (row.implicitWidth + 12) : 0
  implicitHeight: bar ? bar.barSize : 26

  Row {
    id: row
    anchors.centerIn: parent
    spacing: root.barGap

    Repeater {
      model: root.bands

      Rectangle {
        width: root.barWidth
        radius: root.barWidth / 2
        anchors.bottom: parent.bottom
        height: Math.max(2, root.level(modelData) * ((root.bar ? root.bar.barSize : 26) - 8))
        color: root.bar ? root.bar.barForeground : "white"
        opacity: 0.5 + 0.5 * root.level(modelData)

        Behavior on height {
          NumberAnimation { duration: 90; easing.type: Easing.OutQuad }
        }
      }
    }
  }

  Process {
    id: cavaProc
    command: ["cava", "-p", Quickshell.env("HOME") + "/.config/cava/bar.conf"]
    running: true
    stdout: SplitParser {
      onRead: function (line) {
        var parts = String(line || "").split(";").filter(function (s) { return s.length > 0 })
        if (parts.length === 0) return
        var values = parts.map(Number).filter(function (n) { return !isNaN(n) })
        if (values.length > 0) root.bands = values
      }
    }
  }
}
