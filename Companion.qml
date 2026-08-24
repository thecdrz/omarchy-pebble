import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import Quickshell.Wayland
import qs.Commons
import qs.Ui
import "."

Item {
  id: root
  property var shell: null
  property var manifest: null
  property string omarchyPath: ""
  readonly property string pluginId: manifest && manifest.id ? String(manifest.id) : "io.github.thecdrz.pebble"
  readonly property string companionName: "Pebble"
  property string speciesId: "penguin"
  readonly property string speciesBase: "assets/species/" + speciesId + "/"
  readonly property string speciesName: speciesId === "penguin" ? "Penguin" : speciesId === "gecko" ? "Leopard gecko" : "Raccoon"
  readonly property bool isGecko: speciesId === "gecko"
  readonly property bool isPenguin: speciesId === "penguin"
  // Soft lift so dark penguin art reads on dark bars without full recolor.
  readonly property real petColorization: isPenguin ? 0.40 : isGecko ? 0.12 : 0.18
  readonly property real petBrightness: isPenguin ? 0.18 : 0
  // Belly-slide frames 4–5 fill ~2× the canvas vs walk; compensate so he doesn't balloon.
  readonly property real slideVisualScale: {
    if (action !== "sliding")
      return 1
    var factors = [0.98, 0.92, 0.88, 0.82, 0.60, 0.56, 0.84, 0.90]
    var idx = Math.max(0, Math.min(7, poseFrame))
    return factors[idx]
  }
  property string conceptId: ""
  readonly property bool auditioning: conceptId !== ""
  readonly property string conceptName: conceptId === "bird" ? "Songbird"
    : conceptId === "frog" ? "Tree frog" : conceptId === "nova" ? "Nova" : "Cat"
  readonly property string stateDir: Quickshell.env("HOME") + "/.local/state/omarchy/pebble"
  readonly property string statePath: stateDir + "/state.json"
  readonly property int stateMaxBytes: 65536
  property string pendingStatePayload: ""
  property string activeStatePayload: ""
  readonly property var bar: shell ? shell.bar : null
  readonly property int barSize: bar && bar.barSize ? bar.barSize : 30
  readonly property string barPosition: bar ? String(bar.position) : "top"
  readonly property bool barHidden: bar ? bar.barHidden === true : false
  readonly property bool horizontalBar: barPosition === "top" || barPosition === "bottom"
  readonly property var petScreen: {
    var screens = Quickshell.screens
    if (!screens || screens.length === 0) return null
    var wanted = Hyprland.focusedMonitor ? String(Hyprland.focusedMonitor.name || "") : ""
    for (var i = 0; i < screens.length; i++) if (String(screens[i].name || "") === wanted) return screens[i]
    return screens[0]
  }

  property string action: "home"
  property string journeyPhase: "home"
  property int poseFrame: 0
  property int walkFrame: 0
  property int sleepFrame: 0
  property int idleFrame: 0
  property int lastIdleFrame: -1
  property int previousIdleFrame: -1
  property real idleBlend: 1
  property int idleBeatsRemaining: 0
  property real pendingDestination: 0
  property real petX: 0
  property real conceptX: 0
  property real conceptTargetX: 0
  property int conceptDirection: 1
  property int conceptHopCount: 5
  property real targetX: 0
  property real finalX: 0
  property int direction: 1
  property bool placed: false
  property bool pauseOnRoute: false
  property bool finalCuriosity: false
  property real pace: 96
  property int pokeCount: 0
  property double lastPoke: 0
  property bool playfulQueued: false
  property bool retreatQueued: false
  property bool clockQueued: false
  property bool clockTransit: false
  property int clockTransitDirection: -1
  property real clockTransitDestination: 0
  property string clockTransitEpisode: ""
  property string clockStyle: ""
  property int clockPeekHoldMs: 850
  property int clockPeekLoops: 1
  property string clockChaseItem: ""
  property bool slipQueued: false
  property string queuedDiscoveryItem: ""
  property string storyQueued: ""
  property string storyName: ""
  property int storyStage: 0
  property string storyPropKind: ""
  property real storyPropX: 0
  property real storyPropY: 0
  property real storyPropOpacity: 0
  property real storyPropScale: 1
  property real storyPropRotation: 0
  property string headPropKind: ""
  property real headPropRotation: 0
  property real headPropScale: 1
  readonly property int cannonSpriteW: 29
  readonly property int cannonSpriteH: 16
  readonly property real cannonArtScale: Math.min(1.32, (root.petHeight / cannonSpriteH) * 0.93)
  readonly property bool petRenderLayer: !(cannonVisible && storyName === "cannon")
  property real storyPetOffset: 0
  property bool hoopVisible: false
  property real hoopX: 0
  property real hoopY: 0
  property real hoopOpacity: 0
  property real hoopScale: 1
  property bool hoopSuccess: true
  property bool sumoWin: true
  property bool cannonStick: true
  property bool cannonVisible: false
  property real cannonX: 0
  property real cannonY: 0
  property real cannonOpacity: 0
  property real cannonScale: 1
  property bool cannonFlash: false
  property real hoopGlow: 0
  property real hoopGateWidth: 28
  property bool storyPetInFront: false
  property int homeStoryStage: 0
  property string homeStoryName: ""
  property int homePoseFrame: 0
  property bool deepSleeping: false
  property int outingActsRemaining: 0
  property string personalityMood: "sleepy"
  property string episodeName: ""
  property real animalOpacity: 1
  property bool discoveryVisible: false
  property real discoveryX: 0
  property string discoveryItem: ""
  property real toyHop: 0
  property real toySpin: 0
  property int toyBumps: 0
  property double lastToyBumpAt: 0
  property real toyVx: 0
  property bool toyFumblePending: false
  property int toyEdgeHits: 0
  property bool peeking: false
  property bool rustling: false
  property real peekOpacity: 0
  property real peekLift: 3
  property real eyeOpen: 1
  property bool stateDirReady: false
  property bool stateReady: false
  property bool panelOpen: false
  property bool devPanelOpen: false
  // Shipped builds hide dev chips; set PEBBLE_DEV=1 for the panel section, or use IPC preview/dev.
  readonly property bool devToolsEnabled: Quickshell.env("PEBBLE_DEV") === "1"
  readonly property var devTriggers: [
    { id: "slip", label: "Slip" },
    { id: "slide", label: "Slide" },
    { id: "clock", label: "Peek" },
    { id: "magic", label: "Magic" },
    { id: "retreat", label: "Hide" },
    { id: "discover", label: "Toy drop" },
    { id: "fire-hoop", label: "Flame gate" },
    { id: "cannon", label: "Cannon" },
    { id: "parade-leaf", label: "Parade" },
    { id: "sumo-pebble", label: "Sumo" },
    { id: "rain-umbrella", label: "Umbrella" },
    { id: "fishing", label: "Fish" },
    { id: "sneeze", label: "Sneeze" },
    { id: "zoomies", label: "Zoomies" },
    { id: "dusk-watch", label: "Dusk" },
    { id: "show-and-tell", label: "Treasure" },
    { id: "firefly", label: "Firefly" },
    { id: "stretch", label: "Stretch" },
    { id: "edge-watch", label: "Edge" },
    { id: "listen", label: "Listen" },
    { id: "stargaze", label: "Stars" },
    { id: "leaf-toss", label: "Leaf toss" },
    { id: "polish", label: "Polish" },
    { id: "lost-pebble", label: "Runaway" },
    { id: "collection-sort", label: "Sort" }
  ]
  property bool snoozed: false
  property double snoozeUntil: 0
  property int activityLevel: 1
  property bool reducedMotion: false
  property bool introSeen: false
  property bool curiousCursor: true
  property bool petHovered: false
  property bool gestureHintShown: false
  property string pokeCue: ""
  property real pointerX: -1
  property real pointerY: -1
  property real cursorBarX: -1
  property real curiousLean: 0
  property double lastCuriousScootAt: 0
  property real chaseTargetX: -1
  property bool pendingInteractiveWake: false
  property int playMood: 1
  property double lastPlayMoodFlipAt: 0
  readonly property int curiousMargin: 16
  readonly property string cursorHelper: {
    var dir = String(Qt.resolvedUrl("."))
    return dir.replace(/^file:\/\//, "") + "/bin/pebble-cursor"
  }
  readonly property int cursorInterval: sleeping ? 450 : 100
  property double firstMetAt: 0
  property string lastSeenDay: ""
  property int daysTogether: 1
  property var recentEpisodes: []
  property var episodeCounts: ({})
  property int repeatAvoided: 0
  property int workspaceChanges: 0
  property double lastContextReactionAt: 0
  property int outings: 0
  property int totalPokes: 0
  property int distanceWalked: 0
  property int leavesFound: 0
  property int pebblesFound: 0
  property int starsFound: 0
  property int slidesCompleted: 0
  property int slipsCompleted: 0
  property int clockPassages: 0
  property int suspiciousRetreats: 0
  property string recentEvent: "Settled into a new home in the bar."
  property double recentEventAt: 0
  property int recentEventPriority: 0
  property var episodeTimes: ({})
  property string lastDirectedEpisode: ""
  property double lastDirectedEpisodeAt: 0
  property string carriedItem: ""
  // Bar-lane props are authored PNG sprites (PropArt.qml + assets/props/).
  readonly property string activityName: activityLevel === 0 ? "Quiet" : activityLevel === 2 ? "Lively" : "Normal"
  readonly property string motionName: reducedMotion ? "Reduced" : "Full"
  readonly property string curiousCursorName: curiousCursor ? "On" : "Off"
  readonly property string hoverTipText: ""
  readonly property var journalAnchor: auditioning ? conceptPet : sleeping ? den : animal
  readonly property string favoriteItem: pebblesFound >= leavesFound && pebblesFound >= starsFound && pebblesFound > 0 ? "pebbles"
    : leavesFound >= starsFound && leavesFound > 0 ? "leaves" : starsFound > 0 ? "stars" : "quiet corners"
  readonly property string favoritePropKind: favoriteItem === "pebbles" ? "pebble"
    : favoriteItem === "leaves" ? "leaf" : favoriteItem === "stars" ? "star" : ""
  readonly property string bondName: daysTogether >= 14 || outings >= 100 ? "Trusted companion"
    : daysTogether >= 4 || outings >= 25 ? "Familiar friend" : "New neighbor"
  readonly property int focusedWorkspaceId: Hyprland.focusedWorkspace ? Number(Hyprland.focusedWorkspace.id) : -1
  readonly property bool sleeping: action === "home"
  readonly property bool walking: action === "walk" || action === "clockApproach"
  readonly property bool posing: action === "emerging" || action === "entering" || action === "starting" || action === "stopping" || action === "settling" || action === "sliding" || action === "slipping" || action === "clockApproach" || action === "clockHidden" || action === "clockPeek"
  readonly property real petHeight: Math.round(Math.min(29, Math.max(22, barSize * 0.90)))
  readonly property real petWidth: Math.round(petHeight * 56 / 34)
  readonly property real conceptHeight: Math.round(petHeight * 0.86)
  readonly property real conceptWidth: Math.round(conceptHeight * 56 / 34)
  readonly property real trackLength: petScreen ? petScreen.width : 0
  function widgetWindow(item) {
    if (!item) return null
    try {
      if (bar && typeof bar.targetWindow === "function") return bar.targetWindow(item)
      return item.QsWindow ? item.QsWindow.window : null
    } catch (error) { return null }
  }
  function widgetMatchesScreen(item) {
    var window = widgetWindow(item)
    if (!window || !window.screen || !petScreen) return true
    return String(window.screen.name || "") === String(petScreen.name || "")
  }
  function widgetPoint(item) {
    var window = widgetWindow(item)
    try {
      if (window && window.contentItem) return item.mapToItem(window.contentItem, 0, 0)
      return item.mapToItem(null, 0, 0)
    } catch (error) { return null }
  }
  readonly property var clockLandmark: {
    var fallback = { x: trackLength * 0.5 - 65, width: 130 }
    if (!bar || typeof bar.moduleWidgets !== "function") return fallback
    var clocks = bar.moduleWidgets("omarchy.clock")
    for (var i = 0; i < clocks.length; i++) {
      var item = clocks[i]
      if (!item || Number(item.width) < 8 || typeof item.mapToItem !== "function") continue
      if (!widgetMatchesScreen(item)) continue
      var point = widgetPoint(item)
      if (point && isFinite(Number(point.x))) return { x: Number(point.x), width: Number(item.width) }
    }
    return fallback
  }
  readonly property real clockLeftX: clockLandmark.x
  readonly property real clockRightX: clockLandmark.x + clockLandmark.width
  // Treat the clock and its neighboring center widgets as one landmark so a
  // passage remains clear when weather or indicators sit beside the clock.
  readonly property var passageLandmark: {
    var left = clockLeftX
    var right = clockRightX
    if (!bar || typeof bar.moduleWidgets !== "function") return { x: left, width: right - left }
    var moduleIds = ["omarchy.indicators", "omarchy.clock", "omarchy.keyboard-layout", "omarchy.weather", "omarchy.system-update"]
    for (var moduleIndex = 0; moduleIndex < moduleIds.length; moduleIndex++) {
      var widgets = bar.moduleWidgets(moduleIds[moduleIndex])
      for (var widgetIndex = 0; widgetIndex < widgets.length; widgetIndex++) {
        var widget = widgets[widgetIndex]
        if (!widget || Number(widget.width) < 2 || typeof widget.mapToItem !== "function") continue
        if (!widgetMatchesScreen(widget)) continue
        var point = widgetPoint(widget)
        if (!point || !isFinite(Number(point.x))) continue
        left = Math.min(left, Number(point.x))
        right = Math.max(right, Number(point.x) + Number(widget.width))
      }
    }
    return { x: left, width: Math.max(1, right - left) }
  }
  readonly property real passageLeftX: passageLandmark.x
  readonly property real passageRightX: passageLandmark.x + passageLandmark.width
  // The habitat follows the actual screen width. Pebble sleeps just beyond
  // the clock but can explore the whole bar instead of a fixed pixel lane.
  readonly property real worldMinX: 16
  readonly property real worldMaxX: Math.max(worldMinX, trackLength - petWidth - 16)
  // Far left/right of the bar are packed with tray icons and system widgets.
  // Keep spectacle and lingering stories inside this open lane.
  readonly property real iconMargin: Math.min(140, Math.max(72, Math.round(trackLength * 0.08)))
  readonly property real laneMinX: Math.min(worldMaxX, worldMinX + iconMargin)
  readonly property real laneMaxX: Math.max(laneMinX, worldMaxX - iconMargin)
  readonly property real homeX: Math.min(worldMaxX, Math.max(worldMinX, passageRightX + 96))
  readonly property real doorwayX: Math.min(worldMaxX, homeX + 34)
  readonly property string statusText: snoozed ? "Snoozing for one hour — Wake now or click him"
    : sleeping && activityLevel === 0 ? "Nesting quietly — click to wake, or Explore"
    : sleeping ? "Resting on the bar — click to wake, or Explore"
    : carriedItem !== "" ? "Carrying a " + carriedItem + " home"
    : episodeName === "clock-retreat" ? "Hiding behind the clock"
    : episodeName === "clock-cross" ? "Investigating the clock"
    : episodeName === "clock-chase" ? "Chasing something behind the clock"
    : episodeName === "clock-tumble" ? "Possibly stuck behind the clock"
    : episodeName === "clock-magic" ? "Magic trick: vanish → wrong peek → ta-da"
    : episodeName === "discovery" ? "Searching for treasure"
    : episodeName === "slip" ? "Recovering with dignity"
    : episodeName === "belly-slide" ? "Sliding across the bar"
    : episodeName === "edge-watch" ? "Inspecting a quiet gap on the bar"
    : episodeName === "firefly" ? "Following a tiny light"
    : episodeName === "polish" ? "Polishing a favorite pebble"
    : episodeName === "leaf-toss" ? "Playing with a leaf"
    : episodeName === "stargaze" ? "Watching a small star"
    : episodeName === "collection-sort" ? "Arranging the collection"
    : episodeName === "stretch" ? "Taking a serious stretch"
    : episodeName === "lost-pebble" ? "Chasing a runaway pebble"
    : episodeName === "listen" ? "Listening behind the clock"
    : episodeName === "fire-hoop" ? "Eyeing a flame gate on the bar"
    : episodeName === "parade-leaf" ? "Marching with a leaf hat and tiny flag"
    : episodeName === "sumo-pebble" ? "Preparing to shoulder-check a pebble"
    : episodeName === "cannon" ? "Circus cannon — ball first, then penguin"
    : episodeName === "dusk-watch" ? "Watching the bar go gold"
    : episodeName === "show-and-tell" ? "Showing off a favorite find"
    : episodeName === "rain-umbrella" ? "Waiting out imaginary rain"
    : episodeName === "fishing" ? "Fishing a puddle on the bar"
    : episodeName === "sneeze" ? "Fighting a historic sneeze"
    : episodeName === "zoomies" ? "Experiencing sudden zoomies"
    : personalityMood === "playful" ? "Looking for trouble"
    : personalityMood === "curious" ? "Exploring the bar"
    : "Taking a quiet wander"

  Behavior on storyPetOffset { NumberAnimation { duration: 360; easing.type: Easing.InOutCubic } }

  function clampX(value) { return Math.max(worldMinX, Math.min(worldMaxX, value)) }
  function clampLaneX(value) { return Math.max(laneMinX, Math.min(laneMaxX, value)) }
  // Bar-lane Y for props: same band as the penguin silhouette (no above/below bar space).
  function barPropY() { return Math.round((habitat.height - petHeight) / 2 + petHeight * 0.58) }
  function cannonDrawW() { return cannonSpriteW * cannonArtScale * cannonScale }
  function cannonDrawH() { return cannonSpriteH * cannonArtScale * cannonScale }
  function petFootY() { return Math.round((habitat.height + petHeight) / 2) }
  function cannonFloorY() { return Math.round(petFootY() - cannonDrawH()) }
  function cannonMuzzleX(baseX) { return baseX + (direction > 0 ? cannonDrawW() - 10 : 10) }
  function cannonMuzzleY() { return cannonFloorY() + Math.round(3 * cannonArtScale) }
  function cannonLaunchX() {
    return direction > 0
      ? Math.round(cannonX + cannonDrawW() - petWidth * 0.78)
      : Math.round(cannonX - petWidth * 0.22)
  }
  function stageCannonPair() {
    var cw = cannonDrawW()
    var gap = 20
    var bundle = petWidth + gap + cw
    var roomRight = laneMaxX - petX
    var roomLeft = petX - laneMinX
    if (roomRight >= bundle) {
      direction = 1
      petX = clampLaneX(Math.min(petX, laneMaxX - bundle))
      cannonX = petX + petWidth + gap
    } else if (roomLeft >= bundle) {
      direction = -1
      petX = clampLaneX(Math.max(petX, laneMinX + bundle))
      cannonX = petX - cw - gap
    } else {
      direction = roomRight >= roomLeft ? 1 : -1
      if (direction > 0) {
        petX = clampLaneX(laneMinX + 6)
        cannonX = petX + petWidth + gap
      } else {
        petX = clampLaneX(laneMaxX - petWidth - 6)
        cannonX = petX - cw - gap
      }
    }
    cannonY = cannonFloorY()
  }
  function clearHeadProp() {
    headPropKind = ""
    headPropRotation = 0
    headPropScale = 1
  }
  function stageOpenLane(bias) {
    // bias: 0 leftish, 0.5 mid, 1 rightish — always inside icon-safe lane
    var t = bias === undefined ? (0.28 + Math.random() * 0.44) : Math.max(0.05, Math.min(0.95, bias))
    return Math.round(clampLaneX(laneMinX + (laneMaxX - laneMinX) * t))
  }
  function passageClearance() { return petWidth + 56 }
  function overlapsPassage(x) {
    var right = x + petWidth
    return right > passageLeftX - 24 && x < passageRightX + 24
  }
  function devPreviewSide() {
    var leftRoom = passageLeftX - laneMinX - passageClearance()
    var rightRoom = laneMaxX - passageRightX - passageClearance()
    if (rightRoom >= leftRoom && rightRoom > petWidth + 36) return "right"
    if (leftRoom > petWidth + 36) return "left"
    return rightRoom >= leftRoom ? "right" : "left"
  }
  // Open-lane spot that keeps the clock cluster visible — for dev triggers and spectacle staging.
  function devPreviewX(bias) {
    var side = devPreviewSide()
    var gap = passageClearance()
    var minX, maxX
    if (side === "right") {
      minX = passageRightX + gap
      maxX = laneMaxX
    } else {
      minX = laneMinX
      maxX = passageLeftX - gap - petWidth
    }
    if (maxX <= minX)
      return clampLaneX(homeX)
    var t = bias === undefined ? 0.38 : Math.max(0.08, Math.min(0.92, bias))
    return clampLaneX(Math.round(minX + (maxX - minX) * t))
  }
  function stageOpenLaneClear(bias) {
    if (bias === undefined)
      return devPreviewX(0.18 + Math.random() * 0.64)
    return devPreviewX(bias)
  }
  function clockClearRightX() {
    return clampLaneX(Math.min(laneMaxX - 8, passageRightX + Math.max(56, petWidth + 24)))
  }
  function clockClearLeftX() {
    return clampLaneX(Math.max(laneMinX + 8, passageLeftX - petWidth - Math.max(56, petWidth + 24)))
  }
  function magicWrongPeekX() {
    return clampLaneX(Math.max(laneMinX + 8, clockClearLeftX() - 40))
  }
  function magicEmergeX() {
    return clampLaneX(Math.min(laneMaxX - 8, clockClearRightX() + 32))
  }
  function stageForDevTrigger(name) {
    if (name === "cannon") return clampLaneX(homeX)
    if (name === "listen") return clockClearRightX()
    if (name === "magic") return magicEmergeX()
    if (name === "clock" || name === "retreat") return clockClearRightX()
    if (name === "polish" || name === "collection-sort") return clampLaneX(Math.min(laneMaxX, homeX + 24))
    if (name === "edge-watch") return devPreviewX(devPreviewSide() === "left" ? 0.78 : 0.22)
    return devPreviewX(0.4)
  }
  function faceDevPreview() {
    if (petX + petWidth < passageLeftX - 8) direction = 1
    else if (petX > passageRightX + 8) direction = -1
    else direction = petX > (passageLeftX + passageRightX) * 0.5 ? -1 : 1
  }
  function clearStoryProp() {
    storyPropKind = ""
    storyPropOpacity = 0
    storyPropScale = 1
    storyPropRotation = 0
  }
  function setStoryProp(kind, x, y, opacity, scale, rotation) {
    storyPropKind = kind
    storyPropX = x
    storyPropY = y === undefined ? barPropY() : y
    storyPropOpacity = opacity === undefined ? 1 : opacity
    storyPropScale = scale === undefined ? 1 : scale
    storyPropRotation = rotation === undefined ? 0 : rotation
  }
  function initialPosition() { return homeX }
  function chooseDestination() {
    var usableWidth = Math.max(1, laneMaxX - laneMinX)
    // Prefer the open lane; avoid tray-icon ends unless a rare full wander.
    var crossBarChance = personalityMood === "playful" ? 0.18 : 0.10
    if (Math.random() < crossBarChance) {
      return Math.round(petX < (laneMinX + laneMaxX) * 0.5 ? laneMaxX : laneMinX)
    }
    var reach = Math.min(usableWidth * 0.36, Math.max(72, usableWidth * 0.18))
    var step = (Math.random() < 0.5 ? -1 : 1) * (56 + Math.random() * reach)
    return Math.round(clampLaneX(petX + step))
  }
  function randomDiscoveryType() {
    var roll = Math.random()
    return roll < 0.24 ? "leaf" : roll < 0.86 ? "pebble" : "star"
  }
  function currentHour() { return new Date().getHours() }
  function isDusk() { var hour = currentHour(); return hour >= 17 && hour <= 19 }
  function isNight() { var hour = currentHour(); return hour >= 20 || hour < 6 }
  function collectionSize() { return leavesFound + pebblesFound + starsFound }
  function isStory(name) {
    return ["edge-watch", "firefly", "polish", "leaf-toss", "stargaze", "collection-sort", "stretch", "lost-pebble", "listen", "fire-hoop", "parade-leaf", "sumo-pebble", "cannon", "rain-umbrella", "fishing", "sneeze", "zoomies", "dusk-watch", "show-and-tell"].indexOf(name) >= 0
  }
  function storyEligible(name) {
    if (name === "polish" || name === "lost-pebble") return pebblesFound > 0
    if (name === "leaf-toss") return leavesFound > 0
    if (name === "collection-sort") return collectionSize() >= 3
    if (name === "stargaze") return isNight() || currentHour() >= 19
    if (name === "dusk-watch") return activityLevel >= 1 && isDusk()
    if (name === "show-and-tell") return activityLevel >= 1 && collectionSize() >= 1
    // Circus stunts stay Lively-only and never fight Reduced Motion.
    if (name === "fire-hoop") return activityLevel === 2 && !reducedMotion
    if (name === "parade-leaf") return activityLevel === 2 && !reducedMotion && leavesFound > 0
    if (name === "sumo-pebble") return activityLevel === 2 && !reducedMotion && pebblesFound > 0
    if (name === "cannon") return activityLevel === 2 && !reducedMotion
    if (name === "rain-umbrella") return activityLevel === 2 && !reducedMotion && leavesFound > 0
    if (name === "fishing" || name === "sneeze" || name === "zoomies") return activityLevel === 2 && !reducedMotion
    return true
  }
  function episodeCooldown(name) {
    var base = name === "clock" || name === "magic" ? 240000 : name === "discovery" ? 90000
      : name === "slide" ? 150000 : name === "slip" ? 210000
      : name === "stretch" ? 360000 : name === "firefly" ? 480000
      : name === "edge-watch" ? 540000 : name === "listen" ? 600000
      : name === "polish" || name === "leaf-toss" ? 720000
      : name === "lost-pebble" ? 840000 : name === "collection-sort" ? 900000
      : name === "stargaze" ? 1200000
      : name === "fire-hoop" ? 540000
      : name === "parade-leaf" || name === "sumo-pebble" ? 480000
      : name === "cannon" ? 300000
      : name === "rain-umbrella" || name === "fishing" ? 420000
      : name === "sneeze" || name === "zoomies" ? 240000
      : name === "dusk-watch" ? 900000
      : name === "show-and-tell" ? 540000 : 180000
    return activityLevel === 2 ? Math.round(base * 0.62) : base
  }
  function episodeReady(name) {
    var lastAt = Number(episodeTimes[name]) || 0
    return Date.now() - lastAt >= episodeCooldown(name)
  }
  function markEpisode(name) {
    var now = Date.now()
    var duplicateStart = lastDirectedEpisode === name && now - lastDirectedEpisodeAt < 10000
    episodeTimes[name] = now
    lastDirectedEpisode = name
    lastDirectedEpisodeAt = now
    if (duplicateStart) { saveState(); return }
    var history = recentEpisodes.slice(0)
    history.unshift(name)
    recentEpisodes = history.slice(0, 8)
    var counts = Object.assign({}, episodeCounts)
    counts[name] = safeCounter(counts[name]) + 1
    episodeCounts = counts
    saveState()
  }
  function rememberEvent(message, priority) {
    var now = Date.now()
    if (priority < recentEventPriority && now - recentEventAt < 5 * 60 * 1000) return false
    recentEvent = message
    recentEventPriority = priority
    recentEventAt = now
    return true
  }
  function chooseDirectedEpisode(interactive) {
    var pool = []
    function add(name, weight) {
      if (reducedMotion && (name === "slide" || name === "slip" || name === "lost-pebble" || name === "fire-hoop" || name === "parade-leaf" || name === "sumo-pebble" || name === "cannon" || name === "rain-umbrella" || name === "fishing" || name === "sneeze" || name === "zoomies")) return
      if (!storyEligible(name) || !episodeReady(name) || recentEpisodes.slice(0, 3).indexOf(name) >= 0) {
        if (storyEligible(name) && episodeReady(name)) repeatAvoided++
        return
      }
      for (var index = 0; index < weight; index++) pool.push(name)
    }
    if (activityLevel === 2) {
      // Lively: circus first, locomotion as seasoning — not the whole meal.
      add("discovery", 2); add("clock", 1); add("slide", 1); add("slip", 1)
      add("edge-watch", 1); add("firefly", 1); add("stretch", 1); add("listen", 1)
      add("polish", 1); add("leaf-toss", 1); add("stargaze", 1); add("collection-sort", 1); add("lost-pebble", 1)
      add("fire-hoop", 2); add("parade-leaf", 2); add("sumo-pebble", 2)
      add("cannon", 4)
      add("rain-umbrella", 2); add("fishing", 2); add("sneeze", 3); add("zoomies", 3)
      if (isDusk()) add("dusk-watch", 3)
      add("show-and-tell", 2)
    } else {
      add("discovery", 3); add("clock", 2); add("slide", interactive ? 2 : 1); add("slip", 1)
      add("edge-watch", 2); add("firefly", 2); add("stretch", 2); add("listen", 1)
      add("polish", 1); add("leaf-toss", 1); add("stargaze", 2); add("collection-sort", 1); add("lost-pebble", 1)
      if (isDusk()) add("dusk-watch", 4)
      add("show-and-tell", 2)
    }
    if (pool.length === 0) {
      var fallbacks = ["discovery", "clock", "slide", "slip"]
      for (var fallbackIndex = 0; fallbackIndex < fallbacks.length; fallbackIndex++)
        if (episodeReady(fallbacks[fallbackIndex]) && recentEpisodes.slice(0, 3).indexOf(fallbacks[fallbackIndex]) < 0
            && (!reducedMotion || (fallbacks[fallbackIndex] !== "slide" && fallbacks[fallbackIndex] !== "slip")))
          pool.push(fallbacks[fallbackIndex])
    }
    return pool.length > 0 ? pool[Math.floor(Math.random() * pool.length)] : "walk"
  }
  function queueEpisode(name) {
    if (name === "clock") clockQueued = true
    else if (name === "discovery") { queuedDiscoveryItem = randomDiscoveryType(); episodeName = "discovery" }
    else if (name === "slip") { slipQueued = true; episodeName = "slip" }
    else if (name === "slide") { playfulQueued = true; episodeName = "belly-slide" }
    else if (isStory(name)) { storyQueued = name; episodeName = name }
    if (name !== "walk") markEpisode(name)
  }
  function queueAutonomousEpisode() {
    if (!isPenguin || clockQueued || retreatQueued || slipQueued || playfulQueued || queuedDiscoveryItem !== "") return
    var episodeChance = reducedMotion ? 0.34 : activityLevel === 2 ? 0.74 : 0.46
    if (Math.random() < episodeChance) queueEpisode(chooseDirectedEpisode(false))
  }
  function inviteExplore() {
    if (snoozed) cancelSnooze()
    panelOpen = false
    var choice = chooseDirectedEpisode(true)
    if (sleeping || posing) {
      queueEpisode(choice)
      if (sleeping) wakeAndWalk(true)
      return
    }
    if (choice === "clock") startClockEpisode(false)
    else if (choice === "slip") startSlip()
    else if (choice === "slide") startSlide()
    else if (choice === "discovery") {
      queueEpisode(choice)
      personalityMood = "curious"; journeyPhase = "outbound"
      if (!walking) planRoute()
    } else if (isStory(choice)) {
      queueEpisode(choice)
      if (!walking) planRoute()
    } else if (!walking) planRoute()
  }
  function scheduleRoam() {
    if (auditioning) { roamTimer.stop(); scheduleConceptIdle(); return }
    if (barHidden || !horizontalBar || snoozed || activityLevel === 0) { roamTimer.stop(); return }
    var base = activityLevel === 2 ? 14000 : 30000
    var spread = activityLevel === 2 ? 26000 : 45000
    roamTimer.interval = base + Math.floor(Math.random() * spread); roamTimer.restart()
  }
  function scheduleConceptIdle() {
    if (!auditioning || barHidden || !horizontalBar || snoozed || activityLevel === 0) { conceptIdleTimer.stop(); return }
    var base = activityLevel === 2 ? 6500 : 11000
    var spread = activityLevel === 2 ? 7500 : 15000
    conceptIdleTimer.interval = base + Math.floor(Math.random() * spread)
    conceptIdleTimer.restart()
  }
  function startConceptMotion(playful) {
    if (!placed || !auditioning || conceptTravel.running) return
    conceptIdleTimer.stop()
    var minimumX = homeX
    var maximumX = Math.min(worldMaxX, homeX + 190)
    var distance = (playful ? 85 : 50) + Math.random() * (playful ? 70 : 55)
    var preferredDirection = conceptX >= maximumX - 10 ? -1 : conceptX <= minimumX + 10 ? 1 : (Math.random() < 0.5 ? -1 : 1)
    conceptTargetX = Math.max(minimumX, Math.min(maximumX, conceptX + preferredDirection * distance))
    conceptDirection = conceptTargetX >= conceptX ? 1 : -1
    conceptHopCount = Math.max(4, Math.min(8, Math.round(Math.abs(conceptTargetX - conceptX) / 20)))
    conceptTravel.travelDuration = conceptHopCount * 350
    conceptTravel.restart()
  }
  function schedulePeek() {
    if (barHidden || !horizontalBar || snoozed) { peekTimer.stop(); return }
    var base = activityLevel === 0 ? 4200 : activityLevel === 2 ? 11000 : 8000
    var spread = activityLevel === 0 ? 5200 : activityLevel === 2 ? 12000 : 10000
    peekTimer.interval = base + Math.floor(Math.random() * spread)
    peekTimer.restart()
  }
  function scheduleSleepMarker() {
    if (!sleeping || barHidden || !horizontalBar || homeStoryName !== "") {
      sleepMarkerTimer.stop(); deepSleeping = false; return
    }
    var quiet = activityLevel === 0
    sleepMarkerTimer.interval = deepSleeping
      ? (quiet ? 1600 : 2200) + Math.floor(Math.random() * (quiet ? 1400 : 1800))
      : (quiet ? 3200 : 7000) + Math.floor(Math.random() * (quiet ? 3800 : 9000))
    sleepMarkerTimer.restart()
  }
  function advanceSleepMarker() { deepSleeping = !deepSleeping; scheduleSleepMarker() }
  function beginEmergence(interactive) {
    rustling = false
    if (interactive !== undefined) personalityMood = interactive ? (pokeCount >= 2 ? "playful" : "curious") : "sleepy"
    outings++; saveState()
    var lingerChance = reducedMotion ? 0.20 : activityLevel === 2 ? 0.40 : 0.36
    outingActsRemaining = Math.random() < lingerChance ? (activityLevel === 2 && Math.random() < 0.12 ? 2 : 1) : 0
    journeyPhase = "outbound"; petX = homeX; direction = 1
    poseFrame = isPenguin ? 3 : 0; action = "emerging"; poseTimer.interval = 155; poseTimer.restart()
  }
  function wakeAndWalk(interactive) {
    if (!placed || barHidden || !horizontalBar) return
    if (auditioning) { startConceptMotion(true); return }
    if (walking) { walkMotion.stop(); acknowledgeAnimation.restart(); return }
    roamTimer.stop(); peekTimer.stop(); peekAnimation.stop(); peeking = false
    curiosityAnimation.stop(); settleTurn.stop(); poseTimer.stop()
    pendingInteractiveWake = interactive === true
    if (pendingInteractiveWake && cursorBarX >= 0)
      chaseTargetX = clampX(cursorBarX - petWidth * 0.5)
    else if (!pendingInteractiveWake)
      chaseTargetX = -1
    if (sleeping) {
      cancelHomeStory()
      sleepMarkerTimer.stop(); deepSleeping = false
      personalityMood = interactive ? "curious" : activityLevel === 2 && Math.random() < 0.64 ? "playful" : "sleepy"
      if (interactive !== true) queueAutonomousEpisode()
      if (reducedMotion || !isPenguin) {
        beginEmergence(interactive)
      } else {
        rustling = true; peekOpacity = 0.65; eyeOpen = 1; rustleAnimation.restart(); rustleWatchdog.restart()
      }
    }
    else beginEmergence(interactive)
  }
  function planRoute() {
    var chasing = chaseTargetX >= 0
    if (chasing) {
      finalX = clampX(chaseTargetX)
      chaseTargetX = -1
    } else if (storyQueued === "edge-watch") {
      // Inspect a quiet gap inside the open lane — never tray-icon ends.
      finalX = stageOpenLane(Math.random() < 0.5 ? 0.18 : 0.82)
    } else if (storyQueued === "listen") {
      finalX = clampLaneX(passageRightX + petWidth + 24)
    } else if (storyQueued === "polish" || storyQueued === "collection-sort") {
      finalX = clampLaneX(homeX + 90 + Math.random() * 70)
    } else if (["firefly", "leaf-toss", "lost-pebble", "stargaze"].indexOf(storyQueued) >= 0) {
      finalX = clampLaneX(Math.max(laneMinX + 40, Math.min(laneMaxX - 40, chooseDestination())))
    } else if (storyQueued === "cannon") {
      finalX = clampLaneX(homeX + 8)
    } else if (storyQueued === "fishing") {
      // Puddle-fish mid-lane — never over the clock cluster.
      finalX = stageOpenLaneClear(0.42)
    } else if (["fire-hoop", "parade-leaf", "sumo-pebble", "rain-umbrella", "sneeze", "zoomies", "dusk-watch", "show-and-tell"].indexOf(storyQueued) >= 0) {
      finalX = stageOpenLaneClear()
    } else {
      finalX = chooseDestination()
    }
    pace = chasing
      ? ((isGecko ? 130 : 148) + Math.random() * 36)
      : ((isGecko ? 118 : personalityMood === "playful" ? 135 : personalityMood === "curious" ? 108 : 88)
         + Math.random() * (isGecko ? 55 : 24))
    pauseOnRoute = !chasing && Math.abs(finalX - petX) > 118 && Math.random() < (personalityMood === "sleepy" ? 0.28 : 0.58)
    pendingDestination = pauseOnRoute ? petX + (finalX - petX) * (0.42 + Math.random() * 0.22) : finalX
    if (isPenguin) { poseFrame = 0; action = "starting"; poseTimer.interval = 110; poseTimer.restart() }
    else startLeg(pendingDestination)
  }
  function startLeg(destination) {
    if (isPenguin && retreatQueued) { retreatQueued = false; startClockEpisode(true); return }
    if (isPenguin && clockQueued) { clockQueued = false; startClockEpisode(false); return }
    if (isPenguin && slipQueued) { slipQueued = false; startSlip(); return }
    if (isPenguin && playfulQueued) { playfulQueued = false; startSlide(); return }
    targetX = clampX(destination)
    var crossesCenterLeft = petX > passageRightX && targetX < passageLeftX - petWidth
    var crossesCenterRight = petX + petWidth < passageLeftX && targetX > passageRightX
    if (isPenguin && (crossesCenterLeft || crossesCenterRight)) {
      startClockTransit(targetX, crossesCenterLeft ? -1 : 1)
      return
    }
    direction = targetX >= petX ? 1 : -1
    var legDistance = Math.abs(targetX - petX)
    distanceWalked += Math.round(legDistance); saveState()
    action = "walk"; walkFrame = 0
    walkMotion.from = petX; walkMotion.to = targetX
    var naturalDuration = Math.round(legDistance / pace * 1000)
    var maxLegDuration = personalityMood === "sleepy" ? 10000 : personalityMood === "playful" ? 13000 : 14000
    walkMotion.duration = Math.max(620, Math.min(maxLegDuration, naturalDuration))
    if (naturalDuration > maxLegDuration) pace = legDistance / (maxLegDuration / 1000)
    walkMotion.restart()
  }
  function legFinished() {
    petX = targetX
    if (journeyPhase === "returning") { beginEntering(); return }
    var slipChance = activityLevel === 2 ? 0.20 : 0.10
    if (isPenguin && !reducedMotion && !pauseOnRoute && personalityMood !== "sleepy" && carriedItem === ""
      && episodeReady("slip") && recentEpisodes.slice(0, 3).indexOf("slip") < 0
      && Math.random() < slipChance) { startSlip(); return }
    if (isPenguin) { poseFrame = 0; action = "stopping"; poseTimer.interval = 105; poseTimer.restart(); return }
    finishStoppedLeg()
  }
  function finishStoppedLeg() {
    if (pauseOnRoute && Math.abs(finalX - petX) > 8) {
      pauseOnRoute = false; finalCuriosity = false; action = "curious"; curiosityAnimation.loops = 1
    } else {
      revealDiscovery()
      finalCuriosity = true; action = "curious"; curiosityAnimation.loops = 2
    }
    curiosityAnimation.restart()
  }
  function revealDiscovery() {
    discoveryVisible = false; discoveryItem = ""
    if (journeyPhase !== "outbound" || carriedItem !== "") return
    if (storyQueued !== "") return
    if (queuedDiscoveryItem !== "") {
      discoveryItem = queuedDiscoveryItem
      queuedDiscoveryItem = ""
    } else {
      if (!episodeReady("discovery") || recentEpisodes.slice(0, 3).indexOf("discovery") >= 0 || Math.random() > 0.58) return
      discoveryItem = randomDiscoveryType()
      episodeName = "discovery"
      markEpisode("discovery")
    }
    discoveryX = Math.max(4, Math.min(trackLength - 12, petX + (direction > 0 ? petWidth - 5 : -4)))
    toyHop = 0; toySpin = 0; toyBumps = 0; lastToyBumpAt = 0
    toyVx = 0; toyFumblePending = false; toyEdgeHits = 0
    discoveryVisible = true
    if (!reducedMotion) toyIdleBounce.restart()
  }
  function bumpToy(kick) {
    if (!discoveryVisible || discoveryItem === "") return
    var delta = Number(kick) || 0
    if (Math.abs(delta) < 1) delta = direction * 14
    var weight = discoveryItem === "leaf" ? 0.72 : discoveryItem === "star" ? 1.15 : 1.0
    var spinFactor = discoveryItem === "leaf" ? 14 : discoveryItem === "star" ? 11 : 8
    delta *= weight
    if (action === "sliding") delta *= 1.35
    toyVx = delta
    discoveryX = Math.max(4, Math.min(trackLength - 12, discoveryX + delta * 0.45))
    toySpin += delta * spinFactor
    toyBumps++
    lastToyBumpAt = Date.now()
    toyHopBounce.restart()
    if (!toyPhysicsTimer.running) toyPhysicsTimer.start()
    if (toyBumps === 1) {
      if (discoveryItem === "pebble")
        rememberEvent("Nudged a pebble. It rolled away like it had plans.", 1)
      else if (discoveryItem === "leaf")
        rememberEvent("Poked a leaf. Unexpected aerodynamics.", 1)
      else
        rememberEvent("Batted a tiny star. It bounced on principle.", 1)
    } else if (toyBumps === 3) {
      rememberEvent(discoveryItem === "pebble" ? "The pebble is winning. Temporarily."
        : discoveryItem === "leaf" ? "Leaf chase: ongoing."
        : "Star refused to be collected without drama.", 1)
    } else if (toyBumps === 5) {
      rememberEvent("This is becoming a sport.", 1)
    }
  }
  function toyHitEdge(side) {
    toyEdgeHits++
    toyVx *= -0.62
    if (toyEdgeHits === 1) {
      rememberEvent(side < 0
        ? "Toy kissed the left edge and came back offended."
        : "Toy bounced off the right edge with confidence.", 1)
    } else if (toyEdgeHits === 3) {
      rememberEvent("The bar has walls. The toy has opinions.", 1)
    }
  }
  function maybeToyEscapeClock() {
    if (!discoveryVisible || reducedMotion) return false
    if (clockApproach.running || clockOcclusion.running || clockTransitOcclusion.running) return false
    if (Math.abs(discoveryX - passageRightX) > 30 && Math.abs(discoveryX - passageLeftX) > 30) return false
    if (Math.random() > 0.34) return false
    clockChaseItem = discoveryItem
    discoveryVisible = false
    discoveryItem = ""
    toyVx = 0
    toyPhysicsTimer.stop()
    rememberEvent(clockChaseItem === "pebble" ? "Pebble took the clock shortcut. Rude."
      : clockChaseItem === "leaf" ? "Leaf vanished behind the clock. Predictable."
      : "Star blinked behind the clock.", 1)
    if (isPenguin && journeyPhase === "outbound" && !sleeping)
      startClockEpisode(false)
    return true
  }
  function stepToyPhysics() {
    if (!discoveryVisible || reducedMotion) { toyVx = 0; toyPhysicsTimer.stop(); return }
    if (Math.abs(toyVx) < 0.35) { toyVx = 0; toyPhysicsTimer.stop(); return }
    discoveryX += toyVx * 0.55
    toySpin += toyVx * (discoveryItem === "leaf" ? 2.4 : 1.6)
    var drag = discoveryItem === "leaf" ? 0.94 : discoveryItem === "star" ? 0.90 : 0.86
    toyVx *= drag
    if (discoveryX <= 4) { discoveryX = 4; toyHitEdge(-1) }
    else if (discoveryX >= trackLength - 12) { discoveryX = trackLength - 12; toyHitEdge(1) }
    else if (Math.abs(toyVx) > 4 && maybeToyEscapeClock()) return
    if (Math.abs(toyVx) > 3 && !toyHopBounce.running)
      toyHop = discoveryItem === "star" ? -2.2 : discoveryItem === "leaf" ? -1.4 : -0.8
  }
  function considerToyNudge() {
    if (!discoveryVisible || reducedMotion || auditioning || sleeping) return
    if (Date.now() - lastToyBumpAt < 220) return
    var nose = petX + (direction > 0 ? petWidth * 0.82 : petWidth * 0.18)
    var gap = discoveryX + 5 - nose
    var reach = action === "sliding" ? 26 : 15
    if (Math.abs(gap) > reach) return
    if (action === "sliding")
      bumpToy(direction * (30 + Math.random() * 28))
    else if (walking || action === "curious")
      bumpToy((gap >= 0 ? 1 : -1) * (14 + Math.random() * 16))
  }
  function finishToyCatch() {
    toyFumblePending = false
    if (!discoveryVisible || discoveryItem === "") return
    var nose = petX + petWidth * 0.5
    if (Math.abs(discoveryX - nose) < 90) {
      carriedItem = discoveryItem
      discoveryVisible = false
      discoveryItem = ""
      toyVx = 0
      toyIdleBounce.stop(); toyHopBounce.stop(); toyPhysicsTimer.stop()
      toyHop = 0
      rememberEvent("Caught it on the second try. Dignity restored.", 1)
    } else {
      rememberEvent(discoveryItem === "pebble" ? "Pebble escaped. Rematch pending."
        : discoveryItem === "leaf" ? "Leaf got away. Wind is a co-conspirator."
        : "Star outmaneuvered him. Brief silence.", 1)
      toyVx *= 0.3
    }
  }
  function collectDiscovery() {
    if (!discoveryVisible || discoveryItem === "") return
    if (!reducedMotion && !toyFumblePending && toyBumps < 2 && Math.random() < 0.42) {
      toyFumblePending = true
      bumpToy(direction * (22 + Math.random() * 26))
      rememberEvent(discoveryItem === "pebble" ? "Grabbed for the pebble. Missed. Physics laughed."
        : discoveryItem === "leaf" ? "Almost had the leaf. Almost."
        : "Star slipped through. Typical.", 1)
      toyCatchTimer.restart()
      return
    }
    if (!reducedMotion && toyBumps < 1 && action !== "sliding")
      bumpToy(direction * (10 + Math.random() * 8))
    carriedItem = discoveryItem
    discoveryVisible = false
    discoveryItem = ""
    toyFumblePending = false
    toyVx = 0
    toyIdleBounce.stop(); toyHopBounce.stop(); toyPhysicsTimer.stop()
    toyHop = 0
  }
  function storeDiscovery() {
    var chase = toyBumps >= 2 || toyEdgeHits >= 1
    if (carriedItem === "leaf") {
      leavesFound++
      rememberEvent(chase ? "After a brief leaf chase, secured the evidence." : "Brought home a particularly interesting leaf.", 3)
    } else if (carriedItem === "pebble") {
      pebblesFound++
      rememberEvent(chase ? "Won a rolling contest with a pebble. Barely." : "Found another pebble. Excellent pebble.", 3)
    } else if (carriedItem === "star") {
      starsFound++
      rememberEvent(chase ? "Persuaded a tiny star to come home. It bounced the whole way." : "Found a tiny star and carried it safely home.", 3)
    }
    carriedItem = ""
    toyBumps = 0
    toyEdgeHits = 0
    toyFumblePending = false
    saveState()
  }

  onPetXChanged: if (discoveryVisible) considerToyNudge()
  onDiscoveryVisibleChanged: {
    if (!discoveryVisible) {
      toyIdleBounce.stop()
      toyHopBounce.stop()
      toyPhysicsTimer.stop()
      toyVx = 0
      toyHop = 0
      toyFumblePending = false
    }
  }

  function curiosityFinished() {
    if (finalCuriosity && isPenguin) {
      collectDiscovery()
      if (storyQueued !== "") startQueuedStory()
      else if (personalityMood === "playful" && episodeReady("slide") && Math.random() < (activityLevel === 2 ? 0.12 : 0.14)) startSlide()
      else beginIdleRoutine()
    }
    else if (finalCuriosity) { collectDiscovery(); settleTurn.restart() }
    else if (isPenguin) { pendingDestination = finalX; poseFrame = 0; action = "starting"; poseTimer.interval = 110; poseTimer.restart() }
    else startLeg(finalX)
  }
  function chooseIdleFrame() {
    var pool = personalityMood === "playful" ? [4, 5, 7, 2]
      : personalityMood === "curious" ? [0, 1, 2, 3, 7] : [3, 4, 6]
    var choice = pool[Math.floor(Math.random() * pool.length)]
    if (choice === lastIdleFrame && pool.length > 1) choice = pool[(pool.indexOf(choice) + 1 + Math.floor(Math.random() * (pool.length - 1))) % pool.length]
    lastIdleFrame = choice
    return choice
  }
  function beginIdleRoutine() {
    idleBeatsRemaining = personalityMood === "playful" ? 3 + Math.floor(Math.random() * 2)
      : personalityMood === "curious" ? 2 + Math.floor(Math.random() * 2) : 1 + Math.floor(Math.random() * 2)
    showIdleBeat()
  }
  function showIdleBeat() {
    previousIdleFrame = action === "idleAction" ? idleFrame : -1
    idleFrame = chooseIdleFrame()
    idleBlend = previousIdleFrame >= 0 ? 0 : 1
    action = "idleAction"
    if (previousIdleFrame >= 0) { idleBlendAnimation.restart(); idleTransitionMotion.restart() }
    idleActionTimer.interval = personalityMood === "sleepy" ? 1250 + Math.floor(Math.random() * 550)
      : 760 + Math.floor(Math.random() * 520)
    idleActionTimer.restart()
  }
  function advanceIdleRoutine() {
    idleBeatsRemaining--
    if (idleBeatsRemaining > 0) showIdleBeat()
    else if (isPenguin && episodeName === "" && carriedItem === "" && journeyPhase === "outbound"
      && petX > passageRightX + petWidth && episodeReady("clock") && recentEpisodes.slice(0, 3).indexOf("clock") < 0
      && Math.random() < (activityLevel === 2 ? 0.28 : 0.14)) startClockEpisode(false)
    else if (journeyPhase === "outbound" && carriedItem === "" && outingActsRemaining > 0) {
      outingActsRemaining--
      personalityMood = activityLevel === 2 && Math.random() < 0.58 ? "playful" : "curious"
      episodeName = ""; finalCuriosity = false; planRoute()
    }
    else startReturn()
  }
  function chooseClockStyle(suspicious) {
    if (suspicious) return "shy"
    var toyNear = discoveryVisible && Math.abs(discoveryX - passageRightX) < 140
    if (toyNear && Math.random() < 0.58) return "chase"
    if (!toyNear && Math.random() < 0.20) return "chase"
    if (activityLevel === 2 && !reducedMotion && Math.random() < 0.14) return "magic"
    if (Math.random() < 0.14) return "tumble"
    if (Math.random() < 0.36) return "shy"
    return "bold"
  }
  function startClockEpisode(suspicious, forcedStyle) {
    if (!isPenguin || !placed || clockApproach.running || clockOcclusion.running || clockTransitOcclusion.running) return
    if (petX + petWidth < passageLeftX) { startClockTransit(doorwayX, 1); return }
    markEpisode(suspicious ? "retreat" : (forcedStyle === "magic" ? "magic" : "clock"))
    walkMotion.stop(); slideMotion.stop(); slipMotion.stop(); poseTimer.stop(); curiosityAnimation.stop()
    slideTimer.stop(); slipTimer.stop(); idleActionTimer.stop(); idleBlendAnimation.stop(); idleTransitionMotion.stop()
    clearStoryProp()
    var escapedToy = clockChaseItem
    clockStyle = forcedStyle || (escapedToy !== "" ? "chase" : chooseClockStyle(suspicious === true))
    clockPeekHoldMs = clockStyle === "shy" ? 480
      : clockStyle === "bold" ? 1180
      : clockStyle === "tumble" ? 1680
      : clockStyle === "magic" ? 720
      : 920
    clockPeekLoops = clockStyle === "shy" ? 1 : clockStyle === "bold" ? 2 : clockStyle === "tumble" ? 3 : clockStyle === "magic" ? 2 : 1
    if (clockStyle === "chase") {
      if (escapedToy !== "") {
        // Toy already fled behind the clock — pursue without re-spawning on this side.
        clockChaseItem = escapedToy
        discoveryVisible = false
        discoveryItem = ""
      } else {
        if (!discoveryVisible || discoveryItem === "") {
          discoveryItem = randomDiscoveryType()
          discoveryX = clampX(petX + (direction > 0 ? petWidth - 4 : -6))
          toyHop = 0; toySpin = 0; toyBumps = 0
          discoveryVisible = true
        }
        clockChaseItem = discoveryItem
        // Roll the toy toward the clock mouth so he has something to pursue.
        discoveryX = clampX(passageRightX - 6)
        toySpin += 40
        if (!reducedMotion) toyHopBounce.restart()
      }
      episodeName = "clock-chase"
      personalityMood = "playful"
    } else {
      clockChaseItem = ""
      discoveryVisible = false; discoveryItem = ""
      if (clockStyle === "tumble") {
        episodeName = "clock-tumble"
        personalityMood = "playful"
      } else if (clockStyle === "magic") {
        episodeName = "clock-magic"
        personalityMood = "playful"
      } else if (clockStyle === "shy") {
        episodeName = suspicious ? "clock-retreat" : "clock-cross"
        personalityMood = "cautious"
      } else {
        episodeName = "clock-cross"
        personalityMood = "curious"
      }
    }
    clockTransit = false
    direction = -1
    targetX = clockClearRightX()
    action = "clockApproach"; walkFrame = 0; animalOpacity = 1
    clockApproach.from = petX; clockApproach.to = targetX
    clockApproach.duration = Math.max(480, Math.min(6000, Math.round(Math.abs(targetX - petX) / 180 * 1000)))
    clockApproach.restart()
  }
  function startClockTransit(destination, transitDirection) {
    if (!isPenguin || !placed || clockApproach.running || clockOcclusion.running || clockTransitOcclusion.running) return
    walkMotion.stop(); poseTimer.stop(); curiosityAnimation.stop(); idleActionTimer.stop()
    clockTransit = true
    clockTransitDirection = transitDirection
    clockTransitDestination = clampX(destination)
    clockTransitEpisode = episodeName
    episodeName = "clock-cross"
    direction = transitDirection
    targetX = transitDirection < 0 ? passageRightX + 3 : passageLeftX - petWidth - 3
    action = "clockApproach"; walkFrame = 0; animalOpacity = 1
    clockApproach.from = petX; clockApproach.to = targetX
    clockApproach.duration = Math.max(420, Math.min(6000, Math.round(Math.abs(targetX - petX) / Math.max(180, pace) * 1000)))
    clockApproach.restart()
  }
  function finishClockTransit() {
    var destination = clockTransitDestination
    episodeName = clockTransitEpisode
    clockTransitEpisode = ""
    clockTransit = false
    clockPassages++
    rememberEvent("Took the hidden passage behind the clock.", 1)
    saveState()
    action = "curious"; animalOpacity = 1
    startLeg(destination)
  }
  function finishClockEpisode() {
    animalOpacity = 1
    direction = 1
    petX = clockStyle === "magic" ? magicEmergeX() : clockClearRightX()
    retreatQueued = false
    if (clockStyle === "shy" || episodeName === "clock-retreat") {
      suspiciousRetreats++
      rememberEvent(episodeName === "clock-retreat"
        ? "Retreated behind the clock. Remains suspicious."
        : "Peeked out, reconsidered, and hid again.", 2)
    } else if (clockStyle === "chase") {
      clockPassages++
      // Toy tumbles out first; he claims it with residual dignity.
      if (clockChaseItem !== "") {
        discoveryItem = clockChaseItem
        discoveryX = clampX(passageRightX + 16)
        discoveryVisible = true
        toyHop = 0; toySpin = 25; toyBumps = Math.max(1, toyBumps)
        if (!reducedMotion) toyHopBounce.restart()
        carriedItem = clockChaseItem
        discoveryVisible = false
        discoveryItem = ""
        rememberEvent(clockChaseItem === "pebble" ? "Chased a pebble behind the clock and won. Debatably."
          : clockChaseItem === "leaf" ? "Pursued a leaf into the clock. Retrieved with leaves in places."
          : "A tiny star tried the clock shortcut. He disagreed.", 2)
      } else {
        rememberEvent("Chased something behind the clock. It escaped into Time.", 2)
      }
      clockChaseItem = ""
    } else if (clockStyle === "tumble") {
      clockPassages++
      rememberEvent("Got stuck behind the clock. Emerged with questionable grace.", 2)
    } else if (clockStyle === "magic") {
      clockPassages++
      rememberEvent("Vanished into the clock. Wrong peek. Reappeared. Magicians hate this.", 2)
    } else {
      clockPassages++
      rememberEvent("Stared down the clock. Time blinked first.", 2)
    }
    episodeName = ""
    var tumbleOut = clockStyle === "tumble" && !reducedMotion
    clockStyle = ""
    clearStoryProp()
    saveState()
    if (tumbleOut) {
      // Rare clumsy exit — a short slip sells the stuck beat.
      startSlip()
      return
    }
    startReturn()
  }
  function startReturn() {
    journeyPhase = "returning"; pauseOnRoute = false
    if (activityLevel === 0) personalityMood = "sleepy"
    // Den renders at homeX — returning to doorwayX made sleep look like a teleport jump.
    if (isPenguin) { pendingDestination = homeX; poseFrame = 0; action = "starting"; poseTimer.interval = 110; poseTimer.restart() }
    else startLeg(homeX)
  }
  function beginEntering() {
    if (isPenguin) {
      direction = -1
      petX = homeX
      poseFrame = 0; action = "settling"; poseTimer.interval = 150; poseTimer.restart()
    } else { poseFrame = 7; action = "entering"; poseTimer.interval = 145; poseTimer.restart() }
  }
  function startSlide() {
    if (!isPenguin || !placed || slideMotion.running) return
    markEpisode("slide")
    walkMotion.stop(); poseTimer.stop(); curiosityAnimation.stop(); playfulAnimation.stop(); idleActionTimer.stop()
    var rightRoom = worldMaxX - petX
    var leftRoom = petX - worldMinX
    direction = rightRoom >= 105 || rightRoom >= leftRoom ? 1 : -1
    personalityMood = "playful"; episodeName = "belly-slide"
    targetX = clampX(petX + direction * (72 + Math.random() * 58))
    poseFrame = 0; action = "sliding"
    slideMotion.from = petX; slideMotion.to = targetX; slideMotion.restart(); slideTimer.restart()
  }
  function startSlip() {
    if (!isPenguin || !placed) return
    markEpisode("slip")
    walkMotion.stop(); poseTimer.stop(); curiosityAnimation.stop(); idleActionTimer.stop(); idleBlendAnimation.stop(); idleTransitionMotion.stop()
    var rightRoom = worldMaxX - petX
    var leftRoom = petX - worldMinX
    if ((direction > 0 && rightRoom < 38) || (direction < 0 && leftRoom < 38)) direction *= -1
    targetX = clampX(petX + direction * (32 + Math.random() * 24))
    poseFrame = 0; action = "slipping"; personalityMood = "playful"; episodeName = "slip"
    slipMotion.from = petX; slipMotion.to = targetX; slipMotion.restart()
    slipTimer.interval = 95; slipTimer.restart()
  }
  function finishSlip() {
    petX = targetX
    slipsCompleted++
    rememberEvent("Slipped. Nobody noticed.", 1)
    saveState()
    if (retreatQueued) { retreatQueued = false; startClockEpisode(true) }
    else if (playfulQueued) { playfulQueued = false; startSlide() }
    else { idleBeatsRemaining = 2; showIdleBeat() }
  }
  function storyDelay(milliseconds) {
    storyTimer.interval = milliseconds
    storyTimer.restart()
  }
  function resetStoryVisuals() {
    storyTimer.stop()
    clearStoryProp()
    clearHeadProp()
    storyPetOffset = 0
    hoopVisible = false; hoopOpacity = 0; hoopScale = 1; hoopGlow = 0
    cannonVisible = false; cannonOpacity = 0; cannonScale = 1; cannonFlash = false
    storyPetInFront = false
    animal.sniffRotation = 0; animal.hopOffset = 0
  }
  function startQueuedStory() {
    if (storyQueued === "") { beginIdleRoutine(); return }
    storyName = storyQueued; storyQueued = ""; storyStage = 0
    episodeName = storyName; previousIdleFrame = -1; action = "idleAction"
    advanceStory()
  }
  function finishStory() {
    var notes = {
      "edge-watch": "Confirmed the open lane still has a quiet gap.",
      "firefly": "Followed a tiny light until it vanished.",
      "polish": "Polished one pebble to a respectable shine.",
      "leaf-toss": "A leaf briefly became excellent entertainment.",
      "stargaze": "Stayed up to watch a very small star.",
      "collection-sort": "Rearranged the collection. Again.",
      "stretch": "Completed a surprisingly serious stretch.",
      "lost-pebble": "Recovered a pebble attempting an escape.",
      "listen": "Heard something behind the clock. Probably time.",
      "fire-hoop": hoopSuccess
        ? "Sprinted through a flame gate on the bar. Clean."
        : "Misjudged a flame gate. Singed dignity.",
      "parade-leaf": "Wore a leaf as a hat and marched with a flag. The leaf resigned mid-parade.",
      "sumo-pebble": sumoWin
        ? "Shoulder-checked a pebble. The pebble reconsidered its life choices."
        : "Challenged a pebble to sumo. The pebble won.",
      "cannon": cannonStick
        ? "Fired a cannonball, then himself. Stuck the landing."
        : "The cannonball flew true. The penguin did not.",
      "rain-umbrella": "Sheltered under a leaf. The rain was mostly theoretical.",
      "fishing": "Fished a bar-lane puddle. Catch and release. Mostly release.",
      "sneeze": "Sneezed hard enough to relocate himself.",
      "zoomies": "Completed three unauthorized laps. No notes.",
      "dusk-watch": "Watched the bar go gold. Did not clock out.",
      "show-and-tell": "Presented a favorite find. Audience: the bar."
    }
    if (notes[storyName]) rememberEvent(notes[storyName], storyName === "stargaze" ? 2 : 1)
    resetStoryVisuals(); storyName = ""; episodeName = ""; saveState()
    beginIdleRoutine()
  }
  function advanceStory() {
    var stage = storyStage++
    action = "idleAction"
    if (storyName === "edge-watch") {
      if (stage === 0) { idleFrame = 2; animal.sniffRotation = direction * 8; storyDelay(720) }
      else if (stage === 1) { idleFrame = 0; animal.sniffRotation = direction * -7; animal.hopOffset = 1.5; storyDelay(980) }
      else if (stage === 2) { idleFrame = 7; animal.sniffRotation = 0; animal.hopOffset = 0; storyDelay(620) }
      else finishStory()
    } else if (storyName === "firefly") {
      if (stage === 0) { idleFrame = 0; setStoryProp("firefly", petX + petWidth + 4, Math.round(habitat.height * 0.35), 0.95, 0.85); storyDelay(520) }
      else if (stage === 1) { idleFrame = 1; storyPropX += direction * 22; storyPropY = 2; storyPropScale = 1.25; animal.sniffRotation = direction * 6; storyDelay(720) }
      else if (stage === 2) { idleFrame = 2; storyPropX -= direction * 13; storyPropY = 13; storyPropScale = 0.72; animal.sniffRotation = direction * -5; storyDelay(680) }
      else if (stage === 3) { idleFrame = 7; storyPropX += direction * 34; storyPropY = 4; storyPropScale = 1.05; animal.hopOffset = -3; storyDelay(760) }
      else if (stage === 4) { clearStoryProp(); animal.hopOffset = 0; animal.sniffRotation = 0; storyDelay(480) }
      else finishStory()
    } else if (storyName === "polish") {
      if (stage === 0) { idleFrame = 3; setStoryProp("pebble", petX + petWidth - 5, barPropY(), 1, 1); storyDelay(700) }
      else if (stage === 1) { idleFrame = 0; animal.sniffRotation = 6; storyPropRotation = 28; storyDelay(620) }
      else if (stage === 2) { idleFrame = 2; animal.sniffRotation = -5; storyPropRotation = -24; storyDelay(620) }
      else if (stage === 3) { idleFrame = 7; storyPropKind = "star"; storyPropScale = 1.25; storyDelay(850) }
      else if (stage === 4) { clearStoryProp(); animal.sniffRotation = 0; storyDelay(420) }
      else finishStory()
    } else if (storyName === "leaf-toss") {
      if (stage === 0) { idleFrame = 4; setStoryProp("leaf", petX + petWidth - 2, barPropY(), 0.95, 1); storyDelay(480) }
      else if (stage === 1) { idleFrame = 5; storyPropX += direction * 18; storyPropY = 1; storyPropRotation = 95; animal.hopOffset = -3; storyDelay(720) }
      else if (stage === 2) { idleFrame = 7; storyPropX -= direction * 10; storyPropY = 11; storyPropRotation = 190; animal.hopOffset = 0; storyDelay(620) }
      else if (stage === 3) { idleFrame = 5; storyPropX += direction * 15; storyPropY = 4; storyPropRotation = 285; animal.hopOffset = -2; storyDelay(680) }
      else if (stage === 4) { clearStoryProp(); animal.hopOffset = 0; storyDelay(400) }
      else finishStory()
    } else if (storyName === "stargaze") {
      if (stage === 0) { idleFrame = 1; setStoryProp("star", petX + petWidth + 8, Math.round(habitat.height * 0.22), 0.45, 0.75); storyDelay(700) }
      else if (stage === 1) { idleFrame = 7; storyPropOpacity = 1; storyPropScale = 1.3; animal.sniffRotation = direction * -7; storyDelay(1500) }
      else if (stage === 2) { storyPropOpacity = 0.55; storyPropScale = 0.9; storyDelay(1100) }
      else if (stage === 3) { storyPropOpacity = 1; storyPropScale = 1.15; storyDelay(1300) }
      else if (stage === 4) { clearStoryProp(); animal.sniffRotation = 0; storyDelay(500) }
      else finishStory()
    } else if (storyName === "collection-sort") {
      if (stage === 0) { idleFrame = 3; setStoryProp(pebblesFound > 0 ? "pebble" : "leaf", petX + petWidth - 3, barPropY(), 1, 1); storyDelay(650) }
      else if (stage === 1) { idleFrame = 0; storyPropX += direction * 11; storyPropKind = leavesFound > 0 ? "leaf" : "pebble"; animal.sniffRotation = 5; storyDelay(700) }
      else if (stage === 2) { idleFrame = 2; storyPropX += direction * 10; storyPropKind = starsFound > 0 ? "star" : "pebble"; animal.sniffRotation = -5; storyDelay(700) }
      else if (stage === 3) { idleFrame = 7; storyPropX -= direction * 10; storyPropKind = "pebble"; animal.sniffRotation = 0; storyDelay(900) }
      else if (stage === 4) { clearStoryProp(); storyDelay(420) }
      else finishStory()
    } else if (storyName === "stretch") {
      if (stage === 0) { idleFrame = 6; animal.sniffRotation = direction * -4; storyDelay(780) }
      else if (stage === 1) { idleFrame = 3; animal.hopOffset = 2; storyDelay(620) }
      else if (stage === 2) { idleFrame = 4; animal.hopOffset = -2; animal.sniffRotation = direction * 5; storyDelay(720) }
      else if (stage === 3) { idleFrame = 7; animal.hopOffset = 0; animal.sniffRotation = 0; storyDelay(600) }
      else finishStory()
    } else if (storyName === "lost-pebble") {
      if (stage === 0) { idleFrame = 1; setStoryProp("pebble", petX + petWidth - 4, barPropY(), 1, 1); storyDelay(520) }
      else if (stage === 1) { idleFrame = 2; storyPropX += direction * 58; storyPropRotation = 180; animal.sniffRotation = direction * 9; storyDelay(850) }
      else if (stage === 2) { idleFrame = 5; storyPetOffset = direction * 24; animal.hopOffset = -3; storyDelay(650) }
      else if (stage === 3) { idleFrame = 0; storyPropX -= direction * 13; storyPetOffset = direction * 38; animal.hopOffset = 0; storyDelay(700) }
      else if (stage === 4) { idleFrame = 7; clearStoryProp(); storyPetOffset = 0; animal.sniffRotation = 0; storyDelay(520) }
      else finishStory()
    } else if (storyName === "listen") {
      if (stage === 0) { idleFrame = 0; setStoryProp("dots", passageRightX + 3, Math.round(habitat.height * 0.35), 0.4, 1); animal.sniffRotation = -6; storyDelay(900) }
      else if (stage === 1) { idleFrame = 1; storyPropOpacity = 0.9; animal.sniffRotation = 5; storyDelay(1200) }
      else if (stage === 2) { idleFrame = 2; storyPropScale = 1.25; animal.sniffRotation = -3; storyDelay(900) }
      else if (stage === 3) { idleFrame = 7; clearStoryProp(); animal.sniffRotation = 0; storyDelay(550) }
      else finishStory()
    } else if (storyName === "parade-leaf") {
      if (stage === 0) {
        direction = Math.random() < 0.5 ? -1 : 1
        idleFrame = 7
        headPropKind = "leaf-hat"
        headPropRotation = direction * -10
        headPropScale = 1.05
        setStoryProp("parade-flag", petX + (direction > 0 ? petWidth + 6 : -14), barPropY() - 6, 1, 1.05, direction * 8)
        animal.sniffRotation = direction * 3
        storyDelay(480)
      } else if (stage === 1) {
        idleFrame = 5
        storyPetOffset = direction * 30
        storyPropX = petX + storyPetOffset + (direction > 0 ? petWidth + 8 : -10)
        headPropRotation = direction * 8
        animal.hopOffset = -2
        storyDelay(500)
      } else if (stage === 2) {
        idleFrame = 5
        storyPetOffset = direction * 58
        storyPropX = petX + storyPetOffset + (direction > 0 ? petWidth + 6 : -8)
        headPropRotation = direction * -5
        animal.hopOffset = -2
        storyDelay(480)
      } else if (stage === 3) {
        idleFrame = 2
        headPropKind = ""
        setStoryProp("leaf-hat", petX + storyPetOffset + petWidth * 0.38, barPropY() - 8, 1, 1, direction * 130)
        animal.hopOffset = 0
        animal.sniffRotation = direction * -9
        storyDelay(420)
      } else if (stage === 4) {
        idleFrame = 0
        storyPropY = barPropY()
        storyPropRotation = direction * 210
        animal.sniffRotation = direction * 6
        storyDelay(500)
      } else if (stage === 5) {
        idleFrame = 3
        storyPropX = petX + storyPetOffset + petWidth * 0.52
        storyPropRotation = direction * 20
        storyPropScale = 0.95
        animal.hopOffset = -2
        storyDelay(460)
      } else if (stage === 6) {
        clearStoryProp()
        clearHeadProp()
        animal.hopOffset = 0
        commitStoryTravel()
        storyDelay(320)
      } else finishStory()
    } else if (storyName === "sumo-pebble") {
      if (stage === 0) {
        var roomRight = laneMaxX - (petX + petWidth)
        var roomLeft = petX - laneMinX
        direction = roomRight >= 60 || roomRight >= roomLeft ? 1 : -1
        sumoWin = Math.random() < 0.58
        idleFrame = 1
        setStoryProp("pebble", clampLaneX(petX + (direction > 0 ? 46 : -38)), barPropY(), 1, 1.15)
        animal.sniffRotation = direction * 10
        storyDelay(420)
      } else if (stage === 1) {
        // Pebble rolls in; penguin squares up
        idleFrame = 2
        storyPropX += direction * -10
        storyPropRotation = direction * -40
        animal.hopOffset = -1
        storyDelay(400)
      } else if (stage === 2) {
        // Charge
        idleFrame = 5
        storyPetOffset = direction * 22
        animal.hopOffset = -3
        animal.sniffRotation = direction * 4
        storyDelay(300)
      } else if (stage === 3) {
        // Impact
        idleFrame = 5
        storyPetOffset = direction * 34
        animal.hopOffset = 0
        if (sumoWin) {
          storyPropX = petX + storyPetOffset + (direction > 0 ? petWidth + 8 : -14)
          storyPropY = Math.round(habitat.height * 0.35)
          storyPropRotation = direction * 220
          storyPropScale = 1.3
          animal.sniffRotation = 0
          storyDelay(420)
        } else {
          // Pebble holds the line; penguin ricochets
          storyPropX = petX + storyPetOffset + (direction > 0 ? petWidth - 2 : -6)
          storyPropY = barPropY()
          storyPropRotation = direction * 25
          storyPetOffset = direction * 8
          animal.sniffRotation = direction * -12
          animal.hopOffset = 2
          storyDelay(360)
        }
      } else if (stage === 4) {
        if (sumoWin) {
          idleFrame = 7
          storyPropX += direction * 28
          storyPropY = barPropY()
          storyPropOpacity = 0.55
          storyPropScale = 1
          animal.hopOffset = -1
          storyDelay(520)
        } else {
          idleFrame = 2
          storyPropOpacity = 0.85
          animal.hopOffset = 0
          storyDelay(240)
        }
      } else if (stage === 5) {
        clearStoryProp()
        animal.sniffRotation = 0
        animal.hopOffset = 0
        if (!sumoWin) {
          finishStoryIntoSlip()
        } else {
          commitStoryTravel()
          storyDelay(340)
        }
      } else finishStory()
    } else if (storyName === "cannon") {
      if (stage === 0) {
        petX = clampLaneX(homeX)
        cannonStick = Math.random() < 0.62
        clearStoryProp()
        clearHeadProp()
        stageCannonPair()
        cannonVisible = true
        cannonOpacity = 1
        cannonScale = 1
        cannonFlash = false
        storyPetInFront = true
        storyPetOffset = 0
        idleFrame = 3
        animal.sniffRotation = direction * 5
        animal.hopOffset = 0
        animalOpacity = 1
        storyDelay(560)
      } else if (stage === 1) {
        // Lean toward the breech — still fully beside the barrel, not inside it.
        idleFrame = 2
        storyPetInFront = true
        storyPetOffset = direction * 5
        animal.hopOffset = -1
        animal.sniffRotation = direction * 8
        animalOpacity = 1
        storyDelay(420)
      } else if (stage === 2) {
        commitStoryTravel()
        idleFrame = 3
        storyPetOffset = 0
        animal.hopOffset = 0
        animalOpacity = 0
        storyDelay(320)
      } else if (stage === 3) {
        // Ball first — Pebble is already gone.
        idleFrame = 3
        cannonFlash = true
        storyDelay(220)
      } else if (stage === 4) {
        cannonFlash = false
        cannonVisible = false
        storyPetInFront = true
        petX = clampLaneX(cannonLaunchX())
        action = "sliding"
        poseFrame = 0
        animalOpacity = 1
        animal.hopOffset = -2
        var sail = Math.min(140, Math.max(70, Math.abs((direction > 0 ? laneMaxX : laneMinX) - petX) * 0.72))
        storyPetOffset = direction * sail
        animal.sniffRotation = direction * 6
        storyDelay(620)
      } else if (stage === 5) {
        action = "idleAction"
        animal.hopOffset = 0
        animal.sniffRotation = cannonStick ? 0 : direction * -10
        idleFrame = cannonStick ? 7 : 2
        storyDelay(cannonStick ? 480 : 240)
      } else if (stage === 6) {
        if (!cannonStick) finishStoryIntoSlip()
        else { commitStoryTravel(); storyDelay(300) }
      } else finishStory()
    } else if (storyName === "rain-umbrella") {
      if (stage === 0) {
        direction = Math.random() < 0.5 ? -1 : 1
        idleFrame = 7
        headPropKind = "umbrella"
        headPropRotation = direction * -14
        headPropScale = 1.1
        setStoryProp("rain-drop", petX + petWidth * 0.55, barPropY() - 2, 0.65, 0.9)
        storyDelay(420)
      } else if (stage === 1) {
        idleFrame = 3
        headPropRotation = direction * 10
        storyPropKind = "rain-drop"
        storyPropX += direction * 6
        storyPropY = barPropY() - 4
        storyPropOpacity = 0.8
        animal.sniffRotation = 4
        storyDelay(520)
      } else if (stage === 2) {
        idleFrame = 5
        storyPetOffset = direction * 24
        headPropRotation = direction * -8
        storyPropX += direction * 10
        storyPropY = barPropY() - 3
        storyPropOpacity = 0.95
        storyDelay(520)
      } else if (stage === 3) {
        idleFrame = 5
        storyPetOffset = direction * 46
        headPropRotation = direction * 6
        storyPropX += direction * 8
        storyPropOpacity = 0.85
        storyDelay(520)
      } else if (stage === 4) {
        idleFrame = 7
        clearStoryProp()
        clearHeadProp()
        animal.sniffRotation = 0
        commitStoryTravel()
        storyDelay(400)
      } else finishStory()
    } else if (storyName === "fishing") {
      if (stage === 0) {
        // Mid-lane puddle cast — never tray-icon ends.
        petX = stageOpenLaneClear(0.42)
        direction = Math.random() < 0.5 ? -1 : 1
        idleFrame = 1
        setStoryProp("puddle", petX - 8, barPropY() + 1, 0.95, 1)
        animal.sniffRotation = direction * 6
        storyDelay(500)
      } else if (stage === 1) {
        idleFrame = 0
        storyPropKind = "fishing-rod"
        storyPropX = petX + (direction > 0 ? petWidth - 6 : -8)
        storyPropY = barPropY() - 10
        storyPropRotation = direction * -22
        storyPropOpacity = 1
        animal.sniffRotation = direction * -4
        storyDelay(700)
      } else if (stage === 2) {
        idleFrame = 2
        storyPropKind = "line"
        storyPropX = petX + (direction > 0 ? 22 : -10)
        storyPropY = barPropY() - 4
        storyPropRotation = 0
        storyPropScale = 1
        animal.hopOffset = -1
        storyDelay(520)
      } else if (stage === 3) {
        idleFrame = 2
        storyPropX = petX + (direction > 0 ? 18 : -12)
        storyPropY = barPropY() + 1
        if (Math.random() < 0.55) {
          storyPropKind = "star"
          storyPropScale = 1.1
        } else {
          storyPropKind = "firefly"
          storyPropScale = 0.85
        }
        animal.hopOffset = -1
        storyDelay(520)
      } else if (stage === 4) {
        idleFrame = 7
        storyPropX = petX + petWidth * 0.45
        storyPropY = barPropY()
        animal.hopOffset = 0
        animal.sniffRotation = 0
        storyDelay(560)
      } else if (stage === 5) {
        clearStoryProp()
        storyDelay(320)
      } else finishStory()
    } else if (storyName === "sneeze") {
      if (stage === 0) {
        direction = Math.random() < 0.5 ? -1 : 1
        idleFrame = 2
        animal.sniffRotation = direction * 8
        setStoryProp("dots", petX + petWidth * 0.4, Math.round(habitat.height * 0.28), 0.7, 1)
        storyDelay(420)
      } else if (stage === 1) {
        idleFrame = 0
        animal.sniffRotation = direction * -10
        storyPropOpacity = 1
        storyDelay(380)
      } else if (stage === 2) {
        idleFrame = 5
        storyPropKind = "bang"
        storyPetOffset = direction * 48
        animal.hopOffset = -2
        animal.sniffRotation = direction * 14
        storyDelay(360)
      } else if (stage === 3) {
        animal.hopOffset = 0
        idleFrame = 2
        clearStoryProp()
        animal.sniffRotation = direction * -6
        storyDelay(400)
      } else if (stage === 4) {
        commitStoryTravel()
        animal.sniffRotation = 0
        storyDelay(280)
      } else finishStory()
    } else if (storyName === "zoomies") {
      if (stage === 0) {
        direction = Math.random() < 0.5 ? -1 : 1
        idleFrame = 5
        animal.hopOffset = -1
        storyDelay(180)
      } else if (stage === 1) {
        storyPetOffset = direction * 36
        storyDelay(220)
      } else if (stage === 2) {
        direction *= -1
        storyPetOffset = direction * 28
        idleFrame = 5
        storyDelay(200)
      } else if (stage === 3) {
        direction *= -1
        storyPetOffset = direction * 42
        storyDelay(220)
      } else if (stage === 4) {
        direction *= -1
        storyPetOffset = direction * 18
        idleFrame = 2
        animal.hopOffset = 0
        storyDelay(280)
      } else if (stage === 5) {
        commitStoryTravel()
        idleFrame = 7
        storyDelay(320)
      } else finishStory()
    } else if (storyName === "fire-hoop") {
      if (stage === 0) {
        var roomRight = laneMaxX - (petX + petWidth)
        var roomLeft = petX - laneMinX
        direction = roomRight >= 70 || roomRight >= roomLeft ? 1 : -1
        var gap = Math.min(78, Math.max(48, (direction > 0 ? roomRight : roomLeft) * 0.55))
        var gateCenter = clampLaneX(petX + (direction > 0 ? gap : -gap - 10))
        hoopX = gateCenter - hoopGateWidth * 0.5
        hoopY = barPropY()
        hoopVisible = true
        hoopOpacity = 0
        hoopScale = 1
        hoopGlow = 0
        hoopSuccess = Math.random() < 0.72
        storyPetInFront = false
        idleFrame = 1
        animal.sniffRotation = direction * 6
        animal.hopOffset = 0
        storyDelay(320)
      } else if (stage === 1) {
        hoopOpacity = 1
        idleFrame = 5
        storyPetOffset = (hoopX + hoopGateWidth * 0.5 - petX - petWidth * 0.5) - direction * 22
        animal.sniffRotation = direction * 4
        hoopGlow = 0.45
        storyDelay(400)
      } else if (stage === 2) {
        idleFrame = 5
        storyPetInFront = true
        storyPetOffset = (hoopX + hoopGateWidth * 0.5 - petX - petWidth * 0.5)
        hoopGlow = 0.85
        storyDelay(360)
      } else if (stage === 3) {
        idleFrame = 5
        storyPetOffset = (hoopX + hoopGateWidth * 0.5 - petX - petWidth * 0.5) + direction * 24
        hoopGlow = 1
        storyDelay(380)
      } else if (stage === 4) {
        storyPetInFront = false
        storyPetOffset = (hoopX + hoopGateWidth * 0.5 - petX - petWidth * 0.5) + direction * 38
        hoopGlow = 0.3
        animal.sniffRotation = hoopSuccess ? 0 : direction * -8
        idleFrame = hoopSuccess ? 7 : 2
        storyDelay(hoopSuccess ? 480 : 280)
      } else if (stage === 5) {
        hoopOpacity = 0
        hoopGlow = 0
        animal.sniffRotation = 0
        if (!hoopSuccess) finishStoryIntoSlip()
        else { commitStoryTravel(); storyDelay(360) }
      } else finishStory()
    } else if (storyName === "dusk-watch") {
      if (stage === 0) {
        petX = stageOpenLaneClear(0.58)
        direction = -1
        idleFrame = 1
        clearHeadProp()
        setStoryProp("star", petX - 12, Math.round(habitat.height * 0.20), 0.55, 0.88)
        animal.sniffRotation = -5
        animal.hopOffset = 0
        storyDelay(720)
      } else if (stage === 1) {
        idleFrame = 7
        storyPropOpacity = 1
        storyPropScale = 1.2
        animal.sniffRotation = -8
        storyDelay(1500)
      } else if (stage === 2) {
        idleFrame = 0
        storyPropOpacity = 0.72
        animal.hopOffset = -1
        storyDelay(1100)
      } else if (stage === 3) {
        idleFrame = 7
        storyPropScale = 0.92
        animal.hopOffset = 0
        animal.sniffRotation = -3
        storyDelay(900)
      } else if (stage === 4) {
        clearStoryProp()
        animal.sniffRotation = 0
        storyDelay(380)
      } else finishStory()
    } else if (storyName === "show-and-tell") {
      if (stage === 0) {
        var kind = favoritePropKind !== "" ? favoritePropKind : "pebble"
        direction = Math.random() < 0.5 ? -1 : 1
        idleFrame = 3
        setStoryProp(kind, petX + (direction > 0 ? petWidth - 4 : -10), barPropY(), 1, 1.1)
        animal.sniffRotation = direction * 6
        storyDelay(520)
      } else if (stage === 1) {
        idleFrame = 7
        storyPropY = barPropY() - 6
        storyPropScale = 1.25
        animal.hopOffset = -2
        storyDelay(700)
      } else if (stage === 2) {
        idleFrame = 5
        storyPetOffset = direction * 28
        storyPropX = petX + storyPetOffset + (direction > 0 ? petWidth + 4 : -12)
        animal.hopOffset = -2
        storyDelay(520)
      } else if (stage === 3) {
        idleFrame = 7
        storyPropRotation = direction * 25
        animal.hopOffset = 0
        animal.sniffRotation = 0
        storyDelay(720)
      } else if (stage === 4) {
        idleFrame = 3
        storyPropY = barPropY()
        storyPropScale = 1
        storyPropOpacity = 0.7
        commitStoryTravel()
        storyDelay(460)
      } else if (stage === 5) {
        clearStoryProp()
        storyDelay(320)
      } else finishStory()
    } else finishStory()
  }
  function commitStoryTravel() {
    if (storyPetOffset === 0) return
    petX = clampX(petX + storyPetOffset)
    storyPetOffset = 0
  }
  function finishStoryIntoSlip() {
    var notes = storyName === "sumo-pebble"
      ? "Challenged a pebble to sumo. The pebble won."
      : storyName === "cannon"
      ? "Launched from a bar-lane cannon. Landing negotiations failed."
      : storyName === "fire-hoop"
      ? "Misjudged a flame gate. Singed dignity."
      : "Attempted the hoop. Physics filed a complaint."
    rememberEvent(notes, 2)
    commitStoryTravel()
    resetStoryVisuals()
    storyName = ""
    episodeName = ""
    saveState()
    if (!reducedMotion && isPenguin) startSlip()
    else beginIdleRoutine()
  }
  function cancelStory() {
    resetStoryVisuals(); storyQueued = ""; storyName = ""; storyStage = 0
  }
  function startHomeMoment() {
    if (!sleeping || rustling || snoozed || barHidden) { schedulePeek(); return }
    deepSleeping = false; sleepMarkerTimer.stop()
    var roll = Math.random()
    var night = isNight()
    var dusk = isDusk()
    var bonded = daysTogether >= 4 || outings >= 25
    var packed = collectionSize() >= 6
    var hasTreasure = collectionSize() >= 1
    if (!isPenguin && roll < 0.48) { peekAnimation.restart(); return }
    if (isPenguin) {
      if (activityLevel === 0) {
        if (dusk && roll < 0.34) homeStoryName = "dusk-nest"
        else if (night && roll < 0.46) homeStoryName = "night-dream"
        else if (roll < 0.42) homeStoryName = "dream"
        else if (hasTreasure && roll < 0.58) homeStoryName = "nest-show"
        else if (leavesFound > 0 && roll < 0.72) homeStoryName = "nest-hat"
        else homeStoryName = "nest-rustle"
      } else {
        if (dusk && roll < 0.24) homeStoryName = "dusk-nest"
        else if (night && bonded && roll > 0.78) homeStoryName = "night-dream"
        else if (leavesFound > 0 && roll < 0.12) homeStoryName = "nest-hat"
        else if (hasTreasure && roll < 0.16) homeStoryName = "nest-show"
        else if (packed && roll < 0.22) homeStoryName = "nest-tidy"
        else if (roll < 0.22) homeStoryName = "wake-look"
        else if (roll < 0.42) homeStoryName = "preen"
        else if (roll < 0.68) homeStoryName = "dream"
        else if (night && roll > 0.84) homeStoryName = "night-dream"
        else homeStoryName = "nest-tidy"
      }
    } else {
      homeStoryName = night && roll > 0.84 ? "night-dream" : dusk && roll < 0.3 ? "dusk-nest" : roll < 0.74 ? "dream" : "nest-tidy"
    }
    homeStoryStage = 0
    if (bonded && Math.random() < (activityLevel === 0 ? 0.34 : 0.2))
      rememberEvent(homeStoryName === "night-dream" ? "Shared a quiet night watch from the nest."
        : homeStoryName === "dusk-nest" ? "Watched evening settle over the bar from the nest."
        : homeStoryName === "nest-hat" ? "Tried a leaf as a sleep cap. Approved, mostly."
        : homeStoryName === "nest-show" ? "Lined up a favorite find beside the nest."
        : homeStoryName === "nest-tidy" ? "Re-sorted the treasures by the nest."
        : homeStoryName === "nest-rustle" ? "Rustled in the nest and settled deeper."
        : homeStoryName === "preen" ? "Took a careful moment to tidy up."
        : "Stretched, peeked, and settled again.", 0)
    advanceHomeStory()
  }
  function homeStoryDelay(milliseconds) {
    homeMomentTimer.interval = milliseconds
    homeMomentTimer.restart()
  }
  function cancelHomeStory() {
    homeMomentTimer.stop(); homeStoryName = ""; homeStoryStage = 0
    homePoseFrame = 0
    clearStoryProp()
    den.rustleRotation = 0
  }
  function finishHomeStory() { cancelHomeStory(); schedulePeek(); scheduleSleepMarker() }
  function advanceHomeStory() {
    var stage = homeStoryStage++
    if (homeStoryName === "wake-look") {
      if (stage === 0) { homePoseFrame = 3; den.rustleRotation = -1.2; homeStoryDelay(620) }
      else if (stage === 1) { homePoseFrame = 0; den.rustleRotation = 1.5; homeStoryDelay(780) }
      else if (stage === 2) { homePoseFrame = 2; den.rustleRotation = -1; homeStoryDelay(680) }
      else if (stage === 3) { den.rustleRotation = 0; homeStoryDelay(420) }
      else finishHomeStory()
    } else if (homeStoryName === "preen") {
      if (stage === 0) { homePoseFrame = 6; den.rustleRotation = 1.2; homeStoryDelay(720) }
      else if (stage === 1) { homePoseFrame = 0; den.rustleRotation = -1; homeStoryDelay(560) }
      else if (stage === 2) { homePoseFrame = 6; den.rustleRotation = 1; homeStoryDelay(680) }
      else if (stage === 3) { den.rustleRotation = 0; homeStoryDelay(420) }
      else finishHomeStory()
    } else if (homeStoryName === "dream") {
      if (stage === 0) { setStoryProp("firefly", homeX + petWidth - 5, Math.round(habitat.height * 0.4), 0.45, 0.7); homeStoryDelay(650) }
      else if (stage === 1) { storyPropKind = "bubble"; storyPropX += 7; storyPropY = Math.round(habitat.height * 0.3); storyPropOpacity = 0.8; storyPropScale = 0.9; homeStoryDelay(800) }
      else if (stage === 2) { storyPropKind = "dots"; storyPropX += 6; storyPropY = Math.round(habitat.height * 0.22); storyPropOpacity = 0.9; storyPropScale = 1.05; homeStoryDelay(900) }
      else if (stage === 3) { clearStoryProp(); homeStoryDelay(400) }
      else finishHomeStory()
    } else if (homeStoryName === "nest-tidy") {
      if (stage === 0) { setStoryProp(favoriteItem === "pebbles" ? "pebble" : favoriteItem === "leaves" ? "leaf" : favoriteItem === "stars" ? "star" : "firefly", homeX + petWidth - 8, barPropY(), 0.85, 1); den.rustleRotation = -1.8; homeStoryDelay(480) }
      else if (stage === 1) { storyPropX += 9; storyPropRotation = 80; den.rustleRotation = 1.8; homeStoryDelay(520) }
      else if (stage === 2) { storyPropX -= 5; clearStoryProp(); den.rustleRotation = -0.8; homeStoryDelay(450) }
      else finishHomeStory()
    } else if (homeStoryName === "night-dream") {
      if (stage === 0) { setStoryProp("star", homeX + petWidth + 2, Math.round(habitat.height * 0.22), 0.35, 0.7); homeStoryDelay(750) }
      else if (stage === 1) { storyPropOpacity = 0.95; storyPropScale = 1.2; homeStoryDelay(1100) }
      else if (stage === 2) { storyPropOpacity = 0.4; storyPropScale = 0.8; homeStoryDelay(850) }
      else if (stage === 3) { clearStoryProp(); homeStoryDelay(420) }
      else finishHomeStory()
    } else if (homeStoryName === "dusk-nest") {
      if (stage === 0) {
        if (activityLevel !== 0) homePoseFrame = 3
        else sleepFrame = 1
        den.rustleRotation = -1; setStoryProp("star", homeX + petWidth + 4, Math.round(habitat.height * 0.18), 0.5, 0.85); homeStoryDelay(700)
      } else if (stage === 1) {
        if (activityLevel !== 0) homePoseFrame = 0
        else sleepFrame = 2
        storyPropOpacity = 1; storyPropScale = 1.15; homeStoryDelay(1200)
      } else if (stage === 2) {
        if (activityLevel !== 0) homePoseFrame = 2
        else sleepFrame = 0
        storyPropOpacity = 0.65; den.rustleRotation = 0.8; homeStoryDelay(900)
      } else if (stage === 3) { clearStoryProp(); den.rustleRotation = 0; homeStoryDelay(420) }
      else finishHomeStory()
    } else if (homeStoryName === "nest-show") {
      if (stage === 0) { setStoryProp(favoritePropKind !== "" ? favoritePropKind : "pebble", homeX + petWidth - 6, barPropY(), 0.95, 1.1); den.rustleRotation = -1.4; homeStoryDelay(560) }
      else if (stage === 1) { storyPropY = barPropY() - 4; storyPropScale = 1.2; den.rustleRotation = 1.2; homeStoryDelay(720) }
      else if (stage === 2) { storyPropY = barPropY(); storyPropRotation = 20; den.rustleRotation = -0.6; homeStoryDelay(640) }
      else if (stage === 3) { clearStoryProp(); den.rustleRotation = 0; homeStoryDelay(380) }
      else finishHomeStory()
    } else if (homeStoryName === "nest-hat") {
      if (activityLevel === 0) {
        if (stage === 0) { sleepFrame = 1; den.rustleRotation = 1.2; homeStoryDelay(820) }
        else if (stage === 1) { sleepFrame = 2; den.rustleRotation = -0.8; homeStoryDelay(900) }
        else if (stage === 2) { sleepFrame = 0; den.rustleRotation = 0.5; homeStoryDelay(640) }
        else if (stage === 3) { den.rustleRotation = 0; homeStoryDelay(400) }
        else finishHomeStory()
      } else {
        if (stage === 0) { homePoseFrame = 6; den.rustleRotation = 1.4; homeStoryDelay(680) }
        else if (stage === 1) { homePoseFrame = 0; den.rustleRotation = -1; homeStoryDelay(720) }
        else if (stage === 2) { homePoseFrame = 6; den.rustleRotation = 0.8; homeStoryDelay(640) }
        else if (stage === 3) { den.rustleRotation = 0; homeStoryDelay(400) }
        else finishHomeStory()
      }
    } else if (homeStoryName === "nest-rustle") {
      if (stage === 0) { sleepFrame = 1; den.rustleRotation = -0.8; homeStoryDelay(520) }
      else if (stage === 1) { sleepFrame = 2; den.rustleRotation = 1; homeStoryDelay(680) }
      else if (stage === 2) { sleepFrame = 0; den.rustleRotation = -0.5; homeStoryDelay(560) }
      else if (stage === 3) { den.rustleRotation = 0; homeStoryDelay(400) }
      else finishHomeStory()
    } else finishHomeStory()
  }
  function curlUp() {
    cancelStory(); cancelHomeStory()
    action = "home"; journeyPhase = "home"; petX = homeX; poseFrame = 0; pokeCount = 0
    sleepFrame = 0; idleBeatsRemaining = 0; outingActsRemaining = 0; playfulQueued = false; retreatQueued = false; clockQueued = false; slipQueued = false
    episodeName = ""; clockTransit = false; clockTransitEpisode = ""; clockStyle = ""; clockChaseItem = ""; animalOpacity = 1; discoveryVisible = false; discoveryItem = ""; toyVx = 0; toyFumblePending = false; toyEdgeHits = 0; personalityMood = "sleepy"
    animal.sniffRotation = 0; animal.hopOffset = 0; animal.breathScale = 1
    peeking = false; rustling = false; peekOpacity = 0; scheduleRoam(); schedulePeek(); scheduleSleepMarker()
  }
  function goHomeGracefully() {
    // Prefer a visible walk home so he does not vanish mid-bar and pop into the nest.
    if (sleeping || barHidden || !placed) { goToSleep(); return }
    if (Math.abs(petX - homeX) < 32) { beginEntering(); return }
    close()
    storyQueued = ""
    episodeName = ""
    playfulQueued = false
    retreatQueued = false
    clockQueued = false
    slipQueued = false
    chaseTargetX = -1
    startReturn()
  }
  function goToSleep() {
    walkMotion.stop(); curiosityAnimation.stop(); acknowledgeAnimation.stop(); playfulAnimation.stop()
    rustleAnimation.stop(); settleTurn.stop(); poseTimer.stop(); conceptTravel.stop(); slideMotion.stop(); slideTimer.stop()
    slipMotion.stop(); slipTimer.stop(); clockApproach.stop(); clockOcclusion.stop(); clockTransitOcclusion.stop()
    idleActionTimer.stop(); idleBlendAnimation.stop(); idleTransitionMotion.stop()
    animalOpacity = 1
    chaseTargetX = -1
    pendingInteractiveWake = false
    curlUp()
  }
  function poke() {
    if (snoozed) cancelSnooze()
    if (sleeping && rustling) forceWake()
    var now = Date.now()
    pokeCount = now - lastPoke < 2200 ? Math.min(3, pokeCount + 1) : 1; lastPoke = now
    totalPokes++; saveState()
    pokeCue = ""
    if (sleeping) {
      var wakeRoll = Math.random()
      if (!reducedMotion && isPenguin && wakeRoll < 0.28) {
        wakeAndWalk(true)
        playfulQueued = true
      } else if (!reducedMotion && isPenguin && wakeRoll < 0.48) {
        retreatQueued = true
        wakeAndWalk(true)
      } else if (!reducedMotion && wakeRoll < 0.68) {
        playMood = Math.random() < 0.5 ? 1 : -1
        wakeAndWalk(true)
      } else {
        wakeAndWalk(true)
      }
      return
    }
    if (posing) {
      if (!reducedMotion && pokeCount >= 3 && isPenguin) retreatQueued = true
      else if (!reducedMotion && pokeCount >= 2 && isPenguin) playfulQueued = true
      return
    }
    if (storyName !== "") cancelStory()
    walkMotion.stop(); curiosityAnimation.stop(); acknowledgeAnimation.stop(); playfulAnimation.stop()
    // Poke chain still unlocks slide / clock hide; first poke often rolls a surprise.
    if (!reducedMotion && pokeCount >= 3 && isPenguin) {
      startClockEpisode(true)
    } else if (!reducedMotion && pokeCount >= 2 && isPenguin) {
      startSlide()
    } else if (pokeCount >= 2) {
      playfulAnimation.restart()
    } else if (!reducedMotion && activityLevel === 2 && Math.random() < 0.14) {
      var stunts = []
      if (episodeReady("fire-hoop")) stunts.push("fire-hoop")
      if (leavesFound > 0 && episodeReady("parade-leaf")) stunts.push("parade-leaf")
      if (pebblesFound > 0 && episodeReady("sumo-pebble")) stunts.push("sumo-pebble")
      if (episodeReady("cannon")) stunts.push("cannon")
      if (leavesFound > 0 && episodeReady("rain-umbrella")) stunts.push("rain-umbrella")
      if (episodeReady("fishing")) stunts.push("fishing")
      if (episodeReady("sneeze")) stunts.push("sneeze")
      if (episodeReady("zoomies")) stunts.push("zoomies")
      if (stunts.length > 0) {
        var pick = stunts[Math.floor(Math.random() * stunts.length)]
        queueEpisode(pick)
        if (storyQueued === pick) startQueuedStory()
      } else if (Math.random() < 0.55) {
        playfulAnimation.restart()
      }
    } else if (!reducedMotion && Math.random() < 0.55) {
      var antic = Math.floor(Math.random() * 6)
      if (antic === 0 && isPenguin) startSlip()
      else if (antic === 1 && isPenguin) startSlide()
      else if (antic === 2) {
        playMood = -1
        scootAlongBar((cursorBarX >= 0 && cursorBarX < petX + petWidth * 0.5 ? 70 : -70), 3.0)
      } else if (antic === 3) {
        playMood = 1
        if (cursorBarX >= 0) {
          var toward = clampX(cursorBarX - petWidth * 0.5)
          scootAlongBar(toward - petX, 3.2)
        } else playfulAnimation.restart()
      } else if (antic === 4) playfulAnimation.restart()
      else acknowledgeAnimation.restart()
      if (Math.random() < 0.35) rememberEvent("Got startled by a poke.", 0)
    } else {
      acknowledgeAnimation.restart()
    }
  }
  function telegraphPoke(message) {
    // Tips removed — keep poke chaining without on-bar text.
    pokeCue = ""
  }

  function safeCounter(value) {
    var number = Number(value)
    return isFinite(number) ? Math.max(0, Math.floor(number)) : 0
  }
  function safeTimestamp(value, maximum) {
    var number = Number(value)
    if (!isFinite(number) || number < 0) return 0
    return Math.min(number, maximum)
  }
  function cleanEpisodeTimes(raw) {
    var cleaned = ({})
    if (!raw || typeof raw !== "object") return cleaned
    var now = Date.now()
    var names = ["clock", "discovery", "slide", "slip", "retreat", "edge-watch", "firefly", "polish", "leaf-toss", "stargaze", "collection-sort", "stretch", "lost-pebble", "listen", "fire-hoop", "parade-leaf", "sumo-pebble", "cannon", "rain-umbrella", "fishing", "sneeze", "zoomies", "dusk-watch", "show-and-tell"]
    for (var index = 0; index < names.length; index++) {
      var timestamp = safeTimestamp(raw[names[index]], now + 60000)
      if (timestamp > 0) cleaned[names[index]] = timestamp
    }
    return cleaned
  }
  function episodeNames() {
    return ["clock", "discovery", "slide", "slip", "retreat", "edge-watch", "firefly", "polish", "leaf-toss", "stargaze", "collection-sort", "stretch", "lost-pebble", "listen", "fire-hoop", "parade-leaf", "sumo-pebble", "cannon", "rain-umbrella", "fishing", "sneeze", "zoomies", "dusk-watch", "show-and-tell"]
  }
  function cleanRecentEpisodes(raw) {
    var cleaned = []
    if (!Array.isArray(raw)) return cleaned
    var names = episodeNames()
    for (var index = 0; index < raw.length && cleaned.length < 8; index++) {
      var name = String(raw[index] || "")
      if (names.indexOf(name) >= 0 && (cleaned.length === 0 || cleaned[cleaned.length - 1] !== name)) cleaned.push(name)
    }
    return cleaned
  }
  function cleanEpisodeCounts(raw) {
    var cleaned = ({})
    if (!raw || typeof raw !== "object") return cleaned
    var names = episodeNames()
    for (var index = 0; index < names.length; index++) {
      var count = safeCounter(raw[names[index]])
      if (count > 0) cleaned[names[index]] = count
    }
    return cleaned
  }
  function noteVisit() {
    var now = Date.now()
    var today = new Date(now).toISOString().slice(0, 10)
    if (firstMetAt <= 0) firstMetAt = now
    if (lastSeenDay !== "" && lastSeenDay !== today) daysTogether = Math.max(1, daysTogether + 1)
    lastSeenDay = today
  }
  function loadState(raw) {
    try {
      var data = JSON.parse(String(raw || "{}"))
      var stateVersion = Number(data.version) || 0
      if (stateVersion < 5) {
        speciesId = "penguin"
        conceptId = ""
      } else {
        speciesId = ["penguin", "gecko", "raccoon"].indexOf(String(data.species)) >= 0 ? String(data.species) : "penguin"
        var storedConcept = String(data.concept || "")
        conceptId = ["cat", "bird", "frog", "nova"].indexOf(storedConcept) >= 0 ? storedConcept : ""
      }
      outings = safeCounter(data.outings)
      totalPokes = safeCounter(data.pokes)
      distanceWalked = safeCounter(data.distance)
      leavesFound = safeCounter(data.leaves)
      pebblesFound = safeCounter(data.pebbles)
      starsFound = safeCounter(data.stars)
      slidesCompleted = safeCounter(data.slides)
      slipsCompleted = safeCounter(data.slips)
      clockPassages = safeCounter(data.passages)
      suspiciousRetreats = safeCounter(data.retreats)
      recentEvent = String(data.recentEvent || "I'm Pebble. I wander the whole bar, rest here, and remember what I find.").slice(0, 240)
      recentEventAt = safeTimestamp(data.recentEventAt, Date.now() + 60000)
      recentEventPriority = Math.max(0, Math.min(3, safeCounter(data.recentEventPriority)))
      episodeTimes = cleanEpisodeTimes(data.episodeTimes)
      recentEpisodes = cleanRecentEpisodes(data.recentEpisodes)
      episodeCounts = cleanEpisodeCounts(data.episodeCounts)
      repeatAvoided = safeCounter(data.repeatAvoided)
      var storedEpisode = String(data.lastDirectedEpisode || "")
      lastDirectedEpisode = ["clock", "discovery", "slide", "slip", "retreat", "edge-watch", "firefly", "polish", "leaf-toss", "stargaze", "collection-sort", "stretch", "lost-pebble", "listen", "fire-hoop", "parade-leaf", "sumo-pebble", "cannon", "rain-umbrella", "fishing", "sneeze", "zoomies", "dusk-watch", "show-and-tell"].indexOf(storedEpisode) >= 0 ? storedEpisode : ""
      lastDirectedEpisodeAt = safeTimestamp(data.lastDirectedEpisodeAt, Date.now() + 60000)
      var storedActivity = Number(data.activity)
      activityLevel = isNaN(storedActivity) ? 1 : Math.max(0, Math.min(2, storedActivity))
      reducedMotion = data.reducedMotion === true
      introSeen = data.introSeen === true
      curiousCursor = ("curiousCursor" in data) ? data.curiousCursor === true : true
      gestureHintShown = data.gestureHintShown === true
      firstMetAt = safeTimestamp(data.firstMetAt, Date.now() + 60000)
      lastSeenDay = /^\d{4}-\d{2}-\d{2}$/.test(String(data.lastSeenDay || "")) ? String(data.lastSeenDay) : ""
      daysTogether = Math.max(1, Math.min(100000, safeCounter(data.daysTogether) || 1))
      noteVisit()
      snoozeUntil = safeTimestamp(data.snoozeUntil, Date.now() + 60 * 60 * 1000)
      snoozed = snoozeUntil > Date.now()
      if (snoozed) {
        snoozeTimer.interval = Math.max(1, Math.round(snoozeUntil - Date.now()))
        snoozeTimer.restart()
      } else snoozeUntil = 0
    } catch (error) { console.warn("pebble: ignored invalid local state", error) }
    stateReady = true; saveState(); scheduleRoam()
  }
  function saveState() {
    if (!stateReady || !stateDirReady) return
    var payload = JSON.stringify({
      version: 9, species: speciesId, concept: conceptId, outings: outings, pokes: totalPokes,
      distance: distanceWalked, leaves: leavesFound, pebbles: pebblesFound,
      stars: starsFound, slides: slidesCompleted, slips: slipsCompleted,
      passages: clockPassages, retreats: suspiciousRetreats, recentEvent: recentEvent,
      recentEventAt: recentEventAt, recentEventPriority: recentEventPriority,
      episodeTimes: episodeTimes, lastDirectedEpisode: lastDirectedEpisode, lastDirectedEpisodeAt: lastDirectedEpisodeAt,
      recentEpisodes: recentEpisodes, episodeCounts: episodeCounts, repeatAvoided: repeatAvoided,
      activity: activityLevel, reducedMotion: reducedMotion, introSeen: introSeen,
      curiousCursor: curiousCursor, gestureHintShown: gestureHintShown,
      firstMetAt: firstMetAt, lastSeenDay: lastSeenDay, daysTogether: daysTogether, snoozeUntil: snoozeUntil
    }, null, 2) + "\n"
    if (payload.length > stateMaxBytes) {
      console.warn("pebble: refused oversized local state")
      return
    }
    pendingStatePayload = payload
    stateWriteTimer.restart()
  }
  function flushStateWrite() {
    if (!stateReady || !stateDirReady || pendingStatePayload === "") return
    if (stateWriteProc.running) { stateWriteTimer.restart(); return }
    activeStatePayload = pendingStatePayload
    pendingStatePayload = ""
    stateWriteProc.command = ["bash", "-c",
      "set -eu\n"
      + "path=\"$1\"\n"
      + "payload=\"$2\"\n"
      + "bytes=$(printf '%s' \"$payload\" | wc -c)\n"
      + "[ \"$bytes\" -le 65536 ]\n"
      + "dir=${path%/*}\n"
      + "if [ -e \"$path\" ] || [ -L \"$path\" ]; then [ -f \"$path\" ] && [ ! -L \"$path\" ]; fi\n"
      + "tmp=$(mktemp --tmpdir=\"$dir\" .pebble-state.XXXXXX)\n"
      + "trap 'rm -f -- \"$tmp\"' EXIT HUP INT TERM\n"
      + "printf '%s' \"$payload\" > \"$tmp\"\n"
      + "chmod 600 \"$tmp\"\n"
      + "mv -fT -- \"$tmp\" \"$path\"\n"
      + "trap - EXIT",
      "pebble-state-write", statePath, activeStatePayload]
    stateWriteProc.running = true
  }
  function cycleActivity() { activityLevel = (activityLevel + 1) % 3; saveState(); scheduleRoam() }
  function setActivityLevel(level) {
    var next = Math.max(0, Math.min(2, Number(level) || 0))
    var enteringQuiet = next === 0 && activityLevel !== 0
    activityLevel = next
    saveState(); scheduleRoam()
    if (enteringQuiet && !sleeping && placed && !barHidden) goHomeGracefully()
  }
  function toggleCuriousCursor() {
    curiousCursor = !curiousCursor
    if (!curiousCursor) { cursorBarX = -1; curiousLean = 0 }
    saveState()
  }
  function setCuriousCursor(enabled) {
    curiousCursor = enabled === true
    if (!curiousCursor) { cursorBarX = -1; curiousLean = 0 }
    saveState()
  }
  function acknowledgeIntro() { if (!introSeen) { introSeen = true; saveState() } }
  function markGestureHint() {
    if (!gestureHintShown) { gestureHintShown = true; saveState() }
  }
  function openJournal() {
    panelOpen = true
    markGestureHint()
  }
  function stageMidBar() {
    petX = devPreviewX(0.4)
    faceDevPreview()
  }
  function forceWake() {
    if (snoozed) cancelSnooze()
    cancelHomeStory()
    sleepMarkerTimer.stop()
    deepSleeping = false
    peeking = false
    rustling = false
    rustleWatchdog.stop()
    rustleAnimation.stop()
    peekAnimation.stop()
    den.rustleRotation = 0
    pendingInteractiveWake = false
    chaseTargetX = -1
    journeyPhase = "outbound"
    if (personalityMood === "sleepy") personalityMood = "playful"
    action = "idleAction"
    idleFrame = 7
    poseFrame = 0
    walkFrame = 0
    animal.sniffRotation = 0
    animal.hopOffset = 0
    animalOpacity = 1
  }
  function prepareDevStage() {
    // Stop whatever he is doing — position is chosen per dev trigger, away from the clock.
    cancelStory(); cancelHomeStory()
    walkMotion.stop(); curiosityAnimation.stop(); acknowledgeAnimation.stop(); playfulAnimation.stop()
    rustleAnimation.stop(); settleTurn.stop(); poseTimer.stop()
    slideMotion.stop(); slideTimer.stop(); slipMotion.stop(); slipTimer.stop()
    clockApproach.stop(); clockOcclusion.stop(); clockTransitOcclusion.stop()
    idleActionTimer.stop(); idleBlendAnimation.stop(); idleTransitionMotion.stop()
    roamTimer.stop(); peekTimer.stop()
    storyPetOffset = 0
    storyPetInFront = false
    animal.hopOffset = 0
    animal.sniffRotation = 0
    animalOpacity = 1
    hoopVisible = false; hoopOpacity = 0; hoopGlow = 0
    cannonVisible = false; cannonOpacity = 0; cannonFlash = false
    clearHeadProp()
    discoveryVisible = false; discoveryItem = ""; toyVx = 0
    clockTransit = false; clockStyle = ""; clockChaseItem = ""
    playfulQueued = false; retreatQueued = false; clockQueued = false; slipQueued = false
    storyQueued = ""; storyName = ""; storyStage = 0
    peeking = false; deepSleeping = false
    personalityMood = "playful"
    // Dev triggers must work even when he is sleeping, snoozed, or stuck mid-episode.
    forceWake()
  }
  function runDevTrigger(name) {
    // Keep the Dev panel open so you can fire the next action immediately.
    panelOpen = true
    if (devToolsEnabled) devPanelOpen = true
    prepareDevStage()
    petX = stageForDevTrigger(name)
    faceDevPreview()
    if (name === "slip") { startSlip(); return }
    if (name === "slide") { startSlide(); return }
    if (name === "clock") { startClockEpisode(false, "bold"); return }
    if (name === "magic") { startClockEpisode(false, "magic"); return }
    if (name === "retreat") { startClockEpisode(true); return }
    if (name === "discover") {
      // Dev-only: spawn a rolling pebble toy (normal gameplay find).
      discoveryItem = "pebble"
      discoveryX = Math.max(4, Math.min(trackLength - 12, petX + (direction > 0 ? petWidth + 10 : -14)))
      toyHop = 0; toySpin = 0; toyBumps = 0; toyVx = 0; toyEdgeHits = 0
      discoveryVisible = true
      episodeName = "discovery"
      if (!reducedMotion) toyIdleBounce.restart()
      rememberEvent("Dev: dropped a rolling pebble to chase.", 0)
      beginIdleRoutine()
      return
    }
    if (!isStory(name)) return
    // Unlock collection gates so leaf/pebble stories are testable.
    if ((name === "parade-leaf" || name === "rain-umbrella" || name === "leaf-toss") && leavesFound < 1)
      leavesFound = 1
    if ((name === "sumo-pebble" || name === "polish" || name === "lost-pebble") && pebblesFound < 1)
      pebblesFound = 1
    if (name === "show-and-tell" && collectionSize() < 1)
      pebblesFound = 1
    if (name === "collection-sort" && collectionSize() < 3) {
      pebblesFound = Math.max(pebblesFound, 1)
      leavesFound = Math.max(leavesFound, 1)
      starsFound = Math.max(starsFound, 1)
    }
    storyName = name
    storyQueued = ""
    storyStage = 0
    episodeName = name
    action = "idleAction"
    idleFrame = 1
    advanceStory()
  }
  function openCare() {
    // Alias — single flat panel; kept for IPC compatibility.
    openJournal()
  }
  function onPetHover(entered) {
    petHovered = entered
    if (!entered) return
    if (sleeping && !rustling && !snoozed && !reducedMotion) {
      den.rustleRotation = personalityMood === "playful" ? 2.8 : (gestureHintShown ? 1.4 : 2.0)
      if (collectionSize() >= 8 && Math.random() < 0.12)
        rememberEvent("Stirred at a familiar touch near his sleep spot.", 0)
      hoverStirTimer.restart()
    } else if (!sleeping && !posing && !walking && !reducedMotion) {
      var lean = direction * (curiousCursor ? 10 : 6)
      if (personalityMood === "curious") lean *= 1.2
      animal.sniffRotation = lean
      animal.hopOffset = personalityMood === "sleepy" ? -1.0 : personalityMood === "playful" ? -3.2 : -2.2
      hoverStirTimer.restart()
    }
  }
  function pointerOnBar() {
    if (!petScreen || pointerX < 0) return false
    var sx = Number(petScreen.x) || 0
    var sy = Number(petScreen.y) || 0
    var sw = Number(petScreen.width) || 0
    var sh = Number(petScreen.height) || 0
    if (pointerX < sx || pointerX > sx + sw || pointerY < sy || pointerY > sy + sh) return false
    var depth = barSize + curiousMargin
    if (barPosition === "top") return pointerY - sy <= depth
    if (barPosition === "bottom") return (sy + sh) - pointerY <= depth
    return false
  }
  function flipPlayMoodMaybe() {
    var now = Date.now()
    if (now - lastPlayMoodFlipAt < 7000) return
    if (Math.random() < 0.28) {
      playMood *= -1
      lastPlayMoodFlipAt = now
    }
  }
  function scootAlongBar(deltaX, durationScale) {
    if (auditioning || posing || storyName !== "" || snoozed || activityLevel === 0) return false
    var scoot = clampX(petX + deltaX)
    if (Math.abs(scoot - petX) < 10) return false
    walkMotion.stop()
    curiosityAnimation.stop()
    acknowledgeAnimation.stop()
    playfulAnimation.stop()
    targetX = scoot
    direction = scoot >= petX ? 1 : -1
    walkMotion.from = petX
    walkMotion.to = scoot
    walkMotion.duration = Math.max(140, Math.round(Math.abs(scoot - petX) * (durationScale || 4.2)))
    action = "walk"
    walkFrame = 0
    walkMotion.restart()
    return true
  }
  function applyCuriousLean(targetX) {
    if (!curiousCursor || reducedMotion || auditioning) { curiousLean = 0; return }
    if (posing || storyName !== "") return
    var petCenter = (sleeping ? homeX : petX) + petWidth * 0.5
    var delta = targetX - petCenter
    if (Math.abs(delta) < 10) { curiousLean = 0; return }
    var lean = Math.max(-1, Math.min(1, delta / 90))
    curiousLean = lean
    // Quiet: look / rustle only. Normal: small scoots while awake. Lively: nest-wake + chase.
    var mayChase = activityLevel > 0 && !snoozed
    var lively = activityLevel === 2
    var scootGap = lively ? 900 : 1800
    flipPlayMoodMaybe()
    var chaseSign = playMood >= 0 ? 1 : -1
    if (sleeping && !rustling && !snoozed) {
      den.rustleRotation = lean * (lively ? 4.0 : 2.2)
      direction = lean >= 0 ? 1 : -1
      if (lively && Math.abs(delta) < 150 && Date.now() - lastCuriousScootAt > 1600) {
        lastCuriousScootAt = Date.now()
        chaseTargetX = clampX(targetX - petWidth * 0.5)
        wakeAndWalk(true)
      }
    } else if (!sleeping && !walking) {
      animal.sniffRotation = lean * (lively ? 14 : 9)
      animal.hopOffset = lively ? -1.6 : -1.0
      direction = (chaseSign * lean) >= 0 ? 1 : -1
      if (mayChase && Math.abs(delta) > (lively ? 28 : 44)
          && Date.now() - lastCuriousScootAt > scootGap) {
        lastCuriousScootAt = Date.now()
        var dashScale = lively ? 0.62 : 0.38
        var dash = Math.min(lively ? 110 : 62, Math.max(lively ? 42 : 24, Math.abs(delta) * dashScale)) * chaseSign * (lean >= 0 ? 1 : -1)
        if (scootAlongBar(dash, lively ? 3.2 : 4.4) && Math.random() < (lively ? 0.28 : 0.12))
          rememberEvent(playMood >= 0 ? "Chased the pointer along the bar." : "Bolted away from the pointer.", 0)
      }
    } else if (walking && mayChase && Math.abs(delta) > (lively ? 34 : 52)
               && Date.now() - lastCuriousScootAt > (lively ? 1100 : 2000)) {
      lastCuriousScootAt = Date.now()
      if (lively && playMood >= 0 && Math.abs(delta) > 56) {
        walkMotion.stop()
        var toward = clampX(petX + Math.min(120, Math.max(48, Math.abs(delta) * 0.55)) * (lean >= 0 ? 1 : -1))
        if (Math.abs(toward - petX) > 10) {
          root.targetX = toward
          direction = toward >= petX ? 1 : -1
          walkMotion.from = petX
          walkMotion.to = toward
          walkMotion.duration = Math.max(160, Math.round(Math.abs(toward - petX) * 3.4))
          action = "walk"
          walkFrame = 0
          walkMotion.restart()
        }
      } else {
        var step = Math.min(lively ? 96 : 54, Math.max(lively ? 44 : 22, Math.abs(delta) * (lively ? 0.48 : 0.32))) * chaseSign * (lean >= 0 ? 1 : -1)
        scootAlongBar(step, lively ? 3.0 : 4.2)
      }
    }
  }
  function ingestPointer(x, y) {
    if (!curiousCursor || !petScreen || barHidden || !horizontalBar) {
      pointerX = -1; pointerY = -1; cursorBarX = -1; curiousLean = 0
      return
    }
    pointerX = x; pointerY = y
    if (!pointerOnBar()) { cursorBarX = -1; curiousLean = 0; return }
    cursorBarX = x - (Number(petScreen.x) || 0)
    applyCuriousLean(cursorBarX)
  }
  function toggleReducedMotion() {
    reducedMotion = !reducedMotion
    if (reducedMotion && (action === "sliding" || action === "slipping")) goToSleep()
    saveState(); scheduleRoam()
  }
  function snoozeOneHour() {
    snoozeUntil = Date.now() + 60 * 60 * 1000
    snoozed = true
    snoozeTimer.interval = 60 * 60 * 1000
    snoozeTimer.restart()
    goToSleep()
    panelOpen = false
    saveState()
  }
  function cancelSnooze() {
    if (!snoozed && snoozeUntil === 0) return
    snoozeTimer.stop()
    snoozed = false
    snoozeUntil = 0
    saveState()
    scheduleRoam()
    schedulePeek()
  }
  function toggleSnooze() { if (snoozed) cancelSnooze(); else snoozeOneHour() }
  function cycleSpecies() {
    goToSleep()
    conceptId = ""
    speciesId = speciesId === "penguin" ? "raccoon" : speciesId === "raccoon" ? "gecko" : "penguin"
    saveState()
  }
  function selectConcept(id) {
    goToSleep()
    conceptId = id
    conceptX = homeX
    saveState()
    scheduleRoam()
  }
  function handlePetClick(button) {
    acknowledgeIntro()
    if (button === Qt.RightButton) {
      if (panelOpen) { panelOpen = false }
      else openJournal()
    } else if (button === Qt.MiddleButton) goHomeGracefully()
    else if (auditioning) startConceptMotion(true)
    else poke()
  }
  function close() { panelOpen = false }

  onTrackLengthChanged: {
    if (!placed && trackLength > petWidth) {
      petX = initialPosition(); conceptX = homeX; placed = true
      scheduleRoam(); schedulePeek()
    } else if (placed) {
      petX = clampX(petX)
      conceptX = Math.max(homeX, Math.min(Math.min(worldMaxX, homeX + 190), conceptX))
    }
  }
  onPetScreenChanged: {
    if (placed) goToSleep()
  }
  onFocusedWorkspaceIdChanged: {
    if (stateReady && focusedWorkspaceId >= 0) {
      workspaceChanges++
      var now = Date.now()
      if (sleeping && !snoozed && !barHidden && workspaceChanges % 4 === 0 && now - lastContextReactionAt > 8 * 60 * 1000) {
        lastContextReactionAt = now
        peekTimer.interval = reducedMotion ? 2600 : 1200
        peekTimer.restart()
      }
    }
  }
  onBarHiddenChanged: {
    panelOpen = false
    if (barHidden) goToSleep()
    else { scheduleRoam(); schedulePeek(); scheduleSleepMarker() }
  }
  onHorizontalBarChanged: {
    panelOpen = false
    goToSleep()
  }

  Process {
    command: ["mkdir", "-p", root.stateDir]
    running: true
    onExited: {
      root.stateDirReady = true
      stateReadProc.running = true
    }
  }
  Process {
    id: stateReadProc
    command: ["bash", "-c",
      "set -eu\n"
      + "path=\"$1\"\n"
      + "[ -f \"$path\" ] && [ ! -L \"$path\" ]\n"
      + "[ \"$(stat -c '%F' -- \"$path\")\" = \"regular file\" ]\n"
      + "size=$(stat -c '%s' -- \"$path\")\n"
      + "[ \"$size\" -le 65536 ]\n"
      + "timeout --foreground 1s dd if=\"$path\" iflag=nofollow,nonblock bs=1 count=65536 status=none",
      "pebble-state-read", root.statePath]
    stdout: StdioCollector { id: stateReadStdout; waitForEnd: true }
    onExited: function(exitCode) {
      var raw = String(stateReadStdout.text || "")
      if (exitCode !== 0 || raw.length > root.stateMaxBytes) root.loadState("{}")
      else root.loadState(raw)
    }
  }
  Timer {
    id: stateWriteTimer
    interval: 80
    repeat: false
    onTriggered: root.flushStateWrite()
  }
  Process {
    id: stateWriteProc
    running: false
    command: []
    onExited: function(exitCode) {
      root.activeStatePayload = ""
      if (exitCode !== 0) console.warn("pebble: atomic state write failed")
      if (root.pendingStatePayload !== "") stateWriteTimer.restart()
    }
  }

  Timer {
    id: poseTimer; repeat: true
    onTriggered: {
      if (root.action === "emerging") {
        if (root.isPenguin && root.poseFrame > 0) {
          root.poseFrame--
          root.petX = root.homeX + (3 - root.poseFrame) * 3
        } else if (root.isPenguin) {
          stop()
          if (root.storyQueued === "cannon") root.startQueuedStory()
          else root.planRoute()
        }
        else if (root.poseFrame < 7) { root.poseFrame++; root.petX += 4; interval = root.poseFrame < 2 ? 210 : 135 }
        else { stop(); root.planRoute() }
      } else if (root.action === "starting") {
        if (root.poseFrame < 3) root.poseFrame++
        else { stop(); root.startLeg(root.pendingDestination) }
      } else if (root.action === "stopping") {
        if (root.poseFrame < 3) root.poseFrame++
        else { stop(); if (root.playfulQueued) { root.playfulQueued = false; root.startSlide() } else root.finishStoppedLeg() }
      } else if (root.action === "settling") {
        // In-place tuck at homeX so the sleep den appears where he already is.
        if (root.poseFrame < 3) root.poseFrame++
        else { stop(); root.storeDiscovery(); root.curlUp() }
      } else if (root.action === "entering") {
        if (root.poseFrame > 0) { root.poseFrame--; root.petX -= 4 }
        else { stop(); root.storeDiscovery(); root.curlUp() }
      } else stop()
    }
  }
  Timer { id: roamTimer; onTriggered: root.wakeAndWalk(false) }
  Timer {
    id: snoozeTimer
    onTriggered: {
      root.snoozed = false
      root.snoozeUntil = 0
      root.saveState()
      root.scheduleRoam()
      root.schedulePeek()
    }
  }

  Timer {
    id: rustleWatchdog
    interval: 1800
    repeat: false
    onTriggered: {
      if (root.rustling && root.sleeping)
        root.forceWake()
    }
  }
  Timer {
    id: pokeCueTimer
    interval: 1600
    repeat: false
    onTriggered: root.pokeCue = ""
  }
  Timer {
    id: hoverStirTimer
    interval: 420
    repeat: false
    onTriggered: {
      if (root.sleeping) den.rustleRotation = 0
      else {
        animal.sniffRotation = 0
        animal.hopOffset = 0
      }
    }
  }
  // Navbar-Cat style: long-lived Hyprland socket sampler (not hyprctl-per-tick).
  Process {
    id: cursorFeed
    running: root.curiousCursor && root.horizontalBar && !root.barHidden
    command: [root.cursorHelper]
    stdinEnabled: true
    stdout: SplitParser {
      onRead: function(line) {
        var parts = String(line).trim().split(/\s+/)
        if (parts.length < 2) return
        var x = parseInt(parts[0], 10)
        var y = parseInt(parts[1], 10)
        if (isNaN(x) || isNaN(y)) return
        root.ingestPointer(x, y)
      }
    }
  }
  onCursorIntervalChanged: if (cursorFeed.running) cursorFeed.write(cursorInterval + "\n")
  Timer { id: conceptIdleTimer; onTriggered: root.startConceptMotion(false) }
  Timer { id: idleActionTimer; onTriggered: root.advanceIdleRoutine() }
  Timer { id: storyTimer; onTriggered: root.advanceStory() }
  Timer { id: homeMomentTimer; onTriggered: root.advanceHomeStory() }
  Timer { id: sleepMarkerTimer; onTriggered: root.advanceSleepMarker() }
  Timer {
    id: sleepLoopTimer
    interval: 2600; repeat: true; running: root.sleeping && root.isPenguin && !root.rustling && !root.reducedMotion
    onTriggered: root.sleepFrame = (root.sleepFrame + 1) % 4
  }
  Timer {
    id: slideTimer; interval: 132; repeat: true
    onTriggered: {
      if (root.poseFrame < 7) root.poseFrame++
      else stop()
    }
  }
  Timer {
    id: slipTimer; interval: 95; repeat: true
    onTriggered: {
      if (root.poseFrame < 15) {
        root.poseFrame++
        interval = root.poseFrame < 5 ? 95 : root.poseFrame < 8 ? 120 : root.poseFrame < 12 ? 270 : 120
      } else { stop(); root.finishSlip() }
    }
  }
  Timer { id: peekTimer; onTriggered: root.startHomeMoment() }
  Timer {
    interval: Math.max(76, Math.round(122 - root.pace * 0.25)); repeat: true; running: root.walking
    onTriggered: root.walkFrame = (root.walkFrame + 1) % 6
  }
  NumberAnimation {
    id: walkMotion; target: root; property: "petX"; easing.type: Easing.InOutCubic
    onFinished: root.legFinished()
  }
  NumberAnimation {
    id: clockApproach; target: root; property: "petX"; easing.type: Easing.InOutCubic
    onFinished: {
      root.petX = root.targetX
      root.action = "clockHidden"
      if (root.clockTransit) clockTransitOcclusion.restart(); else clockOcclusion.restart()
    }
  }
  SequentialAnimation {
    id: clockOcclusion
    ScriptAction {
      script: {
        if (root.clockStyle === "magic") {
          root.episodeName = "clock-magic"
          root.setStoryProp("bang", root.petX + root.petWidth * 0.35, root.barPropY() - 2, 1, 1.1)
        }
      }
    }
    ParallelAnimation {
      NumberAnimation { target: root; property: "animalOpacity"; to: 0; duration: 235; easing.type: Easing.InCubic }
    }
    ScriptAction {
      script: {
        root.clearStoryProp()
        if (root.clockStyle === "magic") {
          root.direction = -1
          root.petX = root.magicWrongPeekX()
          root.idleFrame = 2
          root.action = "clockPeek"
          root.setStoryProp("bang", root.petX + root.petWidth * 0.4, root.barPropY() - 3, 0.95, 1)
        } else {
          root.direction = -1
          root.petX = root.clockClearLeftX()
          root.idleFrame = (root.clockStyle === "shy" || root.episodeName === "clock-retreat") ? 0 : 1
          root.action = "clockPeek"
        }
        if (root.clockStyle === "chase" && root.discoveryVisible)
          root.discoveryVisible = false
      }
    }
    ParallelAnimation {
      NumberAnimation { target: root; property: "animalOpacity"; to: 1; duration: 300; easing.type: Easing.OutCubic }
    }
    PauseAnimation { duration: root.clockPeekHoldMs }
    SequentialAnimation {
      loops: Math.max(1, root.clockPeekLoops)
      NumberAnimation { target: animal; property: "sniffRotation"; to: -5; duration: 100; easing.type: Easing.InOutSine }
      NumberAnimation { target: animal; property: "sniffRotation"; to: 4; duration: 130; easing.type: Easing.InOutSine }
      NumberAnimation { target: animal; property: "sniffRotation"; to: -2; duration: 90; easing.type: Easing.InOutSine }
    }
    PauseAnimation { duration: root.clockStyle === "bold" || root.clockStyle === "chase" ? 160 : (root.clockStyle === "magic" ? 200 : 1) }
    ScriptAction {
      script: {
        if (root.clockStyle === "bold" || root.clockStyle === "chase") {
          root.action = "clockPeek"
          animal.hopOffset = -1.8
        } else if (root.clockStyle === "tumble") {
          animal.sniffRotation = 8
        } else if (root.clockStyle === "magic") {
          animal.sniffRotation = -10
          animal.hopOffset = 1
          root.idleFrame = 0
          root.setStoryProp("dots", root.petX + root.petWidth + 4, root.barPropY() - 6, 0.85, 1)
        }
      }
    }
    PauseAnimation { duration: root.clockStyle === "bold" || root.clockStyle === "chase" ? 380 : (root.clockStyle === "tumble" ? 520 : (root.clockStyle === "magic" ? 640 : 40)) }
    ScriptAction { script: { animal.hopOffset = 0; animal.sniffRotation = 0; if (root.clockStyle === "magic") root.clearStoryProp() } }
    ParallelAnimation {
      NumberAnimation { target: animal; property: "sniffRotation"; to: 0; duration: 120; easing.type: Easing.OutCubic }
      NumberAnimation { target: root; property: "animalOpacity"; to: 0; duration: 190; easing.type: Easing.InCubic }
    }
    ScriptAction {
      script: {
        if (root.clockStyle === "magic") {
          root.petX = root.magicEmergeX()
          root.direction = 1
          root.action = "idleAction"
          root.idleFrame = 7
          root.setStoryProp("bang", root.petX + root.petWidth * 0.25, root.barPropY() - 4, 1, 1.2)
        } else {
          root.petX = root.clockClearRightX()
          root.direction = 1
          root.action = "clockPeek"
          root.idleFrame = 7
        }
      }
    }
    NumberAnimation { target: root; property: "animalOpacity"; to: 1; duration: 230; easing.type: Easing.OutCubic }
    PauseAnimation { duration: root.clockStyle === "magic" ? 520 : 1 }
    ScriptAction { script: root.finishClockEpisode() }
  }
  SequentialAnimation {
    id: clockTransitOcclusion
    ParallelAnimation {
      NumberAnimation {
        target: root; property: "petX"
        to: root.clockTransitDirection < 0 ? root.passageRightX - root.petWidth * 0.48 : root.passageLeftX - root.petWidth * 0.52
        duration: 280; easing.type: Easing.InCubic
      }
      NumberAnimation { target: root; property: "animalOpacity"; to: 0; duration: 235; easing.type: Easing.InCubic }
    }
    ScriptAction {
      script: {
        root.direction = root.clockTransitDirection
        root.petX = root.clockTransitDirection < 0
          ? root.passageLeftX - root.petWidth * 0.42
          : root.passageRightX - root.petWidth * 0.58
        root.idleFrame = 1
        root.action = "clockPeek"
      }
    }
    ParallelAnimation {
      NumberAnimation { target: root; property: "animalOpacity"; to: 1; duration: 280; easing.type: Easing.OutCubic }
      NumberAnimation {
        target: root; property: "petX"
        to: root.clockTransitDirection < 0 ? root.passageLeftX - root.petWidth - 12 : root.passageRightX + 12
        duration: 390; easing.type: Easing.OutCubic
      }
    }
    PauseAnimation { duration: 320 }
    ScriptAction { script: root.finishClockTransit() }
  }
  NumberAnimation {
    id: slideMotion; target: root; property: "petX"; duration: 1050; easing.type: Easing.OutCubic
    onFinished: {
      root.petX = root.targetX
      root.slidesCompleted++
      root.rememberEvent("Took the fast way across the bar.", 1)
      root.saveState()
      if (root.retreatQueued) { root.retreatQueued = false; root.startClockEpisode(true) }
      else { root.idleBeatsRemaining = 2; root.showIdleBeat() }
    }
  }
  NumberAnimation { id: slipMotion; target: root; property: "petX"; duration: 1100; easing.type: Easing.OutCubic }
  NumberAnimation { id: idleBlendAnimation; target: root; property: "idleBlend"; to: 1; duration: 155; easing.type: Easing.InOutSine }
  SequentialAnimation {
    id: idleTransitionMotion
    ParallelAnimation {
      NumberAnimation { target: animal; property: "hopOffset"; to: -1.2; duration: 75; easing.type: Easing.OutQuad }
      NumberAnimation { target: animal; property: "sniffRotation"; to: root.direction * 1.8; duration: 75; easing.type: Easing.OutQuad }
    }
    ParallelAnimation {
      NumberAnimation { target: animal; property: "hopOffset"; to: 0; duration: 100; easing.type: Easing.InQuad }
      NumberAnimation { target: animal; property: "sniffRotation"; to: 0; duration: 100; easing.type: Easing.InOutQuad }
    }
  }
  SequentialAnimation {
    id: peekAnimation
    ScriptAction { script: { root.peeking = true; root.peekOpacity = 0; root.peekLift = 3; root.eyeOpen = 1 } }
    ParallelAnimation {
      NumberAnimation { target: root; property: "peekOpacity"; to: 0.48; duration: 220; easing.type: Easing.OutCubic }
      NumberAnimation { target: root; property: "peekLift"; to: 0; duration: 280; easing.type: Easing.OutCubic }
    }
    PauseAnimation { duration: 420 }
    NumberAnimation { target: root; property: "eyeOpen"; to: 0.08; duration: 65; easing.type: Easing.InQuad }
    NumberAnimation { target: root; property: "eyeOpen"; to: 1; duration: 85; easing.type: Easing.OutQuad }
    PauseAnimation { duration: 260 }
    NumberAnimation { target: root; property: "eyeOpen"; to: 0.08; duration: 65; easing.type: Easing.InQuad }
    NumberAnimation { target: root; property: "eyeOpen"; to: 1; duration: 85; easing.type: Easing.OutQuad }
    PauseAnimation { duration: 460 }
    NumberAnimation { target: root; property: "peekOpacity"; to: 0; duration: 260; easing.type: Easing.InCubic }
    ScriptAction { script: { root.peeking = false; root.schedulePeek() } }
  }
  SequentialAnimation {
    id: rustleAnimation
    NumberAnimation { target: den; property: "rustleRotation"; to: -2.5; duration: 85; easing.type: Easing.OutQuad }
    NumberAnimation { target: den; property: "rustleRotation"; to: 2.5; duration: 105; easing.type: Easing.InOutQuad }
    NumberAnimation { target: den; property: "rustleRotation"; to: -1.5; duration: 90; easing.type: Easing.InOutQuad }
    NumberAnimation { target: den; property: "rustleRotation"; to: 0; duration: 100; easing.type: Easing.OutQuad }
    ScriptAction { script: root.beginEmergence(root.pendingInteractiveWake) }
    onStopped: {
      root.rustleWatchdog.stop()
      if (root.rustling && root.sleeping)
        root.beginEmergence(root.pendingInteractiveWake)
    }
  }
  SequentialAnimation {
    id: curiosityAnimation
    NumberAnimation { target: animal; property: "sniffOffset"; to: 2.1; duration: 170; easing.type: Easing.InOutSine }
    NumberAnimation { target: animal; property: "sniffRotation"; to: 5; duration: 135; easing.type: Easing.InOutSine }
    PauseAnimation { duration: 110 }
    ParallelAnimation {
      NumberAnimation { target: animal; property: "sniffOffset"; to: 0; duration: 190; easing.type: Easing.OutCubic }
      NumberAnimation { target: animal; property: "sniffRotation"; to: 0; duration: 190; easing.type: Easing.OutCubic }
    }
    onFinished: root.curiosityFinished()
  }
  SequentialAnimation {
    id: acknowledgeAnimation
    ScriptAction { script: root.action = "curious" }
    NumberAnimation { target: animal; property: "hopOffset"; to: -4; duration: 100; easing.type: Easing.OutQuad }
    ParallelAnimation {
      NumberAnimation { target: animal; property: "hopOffset"; to: 0; duration: 150; easing.type: Easing.OutBounce }
      NumberAnimation { target: animal; property: "sniffRotation"; to: root.direction * -7; duration: 120; easing.type: Easing.OutCubic }
    }
    NumberAnimation { target: animal; property: "sniffRotation"; to: 0; duration: 120; easing.type: Easing.InOutCubic }
    PauseAnimation { duration: 90 }
    ScriptAction { script: root.planRoute() }
  }
  SequentialAnimation {
    id: playfulAnimation
    ScriptAction { script: root.action = "curious" }
    NumberAnimation { target: animal; property: "hopOffset"; to: -5; duration: 85; easing.type: Easing.OutQuad }
    NumberAnimation { target: animal; property: "hopOffset"; to: 0; duration: 105; easing.type: Easing.OutBounce }
    ScriptAction { script: root.direction *= -1 }
    NumberAnimation { target: animal; property: "hopOffset"; to: -4; duration: 75; easing.type: Easing.OutQuad }
    ParallelAnimation {
      NumberAnimation { target: animal; property: "hopOffset"; to: 0; duration: 110; easing.type: Easing.OutBounce }
      NumberAnimation { target: animal; property: "sniffRotation"; to: 8; duration: 90; easing.type: Easing.OutCubic }
    }
    NumberAnimation { target: animal; property: "sniffRotation"; to: 0; duration: 100; easing.type: Easing.InOutCubic }
    ScriptAction { script: root.planRoute() }
  }
  SequentialAnimation {
    id: settleTurn
    ScriptAction { script: root.action = "curious" }
    ParallelAnimation {
      NumberAnimation { target: animal; property: "hopOffset"; to: -2; duration: 130; easing.type: Easing.OutQuad }
      NumberAnimation { target: animal; property: "sniffRotation"; to: 5; duration: 130; easing.type: Easing.InOutSine }
    }
    ScriptAction { script: root.direction *= -1 }
    ParallelAnimation {
      NumberAnimation { target: animal; property: "hopOffset"; to: 0; duration: 150; easing.type: Easing.OutCubic }
      NumberAnimation { target: animal; property: "sniffRotation"; to: -4; duration: 150; easing.type: Easing.InOutSine }
    }
    PauseAnimation { duration: 90 }
    ParallelAnimation {
      NumberAnimation { target: animal; property: "hopOffset"; to: -1.5; duration: 120; easing.type: Easing.OutQuad }
      NumberAnimation { target: animal; property: "sniffRotation"; to: 3; duration: 120; easing.type: Easing.InOutSine }
    }
    ScriptAction { script: root.direction *= -1 }
    ParallelAnimation {
      NumberAnimation { target: animal; property: "hopOffset"; to: 0; duration: 145; easing.type: Easing.OutCubic }
      NumberAnimation { target: animal; property: "sniffRotation"; to: 0; duration: 145; easing.type: Easing.InOutSine }
    }
    ScriptAction { script: root.startReturn() }
  }
  SequentialAnimation {
    id: breathing; running: !root.reducedMotion && !root.sleeping && !root.walking && !root.posing && !root.auditioning; loops: Animation.Infinite
    onRunningChanged: if (!running) animal.breathScale = 1
    NumberAnimation { target: animal; property: "breathScale"; to: 1.025; duration: 1750; easing.type: Easing.InOutSine }
    NumberAnimation { target: animal; property: "breathScale"; to: 1; duration: 1950; easing.type: Easing.InOutSine }
  }
  SequentialAnimation {
    id: conceptBreathing; running: root.auditioning; loops: Animation.Infinite
    NumberAnimation { target: conceptPet; property: "breathScale"; to: 1.035; duration: 1650; easing.type: Easing.InOutSine }
    NumberAnimation { target: conceptPet; property: "breathScale"; to: 1; duration: 1850; easing.type: Easing.InOutSine }
  }
  SequentialAnimation {
    id: toyIdleBounce
    running: false
    loops: Animation.Infinite
    NumberAnimation {
      target: root; property: "toyHop"
      to: root.discoveryItem === "star" ? -4.2 : root.discoveryItem === "leaf" ? -3.6 : -2.4
      duration: root.discoveryItem === "leaf" ? 340 : 260
      easing.type: Easing.OutQuad
    }
    NumberAnimation {
      target: root; property: "toyHop"; to: 0
      duration: root.discoveryItem === "pebble" ? 280 : 340
      easing.type: Easing.InQuad
    }
    PauseAnimation { duration: root.discoveryItem === "star" ? 90 : 180 }
    ScriptAction { script: root.toySpin += root.discoveryItem === "leaf" ? 22 : root.discoveryItem === "star" ? 16 : 10 }
  }
  SequentialAnimation {
    id: toyHopBounce
    NumberAnimation {
      target: root; property: "toyHop"
      to: root.discoveryItem === "star" ? -7.0 : root.discoveryItem === "leaf" ? -5.0 : -4.2
      duration: 110; easing.type: Easing.OutQuad
    }
    NumberAnimation {
      target: root; property: "toyHop"; to: 0
      duration: root.discoveryItem === "pebble" ? 200 : 170
      easing.type: Easing.OutBounce
    }
  }
  Timer {
    id: toyPhysicsTimer
    interval: 32
    repeat: true
    running: false
    onTriggered: root.stepToyPhysics()
  }
  Timer {
    id: toyCatchTimer
    interval: 720
    repeat: false
    onTriggered: root.finishToyCatch()
  }
  ParallelAnimation {
    id: conceptTravel
    property int travelDuration: 560
    NumberAnimation {
      target: root; property: "conceptX"; to: root.conceptTargetX
      duration: conceptTravel.travelDuration; easing.type: Easing.InOutCubic
    }
    SequentialAnimation {
      loops: root.conceptHopCount
      NumberAnimation {
        target: conceptPet; property: "hopOffset"
        to: root.conceptId === "frog" ? -5 : root.conceptId === "bird" ? -3.5 : -2.5
        duration: 145; easing.type: Easing.OutQuad
      }
      NumberAnimation { target: conceptPet; property: "hopOffset"; to: 0; duration: 205; easing.type: Easing.InQuad }
    }
    onFinished: root.scheduleConceptIdle()
  }

  IpcHandler {
    target: root.pluginId
    function pet(): void { root.poke() }
    function roam(): void { root.forceWake(); root.wakeAndWalk(true) }
    function wake(): void { root.forceWake() }
    function explore(): void { root.inviteExplore() }
    function sleep(): void { root.goToSleep() }
    function slip(): void {
      if (root.sleeping || root.posing) {
        root.slipQueued = true; root.episodeName = "slip"
        if (root.sleeping) root.wakeAndWalk(true)
      } else root.startSlip()
    }
    function clock(): void {
      if (root.sleeping || root.posing) { root.clockQueued = true; root.wakeAndWalk(true) }
      else root.startClockEpisode(false)
    }
    function retreat(): void {
      if (root.sleeping || root.posing) { root.retreatQueued = true; root.wakeAndWalk(true) }
      else root.startClockEpisode(true)
    }
    function discover(): void {
      root.goToSleep()
      root.queuedDiscoveryItem = "pebble"; root.episodeName = "discovery"
      root.wakeAndWalk(true)
    }
    function story(name: string): void {
      if (!root.isStory(name)) return
      root.goToSleep()
      root.storyQueued = name; root.episodeName = name; root.markEpisode(name)
      root.wakeAndWalk(true)
    }
    function preview(name: string): void {
      root.runDevTrigger(name)
    }
    function dev(name: string): void {
      root.runDevTrigger(name)
    }
    function home(name: string): void {
      if (["wake-look", "preen", "dream", "nest-tidy", "night-dream", "dusk-nest", "nest-show", "nest-hat", "nest-rustle"].indexOf(name) < 0) return
      root.goToSleep(); peekTimer.stop()
      root.homeStoryName = name; root.homeStoryStage = 0; root.advanceHomeStory()
    }
    function dream(): void {
      root.goToSleep(); peekTimer.stop()
      root.homeStoryName = "dream"; root.homeStoryStage = 0; root.advanceHomeStory()
    }
    function motion(mode: string): void {
      var wanted = String(mode || "").toLowerCase()
      if (wanted === "reduced" || wanted === "on") root.reducedMotion = true
      else if (wanted === "full" || wanted === "off") root.reducedMotion = false
      else root.reducedMotion = !root.reducedMotion
      root.saveState(); root.scheduleRoam()
    }
    function journal(): void {
      if (root.panelOpen) root.close()
      else root.openJournal()
    }
    function care(): void { root.openCare() }
    function activity(level: string): void {
      var wanted = String(level || "").toLowerCase()
      if (wanted === "quiet" || wanted === "0") root.setActivityLevel(0)
      else if (wanted === "lively" || wanted === "2") root.setActivityLevel(2)
      else if (wanted === "normal" || wanted === "1") root.setActivityLevel(1)
      else root.cycleActivity()
    }
    function curious(mode: string): void {
      var wanted = String(mode || "").toLowerCase()
      if (wanted === "on" || wanted === "true" || wanted === "1") root.setCuriousCursor(true)
      else if (wanted === "off" || wanted === "false" || wanted === "0") root.setCuriousCursor(false)
      else root.toggleCuriousCursor()
    }
  }

  PanelWindow {
    id: habitat; screen: root.petScreen; visible: root.petScreen !== null && root.horizontalBar && !root.barHidden
    color: "transparent"; exclusionMode: ExclusionMode.Ignore
    // Match Omarchy's bar layer so fullscreen windows cover the companion too.
    WlrLayershell.namespace: "pebble"; WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
    anchors { top: root.barPosition !== "bottom"; bottom: root.barPosition === "bottom"; left: true; right: true }
    implicitHeight: root.barSize
    // Mask = penguin box, extended vertically for tall props. Never widen into a bar-punching strip.
    readonly property rect companionMask: {
      var x, y, r, b
      if (root.auditioning) {
        x = conceptPet.x; y = conceptPet.y
        r = x + conceptPet.width; b = y + conceptPet.height
      } else if (root.sleeping) {
        x = den.x; y = den.y
        r = x + den.width * den.scale; b = y + den.height * den.scale
        if (root.storyPropKind !== "" && root.storyPropOpacity > 0) {
          x = Math.min(x, storyProp.x)
          y = Math.min(y, storyProp.y)
          r = Math.max(r, storyProp.x + storyProp.width)
          b = Math.max(b, storyProp.y + storyProp.height)
        }
        if (nestTreasure.visible) {
          x = Math.min(x, nestTreasure.x)
          y = Math.min(y, nestTreasure.y)
          r = Math.max(r, nestTreasure.x + nestTreasure.width)
          b = Math.max(b, nestTreasure.y + nestTreasure.height)
        }
      } else {
        x = animal.x; y = animal.y
        r = x + animal.width; b = y + animal.height
        if (root.headPropKind !== "")
          y = Math.min(y, animal.y - 11 * root.headPropScale)
        if (root.cannonVisible) {
          b = Math.max(b, root.cannonY + root.cannonDrawH())
          x = Math.min(x, root.cannonX)
          r = Math.max(r, root.cannonX + root.cannonDrawW())
        }
        if (root.hoopVisible) {
          b = Math.max(b, root.hoopY + 12 * root.hoopScale)
          x = Math.min(x, root.hoopX)
          r = Math.max(r, root.hoopX + root.hoopGateWidth * root.hoopScale)
        }
        if (root.storyPropKind !== "" && root.storyPropOpacity > 0) {
          y = Math.min(y, storyProp.y)
          b = Math.max(b, storyProp.y + storyProp.height)
        }
        if (root.discoveryVisible && root.discoveryItem !== "") {
          y = Math.min(y, discoveryToy.y)
          b = Math.max(b, discoveryToy.y + discoveryToy.height)
        }
      }
      return Qt.rect(x - 1, y - 1, r - x + 2, b - y + 2)
    }
    mask: Region {
      x: Math.round(habitat.companionMask.x)
      y: Math.round(habitat.companionMask.y)
      width: Math.round(habitat.companionMask.width)
      height: Math.round(habitat.companionMask.height)
    }

    Item {
      id: den
      property real rustleRotation: 0
      // Sleep sprites tuck smaller in-canvas — scale up so the nest reads on dark bars.
      scale: root.sleeping && root.isPenguin ? 1.22 : 1
      x: root.homeX - (scale > 1 ? root.petWidth * (scale - 1) * 0.5 : 0)
      y: Math.round((habitat.height - height * scale) / 2)
      width: root.isPenguin ? root.petWidth : 38
      height: root.isPenguin ? root.petHeight : Math.min(28, habitat.height)
      z: 3
      visible: !root.auditioning && (!root.isPenguin || root.sleeping)
      rotation: rustleRotation
      transformOrigin: Item.Bottom
      Image {
        anchors.fill: parent
        source: Qt.resolvedUrl(root.speciesBase + (root.isPenguin
          ? root.homeStoryName === "wake-look" || root.homeStoryName === "preen"
            || ((root.homeStoryName === "dusk-nest" || root.homeStoryName === "nest-hat") && root.activityLevel !== 0)
            ? "idle-actions/" + root.homePoseFrame + ".png"
            : "sleep-loop/" + root.sleepFrame + ".png"
          : "habitat.png"))
        fillMode: Image.PreserveAspectFit
        smooth: false
        mipmap: false
        layer.enabled: true
        layer.effect: MultiEffect {
          brightness: root.petBrightness
          colorization: root.petColorization
          colorizationColor: Color.bar.text
        }
      }
      Text {
        id: sleepMarker
        x: parent.width - 7; y: 0
        visible: root.sleeping && root.isPenguin && root.deepSleeping && !root.rustling && root.homeStoryName === ""
        text: "z"; color: Color.accent; font.pixelSize: root.activityLevel === 0 ? 13 : 11; font.bold: true; z: 5
        SequentialAnimation on opacity {
          running: sleepMarker.visible; loops: Animation.Infinite
          NumberAnimation { from: 0.35; to: 0.95; duration: 1250; easing.type: Easing.InOutSine }
          NumberAnimation { from: 0.95; to: 0.35; duration: 1550; easing.type: Easing.InOutSine }
        }
      }
      PropArt {
        visible: root.homeStoryName === "nest-hat" && root.leavesFound > 0
        kind: "leaf-hat"
        artScale: 0.95
        x: parent.width * 0.28 - 4
        y: -3
        z: 6
      }
      MouseArea {
        anchors.fill: parent
        enabled: root.sleeping
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
        onClicked: function(mouse) { root.handlePetClick(mouse.button) }
        onContainsMouseChanged: root.onPetHover(containsMouse)
      }
    }

    PropArt {
      id: nestTreasure
      kind: root.favoritePropKind
      x: root.homeX + root.petWidth * 0.70
      y: root.barPropY()
      artScale: root.activityLevel === 0 ? 1.05 : 0.9
      opacity: 0.92
      z: 2
      visible: root.sleeping && root.isPenguin && !root.auditioning
        && root.favoritePropKind !== ""
        && root.homeStoryName !== "nest-tidy"
        && root.homeStoryName !== "nest-show"
    }

    Item {
      id: denEyes
      x: root.homeX + 14
      y: Math.round(habitat.height / 2)
      width: 10
      height: 3
      z: 5
      visible: root.sleeping && !root.isGecko && !root.isPenguin && (root.peeking || root.rustling)
      opacity: root.rustling ? 1 : Math.min(1, root.peekOpacity * 2.1)
      Rectangle {
        x: 0
        y: 1 - height / 2
        width: 2.4
        height: 2.4 * root.eyeOpen
        radius: width / 2
        color: Color.bar.text
      }
      Rectangle {
        x: 7
        y: 1 - height / 2
        width: 2.4
        height: 2.4 * root.eyeOpen
        radius: width / 2
        color: Color.bar.text
      }
    }

    PropArt {
      id: discoveryToy
      x: root.discoveryX
      y: Math.round((habitat.height - height) / 2 + 4 + root.toyHop)
      kind: root.discoveryItem
      artScale: 1
      visible: root.discoveryVisible && !root.auditioning && root.discoveryItem !== ""
      rotation: root.toySpin
      opacity: 0.95
      z: 1
      Behavior on x { enabled: root.discoveryVisible && !root.reducedMotion && Math.abs(root.toyVx) < 2.5; NumberAnimation { duration: 160; easing.type: Easing.OutCubic } }
    }

    Item {
      id: fireHoop
      x: root.hoopX
      y: root.hoopY
      width: root.hoopGateWidth
      height: 10
      visible: root.hoopVisible && !root.auditioning
      opacity: root.hoopOpacity
      scale: root.hoopScale
      z: 3
      transformOrigin: Item.Center
      Behavior on opacity { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }
      Behavior on scale { NumberAnimation { duration: 260; easing.type: Easing.OutBack } }
      Behavior on x { enabled: root.hoopVisible; NumberAnimation { duration: 280; easing.type: Easing.OutCubic } }

      PropArt { x: 0; y: 1; kind: "gate-post"; artScale: 1; opacity: root.hoopOpacity }
      PropArt {
        x: 4; y: 0; kind: "gate-flame"; artScale: 1
        opacity: (0.55 + root.hoopGlow * 0.45) * root.hoopOpacity
      }
      PropArt {
        x: root.hoopGateWidth - 14; y: 0; kind: "gate-flame"; artScale: 1
        opacity: (0.55 + root.hoopGlow * 0.45) * root.hoopOpacity
      }
      PropArt {
        x: root.hoopGateWidth - 4; y: 1; kind: "gate-post"; artScale: 1
        opacity: root.hoopOpacity
      }
    }

    PropArt {
      id: storyProp
      x: root.storyPropX
      y: root.storyPropY
      kind: root.storyPropKind
      artScale: root.storyPropScale
      visible: root.storyPropKind !== "" && !root.auditioning
      opacity: root.storyPropOpacity
      rotation: root.storyPropRotation
      z: 4
      transformOrigin: Item.Center
      Behavior on x { enabled: root.storyPropOpacity > 0; NumberAnimation { duration: 430; easing.type: Easing.InOutCubic } }
      Behavior on y { enabled: root.storyPropOpacity > 0; NumberAnimation { duration: 360; easing.type: Easing.InOutCubic } }
      Behavior on opacity { NumberAnimation { duration: 260; easing.type: Easing.OutSine } }
      Behavior on artScale { enabled: root.storyPropOpacity > 0; NumberAnimation { duration: 300; easing.type: Easing.InOutSine } }
      Behavior on rotation { enabled: root.storyPropOpacity > 0; NumberAnimation { duration: 420; easing.type: Easing.InOutCubic } }
    }

    Item {
      id: animal
      property real breathScale: 1
      property real sniffOffset: 0
      property real sniffRotation: 0
      property real hopOffset: 0
      x: root.petX + root.storyPetOffset; y: Math.round((habitat.height - height) / 2 + sniffOffset + hopOffset)
      width: root.petWidth; height: root.petHeight; rotation: sniffRotation; scale: breathScale * root.slideVisualScale
      visible: !root.sleeping
      opacity: root.animalOpacity
      z: root.cannonVisible && root.storyName === "cannon" ? 8 : (root.storyPetInFront ? 6 : 2)
      transform: Scale { origin.x: animal.width / 2; origin.y: animal.height / 2; xScale: root.direction }

      component PetImage: Image {
        anchors.fill: parent; fillMode: Image.PreserveAspectFit; smooth: false; mipmap: false; cache: true
        layer.enabled: root.petRenderLayer
        layer.effect: MultiEffect {
          brightness: root.petBrightness
          colorization: root.petColorization
          colorizationColor: Color.bar.text
        }
      }
      Repeater { model: 6; PetImage { required property int index; source: Qt.resolvedUrl(root.speciesBase + "walk/" + index + ".png"); visible: false } }
      Repeater { model: 8; PetImage { required property int index; source: Qt.resolvedUrl(root.speciesBase + "wake/" + index + ".png"); visible: false } }
      Repeater { model: root.isPenguin ? 4 : 0; PetImage { required property int index; source: Qt.resolvedUrl(root.speciesBase + "settle/" + index + ".png"); visible: false } }
      Repeater { model: root.isPenguin ? 4 : 0; PetImage { required property int index; source: Qt.resolvedUrl(root.speciesBase + "sleep-loop/" + index + ".png"); visible: false } }
      Repeater { model: root.isPenguin ? 4 : 0; PetImage { required property int index; source: Qt.resolvedUrl(root.speciesBase + "start/" + index + ".png"); visible: false } }
      Repeater { model: root.isPenguin ? 4 : 0; PetImage { required property int index; source: Qt.resolvedUrl(root.speciesBase + "stop/" + index + ".png"); visible: false } }
      Repeater { model: root.isPenguin ? 8 : 0; PetImage { required property int index; source: Qt.resolvedUrl(root.speciesBase + "idle-actions/" + index + ".png"); visible: false } }
      Repeater { model: root.isPenguin ? 8 : 0; PetImage { required property int index; source: Qt.resolvedUrl(root.speciesBase + "slide/" + index + ".png"); visible: false } }
      Repeater { model: root.isPenguin ? 16 : 0; PetImage { required property int index; source: Qt.resolvedUrl(root.speciesBase + "slip/" + index + ".png"); visible: false } }
      PetImage {
        visible: root.action === "idleAction" && root.previousIdleFrame >= 0 && root.idleBlend < 1
        opacity: 1 - root.idleBlend
        source: visible ? Qt.resolvedUrl(root.speciesBase + "idle-actions/" + root.previousIdleFrame + ".png") : ""
      }
      PetImage {
        opacity: root.action === "idleAction" && root.previousIdleFrame >= 0 ? root.idleBlend : 1
        source: root.isPenguin && (root.action === "emerging" || root.action === "settling") ? Qt.resolvedUrl(root.speciesBase + "settle/" + root.poseFrame + ".png")
          : root.isPenguin && root.action === "starting" ? Qt.resolvedUrl(root.speciesBase + "start/" + root.poseFrame + ".png")
          // Reverse the same silhouette used to accelerate.  The original stop
          // drawings were substantially narrower, which made the following
          // front-facing idle pose appear to jump in scale.
          : root.isPenguin && root.action === "stopping" ? Qt.resolvedUrl(root.speciesBase + "start/" + (3 - root.poseFrame) + ".png")
          : root.isPenguin && root.action === "idleAction" ? Qt.resolvedUrl(root.speciesBase + "idle-actions/" + root.idleFrame + ".png")
          : root.isPenguin && root.action === "sliding" ? Qt.resolvedUrl(root.speciesBase + "slide/" + root.poseFrame + ".png")
          : root.isPenguin && root.action === "slipping" ? Qt.resolvedUrl(root.speciesBase + "slip/" + root.poseFrame + ".png")
          : root.isPenguin && root.action === "clockPeek" ? Qt.resolvedUrl(root.speciesBase + "idle-actions/" + root.idleFrame + ".png")
          : root.isPenguin && root.action === "clockApproach" ? Qt.resolvedUrl(root.speciesBase + "walk/" + root.walkFrame + ".png")
          : root.posing ? Qt.resolvedUrl(root.speciesBase + "wake/" + root.poseFrame + ".png")
          : root.walking ? Qt.resolvedUrl(root.speciesBase + "walk/" + root.walkFrame + ".png")
          : Qt.resolvedUrl(root.speciesBase + "idle.png")
      }
      PropArt {
        visible: root.headPropKind !== ""
        kind: root.headPropKind
        artScale: root.headPropScale
        rotation: root.headPropRotation
        x: animal.width * 0.30 - width / 2
        y: -height + 5
        z: 6
        transformOrigin: Item.Bottom
        Behavior on rotation { NumberAnimation { duration: 320; easing.type: Easing.InOutSine } }
      }
      PropArt {
        visible: root.carriedItem !== "" && root.journeyPhase === "returning"
        x: animal.width - 12
        y: animal.height - 14
        kind: root.carriedItem
        artScale: 0.85
        z: 4
      }
      MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
        onClicked: function(mouse) { root.handlePetClick(mouse.button) }
        onContainsMouseChanged: root.onPetHover(containsMouse)
      }
    }

    Item {
      id: cannonProp
      x: root.cannonX
      y: root.cannonY
      width: root.cannonDrawW()
      height: root.cannonDrawH()
      visible: root.cannonVisible && !root.auditioning
      opacity: root.cannonOpacity
      z: root.cannonVisible && root.storyName === "cannon" ? 1 : (root.storyPetInFront ? 2 : 8)
      transformOrigin: root.direction > 0 ? Item.Left : Item.Right
      transform: Scale {
        origin.x: root.direction > 0 ? 0 : cannonProp.width
        origin.y: cannonProp.height
        xScale: root.direction
        yScale: 1
      }
      Behavior on opacity { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }

      PropArt {
        kind: "cannon"
        artScale: root.cannonArtScale
        anchors.bottom: parent.bottom
        x: 0
      }
      PropArt {
        kind: "flash"
        visible: root.cannonFlash
        artScale: root.cannonArtScale
        // Local right = muzzle (parent Scale flips with direction).
        x: parent.width - 10 * root.cannonArtScale
        y: Math.round(1 * root.cannonArtScale)
      }
      PropArt {
        kind: "cannonball"
        visible: root.cannonFlash
        artScale: root.cannonArtScale
        x: parent.width - 12 * root.cannonArtScale
        y: Math.round(0 * root.cannonArtScale)
      }
    }

    Item {
      id: conceptPet
      property real breathScale: 1
      property real hopOffset: 0
      property real reactionRotation: 0
      x: root.conceptX
      y: Math.round((habitat.height - height) / 2 + hopOffset)
      width: root.conceptWidth
      height: root.conceptHeight
      visible: root.auditioning
      z: 4
      scale: breathScale
      rotation: reactionRotation
      transformOrigin: Item.Bottom
      transform: Scale { origin.x: conceptPet.width / 2; origin.y: conceptPet.height / 2; xScale: root.conceptDirection }
      Image {
        anchors.fill: parent
        source: root.auditioning ? Qt.resolvedUrl("assets/concepts/" + root.conceptId + ".png") : ""
        fillMode: Image.PreserveAspectFit
        smooth: false
        mipmap: false
        layer.enabled: true
        layer.effect: MultiEffect { colorization: 0.05; colorizationColor: Color.bar.text }
      }
      MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
        onClicked: function(mouse) { root.handlePetClick(mouse.button) }
        onContainsMouseChanged: root.onPetHover(containsMouse)
      }
    }

  }

  PopupCard {
    id: journal
    anchorItem: root.journalAnchor
    bar: root.bar
    owner: root
    open: root.panelOpen
    contentWidth: fittedContentWidth(root.devToolsEnabled && root.devPanelOpen ? 380 : 340)
    contentHeight: fittedContentHeight(panelColumn.implicitHeight, root.devToolsEnabled && root.devPanelOpen ? 760 : 520)

    Column {
      id: panelColumn
      width: parent.width
      spacing: 10

      Row {
        width: parent.width
        Text {
          id: panelTitle
          text: "PEBBLE"
          color: Color.accent
          font.pixelSize: 15
          font.bold: true
        }
        Item { width: Math.max(8, parent.width - panelTitle.implicitWidth - localBadge.implicitWidth); height: 1 }
        Text {
          id: localBadge
          text: "LOCAL"
          color: Color.bar.text
          opacity: 0.55
          font.pixelSize: 10
          font.bold: true
          anchors.verticalCenter: panelTitle.verticalCenter
        }
      }
      Rectangle { width: parent.width; height: 1; color: Color.accent; opacity: 0.5 }

      Row {
        width: parent.width
        spacing: 8
        Rectangle {
          width: 7; height: 7; radius: 4; color: Color.accent
          anchors.verticalCenter: parent.verticalCenter
        }
        Text {
          text: "NOW"
          color: Color.accent
          font.pixelSize: 10
          font.bold: true
          anchors.verticalCenter: parent.verticalCenter
        }
        Text {
          width: Math.max(60, panelColumn.width - 56)
          text: root.statusText
          color: Color.bar.text
          opacity: 0.92
          font.pixelSize: 13
          wrapMode: Text.WordWrap
        }
      }

      Rectangle {
        width: parent.width
        height: momentLabel.height + momentBody.height + 22
        radius: 7
        color: "transparent"
        border.width: 1
        border.color: Color.accent
        Rectangle { anchors.fill: parent; anchors.margins: 1; radius: 6; color: Color.bar.text; opacity: 0.10 }
        Rectangle { x: 0; y: 0; width: 3; height: parent.height; radius: 2; color: Color.accent }
        Text {
          id: momentLabel
          x: 14; y: 10
          text: "LATEST MOMENT"
          color: Color.accent
          font.pixelSize: 10
          font.bold: true
        }
        Text {
          id: momentBody
          x: 14
          y: momentLabel.y + momentLabel.height + 6
          width: parent.width - 28
          text: root.recentEvent
          color: Color.bar.text
          font.pixelSize: 13
          font.bold: true
          wrapMode: Text.WordWrap
        }
      }

      Row {
        spacing: 8
        Rectangle {
          width: Math.floor((panelColumn.width - 8) / 2)
          height: 34
          radius: 7
          color: "transparent"
          border.width: 1
          border.color: Color.accent
          Rectangle {
            anchors.fill: parent; anchors.margins: 1; radius: 6
            color: Color.accent
            opacity: primaryAct.containsMouse ? 0.36 : 0.24
          }
          Text {
            anchors.centerIn: parent
            text: root.sleeping ? "Explore" : "Go home"
            color: Color.bar.text
            font.pixelSize: 13
            font.bold: true
          }
          MouseArea {
            id: primaryAct
            anchors.fill: parent
            hoverEnabled: true
            onClicked: {
              if (root.sleeping) root.inviteExplore()
              else root.goHomeGracefully()
            }
          }
        }
        Rectangle {
          width: Math.ceil((panelColumn.width - 8) / 2)
          height: 34
          radius: 7
          color: "transparent"
          border.width: snoozeAct.containsMouse || root.snoozed ? 1 : 0
          border.color: Color.accent
          Rectangle {
            anchors.fill: parent
            radius: parent.radius
            color: snoozeAct.containsMouse || root.snoozed ? Color.accent : Color.bar.text
            opacity: snoozeAct.containsMouse || root.snoozed ? 0.30 : 0.12
          }
          Text {
            anchors.centerIn: parent
            text: root.snoozed ? "Wake now" : "Snooze 1h"
            color: Color.bar.text
            font.pixelSize: 13
          }
          MouseArea {
            id: snoozeAct
            anchors.fill: parent
            hoverEnabled: true
            onClicked: root.toggleSnooze()
          }
        }
      }

      Text {
        text: "ENERGY"
        color: Color.accent
        font.pixelSize: 10
        font.bold: true
      }
      Row {
        spacing: 6
        Repeater {
          model: [
            { label: "Quiet", level: 0 },
            { label: "Normal", level: 1 },
            { label: "Lively", level: 2 }
          ]
          delegate: Rectangle {
            required property var modelData
            width: Math.floor((panelColumn.width - 12) / 3)
            height: 30
            radius: 6
            color: "transparent"
            border.width: 1
            border.color: Color.accent
            opacity: root.activityLevel === modelData.level ? 1 : 0.55
            Rectangle {
              anchors.fill: parent; anchors.margins: 1; radius: 5
              color: Color.accent
              opacity: root.activityLevel === modelData.level ? 0.32 : (energyMouse.containsMouse ? 0.16 : 0.06)
            }
            Text {
              anchors.centerIn: parent
              text: modelData.label
              color: Color.bar.text
              font.pixelSize: 12
              font.bold: root.activityLevel === modelData.level
            }
            MouseArea {
              id: energyMouse
              anchors.fill: parent
              hoverEnabled: true
              onClicked: { root.acknowledgeIntro(); root.setActivityLevel(modelData.level) }
            }
          }
        }
      }
      Text {
        width: parent.width
        text: "Quiet sleeps · Normal wanders · Lively shows off"
        color: Color.bar.text
        opacity: 0.62
        font.pixelSize: 11
        wrapMode: Text.WordWrap
      }

      Row {
        spacing: 8
        Rectangle {
          width: Math.floor((panelColumn.width - 8) / 2)
          height: 30
          radius: 6
          color: "transparent"
          border.width: 1
          border.color: Color.accent
          Rectangle {
            anchors.fill: parent; anchors.margins: 1; radius: 5
            color: Color.accent
            opacity: root.curiousCursor ? 0.30 : (curiousAct.containsMouse ? 0.16 : 0.06)
          }
          Text {
            anchors.centerIn: parent
            text: "Curious · " + root.curiousCursorName
            color: Color.bar.text
            font.pixelSize: 12
            font.bold: true
          }
          MouseArea {
            id: curiousAct
            anchors.fill: parent
            hoverEnabled: true
            onClicked: { root.acknowledgeIntro(); root.toggleCuriousCursor() }
          }
        }
        Rectangle {
          width: Math.ceil((panelColumn.width - 8) / 2)
          height: 30
          radius: 6
          color: "transparent"
          border.width: calmAct.containsMouse || root.reducedMotion ? 1 : 0
          border.color: Color.accent
          Rectangle {
            anchors.fill: parent
            radius: parent.radius
            color: root.reducedMotion || calmAct.containsMouse ? Color.accent : Color.bar.text
            opacity: root.reducedMotion ? 0.28 : (calmAct.containsMouse ? 0.16 : 0.08)
          }
          Text {
            anchors.centerIn: parent
            text: root.reducedMotion ? "Calm motion" : "Full motion"
            color: Color.bar.text
            opacity: 0.88
            font.pixelSize: 12
          }
          MouseArea {
            id: calmAct
            anchors.fill: parent
            hoverEnabled: true
            onClicked: { root.acknowledgeIntro(); root.toggleReducedMotion() }
          }
        }
      }

      Text {
        width: parent.width
        text: root.bondName + "  ·  ● " + root.pebblesFound + "  ◆ " + root.leavesFound + "  ✦ " + root.starsFound
        color: Color.bar.text
        opacity: 0.72
        font.pixelSize: 12
        wrapMode: Text.WordWrap
      }

      Column {
        visible: root.devToolsEnabled
        width: parent.width
        spacing: 6
        height: root.devToolsEnabled ? implicitHeight : 0

      Rectangle {
        width: parent.width
        height: 30
        radius: 6
        color: "transparent"
        border.width: 1
        border.color: Color.accent
        Rectangle {
          anchors.fill: parent; anchors.margins: 1; radius: 5
          color: Color.accent
          opacity: root.devPanelOpen ? 0.28 : (devToggle.containsMouse ? 0.14 : 0.06)
        }
        Text {
          anchors.centerIn: parent
          text: root.devPanelOpen ? "Dev triggers ▴" : "Dev triggers ▾"
          color: Color.bar.text
          font.pixelSize: 12
          font.bold: true
        }
        MouseArea {
          id: devToggle
          anchors.fill: parent
          hoverEnabled: true
          onClicked: root.devPanelOpen = !root.devPanelOpen
        }
      }

      Text {
        visible: root.devPanelOpen
        width: parent.width
        text: "Stays open while you test. Wakes him if sleeping. Stages in the open lane (not tray ends)."
        color: Color.bar.text
        opacity: 0.65
        font.pixelSize: 11
        wrapMode: Text.WordWrap
      }

      Flow {
        visible: root.devPanelOpen
        width: parent.width
        spacing: 6
        Repeater {
          model: root.devTriggers
          delegate: Rectangle {
            required property var modelData
            width: Math.max(58, Math.ceil(devLabel.implicitWidth + 16))
            height: 28
            radius: 6
            color: "transparent"
            border.width: 1
            border.color: Color.accent
            Rectangle {
              anchors.fill: parent; anchors.margins: 1; radius: 5
              color: Color.accent
              opacity: devChip.containsMouse ? 0.30 : 0.10
            }
            Text {
              id: devLabel
              anchors.centerIn: parent
              text: modelData.label
              color: Color.bar.text
              font.pixelSize: 11
              font.bold: true
            }
            MouseArea {
              id: devChip
              anchors.fill: parent
              hoverEnabled: true
              onClicked: root.runDevTrigger(modelData.id)
            }
          }
        }
      }

      } // devToolsEnabled Column

      Rectangle {
        width: parent.width
        height: 32
        radius: 7
        color: "transparent"
        border.width: closeAct.containsMouse ? 1 : 0
        border.color: Color.accent
        Rectangle {
          anchors.fill: parent
          radius: parent.radius
          color: closeAct.containsMouse ? Color.accent : Color.bar.text
          opacity: closeAct.containsMouse ? 0.26 : 0.10
        }
        Text {
          anchors.centerIn: parent
          text: "Close"
          color: Color.bar.text
          font.pixelSize: 13
        }
        MouseArea {
          id: closeAct
          anchors.fill: parent
          hoverEnabled: true
          onClicked: root.close()
        }
      }
    }
  }
}
