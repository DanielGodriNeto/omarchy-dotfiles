import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick
import qs.Commons
import qs.Commons as Commons
import qs.Ui

// Koi lake panel: opened from the koi button in the bar. Settings live in ~/.config/omarchy/lake.json,
// read and written through ~/.local/bin/lake-config; the plugin mancato.lake applies them live.
Item {
  id: root

  property var shell: null
  property var manifest: null
  property bool opened: false

  property bool enabled: true
  property string mode: "auto"
  property int count: 16
  property real speed: 1
  property string palette: "mix"
  property bool ripples: true

  readonly property color cardColor: Commons.Color.menu.background
  readonly property color textColor: Commons.Color.menu.text
  readonly property color accent: Commons.Color.accent
  readonly property int radius: Style.cornerRadius
  readonly property string summary: !enabled ? "Desligado"
    : (mode === "always" ? "Sempre" : mode === "idle" ? "Só terminais parados" : "Automático") + "  ·  " + count + " carpas"

  function open(payloadJson) {
    root.opened = true
    root.refresh()
    Qt.callLater(function() { keys.forceActiveFocus() })
  }

  function dismiss() {
    root.opened = false
    if (root.shell && typeof root.shell.hide === "function")
      root.shell.hide((root.manifest && root.manifest.id) || "mancato.lakepanel")
  }

  function toggle() {
    if (root.opened) root.dismiss()
    else root.open("{}")
  }

  function refresh() { if (!statusProc.running) statusProc.running = true }

  function set(key, value) {
    if (setProc.running) return
    setProc.command = ["lake-config", "set", key, String(value)]
    setProc.running = true
  }

  Process {
    id: statusProc
    command: ["lake-config"]
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: {
        try {
          var c = JSON.parse(text)
          root.enabled = c.enabled !== false
          root.mode = c.mode || "auto"
          root.count = c.count || 16
          root.speed = c.speed || 1
          root.palette = c.palette || "mix"
          root.ripples = c.ripples !== false
        } catch (e) {}
      }
    }
  }

  Process {
    id: setProc
    onRunningChanged: if (!running) root.refresh()
  }

  component Chip: Rectangle {
    id: chip
    property string label: ""
    property bool on: false
    signal clicked()
    implicitWidth: lbl.implicitWidth + Style.space(22)
    implicitHeight: Style.space(28)
    radius: height / 2
    color: on ? root.accent : Qt.alpha(root.textColor, 0.12)
    Text {
      id: lbl
      anchors.centerIn: parent
      text: chip.label
      color: chip.on ? Commons.Color.background : root.textColor
      font.family: Style.font.menuFamily
      font.pixelSize: Style.font.body
    }
    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: chip.clicked() }
  }

  component Section: Column {
    id: sec
    property string title: ""
    default property alias content: flow.data
    width: parent.width
    spacing: Style.space(6)
    Text {
      text: sec.title
      color: root.textColor
      opacity: 0.7
      font.family: Style.font.menuFamily
      font.pixelSize: Style.font.caption + 1
    }
    Flow { id: flow; width: parent.width; spacing: Style.space(6) }
  }

  OverlayWindow {
    id: panel
    shown: root.opened
    WlrLayershell.namespace: "mancato-lakepanel"

    Rectangle { anchors.fill: parent; color: Qt.alpha(Commons.Color.background, 0.5) }
    MouseArea { anchors.fill: parent; onClicked: root.dismiss() }

    Item {
      id: keys
      anchors.fill: parent
      focus: true
      Keys.priority: Keys.BeforeItem
      Keys.onPressed: function(event) {
        if (event.key === Qt.Key_Escape) { root.dismiss(); event.accepted = true }
      }
    }

    Rectangle {
      id: card
      anchors.top: parent.top
      anchors.right: parent.right
      anchors.topMargin: Style.space(48)
      anchors.rightMargin: Style.space(12)
      width: Style.space(360)
      height: col.implicitHeight + Style.space(28)
      radius: root.radius
      color: root.cardColor
      border.width: 1
      border.color: Qt.alpha(root.textColor, 0.18)
      MouseArea { anchors.fill: parent }

      Column {
        id: col
        anchors.fill: parent
        anchors.margins: Style.space(14)
        spacing: Style.space(12)

        Row {
          spacing: Style.space(10)
          Rectangle {
            width: Style.space(40)
            height: Style.space(40)
            radius: root.radius
            color: Qt.alpha(root.accent, root.enabled ? 0.22 : 0.08)
            Text {
              anchors.centerIn: parent
              textFormat: Text.PlainText
              text: "󰈺"
              color: root.enabled ? root.accent : root.textColor
              opacity: root.enabled ? 1 : 0.5
              font.family: Style.font.menuFamily
              font.pixelSize: Style.space(24)
            }
          }
          Column {
            anchors.verticalCenter: parent.verticalCenter
            Text {
              text: "Lago de carpas"
              color: root.textColor
              font.family: Style.font.menuFamily
              font.pixelSize: Style.font.title
            }
            Text {
              text: root.summary
              color: root.accent
              opacity: 0.9
              font.family: Style.font.menuFamily
              font.pixelSize: Style.font.caption + 1
            }
          }
        }

        Row {
          spacing: Style.space(8)
          Chip { label: root.enabled ? "Ligado" : "Desligado"; on: root.enabled; onClicked: root.set("enabled", "toggle") }
          Chip { label: "Ondas ao clicar"; on: root.ripples; onClicked: root.set("ripples", "toggle") }
        }

        Rectangle { width: parent.width; height: 1; color: Qt.alpha(root.textColor, 0.14) }

        Section {
          title: "Onde aparece"
          Chip { label: "Automático"; on: root.mode === "auto"; onClicked: root.set("mode", "auto") }
          Chip { label: "Só parados"; on: root.mode === "idle"; onClicked: root.set("mode", "idle") }
          Chip { label: "Sempre"; on: root.mode === "always"; onClicked: root.set("mode", "always") }
        }
        Text {
          width: parent.width
          wrapMode: Text.WordWrap
          text: "Automático mostra em todos os terminais no modo Performance e só nos parados nos outros."
          color: root.textColor
          opacity: 0.55
          font.family: Style.font.menuFamily
          font.pixelSize: Style.font.caption
        }

        Section {
          title: "Carpas"
          Chip { label: "Poucas"; on: root.count <= 8; onClicked: root.set("count", 8) }
          Chip { label: "Normal"; on: root.count > 8 && root.count <= 16; onClicked: root.set("count", 16) }
          Chip { label: "Muitas"; on: root.count > 16; onClicked: root.set("count", 28) }
        }

        Section {
          title: "Velocidade"
          Chip { label: "Calmo"; on: root.speed < 0.8; onClicked: root.set("speed", "slow") }
          Chip { label: "Normal"; on: root.speed >= 0.8 && root.speed <= 1.2; onClicked: root.set("speed", "normal") }
          Chip { label: "Rápido"; on: root.speed > 1.2; onClicked: root.set("speed", "fast") }
        }

        Section {
          title: "Cores"
          Chip { label: "Mistura"; on: root.palette === "mix"; onClicked: root.set("palette", "mix") }
          Chip { label: "Quentes"; on: root.palette === "warm"; onClicked: root.set("palette", "warm") }
          Chip { label: "Frias"; on: root.palette === "cool"; onClicked: root.set("palette", "cool") }
          Chip { label: "Da pintura"; on: root.palette === "paint"; onClicked: root.set("palette", "paint") }
        }
      }
    }
  }
}
