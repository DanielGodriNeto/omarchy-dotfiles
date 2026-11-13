import QtQuick
import Quickshell.Io
import qs.Ui
import qs.Commons
import qs.Commons as Commons

Panel {
  id: root
  moduleName: "mancato.control-center"
  ipcTarget: "mancato.control-center"

  property var st: ({ wifi: false, bt: false, night: false, profile: "", volume: 0, muted: false, brightness: 50 })
  readonly property var profileOrder: ["power-saver", "balanced", "performance"]
  readonly property var profileNames: ({ "power-saver": "Economia", "balanced": "Equilibrado", "performance": "Desempenho" })

  function run(command) {
    Util.execDetached(command)
    refreshSoon.restart()
  }
  function nextProfile() {
    var i = profileOrder.indexOf(st.profile)
    return profileOrder[(i + 1) % profileOrder.length]
  }

  Process {
    id: poll
    command: ["control-center-state"]
    stdout: StdioCollector {
      onStreamFinished: {
        try { root.st = JSON.parse(text) } catch (e) {}
      }
    }
  }
  Timer { interval: 3000; repeat: true; running: root.opened; triggeredOnStart: true; onTriggered: if (!poll.running) poll.running = true }
  Timer { id: refreshSoon; interval: 600; onTriggered: if (!poll.running) poll.running = true }

  BarIconButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: "󰒓"
    tooltipText: "Central de controle"
    onPressed: function(b) { root.toggle() }
  }

  KeyboardPanel {
    id: panel
    anchorItem: button
    owner: root
    bar: root.bar
    open: root.opened
    focusTarget: panel.loadedContent
    contentWidth: panel.fittedContentWidth(Style.space(340))
    contentHeight: panel.fittedContentHeight(panel.loadedContentHeight)

    content: PanelKeyCatcher {
      anchors.fill: parent
      implicitHeight: column.implicitHeight
      onCloseRequested: root.close()
      onTabRequested: function(direction) { root.switchPanel(direction) }

      Column {
        id: column
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        spacing: Style.space(12)

        Grid {
          id: tiles
          width: parent.width
          columns: 2
          spacing: Style.space(8)

          Tile { icon: "󰖩"; label: "Wi-Fi"; sub: root.st.wifi ? "Ligado" : "Desligado"; on: root.st.wifi
            onClicked: root.run("nmcli radio wifi " + (root.st.wifi ? "off" : "on")) }
          Tile { icon: "󰂯"; label: "Bluetooth"; sub: root.st.bt ? "Ligado" : "Desligado"; on: root.st.bt
            onClicked: root.run("bluetoothctl power " + (root.st.bt ? "off" : "on")) }
          Tile { icon: "󰖔"; label: "Luz noturna"; sub: root.st.night ? "Ligada" : "Desligada"; on: root.st.night
            onClicked: root.run("omarchy-toggle-nightlight") }
          Tile { icon: "󱐋"; label: "Energia"; sub: root.profileNames[root.st.profile] || root.st.profile; on: root.st.profile === "performance"
            onClicked: root.run("powerprofilesctl set " + root.nextProfile()) }
        }

        SliderRow {
          icon: root.st.muted ? "󰝟" : "󰕾"
          value: root.st.volume
          maximum: 1.0
          onMoved: function(v) { root.run("wpctl set-volume @DEFAULT_AUDIO_SINK@ " + Math.round(v * 100) + "%") }
          onIconClicked: root.run("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle")
        }
        SliderRow {
          icon: "󰃟"
          value: root.st.brightness / 100
          maximum: 1.0
          onMoved: function(v) { root.run("brightnessctl -q set " + Math.max(1, Math.round(v * 100)) + "%") }
        }
      }
    }
  }

  component Tile: Rectangle {
    id: tile
    property string icon: ""
    property string label: ""
    property string sub: ""
    property bool on: false
    signal clicked()
    width: parent ? (parent.width - parent.spacing) / 2 : 100
    height: Style.space(64)
    radius: Style.cornerRadius
    color: on ? Commons.Color.accent : Style.selectedFillFor(root.bar.foreground, Commons.Color.accent)
    Behavior on color { ColorAnimation { duration: Style.duration(180) } }
    readonly property color fg: on ? root.bar.background : root.bar.foreground

    Text {
      id: glyph
      textFormat: Text.PlainText
      text: tile.icon
      color: tile.fg
      font.family: root.bar.fontFamily
      font.pixelSize: Style.font.display
      anchors.left: parent.left
      anchors.leftMargin: Style.space(14)
      anchors.verticalCenter: parent.verticalCenter
    }
    Column {
      anchors.left: glyph.right
      anchors.leftMargin: Style.space(12)
      anchors.right: parent.right
      anchors.rightMargin: Style.space(8)
      anchors.verticalCenter: parent.verticalCenter
      Text { textFormat: Text.PlainText; text: tile.label; color: tile.fg; font.family: root.bar.fontFamily; font.pixelSize: Style.font.body; font.bold: true; elide: Text.ElideRight; width: parent.width }
      Text { textFormat: Text.PlainText; text: tile.sub; color: tile.fg; opacity: 0.75; font.family: root.bar.fontFamily; font.pixelSize: Style.font.caption; elide: Text.ElideRight; width: parent.width }
    }
    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: tile.clicked() }
  }

  component SliderRow: Item {
    id: row
    property string icon: ""
    property alias value: slider.value
    property alias maximum: slider.maximum
    signal moved(real v)
    signal iconClicked()
    width: parent ? parent.width : 100
    height: Style.space(32)

    Text {
      id: rowIcon
      textFormat: Text.PlainText
      text: row.icon
      color: root.bar.foreground
      font.family: root.bar.fontFamily
      font.pixelSize: Style.font.display
      width: Style.space(28)
      anchors.left: parent.left
      anchors.verticalCenter: parent.verticalCenter
      MouseArea { anchors.fill: parent; onClicked: row.iconClicked() }
    }
    PanelSlider {
      id: slider
      bar: root.bar
      anchors.left: rowIcon.right
      anchors.leftMargin: Style.space(8)
      anchors.right: parent.right
      anchors.verticalCenter: parent.verticalCenter
      minimum: 0
      step: 0.01
      onMoved: function(v) { row.moved(v) }
    }
  }
}
