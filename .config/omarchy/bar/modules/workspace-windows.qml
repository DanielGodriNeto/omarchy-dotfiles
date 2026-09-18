import QtQuick
import Quickshell.Hyprland

// Custom bar module (bar.layout entry: { "id": "workspace-windows", "type": "qml" }).
// One small vertical bar per window on the currently focused workspace,
// brighter for the focused window - a mini layout indicator matching the
// two-tone bars next to the workspace numbers in the Cyberpunk Edgerunners
// preview.
Item {
  id: root

  property var bar
  property string moduleName
  property var settings

  readonly property var focusedWs: Hyprland.focusedWorkspace
  readonly property var windows: focusedWs && focusedWs.toplevels ? focusedWs.toplevels.values : []

  implicitWidth: windows.length > 0 ? (row.implicitWidth + 6) : 0
  implicitHeight: bar ? bar.barSize : 26
  visible: windows.length > 0

  Row {
    id: row
    anchors.centerIn: parent
    spacing: 2

    Repeater {
      model: root.windows

      Rectangle {
        required property var modelData
        width: 4
        radius: 1
        height: Math.max(6, (root.bar ? root.bar.barSize : 26) - 12)
        anchors.verticalCenter: parent.verticalCenter
        color: root.bar ? root.bar.barForeground : "white"
        opacity: modelData && modelData.activated ? 1.0 : 0.4
      }
    }
  }
}
