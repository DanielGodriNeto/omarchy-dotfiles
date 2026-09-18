import QtQuick
import Quickshell
import Quickshell.Wayland

// Custom bar module (bar.layout entry: { "id": "apps-pill", "type": "qml" }).
// One icon per running application, taskbar-style, inside a single pill.
// Click an icon to focus/cycle that app's windows.
Item {
  id: root

  property var bar
  property string moduleName
  property var settings

  // [{ appId, icon, active, windows: [Toplevel,...], cursor }]
  property var apps: []

  implicitWidth: apps.length > 0 ? pill.implicitWidth : 0
  implicitHeight: bar ? bar.barSize : 26
  visible: apps.length > 0

  function desktopIcon(appId) {
    var id = String(appId || "")
    if (!id) return Quickshell.iconPath("application-x-executable", true)
    var lower = id.toLowerCase()
    var entries = DesktopEntries.applications ? (DesktopEntries.applications.values || []) : []
    for (var i = 0; i < entries.length; i++) {
      var e = entries[i]
      var entryId = String(e.id || "").replace(/\.desktop$/, "").toLowerCase()
      var startup = String(e.startupClass || "").toLowerCase()
      if (entryId === lower || startup === lower) {
        var themed = Quickshell.iconPath(e.icon || "", true)
        if (themed.length > 0) return themed
        break
      }
    }
    var direct = Quickshell.iconPath(id, true)
    if (direct.length > 0) return direct
    var directLower = Quickshell.iconPath(lower, true)
    if (directLower.length > 0) return directLower
    return Quickshell.iconPath("application-x-executable", true)
  }

  function rebuild() {
    var toplevels = ToplevelManager.toplevels ? (ToplevelManager.toplevels.values || []) : []
    var order = []
    var byId = ({})
    for (var i = 0; i < toplevels.length; i++) {
      var t = toplevels[i]
      var id = String(t.appId || "unknown")
      if (!byId[id]) {
        byId[id] = { appId: id, icon: root.desktopIcon(id), windows: [], active: false, cursor: 0 }
        order.push(id)
      }
      byId[id].windows.push(t)
      if (t.activated) byId[id].active = true
    }
    var next = []
    for (var j = 0; j < order.length; j++) next.push(byId[order[j]])
    root.apps = next
  }

  Connections {
    target: ToplevelManager
    function onActiveToplevelChanged() { root.rebuild() }
  }

  Connections {
    target: ToplevelManager.toplevels
    function onValuesChanged() { root.rebuild() }
  }

  Component.onCompleted: rebuild()

  Pill {
    id: pill
    anchors.fill: parent
    barSize: root.bar ? root.bar.barSize : 26
    pillColor: Qt.rgba(1, 1, 1, 0.08)
    clickable: false

    Row {
      spacing: 8

      Repeater {
        model: root.apps

        Item {
          id: appIcon
          required property var modelData
          readonly property real size: 16
          width: size
          height: size

          Image {
            anchors.fill: parent
            source: appIcon.modelData.icon
            fillMode: Image.PreserveAspectFit
            asynchronous: true
            sourceSize.width: width * Screen.devicePixelRatio
            sourceSize.height: height * Screen.devicePixelRatio
            opacity: appIcon.modelData.active ? 1.0 : 0.6
          }

          Rectangle {
            visible: appIcon.modelData.active
            width: 4
            height: 4
            radius: 2
            color: root.bar ? root.bar.barForeground : "white"
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: -5
          }

          MouseArea {
            anchors.fill: parent
            anchors.margins: -3
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
              var entry = appIcon.modelData
              if (!entry.windows || entry.windows.length === 0) return
              entry.cursor = (entry.cursor + 1) % entry.windows.length
              var target = entry.windows[entry.cursor]
              if (target && target.activate) target.activate()
            }
            onEntered: if (root.bar) root.bar.showTooltip(appIcon, appIcon.modelData.appId)
            onExited: if (root.bar) root.bar.hideTooltip(appIcon)
          }
        }
      }
    }
  }
}
