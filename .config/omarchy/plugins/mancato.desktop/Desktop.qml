import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
import QtQuick
import qs.Commons
import qs.Commons as Commons

// A large clock in the upper third and the current painting's caption in the
// bottom-left corner, on the Bottom layer: windows cover them, an empty
// workspace shows them. Input passes straight through.
Scope {
  id: root

  property var shell: null
  property var manifest: null

  property string caption: ""
  // The big clock can be switched off (desktop-clock); the caption stays.
  property bool clockOn: true
  property date now: new Date()

  readonly property string statePath: Quickshell.env("HOME") + "/.local/state/painting-theme/state.json"
  readonly property color textColor: Commons.Color.menu.text
  readonly property color accent: Commons.Color.accent

  function cleanTitle(raw) {
    var t = String(raw || "").replace(/\.(jpe?g|png|webp)$/i, "").replace(/_/g, " ").trim()
    return t.length > 90 ? t.slice(0, 87) + "…" : t
  }

  Timer {
    interval: 1000
    running: true
    repeat: true
    onTriggered: root.now = new Date()
  }

  FileView {
    id: clockFile
    path: Quickshell.env("HOME") + "/.config/omarchy/desktop-clock"
    watchChanges: true
    printErrors: false
    onFileChanged: reload()
    onLoaded: root.clockOn = text().trim() !== "off"
    onLoadFailed: root.clockOn = true
  }

  FileView {
    id: stateFile
    path: root.statePath
    watchChanges: true
    printErrors: false
    onFileChanged: reload()
    onLoaded: {
      try { root.caption = root.cleanTitle(JSON.parse(text()).title) } catch (e) { root.caption = "" }
    }
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
      WlrLayershell.namespace: "mancato-desktop"
      anchors { top: true; bottom: true; left: true; right: true }
      mask: Region {}

      // Relógio e legenda só aparecem com o workspace vazio: com janelas translúcidas
      // (terminal com opacidade) eles apareciam por trás delas.
      readonly property var monitor: Hyprland.monitorFor(screen)
      readonly property int workspaceId: monitor && monitor.activeWorkspace ? monitor.activeWorkspace.id : -1
      readonly property bool occupied: {
        var tops = Hyprland.toplevels.values
        for (var i = 0; i < tops.length; i++) {
          var ws = tops[i].workspace
          if (ws && ws.id === workspaceId) return true
        }
        return false
      }
      property real shown: occupied ? 0 : 1
      Behavior on shown { NumberAnimation { duration: Style.duration(180); easing.type: Easing.OutCubic } }
      visible: shown > 0.01

      Rectangle {
        visible: root.clockOn
        anchors.horizontalCenter: parent.horizontalCenter
        y: parent.height * 0.2
        width: clockColumn.implicitWidth + 64
        height: clockColumn.implicitHeight + 36
        radius: Style.cornerRadius * 2
        color: Qt.alpha(Commons.Color.background, 0.68)
        opacity: win.shown
      }

      Column {
        id: clockColumn
        visible: root.clockOn
        opacity: win.shown
        anchors.horizontalCenter: parent.horizontalCenter
        y: parent.height * 0.2 + 18
        spacing: 4

        Text {
          anchors.horizontalCenter: parent.horizontalCenter
          text: Qt.formatTime(root.now, "HH:mm")
          color: root.textColor
          opacity: 0.92
          font.family: Style.font.menuFamily
          font.pixelSize: 96
          font.weight: Font.Medium
        }
        Text {
          anchors.horizontalCenter: parent.horizontalCenter
          text: Qt.locale("pt_BR").toString(root.now, "dddd, d 'de' MMMM")
          color: root.accent
          opacity: 0.9
          font.family: Style.font.menuFamily
          font.pixelSize: 22
        }
      }

      Rectangle {
        visible: root.caption !== ""
        opacity: win.shown
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.margins: 16
        width: cap.implicitWidth + 24
        height: cap.implicitHeight + 14
        radius: Style.cornerRadius
        color: Qt.alpha(Commons.Color.background, 0.7)
        Text {
          id: cap
          anchors.centerIn: parent
          text: root.caption
          color: root.textColor
          opacity: 0.85
          font.family: Style.font.menuFamily
          font.pixelSize: Style.font.caption + 2
        }
      }
    }
  }
}
