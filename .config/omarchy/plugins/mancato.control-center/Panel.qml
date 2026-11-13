import QtQuick
import Quickshell.Io
import qs.Ui
import qs.Commons
import qs.Commons as Commons

Panel {
  id: root
  moduleName: "mancato.control-center"
  ipcTarget: "mancato.control-center"

  property var st: ({ wifi: false, bt: false, night: false, dnd: false, profile: "", volume: 0, muted: false, brightness: 50, radius: 12 })
  // Corner radius presets: what they are called and the radius they set.
  readonly property var radiusPresets: [{ name: "Retos", value: 0 }, { name: "Suaves", value: 6 }, { name: "Padrão", value: 12 }, { name: "Redondos", value: 18 }]
  function setRadius(value) {
    var next = JSON.parse(JSON.stringify(st))
    next.radius = value
    st = next
    run("corner-radius " + value)
  }
  function stepRadius(direction) {
    var index = 0
    for (var i = 0; i < radiusPresets.length; i++) if (radiusPresets[i].value <= st.radius) index = i
    var target = Math.max(0, Math.min(radiusPresets.length - 1, index + direction))
    if (target !== index) setRadius(radiusPresets[target].value)
  }
  readonly property var profileOrder: ["power-saver", "balanced", "performance"]
  readonly property var profileNames: ({ "power-saver": "Economia", "balanced": "Equilibrado", "performance": "Desempenho" })

  // Cursor do teclado: 0-4 tiles (2 colunas, o 5o ocupa a linha), 5 volume, 6 brilho, 7 cantos
  property int cursor: -1
  onOpenedChanged: if (!opened) cursor = -1
  function move(dx, dy) {
    if (cursor < 0) { cursor = 0; return }
    if (dy > 0) cursor = cursor <= 1 ? cursor + 2 : (cursor <= 3 ? 4 : Math.min(7, cursor + 1))
    else if (dy < 0) cursor = cursor >= 5 ? cursor - 1 : (cursor === 4 ? 2 : (cursor >= 2 ? cursor - 2 : cursor))
    else if (cursor <= 3) cursor = cursor ^ 1
    else if (cursor === 5) run("wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%" + (dx > 0 ? "+" : "-"))
    else if (cursor === 6) run("brightnessctl -q set 5%" + (dx > 0 ? "+" : "-"))
    else if (cursor === 7) stepRadius(dx > 0 ? 1 : -1)
  }
  function activate() {
    if (cursor === 0) run("nmcli radio wifi " + (st.wifi ? "off" : "on"))
    else if (cursor === 1) run("bluetoothctl power " + (st.bt ? "off" : "on"))
    else if (cursor === 2) run("omarchy-toggle-nightlight")
    else if (cursor === 3) run("powerprofilesctl set " + nextProfile())
    else if (cursor === 4) run("omarchy-toggle-notification-silencing")
    else if (cursor === 5) run("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle")
  }
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

  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  BarIconButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: "󰒓"
    slotSize: Style.bar.statusSlot
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
      onMoveRequested: function(dx, dy) { root.move(dx, dy) }
      onActivateRequested: root.activate()

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

          Tile { idx: 0; icon: "󰖩"; label: "Wi-Fi"; sub: root.st.wifi ? "Ligado" : "Desligado"; on: root.st.wifi
            onClicked: root.run("nmcli radio wifi " + (root.st.wifi ? "off" : "on")) }
          Tile { idx: 1; icon: "󰂯"; label: "Bluetooth"; sub: root.st.bt ? "Ligado" : "Desligado"; on: root.st.bt
            onClicked: root.run("bluetoothctl power " + (root.st.bt ? "off" : "on")) }
          Tile { idx: 2; icon: "󰖔"; label: "Luz noturna"; sub: root.st.night ? "Ligada" : "Desligada"; on: root.st.night
            onClicked: root.run("omarchy-toggle-nightlight") }
          Tile { idx: 3; icon: "󱐋"; label: "Energia"; sub: root.profileNames[root.st.profile] || root.st.profile; on: root.st.profile === "performance"
            onClicked: root.run("powerprofilesctl set " + root.nextProfile()) }
        }

        Tile { idx: 4; wide: true; icon: "󰂛"; label: "Não perturbe"; sub: root.st.dnd ? "Notificações silenciadas" : "Notificações ativas"; on: root.st.dnd
          onClicked: root.run("omarchy-toggle-notification-silencing") }

        SliderRow {
          idx: 5
          icon: root.st.muted ? "󰝟" : "󰕾"
          value: root.st.volume
          maximum: 1.0
          onMoved: function(v) { root.run("wpctl set-volume @DEFAULT_AUDIO_SINK@ " + Math.round(v * 100) + "%") }
          onIconClicked: root.run("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle")
        }
        SliderRow {
          idx: 6
          icon: "󰃟"
          value: root.st.brightness / 100
          maximum: 1.0
          onMoved: function(v) { root.run("brightnessctl -q set " + Math.max(1, Math.round(v * 100)) + "%") }
        }

        // Cantos: quatro predefinicoes; cada chip mostra o raio que aplica.
        Item {
          width: parent.width
          height: Style.space(52)

          Rectangle {
            anchors.fill: parent
            radius: Style.cornerRadius
            color: "transparent"
            border.width: root.cursor === 7 ? 2 : 0
            border.color: Commons.Color.accent
          }

          Text {
            id: radiusLabel
            textFormat: Text.PlainText
            text: "Cantos"
            color: root.bar.foreground
            opacity: 0.75
            font.family: root.bar.fontFamily
            font.pixelSize: Style.font.caption
            anchors.left: parent.left
            anchors.leftMargin: Style.space(4)
            anchors.top: parent.top
          }

          Row {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            spacing: Style.space(6)

            Repeater {
              model: root.radiusPresets

              delegate: Rectangle {
                id: chip
                required property var modelData
                readonly property bool current: root.st.radius === modelData.value
                width: (parent.width - parent.spacing * 3) / 4
                height: Style.space(30)
                radius: Math.min(Style.space(modelData.value), height / 2)
                color: current ? Commons.Color.accent : Style.selectedFillFor(root.bar.foreground, Commons.Color.accent)
                Behavior on color { ColorAnimation { duration: Style.duration(180) } }

                Text {
                  anchors.centerIn: parent
                  textFormat: Text.PlainText
                  text: chip.modelData.name
                  color: chip.current ? root.bar.background : root.bar.foreground
                  font.family: root.bar.fontFamily
                  font.pixelSize: Style.font.caption
                  font.bold: chip.current
                }
                MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: root.setRadius(chip.modelData.value) }
              }
            }
          }
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
    property int idx: -1
    property bool wide: false
    signal clicked()
    width: parent ? (wide ? parent.width : (parent.width - parent.spacing) / 2) : 100
    border.width: root.cursor === idx ? 2 : 0
    border.color: Commons.Color.accent
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
    property int idx: -1
    signal moved(real v)
    signal iconClicked()
    width: parent ? parent.width : 100
    height: Style.space(32)
    Rectangle {
      anchors.fill: parent
      radius: Style.cornerRadius
      color: "transparent"
      border.width: root.cursor === row.idx ? 2 : 0
      border.color: Commons.Color.accent
    }

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
