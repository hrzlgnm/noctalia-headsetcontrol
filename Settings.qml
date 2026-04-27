import QtQuick
import QtQuick.Layouts
import QtQuick.Controls 2.5
import Quickshell
import qs.Commons
import qs.Widgets

Item {
  id: root
  property var pluginApi: null

  implicitWidth: 500
  implicitHeight: col.implicitHeight + 16 * 2

  ColumnLayout {
    id: col
    anchors.fill: parent
    spacing: 10

    NText {
      text: "HeadsetControl Settings"
      font.pixelSize: 16
      font.weight: Font.Bold
      color: "#ffffff"
    }

    Rectangle { Layout.fillWidth: true; height: 1; color: "#333" }

    NText { text: "Polling Interval (seconds, 0 to disable)"; font.pixelSize: 13; color: "#ffffff" }
    RowLayout { spacing: 6
      Slider { id: pollSlider; Layout.fillWidth: true; from: 0; to: 300; stepSize: 5
        value: pluginApi && pluginApi.pluginSettings ? pluginApi.pluginSettings.pollingInterval || 30 : 30
        onMoved: { if (pluginApi) { pluginApi.pluginSettings.pollingInterval = Math.round(value); pluginApi.saveSettings() } }
      }
      NText { text: Math.round(pollSlider.value) + "s"; font.pixelSize: 11; color: "#aaa"; Layout.minimumWidth: 40; horizontalAlignment: Text.AlignRight }
    }

    Rectangle { Layout.fillWidth: true; height: 1; color: "#333" }

    NCheckbox {
      id: showPctCheckbox
      text: "Show battery percentage in bar"
      checked: pluginApi && pluginApi.pluginSettings ? pluginApi.pluginSettings.barShowPercentage !== false : true
      onToggled: { if (pluginApi) { pluginApi.pluginSettings.barShowPercentage = checked; pluginApi.saveSettings() } }
    }

    Rectangle { Layout.fillWidth: true; height: 1; color: "#333" }

    NText { text: "Default Sidetone Level (0-128)"; font.pixelSize: 13; color: "#ffffff" }
    RowLayout { spacing: 6
      Slider { id: sidetoneSlider; Layout.fillWidth: true; from: 0; to: 128; stepSize: 1
        value: pluginApi && pluginApi.pluginSettings ? pluginApi.pluginSettings.lastSidetone || 64 : 64
        onMoved: { if (pluginApi) { pluginApi.pluginSettings.lastSidetone = Math.round(value); pluginApi.saveSettings() } }
      }
      NText { text: Math.round(sidetoneSlider.value); font.pixelSize: 11; color: "#aaa"; Layout.minimumWidth: 30; horizontalAlignment: Text.AlignRight }
    }

    Rectangle { Layout.fillWidth: true; height: 1; color: "#333" }

    NText { text: "Default EQ Preset (0-3)"; font.pixelSize: 13; color: "#ffffff" }
    RowLayout { spacing: 8
      property int currentPreset: pluginApi && pluginApi.pluginSettings ? pluginApi.pluginSettings.lastEqPreset || 0 : 0
      NButton { text: "0"; highlighted: parent.currentPreset === 0; onClicked: { if (pluginApi) { pluginApi.pluginSettings.lastEqPreset = 0; pluginApi.saveSettings() } } }
      NButton { text: "1"; highlighted: parent.currentPreset === 1; onClicked: { if (pluginApi) { pluginApi.pluginSettings.lastEqPreset = 1; pluginApi.saveSettings() } } }
      NButton { text: "2"; highlighted: parent.currentPreset === 2; onClicked: { if (pluginApi) { pluginApi.pluginSettings.lastEqPreset = 2; pluginApi.saveSettings() } } }
      NButton { text: "3"; highlighted: parent.currentPreset === 3; onClicked: { if (pluginApi) { pluginApi.pluginSettings.lastEqPreset = 3; pluginApi.saveSettings() } } }
    }

    Rectangle { Layout.fillWidth: true; height: 1; color: "#333" }

    NButton {
      text: "Apply Default Sidetone Now"
      onClicked: {
        if (pluginApi && pluginApi.mainInstance) {
          var lvl = pluginApi.pluginSettings.lastSidetone || 64
          var p = Qt.createQmlObject(
            'import Quickshell.Io; Process { command: ["headsetcontrol", "-s", "' + lvl + '"]; running: true; ' +
            'function onFinished() { destroy(); } stdout: StdioCollector { } stderr: StdioCollector { } }',
            root, "applySidetone")
        }
      }
      Layout.alignment: Qt.AlignHCenter
    }
  }
}
