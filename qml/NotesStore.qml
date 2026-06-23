pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// Single source of truth for sticky notes data. Persists to
// $XDG_DATA_HOME/quickshell-stickynotes/notes.json (defaults to
// ~/.local/share/quickshell-stickynotes/notes.json), debounced 500ms after
// the last change. Every note window and the manager window read/write
// here, so they stay in sync live.
Singleton {
  id: root

  readonly property string dataDir: ensureTrailingSlash((Quickshell.env("XDG_DATA_HOME") || (Quickshell.env("HOME") + "/.local/share")) + "/quickshell-stickynotes")
  readonly property string dataFile: dataDir + "notes.json"

  property bool directoriesCreated: false
  property bool isLoaded: false

  // Flat array of note records, see createNote() for the schema.
  readonly property alias notes: adapter.notes

  function ensureTrailingSlash(path) {
    return path.endsWith("/") ? path : path + "/";
  }

  Component.onCompleted: {
    Quickshell.execDetached(["mkdir", "-p", root.dataDir]);
    root.directoriesCreated = true;
  }

  FileView {
    id: fileView
    path: root.directoriesCreated ? root.dataFile : undefined
    printErrors: false
    watchChanges: false

    adapter: JsonAdapter {
      id: adapter
      property list<var> notes: []
    }

    onLoaded: {
      root.isLoaded = true;
      console.log("[quickshell-stickynotes] loaded", adapter.notes.length, "note(s) from", root.dataFile);
    }

    onLoadFailed: function (error) {
      // error === 2 -> file does not exist yet, will be created on first save
      root.isLoaded = true;
      if (error !== 2) {
        console.warn("[quickshell-stickynotes] failed to load notes.json:", error);
      }
    }
  }

  Timer {
    id: saveTimer
    interval: 500
    onTriggered: root.performSave()
  }

  property bool saveQueued: false

  function scheduleSave() {
    saveQueued = true;
    saveTimer.restart();
  }

  function performSave() {
    if (!saveQueued) {
      return;
    }
    saveQueued = false;
    Qt.callLater(() => {
                   try {
                     fileView.writeAdapter();
                   } catch (e) {
                     console.warn("[quickshell-stickynotes] failed to write notes.json:", e);
                   }
                 });
  }

  function generateId() {
    return "note-" + Date.now() + "-" + Math.random().toString(36).slice(2, 8);
  }

  // Creates a new note and returns its id. Colors/font/size left empty so
  // the note inherits Config's current defaults until overridden per-note.
  function createNote(screenName) {
    var note = {
      "id": generateId(),
      "text": "",
      "x": 120,
      "y": 120,
      "width": Config.defaultWidth,
      "height": Config.defaultHeight,
      "fontFamily": "",
      "fontSize": 0,
      "bgColor": "",
      "textColor": "",
      "visible": true,
      "screen": screenName || "",
      "createdAt": Date.now()
    };

    var list = root.notes.slice();
    list.push(note);
    adapter.notes = list;
    scheduleSave();
    return note.id;
  }

  function getNote(id) {
    for (var i = 0; i < root.notes.length; i++) {
      if (root.notes[i].id === id) {
        return root.notes[i];
      }
    }
    return null;
  }

  function updateNote(id, patch) {
    var list = root.notes.slice();
    for (var i = 0; i < list.length; i++) {
      if (list[i].id === id) {
        list[i] = Object.assign({}, list[i], patch);
        adapter.notes = list;
        scheduleSave();
        return true;
      }
    }
    return false;
  }

  function setVisible(id, visible) {
    return updateNote(id, {
                         "visible": visible
                       });
  }

  function deleteNote(id) {
    var list = root.notes.filter(function (n) {
      return n.id !== id;
    });
    if (list.length !== root.notes.length) {
      adapter.notes = list;
      scheduleSave();
      return true;
    }
    return false;
  }
}
