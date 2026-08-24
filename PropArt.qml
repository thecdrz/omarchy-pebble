import QtQuick

// Authored pixel prop — theme-fixed PNG from assets/props/.
Item {
  id: root
  property string kind: ""
  property real artScale: 1
  readonly property string propBase: "assets/props/"
  readonly property var propCatalog: ({
    "pebble": [14, 10],
    "leaf": [12, 9],
    "leaf-hat": [15, 7],
    "umbrella": [15, 9],
    "rain-drop": [8, 6],
    "parade-flag": [9, 12],
    "star": [13, 9],
    "firefly": [10, 7],
    "bobber": [5, 10],
    "line": [5, 10],
    "fishing-rod": [9, 11],
    "bang": [12, 7],
    "dots": [12, 3],
    "bubble": [10, 7],
    "puddle": [22, 6],
    "cannon": [29, 16],
    "cannonball": [10, 8],
    "flash": [10, 7],
    "gate-post": [4, 8],
    "gate-flame": [10, 6]
  })

  readonly property var nativeSize: kind !== "" && propCatalog[kind] ? propCatalog[kind] : [12, 12]
  implicitWidth: nativeSize[0] * artScale
  implicitHeight: nativeSize[1] * artScale
  width: implicitWidth
  height: implicitHeight

  Image {
    id: sprite
    anchors.centerIn: parent
    visible: root.kind !== ""
    source: visible ? Qt.resolvedUrl(root.propBase + (root.kind === "line" ? "bobber" : root.kind) + ".png") : ""
    width: root.nativeSize[0] * root.artScale
    height: root.nativeSize[1] * root.artScale
    fillMode: Image.PreserveAspectFit
    smooth: false
    mipmap: false
    cache: true
    antialiasing: false
  }
}
