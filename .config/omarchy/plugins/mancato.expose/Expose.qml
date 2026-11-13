import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import QtQuick
import qs.Commons
import qs.Commons as Commons
import qs.Ui

// Every open window as a 16:9 card. Click brings it to the current workspace,
// the x closes it, Escape leaves.
Item {
  id: root

  property var shell: null
  property var manifest: null

  property bool opened: false
  property int selectedIndex: 0
  property var wins: []      // [{ address, wayland, cls, title, ws }]
  property int originId: 1

  readonly property color cardColor: Commons.Color.menu.background
  readonly property color textColor: Commons.Color.menu.text
  readonly property color accent: Commons.Color.accent
  readonly property int radius: Style.cornerRadius
  readonly property int fade: Style.duration(160)

  function open(payloadJson) {
    Hyprland.refreshWorkspaces()
    Hyprland.refreshToplevels()
    Hyprland.refreshMonitors()
    root.opened = true
    rebuild()
    Qt.callLater(function() { keys.forceActiveFocus() })
  }

  function dismiss() {
    root.opened = false
    if (root.shell && typeof root.shell.hide === "function")
      root.shell.hide((root.manifest && root.manifest.id) || "mancato.expose")
  }

  function toggle() {
    if (root.opened) root.dismiss()
    else root.open("{}")
  }

  function iconFor(cls) {
    return Quickshell.iconPath(String(cls || "").toLowerCase(), "application-x-executable")
  }

  function normAddress(address) {
    var a = String(address || "")
    return a.indexOf("0x") === 0 ? a : "0x" + a
  }

  // Widgets (btop, cliamp...), other Omarchy system windows and anything on a
  // special workspace stay out of the list, so future additions do not clutter it.
  function isSystemWindow(cls, workspaceId) {
    var c = String(cls || "").toLowerCase()
    return workspaceId < 0 || c.indexOf("omarchy-") === 0 || c.indexOf("omarchy_") === 0
  }

  function rebuild() {
    var mon = Hyprland.focusedMonitor
    root.originId = mon && mon.activeWorkspace ? mon.activeWorkspace.id : 1
    var out = []
    var tops = Hyprland.toplevels.values
    for (var i = 0; i < tops.length; i++) {
      var t = tops[i]
      var o = t.lastIpcObject
      if (!t.workspace || !o || !o.mapped) continue
      if (root.isSystemWindow(o.class, t.workspace.id)) continue
      out.push({ address: t.address, wayland: t.wayland, cls: o.class || "", title: o.title || o.class || "",
                 ws: t.workspace.id, focus: Number(o.focusHistoryID !== undefined ? o.focusHistoryID : 9999) })
    }
    out.sort(function(a, b) { return a.focus - b.focus })
    root.wins = out
    root.selectedIndex = 0
  }

  function move(delta) {
    var n = root.wins.length
    if (n === 0) return
    root.selectedIndex = Math.max(0, Math.min(n - 1, root.selectedIndex + delta))
  }

  property string pendingAddress: ""
  property int pendingWorkspace: -1

  // Close first, then move and focus: closing the overlay hands focus back to
  // the old window, which would undo an earlier focus.
  function bring(index) {
    var w = root.wins[index]
    if (!w) return
    root.pendingAddress = root.normAddress(w.address)
    root.pendingWorkspace = root.originId
    root.dismiss()
    bringTimer.restart()
  }

  Timer {
    id: bringTimer
    interval: 90
    onTriggered: {
      var target = "window = \"address:" + root.pendingAddress + "\""
      var steps = []
      if (root.pendingWorkspace >= 1)
        steps.push("hl.dsp.window.move({ workspace = \"" + root.pendingWorkspace + "\", " + target + " })")
      steps.push("hl.dsp.focus({ " + target + " })")
      Quickshell.execDetached(["bash", "-c", steps.map(function(s) { return "hyprctl dispatch '" + s + "'" }).join(" && ")])
    }
  }

  function closeWindow(index) {
    var w = root.wins[index]
    if (!w) return
    Quickshell.execDetached(["hyprctl", "dispatch", "hl.dsp.window.close({ window = \"address:" + root.normAddress(w.address) + "\" })"])
    var next = root.wins.slice()
    next.splice(index, 1)
    root.wins = next
    root.selectedIndex = Math.min(root.selectedIndex, Math.max(0, next.length - 1))
    if (next.length === 0) root.dismiss()
  }

  OverlayWindow {
    id: panel
    shown: root.opened
    WlrLayershell.namespace: "mancato-expose"

    Rectangle {
      anchors.fill: parent
      color: Qt.alpha(Commons.Color.background, 0.86)
    }

    MouseArea {
      anchors.fill: parent
      onClicked: root.dismiss()
    }

    Item {
      id: keys
      anchors.fill: parent
      focus: true
      Keys.priority: Keys.BeforeItem
      Keys.onPressed: function(event) {
        var cols = grid.columns
        if (event.key === Qt.Key_Escape) root.dismiss()
        else if (event.key === Qt.Key_Left || event.key === Qt.Key_H) root.move(-1)
        else if (event.key === Qt.Key_Right || event.key === Qt.Key_L) root.move(1)
        else if (event.key === Qt.Key_Up || event.key === Qt.Key_K) root.move(-cols)
        else if (event.key === Qt.Key_Down || event.key === Qt.Key_J) root.move(cols)
        else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) root.bring(root.selectedIndex)
        else if (event.key === Qt.Key_Delete || event.key === Qt.Key_X) root.closeWindow(root.selectedIndex)
        else return
        event.accepted = true
      }
    }

    Text {
      visible: root.wins.length === 0
      anchors.centerIn: parent
      text: "Nenhuma janela aberta"
      color: root.textColor
      opacity: 0.6
      font.family: Style.font.menuFamily
      font.pixelSize: Style.font.title
    }

    Grid {
      id: grid
      anchors.centerIn: parent
      spacing: Style.space(20)
      columns: Math.max(1, Math.min(root.wins.length, Math.ceil(Math.sqrt(root.wins.length * 1.6))))
      readonly property int rows: Math.max(1, Math.ceil(root.wins.length / columns))
      readonly property real cardW: Math.min(Style.space(520),
        (panel.width * 0.9 - spacing * (columns - 1)) / columns,
        ((panel.height * 0.84 - spacing * (rows - 1)) / rows - Style.space(30)) * 16 / 9)

      Repeater {
        model: root.wins
        delegate: Item {
          id: card
          required property var modelData
          required property int index
          readonly property bool selected: index === root.selectedIndex
          width: grid.cardW
          height: grid.cardW * 9 / 16 + Style.space(30)

          Rectangle {
            id: thumb
            width: parent.width
            height: parent.width * 9 / 16
            radius: root.radius
            color: root.cardColor
            border.width: card.selected ? 2 : 1
            border.color: card.selected ? root.accent : Qt.alpha(root.textColor, 0.18)
            clip: true
            Behavior on border.color { ColorAnimation { duration: root.fade } }

            Image {
              visible: !shot.hasContent
              anchors.centerIn: parent
              width: parent.height * 0.4
              height: width
              source: root.iconFor(card.modelData.cls)
              sourceSize: Qt.size(64, 64)
              fillMode: Image.PreserveAspectFit
            }

            ScreencopyView {
              id: shot
              anchors.fill: parent
              captureSource: root.opened ? card.modelData.wayland : null
              live: false
            }

            MouseArea {
              anchors.fill: parent
              hoverEnabled: true
              onPositionChanged: root.selectedIndex = card.index
              onClicked: root.bring(card.index)
            }

            Rectangle {
              id: closeBtn
              anchors.top: parent.top
              anchors.right: parent.right
              anchors.margins: Style.space(8)
              width: Style.space(24)
              height: width
              radius: width / 2
              visible: card.selected
              color: closeArea.containsMouse ? root.accent : Qt.alpha(Commons.Color.background, 0.8)
              Text {
                anchors.centerIn: parent
                text: "×"
                color: closeArea.containsMouse ? Commons.Color.background : root.textColor
                font.pixelSize: Style.font.title
              }
              MouseArea {
                id: closeArea
                anchors.fill: parent
                hoverEnabled: true
                onClicked: root.closeWindow(card.index)
              }
            }
          }

          Text {
            anchors.top: thumb.bottom
            anchors.topMargin: Style.space(6)
            width: parent.width
            text: card.modelData.title + (card.modelData.ws !== root.originId ? "  ·  ws " + card.modelData.ws : "")
            textFormat: Text.PlainText
            elide: Text.ElideRight
            horizontalAlignment: Text.AlignHCenter
            color: card.selected ? root.accent : root.textColor
            opacity: card.selected ? 1 : 0.75
            font.family: Style.font.menuFamily
            font.pixelSize: Style.font.body
          }
        }
      }
    }
  }
}
