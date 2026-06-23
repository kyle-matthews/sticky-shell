import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import ".."

// Toggleable manager window: list every note (shown or hidden), create new
// ones, toggle visibility, or delete permanently. Closing this window never
// touches the floating notes themselves.
ApplicationWindow {
  id: root

  width: 380
  height: 480
  minimumWidth: 300
  minimumHeight: 240
  title: "Sticky Notes Manager"
  visible: false

  property string confirmingDeleteId: ""

  function toggle() {
    root.visible = !root.visible;
    if (root.visible) {
      root.raise();
      root.requestActivate();
    }
  }

  function show_() {
    root.visible = true;
    root.raise();
    root.requestActivate();
  }

  function hideWindow() {
    root.visible = false;
  }

  // Never let the window's own close button quit the whole app - just hide it.
  onClosing: function (closeEvent) {
    closeEvent.accepted = false;
    root.visible = false;
  }

  ColumnLayout {
    anchors.fill: parent
    anchors.margins: 12
    spacing: 12

    RowLayout {
      Layout.fillWidth: true

      Label {
        text: "Sticky Notes"
        font.pixelSize: 16
        font.bold: true
        Layout.fillWidth: true
      }

      Button {
        text: "+ New Note"
        onClicked: NotesStore.createNote("")
      }
    }

    ScrollView {
      id: scrollView
      Layout.fillWidth: true
      Layout.fillHeight: true
      clip: true

      ColumnLayout {
        width: scrollView.availableWidth
        spacing: 6

        Repeater {
          model: NotesStore.notes

          delegate: Rectangle {
            id: rowDelegate
            required property var modelData

            Layout.fillWidth: true
            implicitHeight: rowLayout.implicitHeight + 12
            radius: 6
            color: Qt.rgba(0.5, 0.5, 0.5, 0.08)

            RowLayout {
              id: rowLayout
              anchors.fill: parent
              anchors.margins: 6
              spacing: 6

              ColumnLayout {
                Layout.fillWidth: true
                spacing: 0

                Label {
                  Layout.fillWidth: true
                  elide: Text.ElideRight
                  text: (rowDelegate.modelData.text && rowDelegate.modelData.text.trim().length > 0) ? rowDelegate.modelData.text.split("\n")[0].slice(0, 40) : "(empty note)"
                }

                Label {
                  font.pixelSize: 10
                  opacity: 0.7
                  text: new Date(rowDelegate.modelData.createdAt).toLocaleString()
                }
              }

              Button {
                text: rowDelegate.modelData.visible ? "Hide" : "Show"
                onClicked: NotesStore.setVisible(rowDelegate.modelData.id, !rowDelegate.modelData.visible)
              }

              Button {
                text: root.confirmingDeleteId === rowDelegate.modelData.id ? "Confirm?" : "Delete"
                onClicked: {
                  if (root.confirmingDeleteId === rowDelegate.modelData.id) {
                    NotesStore.deleteNote(rowDelegate.modelData.id);
                    root.confirmingDeleteId = "";
                  } else {
                    root.confirmingDeleteId = rowDelegate.modelData.id;
                  }
                }
              }
            }
          }
        }

        Label {
          visible: NotesStore.notes.length === 0
          Layout.fillWidth: true
          wrapMode: Text.WordWrap
          opacity: 0.7
          text: "No notes yet. Click \"+ New Note\" to create one."
        }
      }
    }
  }
}
