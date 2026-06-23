pragma Singleton

import QtQuick
import Quickshell

// User-tweakable defaults. Edit the values below to change the look of new
// notes — existing notes that have their own per-note overrides are
// unaffected (see NotesStore.createNote()).
Singleton {
  property color noteColor: "#f9e07f"
  property color textColor: "#2b2b2b"
  property string fontFamily: "sans-serif"
  property int fontSize: 13
  property int defaultWidth: 220
  property int defaultHeight: 220
}
