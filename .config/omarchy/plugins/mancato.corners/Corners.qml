import Quickshell
import Quickshell.Wayland
import QtQuick

// Two tiny always-there layer surfaces in the top corners. Resting the pointer
// in one for a moment toggles a panel; it re-arms once the pointer leaves.
Scope {
  id: root

  property var shell: null
  property var manifest: null

  readonly property int cornerSize: 4
  readonly property int dwell: 140

  component Corner: PanelWindow {
    id: win
    required property string panelId
    property bool atRight: false

    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    implicitWidth: root.cornerSize
    implicitHeight: root.cornerSize
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
    WlrLayershell.namespace: "mancato-corner"
    anchors { top: true; left: !atRight; right: atRight }

    property bool armed: true

    Timer {
      id: dwellTimer
      interval: root.dwell
      onTriggered: {
        if (!win.armed) return
        win.armed = false
        Quickshell.execDetached(["omarchy-shell", "-q", "shell", "toggle", win.panelId, "{}"])
      }
    }

    HoverHandler {
      onHoveredChanged: {
        if (hovered) dwellTimer.restart()
        else { dwellTimer.stop(); win.armed = true }
      }
    }
  }

  Variants {
    model: Quickshell.screens
    delegate: Scope {
      required property var modelData
      Corner { screen: modelData; panelId: "mancato.overview" }
      Corner { screen: modelData; panelId: "mancato.expose"; atRight: true }
    }
  }
}
