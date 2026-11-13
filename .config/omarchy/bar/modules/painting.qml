import QtQuick
import Quickshell.Io

// Custom bar module (bar.layout entry: { "id": "painting", "type": "qml" }).
// Botao do tema por pintura: clique esquerdo troca a pintura (wallpaper + cores
// do sistema), clique direito abre o menu "Pintura do tema" do Omarchy.
// Passar o mouse mostra o nome da pintura atual. Logica em ~/.local/bin/painting-theme.
Item {
  id: root

  property var bar
  property string moduleName
  property var settings

  property string title: ""
  property bool busy: false

  implicitWidth: pill.implicitWidth
  implicitHeight: bar ? bar.barSize : 26

  function refresh() { if (!statusProc.running) statusProc.running = true }

  Process {
    id: statusProc
    command: ["painting-theme", "status"]
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: {
        try { root.title = JSON.parse(text).title || "" } catch (e) { root.title = "" }
      }
    }
  }

  Process {
    id: nextProc
    command: ["painting-theme", "next"]
    onRunningChanged: { root.busy = running; if (!running) root.refresh() }
  }

  Timer {
    interval: 60000
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
    icon: root.busy ? "󰔟" : "󰋩"
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
      if (root.bar) root.bar.showTooltip(root, (root.title || "Pintura do tema") + "\nEsquerdo: trocar · Direito: menu")
    }
    onExited: {
      pill.hovered = false
      if (root.bar) root.bar.hideTooltip(root)
    }
    onClicked: function(mouse) {
      if (mouse.button === Qt.RightButton) {
        if (root.bar) root.bar.run("omarchy menu summon pintura")
      } else if (!nextProc.running) {
        nextProc.running = true
      }
    }
  }
}
