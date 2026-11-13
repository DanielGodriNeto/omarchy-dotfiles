import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import QtQuick
import qs.Commons
import qs.Commons as Commons
import qs.Ui

Item {
  id: root

  property string omarchyPath: Quickshell.env("OMARCHY_PATH")
  property var shell: null
  property var manifest: null

  property bool opened: false
  property int selectedIndex: 0
  property var cards: []          // [{ id, windows: [{ address, wayland, cls, title, x, y, w, h }] }]
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

  function close() { root.opened = false }

  function dismiss() {
    root.opened = false
    if (root.shell && typeof root.shell.hide === "function")
      root.shell.hide((root.manifest && root.manifest.id) || "mancato.overview")
  }

  function toggle() {
    if (root.opened) root.dismiss()
    else root.open("{}")
  }

  function iconFor(cls) {
    return Quickshell.iconPath(String(cls || "").toLowerCase(), "application-x-executable")
  }

  function rebuild() {
    var mon = Hyprland.focusedMonitor
    var info = mon && mon.lastIpcObject ? mon.lastIpcObject : null
    var sc = info && info.scale ? info.scale : 1
    var mx = info ? info.x : 0
    var my = info ? info.y : 0
    var mw = info ? info.width / sc : 1920
    var mh = info ? info.height / sc : 1080
    var activeId = mon && mon.activeWorkspace ? mon.activeWorkspace.id : 1
    root.originId = activeId

    var byId = ({})
    var wss = Hyprland.workspaces.values
    for (var i = 0; i < wss.length; i++) {
      var id = wss[i].id
      if (id > 0 && id < 1000) byId[id] = []
    }
    byId[activeId] = byId[activeId] || []

    var tops = Hyprland.toplevels.values
    for (var j = 0; j < tops.length; j++) {
      var t = tops[j]
      var o = t.lastIpcObject
      if (!t.workspace || !o || !o.mapped || o.hidden) continue
      var wid = t.workspace.id
      if (!(wid in byId)) continue
      byId[wid].push({
        address: t.address, wayland: t.wayland, cls: o.class || "", title: o.title || "",
        x: (o.at[0] - mx) / mw, y: (o.at[1] - my) / mh, w: o.size[0] / mw, h: o.size[1] / mh
      })
    }

    var ids = Object.keys(byId).map(Number).sort(function(a, b) { return a - b })
    var free = 1
    while (ids.indexOf(free) >= 0) free++
    ids.push(free)

    var out = []
    var sel = 0
    for (var k = 0; k < ids.length; k++) {
      out.push({ id: ids[k], windows: byId[ids[k]] || [], ratio: mw / mh })
      if (ids[k] === activeId) sel = k
    }
    root.cards = out
    root.selectedIndex = sel
  }

  function move(delta) {
    var n = root.cards.length
    if (n === 0) return
    root.selectedIndex = Math.max(0, Math.min(n - 1, root.selectedIndex + delta))
  }

  property int pendingId: -1

  // Close first, then switch: closing the overlay hands keyboard focus back
  // to the old window, which would undo an earlier switch.
  function activate(index) {
    var card = root.cards[index]
    if (!card) return
    root.pendingId = card.id !== root.originId ? card.id : -1
    root.dismiss()
    if (root.pendingId >= 0) switchTimer.restart()
  }

  Timer {
    id: switchTimer
    interval: 90
    onTriggered: Quickshell.execDetached(["hyprctl", "dispatch", "hl.dsp.focus({ workspace = \"" + root.pendingId + "\" })"])
  }

  OverlayWindow {
    id: panel
    shown: root.opened
    WlrLayershell.namespace: "mancato-overview"

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
        else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter || event.key === Qt.Key_Space) root.activate(root.selectedIndex)
        else return
        event.accepted = true
      }
    }

    Grid {
      id: grid
      anchors.centerIn: parent
      spacing: Style.space(24)
      columns: Math.max(1, Math.min(root.cards.length, 3))
      readonly property int rows: Math.ceil(root.cards.length / columns)
      readonly property real cardW: Math.min(Style.space(560),
        (panel.width * 0.86 - spacing * (columns - 1)) / columns,
        ((panel.height * 0.8 - spacing * (rows - 1)) / rows - Style.space(36)) * (root.cards.length ? root.cards[0].ratio : 1.6))

      Repeater {
        model: root.cards
        delegate: Item {
          id: card
          required property var modelData
          required property int index
          readonly property bool selected: index === root.selectedIndex
          readonly property bool active: modelData.id === root.originId
          width: grid.cardW
          height: grid.cardW / modelData.ratio + Style.space(36)

          Text {
            id: label
            anchors.horizontalCenter: parent.horizontalCenter
            text: card.modelData.id
            color: card.selected ? root.accent : root.textColor
            opacity: card.selected ? 1 : 0.7
            font.family: Style.font.menuFamily
            font.pixelSize: Style.font.title
            Behavior on opacity { NumberAnimation { duration: root.fade } }
          }

          Rectangle {
            id: thumb
            anchors.top: label.bottom
            anchors.topMargin: Style.space(8)
            width: parent.width
            height: parent.width / card.modelData.ratio
            radius: root.radius
            color: root.cardColor
            border.width: card.selected ? 2 : 1
            border.color: card.selected ? root.accent : Qt.alpha(root.textColor, 0.18)
            Behavior on border.color { ColorAnimation { duration: root.fade } }

            Text {
              visible: card.modelData.windows.length === 0
              anchors.centerIn: parent
              text: "+"
              color: root.textColor
              opacity: 0.35
              font.pixelSize: Style.font.display
            }

            Item {
              anchors.fill: parent
              anchors.margins: 1
              clip: true

              Repeater {
                model: card.modelData.windows
                delegate: Rectangle {
                  id: win
                  required property var modelData
                  x: modelData.x * parent.width
                  y: modelData.y * parent.height
                  width: modelData.w * parent.width
                  height: modelData.h * parent.height
                  radius: Math.max(2, root.radius / 3)
                  color: Qt.alpha(root.textColor, 0.08)
                  border.width: 1
                  border.color: Qt.alpha(root.textColor, 0.25)
                  clip: true

                  Image {
                    visible: !shot.hasContent
                    anchors.centerIn: parent
                    width: Math.min(parent.width, parent.height) * 0.4
                    height: width
                    source: root.iconFor(win.modelData.cls)
                    sourceSize: Qt.size(64, 64)
                    fillMode: Image.PreserveAspectFit
                  }

                  ScreencopyView {
                    id: shot
                    anchors.fill: parent
                    captureSource: root.opened ? win.modelData.wayland : null
                    live: false
                  }
                }
              }
            }

            MouseArea {
              anchors.fill: parent
              hoverEnabled: true
              onPositionChanged: root.selectedIndex = card.index
              onClicked: root.activate(card.index)
            }
          }
        }
      }
    }
  }
}
