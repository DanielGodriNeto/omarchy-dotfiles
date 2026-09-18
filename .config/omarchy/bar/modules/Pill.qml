import QtQuick

// Shared chip chrome for the custom bar widgets in this directory
// (cpu-pill, ram-pill, disk-pill, apps-pill), styled after the r/gnome
// panel-button reference: a dark translucent rounded rectangle (not a
// full stadium capsule) with a lighter inset highlight on hover.
// Every sibling *.qml file can reference `Pill { ... }` with no import:
// QML auto-registers types from .qml files that live next to the file a
// Loader pulls in.
Item {
  id: root

  property string icon: ""
  property string value: ""
  property color foreground: "white"
  property color iconColor: foreground
  property color pillColor: Qt.rgba(0, 0, 0, 0.35)
  property color hoverColor: Qt.rgba(1, 1, 1, 0.14)
  property real cornerRadius: 10
  property real barSize: 26
  property string fontFamily: "monospace"
  property bool hovered: false
  property bool clickable: true
  // Extra content (e.g. the open-apps icon row) can be placed after the
  // icon/value label by reparenting into this row.
  default property alias extraContent: row.data

  signal clicked(var mouse)

  // outerGap is blank space around the chip so adjacent pills in the bar
  // (which lays modules out with zero spacing) still show a visible gap,
  // like the reference's `margin-left/right: 5px` between panel-buttons.
  readonly property real outerGap: 3
  readonly property real horizontalPad: 10
  implicitWidth: row.implicitWidth + horizontalPad * 2 + outerGap * 2
  implicitHeight: Math.max(barSize - 6, row.implicitHeight + 6) + outerGap * 2

  Rectangle {
    id: chip
    anchors.fill: parent
    anchors.margins: root.outerGap
    radius: Math.min(root.cornerRadius, height / 2)
    color: root.hovered ? root.hoverColor : root.pillColor

    Behavior on color { ColorAnimation { duration: 120 } }
  }

  Row {
    id: row
    anchors.centerIn: chip
    spacing: 5

    Text {
      id: iconLabel
      text: root.icon
      visible: text.length > 0
      color: root.iconColor
      font.family: root.fontFamily
      font.pixelSize: 13
      verticalAlignment: Text.AlignVCenter
    }

    Text {
      id: valueLabel
      text: root.value
      visible: text.length > 0
      color: root.foreground
      font.family: root.fontFamily
      font.pixelSize: 12
      verticalAlignment: Text.AlignVCenter
    }
  }

  MouseArea {
    id: mouseArea
    anchors.fill: chip
    hoverEnabled: root.clickable
    enabled: root.clickable
    cursorShape: Qt.PointingHandCursor
    onEntered: root.hovered = true
    onExited: root.hovered = false
    onClicked: function(mouse) { root.clicked(mouse) }
  }
}
