import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import ".."

// Per-note settings: font family/size + background/text color.
// Emits apply(patch) for the caller to persist through NotesStore.
Popup {
  id: root

  property var note: ({})

  signal apply(var patch)

  width: 230
  padding: 12
  modal: false
  focus: true
  closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent

  readonly property var fontChoices: [{
      "key": "",
      "text": "Theme Default"
    }, {
      "key": "sans-serif",
      "text": "Sans Serif"
    }, {
      "key": "serif",
      "text": "Serif"
    }, {
      "key": "monospace",
      "text": "Monospace"
    }, {
      "key": "cursive",
      "text": "Handwriting"
    }]

  function indexOfFontKey(key) {
    for (var i = 0; i < fontChoices.length; i++) {
      if (fontChoices[i].key === key)
        return i;
    }
    return 0;
  }

  contentItem: ColumnLayout {
    spacing: 6

    Label {
      text: "Note settings"
      font.bold: true
      Layout.fillWidth: true
    }

    Label {
      text: "Font"
      font.pixelSize: 10
      opacity: 0.7
    }

    ComboBox {
      Layout.fillWidth: true
      textRole: "text"
      valueRole: "key"
      model: root.fontChoices
      currentIndex: root.indexOfFontKey(root.note.fontFamily || "")
      onActivated: root.apply({
                                 "fontFamily": currentValue
                               })
    }

    Label {
      text: "Font size"
      font.pixelSize: 10
      opacity: 0.7
    }

    SpinBox {
      Layout.fillWidth: true
      from: 8
      to: 48
      value: root.note.fontSize || Config.fontSize
      onValueModified: root.apply({
                                     "fontSize": value
                                   })
    }

    RowLayout {
      Layout.fillWidth: true
      spacing: 12

      ColumnLayout {
        spacing: 2
        Label {
          text: "Background"
          font.pixelSize: 10
          opacity: 0.7
        }
        ColorPicker {
          value: root.note.bgColor || Config.noteColor
          onColorChosen: color => root.apply({
                                                "bgColor": color.toString()
                                              })
        }
      }

      ColumnLayout {
        spacing: 2
        Label {
          text: "Text"
          font.pixelSize: 10
          opacity: 0.7
        }
        ColorPicker {
          value: root.note.textColor || Config.textColor
          onColorChosen: color => root.apply({
                                                 "textColor": color.toString()
                                               })
        }
      }
    }

    Button {
      Layout.fillWidth: true
      text: "Reset to defaults"
      onClicked: root.apply({
                               "bgColor": "",
                               "textColor": "",
                               "fontFamily": "",
                               "fontSize": 0
                             })
    }
  }
}
