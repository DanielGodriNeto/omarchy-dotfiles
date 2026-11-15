import QtQuick
import Quickshell
import Quickshell.Io

// Custom bar module (bar.layout entry: { "id": "koi", "type": "qml" }).
// Botão do lago de carpas: clique esquerdo abre o painel de configuração, clique direito liga ou
// desliga o lago. Configuração em ~/.config/omarchy/lake.json (script lake-config).
Item {
  id: root

  property var bar
  property string moduleName
  property var settings

  property bool lakeOn: true
  property string summary: ""

  implicitWidth: pill.implicitWidth
  implicitHeight: bar ? bar.barSize : 26

  function refresh() { if (!statusProc.running) statusProc.running = true }

  Process {
    id: statusProc
    command: ["lake-config"]
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: {
        try {
          var c = JSON.parse(text)
          root.lakeOn = c.enabled !== false
          root.summary = root.lakeOn ? (c.count + " carpas") : "desligado"
        } catch (e) {}
      }
    }
  }

  Process {
    id: toggleProc
    command: ["lake-config", "set", "enabled", "toggle"]
    onRunningChanged: if (!running) root.refresh()
  }

  Timer {
    interval: 30000
    running: true
    repeat: true
    triggeredOnStart: true
    onTriggered: root.refresh()
  }

  Pill {
    id: pill
    anchors.fill: parent
    barSize: root.bar ? root.bar.barSize : 26
    pillColor: Qt.rgba(1, 1, 1, 0.08)
    foreground: root.bar ? root.bar.barForeground : "white"
    fontFamily: root.bar ? root.bar.fontFamily : "monospace"
    icon: "󰈺"
    iconColor: Qt.alpha(pill.foreground, root.lakeOn ? 1 : 0.4)
    clickable: false
  }

  MouseArea {
    anchors.fill: parent
    acceptedButtons: Qt.LeftButton | Qt.RightButton
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor
    onEntered: {
      pill.hovered = true
      root.refresh()
      if (root.bar) root.bar.showTooltip(root, "Lago de carpas · " + root.summary + "\nEsquerdo: ajustes · Direito: ligar/desligar")
    }
    onExited: {
      pill.hovered = false
      if (root.bar) root.bar.hideTooltip(root)
    }
    onClicked: function(mouse) {
      if (mouse.button === Qt.RightButton) {
        if (!toggleProc.running) toggleProc.running = true
      } else if (root.bar) {
        Quickshell.execDetached(["omarchy-shell", "-q", "shell", "toggle", "mancato.lakepanel", "{}"])
      }
    }
  }
}
