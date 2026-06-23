import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import ".."

// A single sticky note's content. The hosting PanelWindow (created in
// shell.qml) owns the actual window geometry; this component only reports
// drag/resize deltas and persists through NotesStore once an interaction ends.
Item {
  id: note

  required property string noteId

  readonly property var noteData: NotesStore.getNote(noteId) || ({})

  readonly property color effectiveBgColor: noteData.bgColor ? noteData.bgColor : Config.noteColor
  readonly property color effectiveTextColor: noteData.textColor ? noteData.textColor : Config.textColor
  readonly property string effectiveFontFamily: noteData.fontFamily ? noteData.fontFamily : Config.fontFamily
  readonly property real effectiveFontSize: noteData.fontSize || Config.fontSize

  signal moved(real dx, real dy)
  signal moveFinished
  signal resized(real dw, real dh)
  signal resizeFinished
  signal hideRequested

  Rectangle {
    id: card
    anchors.fill: parent
    radius: 8
    color: note.effectiveBgColor
    border.width: 1
    border.color: Qt.darker(note.effectiveBgColor, 1.2)
    clip: true

    ColumnLayout {
      anchors.fill: parent
      spacing: 0

      // Title bar: drag handle + hide + settings
      Item {
        id: titleBar
        Layout.fillWidth: true
        Layout.preferredHeight: 30

        MouseArea {
          id: dragArea
          anchors.fill: parent
          anchors.rightMargin: actionsRow.width + 6
          cursorShape: Qt.OpenHandCursor
          property point lastPos: Qt.point(0, 0)

          onPressed: mouse => {
                       lastPos = mapToGlobal(mouse.x, mouse.y);
                       cursorShape = Qt.ClosedHandCursor;
                     }
          onPositionChanged: mouse => {
                                if (pressed) {
                                  var current = mapToGlobal(mouse.x, mouse.y);
                                  note.moved(current.x - lastPos.x, current.y - lastPos.y);
                                  lastPos = current;
                                }
                              }
          onReleased: {
            cursorShape = Qt.OpenHandCursor;
            note.moveFinished();
          }
          onCanceled: note.moveFinished()
        }

        RowLayout {
          id: actionsRow
          anchors.right: parent.right
          anchors.top: parent.top
          anchors.bottom: parent.bottom
          anchors.rightMargin: 4
          spacing: 2

          Button {
            id: settingsButton
            text: "⚙"
            flat: true
            implicitWidth: 26
            implicitHeight: 26
            contentItem: Text {
              text: settingsButton.text
              color: note.effectiveTextColor
              horizontalAlignment: Text.AlignHCenter
              verticalAlignment: Text.AlignVCenter
            }
            background: Rectangle {
              color: "transparent"
            }
            onClicked: settingsPopover.visible ? settingsPopover.close() : settingsPopover.open()
          }

          Button {
            text: "Hide"
            flat: true
            implicitHeight: 26
            contentItem: Text {
              text: "Hide"
              color: note.effectiveTextColor
              font.pixelSize: 10
              horizontalAlignment: Text.AlignHCenter
              verticalAlignment: Text.AlignVCenter
            }
            background: Rectangle {
              color: "transparent"
            }
            ToolTip.visible: hovered
            ToolTip.text: "Hide (note is kept — reopen from the Notes Manager)"
            onClicked: note.hideRequested()
          }
        }
      }

      Rectangle {
        Layout.fillWidth: true
        height: 1
        color: Qt.alpha(note.effectiveTextColor, 0.15)
      }

      // Text content
      Flickable {
        id: flick
        Layout.fillWidth: true
        Layout.fillHeight: true
        contentWidth: width
        contentHeight: textEdit.implicitHeight
        clip: true
        boundsBehavior: Flickable.StopAtBounds

        TextEdit {
          id: textEdit
          width: flick.width
          padding: 9
          text: note.noteData.text || ""
          color: note.effectiveTextColor
          font.family: note.effectiveFontFamily
          font.pixelSize: note.effectiveFontSize
          wrapMode: TextEdit.Wrap
          selectByMouse: true

          property string lastSavedText: note.noteData.text || ""

          onTextChanged: saveDebounce.restart()

          Timer {
            id: saveDebounce
            interval: 500
            onTriggered: {
              if (textEdit.text !== textEdit.lastSavedText) {
                textEdit.lastSavedText = textEdit.text;
                NotesStore.updateNote(note.noteId, {
                                         "text": textEdit.text
                                       });
              }
            }
          }

          // Reload text if it changes externally (e.g. another window/session)
          Connections {
            target: note
            function onNoteDataChanged() {
              if (note.noteData.text !== undefined && note.noteData.text !== textEdit.text && !textEdit.activeFocus) {
                textEdit.text = note.noteData.text;
                textEdit.lastSavedText = note.noteData.text;
              }
            }
          }
        }
      }
    }
  }

  // Resize grip, bottom-right corner
  MouseArea {
    id: resizeArea
    width: 16
    height: 16
    anchors.right: parent.right
    anchors.bottom: parent.bottom
    cursorShape: Qt.SizeFDiagCursor
    property point lastPos: Qt.point(0, 0)

    onPressed: mouse => {
                 lastPos = mapToGlobal(mouse.x, mouse.y);
               }
    onPositionChanged: mouse => {
                          if (pressed) {
                            var current = mapToGlobal(mouse.x, mouse.y);
                            note.resized(current.x - lastPos.x, current.y - lastPos.y);
                            lastPos = current;
                          }
                        }
    onReleased: note.resizeFinished()
    onCanceled: note.resizeFinished()

    Text {
      anchors.centerIn: parent
      text: "◢"
      color: Qt.alpha(note.effectiveTextColor, 0.5)
      font.pixelSize: 10
    }
  }

  SettingsPopover {
    id: settingsPopover
    parent: titleBar
    x: titleBar.width - width
    y: titleBar.height
    note: note.noteData
    onApply: patch => NotesStore.updateNote(note.noteId, patch)
  }
}
