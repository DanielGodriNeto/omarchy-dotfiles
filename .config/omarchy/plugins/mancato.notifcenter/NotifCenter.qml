import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick
import qs.Commons
import qs.Commons as Commons
import qs.Ui

// Right-hand sheet with the notification history (history.json, kept by the
// notification service for seven days). Read-only; Escape or a click outside leaves.
Item {
  id: root

  property var shell: null
  property var manifest: null
  property bool opened: false
  property var entries: []

  readonly property color cardColor: Commons.Color.menu.background
  readonly property color textColor: Commons.Color.menu.text
  readonly property color accent: Commons.Color.accent
  readonly property int radius: Style.cornerRadius
  readonly property string historyPath: Quickshell.env("HOME") + "/.local/state/omarchy/notifications/history.json"

  function open(payloadJson) {
    historyFile.reload()
    root.opened = true
    Qt.callLater(function() { keys.forceActiveFocus() })
  }

  function dismiss() {
    root.opened = false
    if (root.shell && typeof root.shell.hide === "function")
      root.shell.hide((root.manifest && root.manifest.id) || "mancato.notifcenter")
  }

  function toggle() {
    if (root.opened) root.dismiss()
    else root.open("{}")
  }

  function ago(ts) {
    var s = Math.max(0, Date.now() / 1000 - Number(ts || 0))
    if (s < 60) return "agora"
    if (s < 3600) return Math.floor(s / 60) + " min"
    if (s < 86400) return Math.floor(s / 3600) + " h"
    return Math.floor(s / 86400) + " d"
  }

  FileView {
    id: historyFile
    path: root.historyPath
    printErrors: false
    onLoaded: {
      try { root.entries = JSON.parse(text()) } catch (e) { root.entries = [] }
    }
    onLoadFailed: root.entries = []
  }

  OverlayWindow {
    id: panel
    shown: root.opened
    WlrLayershell.namespace: "mancato-notifcenter"

    Rectangle {
      anchors.fill: parent
      color: Qt.alpha(Commons.Color.background, 0.55)
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
        if (event.key === Qt.Key_Escape) { root.dismiss(); event.accepted = true }
      }
    }

    Rectangle {
      id: sheet
      anchors.top: parent.top
      anchors.bottom: parent.bottom
      anchors.right: parent.right
      anchors.margins: Style.space(12)
      anchors.topMargin: Style.space(48)
      width: Math.min(Style.space(420), parent.width * 0.9)
      radius: root.radius
      color: root.cardColor
      border.width: 1
      border.color: Qt.alpha(root.textColor, 0.18)

      MouseArea { anchors.fill: parent }

      Text {
        id: heading
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.margins: Style.space(16)
        text: "Notificações  ·  " + root.entries.length
        color: root.accent
        font.family: Style.font.menuFamily
        font.pixelSize: Style.font.title
      }

      Text {
        visible: root.entries.length === 0
        anchors.centerIn: parent
        text: "Nada por aqui"
        color: root.textColor
        opacity: 0.6
        font.family: Style.font.menuFamily
        font.pixelSize: Style.font.body
      }

      ListView {
        anchors.top: heading.bottom
        anchors.topMargin: Style.space(10)
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: Style.space(12)
        clip: true
        spacing: Style.space(8)
        model: root.entries
        boundsBehavior: Flickable.StopAtBounds

        delegate: Rectangle {
          required property var modelData
          width: ListView.view.width
          height: col.implicitHeight + Style.space(16)
          radius: Math.max(4, root.radius - 2)
          color: Qt.alpha(root.textColor, 0.07)

          Column {
            id: col
            anchors.fill: parent
            anchors.margins: Style.space(8)
            spacing: Style.space(2)

            Row {
              spacing: Style.space(8)
              Text {
                text: modelData.app || ""
                textFormat: Text.PlainText
                color: root.accent
                font.family: Style.font.menuFamily
                font.pixelSize: Style.font.caption
              }
              Text {
                text: root.ago(modelData.ts)
                color: root.textColor
                opacity: 0.55
                font.family: Style.font.menuFamily
                font.pixelSize: Style.font.caption
              }
            }
            Text {
              width: parent.width
              text: modelData.summary || ""
              textFormat: Text.PlainText
              visible: text !== ""
              color: root.textColor
              wrapMode: Text.Wrap
              maximumLineCount: 2
              elide: Text.ElideRight
              font.family: Style.font.menuFamily
              font.pixelSize: Style.font.body
            }
            Text {
              width: parent.width
              text: modelData.body || ""
              visible: text !== ""
              color: root.textColor
              opacity: 0.7
              wrapMode: Text.Wrap
              maximumLineCount: 3
              elide: Text.ElideRight
              textFormat: Text.PlainText
              font.family: Style.font.menuFamily
              font.pixelSize: Style.font.caption
            }
          }
        }
      }
    }
  }
}
