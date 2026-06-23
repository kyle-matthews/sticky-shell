// shell.qml — entry point for quickshell-stickynotes
// Run standalone with: qs -p /path/to/this/qml/dir
// Or, once installed: qs -c quickshell-stickynotes
//
// Toggle the manager from anywhere with:
//   qs -c quickshell-stickynotes ipc call manager toggle
// Create a new note with:
//   qs -c quickshell-stickynotes ipc call notes create
// Toggle all notes between sitting on the desktop (below normal windows)
// and floating above them with:
//   qs -c quickshell-stickynotes ipc call notes toggleLayer

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import "components"

ShellRoot {
  id: root

  readonly property var allScreenNames: Quickshell.screens.map(function (s) {
    return s.name;
  })

  // Global toggle: false = notes sit on the desktop (below normal windows),
  // true = notes float above normal windows. Session-only by design - notes
  // always start tucked on the desktop on launch.
  property bool notesOnTop: false

  function createNoteOnPrimaryScreen() {
    var s = Quickshell.screens[0];
    NotesStore.createNote(s ? s.name : "");
  }

  Component.onCompleted: console.log("quickshell-stickynotes loaded")

  NotesManager {
    id: managerWindow
  }

  IpcHandler {
    target: "manager"

    function toggle() {
      managerWindow.toggle();
    }

    function show() {
      managerWindow.show_();
    }

    function hide() {
      managerWindow.hideWindow();
    }
  }

  IpcHandler {
    target: "notes"

    function create() {
      root.createNoteOnPrimaryScreen();
    }

    function toggleLayer() {
      root.notesOnTop = !root.notesOnTop;
    }
  }

  // One independent floating PanelWindow per visible note, per screen.
  Variants {
    model: Quickshell.screens

    delegate: Item {
      id: screenDelegate
      required property var modelData

      readonly property var screenNotes: NotesStore.notes.filter(function (n) {
        if (!n.visible)
          return false;
        if (n.screen === modelData.name)
          return true;
        // Orphaned note (its monitor got unplugged/renamed): show on the primary screen.
        return root.allScreenNames.indexOf(n.screen) === -1 && modelData === Quickshell.screens[0];
      })

      Repeater {
        model: screenDelegate.screenNotes

        delegate: Loader {
          id: noteLoader
          required property var modelData
          active: true

          sourceComponent: PanelWindow {
            id: noteWindow
            screen: screenDelegate.modelData
            color: "transparent"

            readonly property string noteId: noteLoader.modelData.id
            property var noteRecord: noteLoader.modelData

            property bool isDragging: false
            property bool isResizing: false

            property real liveX: noteRecord.x
            property real liveY: noteRecord.y
            property real liveWidth: noteRecord.width
            property real liveHeight: noteRecord.height

            onNoteRecordChanged: {
              if (!isDragging) {
                liveX = noteRecord.x;
                liveY = noteRecord.y;
              }
              if (!isResizing) {
                liveWidth = noteRecord.width;
                liveHeight = noteRecord.height;
              }
            }

            WlrLayershell.namespace: "quickshell-stickynotes-" + noteId
            WlrLayershell.layer: root.notesOnTop ? WlrLayer.Top : WlrLayer.Bottom
            WlrLayershell.exclusionMode: ExclusionMode.Ignore
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

            anchors.top: true
            anchors.left: true
            margins.top: liveY
            margins.left: liveX
            implicitWidth: liveWidth
            implicitHeight: liveHeight

            Note {
              anchors.fill: parent
              noteId: noteWindow.noteId

              onMoved: (dx, dy) => {
                noteWindow.isDragging = true;
                noteWindow.liveX += dx;
                noteWindow.liveY += dy;
              }
              onMoveFinished: {
                noteWindow.isDragging = false;
                NotesStore.updateNote(noteWindow.noteId, {
                                         "x": Math.round(noteWindow.liveX),
                                         "y": Math.round(noteWindow.liveY)
                                       });
              }

              onResized: (dw, dh) => {
                noteWindow.isResizing = true;
                noteWindow.liveWidth = Math.max(160, noteWindow.liveWidth + dw);
                noteWindow.liveHeight = Math.max(140, noteWindow.liveHeight + dh);
              }
              onResizeFinished: {
                noteWindow.isResizing = false;
                NotesStore.updateNote(noteWindow.noteId, {
                                         "width": Math.round(noteWindow.liveWidth),
                                         "height": Math.round(noteWindow.liveHeight)
                                       });
              }

              onHideRequested: NotesStore.setVisible(noteWindow.noteId, false)
            }
          }
        }
      }
    }
  }
}
