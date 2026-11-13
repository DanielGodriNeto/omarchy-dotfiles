import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick
import qs.Commons
import qs.Commons as Commons
import qs.Ui

// Painting panel: the current painting, like / dislike with the reasons that
// should (or should not) teach the taste model, change now, time-of-day switch.
// Logic lives in ~/.local/bin/painting-theme.
Item {
  id: root

  property var shell: null
  property var manifest: null
  property bool opened: false

  property string title: ""
  property string artist: ""
  property string genre: ""
  property bool byTime: false
  property int myRating: 0          // 1, -1 or 0
  property string stage: "idle"     // idle | like | dislike
  property var picked: []           // reason ids chosen in the current stage
  property int previewStamp: 0
  property bool busy: false

  readonly property color cardColor: Commons.Color.menu.background
  readonly property color textColor: Commons.Color.menu.text
  readonly property color accent: Commons.Color.accent
  readonly property int radius: Style.cornerRadius
  readonly property string home: Quickshell.env("HOME")
  readonly property var reasons: [
    { id: "cores", label: "Cores" }, { id: "genero", label: "Gênero" }, { id: "estilo", label: "Estilo" },
    { id: "autor", label: "Autor" }, { id: "qualidade", label: "Qualidade" }
  ]

  function open(payloadJson) {
    root.stage = "idle"
    root.picked = []
    root.opened = true
    root.refresh()
    Qt.callLater(function() { keys.forceActiveFocus() })
  }

  function dismiss() {
    root.opened = false
    if (root.shell && typeof root.shell.hide === "function")
      root.shell.hide((root.manifest && root.manifest.id) || "mancato.painting")
  }

  function toggle() {
    if (root.opened) root.dismiss()
    else root.open("{}")
  }

  function refresh() { if (!statusProc.running) statusProc.running = true }

  function cleanTitle(raw) {
    var t = String(raw || "").replace(/\.(jpe?g|png|webp)$/i, "").replace(/_/g, " ").trim()
    return t.length > 80 ? t.slice(0, 77) + "…" : t
  }

  function togglePick(id) {
    var next = root.picked.slice()
    var i = next.indexOf(id)
    if (i >= 0) next.splice(i, 1)
    else {
      if (id === "imagem") next = []
      else next = next.filter(function(x) { return x !== "imagem" })
      next.push(id)
    }
    root.picked = next
  }

  function confirmRating() {
    var verb = root.stage === "like" ? "like" : "dislike"
    var args = ["painting-theme", verb].concat(root.picked)
    root.stage = "idle"
    rateProc.command = args
    rateProc.after = verb === "dislike"
    rateProc.running = true
  }

  Process {
    id: statusProc
    command: ["painting-theme", "status"]
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: {
        try {
          var s = JSON.parse(text)
          root.title = root.cleanTitle(s.title)
          root.artist = (s.features && s.features.artist) || (s.features && s.features.cat) || ""
          root.genre = (s.features && s.features.genre) || ""
          root.byTime = !!(s.config && s.config.by_time)
          root.myRating = s.rating ? s.rating.v : 0
          root.previewStamp++
        } catch (e) {}
      }
    }
  }

  Process {
    id: rateProc
    property bool after: false
    onRunningChanged: if (!running) {
      if (after) { after = false; nextProc.running = true }
      else root.refresh()
    }
  }

  Process {
    id: nextProc
    command: ["painting-theme", "next"]
    onRunningChanged: { root.busy = running; if (!running) root.refresh() }
  }

  Process {
    id: configProc
    onRunningChanged: if (!running) root.refresh()
  }

  Process {
    id: chooseProc
    command: ["painting-theme", "choose"]
    onRunningChanged: if (!running) root.refresh()
  }

  component Chip: Rectangle {
    id: chip
    property string label: ""
    property bool on: false
    property bool danger: false
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

  OverlayWindow {
    id: panel
    shown: root.opened
    WlrLayershell.namespace: "mancato-painting"

    Rectangle { anchors.fill: parent; color: Qt.alpha(Commons.Color.background, 0.5) }
    MouseArea { anchors.fill: parent; onClicked: root.dismiss() }

    Item {
      id: keys
      anchors.fill: parent
      focus: true
      Keys.priority: Keys.BeforeItem
      Keys.onPressed: function(event) {
        if (event.key === Qt.Key_Escape) {
          if (root.stage !== "idle") root.stage = "idle"
          else root.dismiss()
          event.accepted = true
        }
      }
    }

    Rectangle {
      id: card
      anchors.top: parent.top
      anchors.right: parent.right
      anchors.topMargin: Style.space(48)
      anchors.rightMargin: Style.space(12)
      width: Style.space(380)
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
        spacing: Style.space(10)

        Rectangle {
          width: parent.width
          height: width * 9 / 16
          radius: Math.max(4, root.radius - 2)
          clip: true
          color: Qt.alpha(root.textColor, 0.08)
          Image {
            anchors.fill: parent
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
            cache: false
            source: "file://" + root.home + "/.config/omarchy/themes/pintura/preview.png?" + root.previewStamp
          }
        }

        Column {
          width: parent.width
          spacing: 2
          Text {
            width: parent.width
            text: root.title
            elide: Text.ElideRight
            textFormat: Text.PlainText
            color: root.textColor
            font.family: Style.font.menuFamily
            font.pixelSize: Style.font.title
          }
          Text {
            width: parent.width
            text: (root.artist ? root.artist : "") + (root.genre ? "  ·  " + root.genre : "")
            elide: Text.ElideRight
            textFormat: Text.PlainText
            color: root.accent
            opacity: 0.9
            font.family: Style.font.menuFamily
            font.pixelSize: Style.font.caption + 1
          }
        }

        Row {
          spacing: Style.space(8)
          Chip {
            label: "Gostei"
            on: root.stage === "like" || (root.stage === "idle" && root.myRating === 1)
            onClicked: { root.picked = []; root.stage = "like" }
          }
          Chip {
            label: "Não gostei"
            on: root.stage === "dislike" || (root.stage === "idle" && root.myRating === -1)
            onClicked: { root.picked = []; root.stage = "dislike" }
          }
        }

        Column {
          visible: root.stage !== "idle"
          width: parent.width
          spacing: Style.space(8)
          Text {
            text: root.stage === "like" ? "O que você gostou? (nada marcado = tudo)" : "Por que não gostou? (nada marcado = tudo)"
            color: root.textColor
            opacity: 0.75
            font.family: Style.font.menuFamily
            font.pixelSize: Style.font.caption + 1
          }
          Flow {
            width: parent.width
            spacing: Style.space(6)
            Repeater {
              model: root.reasons
              delegate: Chip {
                required property var modelData
                label: modelData.label
                on: root.picked.indexOf(modelData.id) >= 0
                onClicked: root.togglePick(modelData.id)
              }
            }
            Chip {
              visible: root.stage === "dislike"
              label: "Só essa imagem"
              on: root.picked.indexOf("imagem") >= 0
              onClicked: root.togglePick("imagem")
            }
          }
          Chip {
            label: root.stage === "dislike" ? "Confirmar e trocar" : "Confirmar"
            on: true
            onClicked: root.confirmRating()
          }
        }

        Rectangle { width: parent.width; height: 1; color: Qt.alpha(root.textColor, 0.14) }

        Flow {
          width: parent.width
          spacing: Style.space(6)
          Chip {
            label: root.busy ? "Trocando…" : "Trocar agora"
            onClicked: if (!nextProc.running) nextProc.running = true
          }
          Chip {
            label: "Escolher…"
            onClicked: { chooseProc.running = true; root.dismiss() }
          }
          Chip {
            label: "Por horário"
            on: root.byTime
            onClicked: {
              configProc.command = ["painting-theme", "config", "by_time", root.byTime ? "off" : "on"]
              configProc.running = true
            }
          }
        }
      }
    }
  }
}
