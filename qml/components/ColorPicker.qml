import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import ".."

// Small reusable color swatch button that opens a preset-palette + hex popup.
Rectangle {
  id: root

  property color value: "#ffffff"
  signal colorChosen(color color)

  readonly property var presets: ["#ffffff", "#000000", "#e74c3c", "#e67e22", "#f1c40f", "#2ecc71", "#1abc9c", "#3498db", "#9b59b6", "#fd79a8", Config.noteColor.toString(), Config.textColor.toString()]

  width: 28
  height: 28
  radius: 6
  color: root.value
  border.width: 1
  border.color: Qt.darker(root.value, 1.3)

  MouseArea {
    anchors.fill: parent
    cursorShape: Qt.PointingHandCursor
    onClicked: popup.open()
  }

  Popup {
    id: popup
    x: 0
    y: root.height + 4
    width: 196
    padding: 8
    modal: false
    focus: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent

    contentItem: ColumnLayout {
      spacing: 6

      GridLayout {
        columns: 6
        rowSpacing: 4
        columnSpacing: 4

        Repeater {
          model: root.presets
          delegate: Rectangle {
            required property var modelData
            width: 24
            height: 24
            radius: 4
            color: modelData
            border.width: 1
            border.color: Qt.darker(modelData, 1.3)

            MouseArea {
              anchors.fill: parent
              cursorShape: Qt.PointingHandCursor
              onClicked: {
                root.colorChosen(parent.color);
                popup.close();
              }
            }
          }
        }
      }

      TextField {
        id: hexField
        Layout.fillWidth: true
        placeholderText: "#rrggbb"
        text: root.value.toString()
        selectByMouse: true
        onAccepted: {
          if (/^#[0-9a-fA-F]{6}$/.test(text)) {
            root.colorChosen(text);
            popup.close();
          }
        }
      }
    }
  }
}
