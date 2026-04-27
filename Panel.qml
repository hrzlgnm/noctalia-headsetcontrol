import QtQuick
import QtQuick.Layouts
import QtQuick.Controls 2.5
import Quickshell
import qs.Commons
import qs.Widgets

Item {
  id: root
  property var pluginApi: null
  property ShellScreen screen

  readonly property var mainInstance: pluginApi ? pluginApi.mainInstance : null
  readonly property bool isConnected: mainInstance ? mainInstance.isConnected : false
  readonly property int batteryLevel: mainInstance ? mainInstance.batteryLevel : -1
  readonly property string batteryStatus: mainInstance ? mainInstance.batteryStatus : "BATTERY_UNAVAILABLE"

  function sendCommand(args) {
    var cmdJson = JSON.stringify(["headsetcontrol"].concat(args))
    var p = Qt.createQmlObject(
      'import Quickshell.Io; Process { command: ' + cmdJson + '; running: true; ' +
      'function onFinished() { destroy(); } ' +
      'stdout: StdioCollector { } stderr: StdioCollector { } }',
      root, "panelCmd")
  }

  function batteryColor(level) {
    if (level < 0) return "#666666"
    if (level < 20) return "#ef4444"
    if (level < 50) return "#eab308"
    return "#22c55e"
  }

  Rectangle {
    id: panel
    anchors.fill: parent
    color: "#1e1e2e"
    radius: 12

    Item {
      anchors.fill: parent
      anchors.margins: 16

      ColumnLayout {
        id: col
        anchors.fill: parent
        spacing: 10

        NText {
          text: "HeadsetControl"
          font.pixelSize: 16
          font.weight: Font.Bold
          color: "#ffffff"
        }

        Rectangle { Layout.fillWidth: true; height: 1; color: "#333" }

        NText {
          text: root.isConnected ? "Headset Connected" : "No Headset Detected"
          font.pixelSize: 13
          color: root.isConnected ? "#22c55e" : "#666666"
        }

        RowLayout {
          visible: root.isConnected && root.batteryLevel >= 0
          spacing: 6
          NIcon { icon: "battery"; width: 16; height: 16; color: root.batteryColor(root.batteryLevel) }
          NText {
            text: root.batteryLevel + "% (" + root.batteryStatus + ")"
            font.pixelSize: 13
            color: root.batteryColor(root.batteryLevel)
          }
        }

        Rectangle { Layout.fillWidth: true; height: 1; color: "#333"; visible: root.isConnected }

        NText { text: "Sidetone"; visible: root.isConnected; font.pixelSize: 13; color: "#ffffff"; font.weight: Font.Bold }
        RowLayout {
          visible: root.isConnected; spacing: 6
          Slider {
            id: sidetoneSlider; Layout.fillWidth: true; from: 0; to: 128; stepSize: 1
            value: pluginApi && pluginApi.pluginSettings ? pluginApi.pluginSettings.lastSidetone || 64 : 64
            onMoved: { root.sendCommand(["-s", String(value)]); if (pluginApi) pluginApi.pluginSettings.lastSidetone = Math.round(value) }
          }
          NText { text: Math.round(sidetoneSlider.value); font.pixelSize: 11; color: "#aaa"; Layout.minimumWidth: 30; horizontalAlignment: Text.AlignRight }
        }

        Rectangle { Layout.fillWidth: true; height: 1; color: "#333"; visible: root.isConnected }

        NText { text: "Lights"; visible: root.isConnected; font.pixelSize: 13; color: "#ffffff"; font.weight: Font.Bold }
        RowLayout { visible: root.isConnected; spacing: 8
          NButton { text: "On"; onClicked: root.sendCommand(["-l", "1"]) }
          NButton { text: "Off"; onClicked: root.sendCommand(["-l", "0"]) }
        }

        Rectangle { Layout.fillWidth: true; height: 1; color: "#333"; visible: root.isConnected }

        NText { text: "Auto-Off Timer (min)"; visible: root.isConnected; font.pixelSize: 13; color: "#ffffff"; font.weight: Font.Bold }
        RowLayout { visible: root.isConnected; spacing: 6
          Slider { id: inactiveSlider; Layout.fillWidth: true; from: 0; to: 120; stepSize: 1; value: 30
            onMoved: root.sendCommand(["-i", String(value)]) }
          NText { text: Math.round(inactiveSlider.value); font.pixelSize: 11; color: "#aaa"; Layout.minimumWidth: 30; horizontalAlignment: Text.AlignRight }
        }

        Rectangle { Layout.fillWidth: true; height: 1; color: "#333"; visible: root.isConnected }

        NText { text: "Equalizer Preset"; visible: root.isConnected; font.pixelSize: 13; color: "#ffffff"; font.weight: Font.Bold }
        RowLayout { visible: root.isConnected; spacing: 8
          NButton { text: "0"; onClicked: { root.sendCommand(["-p", "0"]); if (pluginApi) pluginApi.pluginSettings.lastEqPreset = 0 } }
          NButton { text: "1"; onClicked: { root.sendCommand(["-p", "1"]); if (pluginApi) pluginApi.pluginSettings.lastEqPreset = 1 } }
          NButton { text: "2"; onClicked: { root.sendCommand(["-p", "2"]); if (pluginApi) pluginApi.pluginSettings.lastEqPreset = 2 } }
          NButton { text: "3"; onClicked: { root.sendCommand(["-p", "3"]); if (pluginApi) pluginApi.pluginSettings.lastEqPreset = 3 } }
        }

        Rectangle { Layout.fillWidth: true; height: 1; color: "#333"; visible: root.isConnected }

        NText { text: "Voice Prompts"; visible: root.isConnected; font.pixelSize: 13; color: "#ffffff"; font.weight: Font.Bold }
        RowLayout { visible: root.isConnected; spacing: 8
          NButton { text: "Enable"; onClicked: root.sendCommand(["-v", "1"]) }
          NButton { text: "Disable"; onClicked: root.sendCommand(["-v", "0"]) }
        }

        Rectangle { Layout.fillWidth: true; height: 1; color: "#333"; visible: root.isConnected }

        NText { text: "Microphone LED"; visible: root.isConnected; font.pixelSize: 13; color: "#ffffff"; font.weight: Font.Bold }
        RowLayout { visible: root.isConnected; spacing: 6
          Slider { id: micLedSlider; Layout.fillWidth: true; from: 0; to: 100; stepSize: 1; value: 50
            onMoved: root.sendCommand(["--microphone-mute-led-brightness", String(value)]) }
          NText { text: Math.round(micLedSlider.value); font.pixelSize: 11; color: "#aaa"; Layout.minimumWidth: 30; horizontalAlignment: Text.AlignRight }
        }

        Rectangle { Layout.fillWidth: true; height: 1; color: "#333"; visible: root.isConnected }

        NText { text: "Volume Limiter"; visible: root.isConnected; font.pixelSize: 13; color: "#ffffff"; font.weight: Font.Bold }
        RowLayout { visible: root.isConnected; spacing: 8
          NButton { text: "On"; onClicked: root.sendCommand(["--volume-limiter", "1"]) }
          NButton { text: "Off"; onClicked: root.sendCommand(["--volume-limiter", "0"]) }
        }

        Rectangle { Layout.fillWidth: true; height: 1; color: "#333"; visible: root.isConnected }

        NText { text: "Chatmix"; visible: root.isConnected; font.pixelSize: 13; color: "#ffffff"; font.weight: Font.Bold }
        NText {
          visible: root.isConnected
          font.pixelSize: 11; color: "#aaa"
          text: {
            if (!mainInstance) return "N/A"
            var lvl = mainInstance.chatmixLevel
            if (lvl < 0) return "N/A"
            return (lvl > 64 ? "Chat" : "Game") + " (" + lvl + ")"
          }
        }

        Rectangle { Layout.fillWidth: true; height: 1; color: "#333"; visible: root.isConnected }

        NText { text: "Notification Sound"; visible: root.isConnected; font.pixelSize: 13; color: "#ffffff"; font.weight: Font.Bold }
        RowLayout { visible: root.isConnected; spacing: 8
          NButton { text: "0"; onClicked: root.sendCommand(["-n", "0"]) }
          NButton { text: "1"; onClicked: root.sendCommand(["-n", "1"]) }
        }

        Rectangle { Layout.fillWidth: true; height: 1; color: "#333"; visible: root.isConnected }

        NText { text: "Bluetooth"; visible: root.isConnected; font.pixelSize: 13; color: "#ffffff"; font.weight: Font.Bold }
        RowLayout { visible: root.isConnected; spacing: 8
          NButton { text: "Power On: On"; onClicked: root.sendCommand(["--bt-when-powered-on", "1"]) }
          NButton { text: "Power On: Off"; onClicked: root.sendCommand(["--bt-when-powered-on", "0"]) }
        }
        RowLayout { visible: root.isConnected; spacing: 6
          NText { text: "Call Volume"; font.pixelSize: 11; color: "#aaa" }
          Slider { id: btVolSlider; Layout.fillWidth: true; from: 0; to: 100; stepSize: 1; value: 50
            onMoved: root.sendCommand(["--bt-call-volume", String(value)]) }
        }

        Rectangle { Layout.fillWidth: true; height: 1; color: "#333"; visible: root.isConnected }

        NButton {
          text: "Refresh Status"
          onClicked: {
            if (mainInstance) {
              mainInstance.updateAll()
            }
          }
          Layout.alignment: Qt.AlignHCenter
        }
      }
    }
  }
}
