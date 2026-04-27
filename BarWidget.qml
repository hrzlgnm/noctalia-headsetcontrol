import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.Commons
import qs.Widgets

Item {
  id: root
  property var pluginApi: null
  property ShellScreen screen
  property string widgetId: ""
  property string section: ""
  property int sectionWidgetIndex: -1
  property int sectionWidgetsCount: 0

  readonly property string screenName: screen?.name ?? ""
  readonly property real barFontSize: 14

  readonly property real contentWidth: content.implicitWidth + 8 * 2
  readonly property real contentHeight: 32

  implicitWidth: contentWidth
  implicitHeight: contentHeight

  readonly property int batteryLevel: pluginApi && pluginApi.mainInstance ? pluginApi.mainInstance.batteryLevel : -1
  readonly property bool isConnected: pluginApi && pluginApi.mainInstance ? pluginApi.mainInstance.isConnected : false
  readonly property bool showPercentage: pluginApi && pluginApi.pluginSettings ? pluginApi.pluginSettings.barShowPercentage !== false : true

  function batteryColor(level) {
    if (level < 0) return "#666666"
    if (level < 20) return "#ef4444"
    if (level < 50) return "#eab308"
    return "#22c55e"
  }

  Rectangle {
    id: visualCapsule
    anchors.fill: parent
    color: mouseArea.containsMouse ? Qt.rgba(1,1,1,0.1) : Qt.rgba(1,1,1,0.05)
    radius: 8
    border.color: Qt.rgba(1,1,1,0.1)
    border.width: 1

    RowLayout {
      id: content
      anchors.centerIn: parent
      spacing: 6

      NIcon {
        icon: root.isConnected ? "headset" : "headset-off"
        width: root.barFontSize
        height: root.barFontSize
        color: root.isConnected ? "#ffffff" : "#666666"
      }

      NText {
        text: root.isConnected ? (root.batteryLevel >= 0 ? root.batteryLevel + "%" : "...") : "N/A"
        font.pixelSize: root.barFontSize * 0.82
        color: root.isConnected ? root.batteryColor(root.batteryLevel) : "#666666"
        visible: root.showPercentage
        Layout.alignment: Qt.AlignVCenter
      }
    }
  }

  MouseArea {
    id: mouseArea
    anchors.fill: parent
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor
    onClicked: {
      if (pluginApi) pluginApi.togglePanel(root.screen)
    }
  }
}
