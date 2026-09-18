import QtQuick
import Quickshell.Io

// Custom bar module (bar.layout entry: { "id": "system-pill", "type": "qml" }).
// Combined "CPU 42% · 48°C  RAM 7.1/16G" readout, matching the Cyberpunk
// Edgerunners preview's plain-text stat line (no pill chip, no disk%).
// Replaces the separate cpu-pill/ram-pill/disk-pill widgets.
Item {
  id: root

  property var bar
  property string moduleName
  property var settings

  property real cpuPercent: 0
  property real cpuTempC: 0
  property real ramUsedGiB: 0
  property real ramTotalGiB: 0

  property real prevIdle: 0
  property real prevTotal: 0
  property bool havePrevCpu: false

  implicitWidth: label.implicitWidth
  implicitHeight: bar ? bar.barSize : 26

  readonly property string cpuText: Math.round(cpuPercent) + "%"
  readonly property string tempText: cpuTempC > 0 ? Math.round(cpuTempC) + "°C" : "--"
  readonly property string ramText: ramTotalGiB > 0
    ? ramUsedGiB.toFixed(1) + "/" + Math.round(ramTotalGiB) + "G"
    : "--"

  Text {
    id: label
    anchors.centerIn: parent
    textFormat: Text.PlainText
    text: "CPU " + root.cpuText + "  ·  " + root.tempText + "   RAM " + root.ramText
    color: root.bar ? root.bar.barForeground : "white"
    font.family: root.bar ? root.bar.fontFamily : "monospace"
    font.pixelSize: 12
  }

  MouseArea {
    anchors.fill: parent
    cursorShape: Qt.PointingHandCursor
    onClicked: if (root.bar) root.bar.run("omarchy-launch-or-focus-tui btop")
  }

  function parseStat(text) {
    var firstLine = String(text || "").split("\n")[0] || ""
    var parts = firstLine.trim().split(/\s+/).slice(1).map(Number)
    if (parts.length < 5) return
    var idle = parts[3] + (parts[4] || 0)
    var total = 0
    for (var i = 0; i < parts.length; i++) total += parts[i]

    if (root.havePrevCpu) {
      var dIdle = idle - root.prevIdle
      var dTotal = total - root.prevTotal
      if (dTotal > 0) root.cpuPercent = Math.max(0, Math.min(100, 100 * (1 - dIdle / dTotal)))
    }
    root.prevIdle = idle
    root.prevTotal = total
    root.havePrevCpu = true
  }

  function parseMeminfo(text) {
    var total = 0
    var available = 0
    var lines = String(text || "").split("\n")
    for (var i = 0; i < lines.length; i++) {
      var line = lines[i]
      if (line.indexOf("MemTotal:") === 0) total = parseFloat(line.replace(/[^0-9]/g, ""))
      else if (line.indexOf("MemAvailable:") === 0) available = parseFloat(line.replace(/[^0-9]/g, ""))
    }
    if (total > 0) {
      root.ramTotalGiB = total / 1024 / 1024
      root.ramUsedGiB = Math.max(0, (total - available)) / 1024 / 1024
    }
  }

  function parseSensors(text) {
    try {
      var data = JSON.parse(text || "{}")
      for (var chip in data) {
        if (chip.indexOf("coretemp") !== 0 && chip.indexOf("k10temp") !== 0) continue
        var fields = data[chip]
        for (var key in fields) {
          if (key.toLowerCase().indexOf("package") === -1 && key.toLowerCase().indexOf("tctl") === -1) continue
          var sub = fields[key]
          for (var inputKey in sub) {
            if (inputKey.indexOf("_input") !== -1) {
              root.cpuTempC = sub[inputKey]
              return
            }
          }
        }
      }
    } catch (e) {
      // ignore malformed output
    }
  }

  Process {
    id: statProc
    command: ["cat", "/proc/stat"]
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: root.parseStat(text)
    }
  }

  Process {
    id: memProc
    command: ["cat", "/proc/meminfo"]
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: root.parseMeminfo(text)
    }
  }

  Process {
    id: sensorsProc
    command: ["sensors", "-j"]
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: root.parseSensors(text)
    }
  }

  Timer {
    interval: 2000
    running: true
    repeat: true
    triggeredOnStart: true
    onTriggered: {
      if (!statProc.running) statProc.running = true
      if (!memProc.running) memProc.running = true
    }
  }

  Timer {
    interval: 5000
    running: true
    repeat: true
    triggeredOnStart: true
    onTriggered: if (!sensorsProc.running) sensorsProc.running = true
  }
}
