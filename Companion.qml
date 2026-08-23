import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import Quickshell.Wayland
import qs.Commons
import qs.Ui

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
  property string conceptId: ""
  readonly property bool auditioning: conceptId !== ""
  readonly property string conceptName: conceptId === "bird" ? "Songbird"
    : conceptId === "frog" ? "Tree frog" : conceptId === "nova" ? "Nova" : "Cat"
  readonly property string stateDir: Quickshell.env("HOME") + "/.local/state/omarchy/pebble"
  readonly property string statePath: stateDir + "/state.json"
  readonly property int stateMaxBytes: 65536
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
  property bool slipQueued: false
  property string queuedDiscoveryItem: ""
  property string storyQueued: ""
  property string storyName: ""
  property int storyStage: 0
  property string storyPropGlyph: ""
  property real storyPropX: 0
  property real storyPropY: 0
  property real storyPropOpacity: 0
  property real storyPropScale: 1
  property real storyPropRotation: 0
  property real storyPetOffset: 0
  property string homeStoryName: ""
  property int homeStoryStage: 0
  property int homePoseFrame: 0
  property bool deepSleeping: false
  property int outingActsRemaining: 0
  property string personalityMood: "sleepy"
  property string episodeName: ""
  property real animalOpacity: 1
  property bool discoveryVisible: false
  property real discoveryX: 0
  property string discoveryItem: ""
  property bool peeking: false
  property bool rustling: false
  property real peekOpacity: 0
  property real peekLift: 3
  property real eyeOpen: 1
  property bool stateDirReady: false
  property bool stateReady: false
  property bool panelOpen: false
  property bool snoozed: false
  property double snoozeUntil: 0
  property int activityLevel: 1
  property bool reducedMotion: false
  property bool introSeen: false
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
  readonly property string carriedGlyph: carriedItem === "leaf" ? "◆" : carriedItem === "pebble" ? "●" : carriedItem === "star" ? "✦" : ""
  readonly property string discoveryGlyph: discoveryItem === "leaf" ? "◆" : discoveryItem === "pebble" ? "●" : discoveryItem === "star" ? "✦" : ""
  readonly property string activityName: activityLevel === 0 ? "Quiet" : activityLevel === 2 ? "Lively" : "Normal"
  readonly property string motionName: reducedMotion ? "Reduced" : "Full"
  readonly property string favoriteItem: pebblesFound >= leavesFound && pebblesFound >= starsFound && pebblesFound > 0 ? "pebbles"
    : leavesFound >= starsFound && leavesFound > 0 ? "leaves" : starsFound > 0 ? "stars" : "quiet corners"
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
  readonly property real homeX: Math.min(worldMaxX, Math.max(worldMinX, passageRightX + 96))
  readonly property real doorwayX: Math.min(worldMaxX, homeX + 34)
  readonly property string statusText: snoozed ? "Snoozing for one hour"
    : sleeping ? "Resting on the bar"
    : carriedItem !== "" ? "Carrying a " + carriedItem + " home"
    : episodeName === "clock-retreat" ? "Hiding behind the clock"
    : episodeName === "clock-cross" ? "Investigating the clock"
    : episodeName === "discovery" ? "Searching for treasure"
    : episodeName === "slip" ? "Recovering with dignity"
    : episodeName === "belly-slide" ? "Sliding across the bar"
    : episodeName === "edge-watch" ? "Inspecting the edge"
    : episodeName === "firefly" ? "Following a tiny light"
    : episodeName === "polish" ? "Polishing a favorite pebble"
    : episodeName === "leaf-toss" ? "Playing with a leaf"
    : episodeName === "stargaze" ? "Watching a small star"
    : episodeName === "collection-sort" ? "Arranging the collection"
    : episodeName === "stretch" ? "Taking a serious stretch"
    : episodeName === "lost-pebble" ? "Chasing a runaway pebble"
    : episodeName === "listen" ? "Listening behind the clock"
    : personalityMood === "playful" ? "Looking for trouble"
    : personalityMood === "curious" ? "Exploring the bar"
    : "Taking a quiet wander"

  Behavior on storyPetOffset { NumberAnimation { duration: 360; easing.type: Easing.InOutCubic } }

  function clampX(value) { return Math.max(worldMinX, Math.min(worldMaxX, value)) }
  function initialPosition() { return doorwayX }
  function chooseDestination() {
    var usableWidth = Math.max(1, worldMaxX - worldMinX)
    var minimumTrip = Math.min(usableWidth * 0.45, Math.max(140, usableWidth * (personalityMood === "playful" ? 0.22 : 0.14)))
    var candidate = worldMinX + Math.random() * usableWidth
    for (var attempt = 0; attempt < 5 && Math.abs(candidate - petX) < minimumTrip; attempt++)
      candidate = worldMinX + Math.random() * usableWidth
    if (Math.abs(candidate - petX) < minimumTrip)
      candidate = petX < (worldMinX + worldMaxX) * 0.5 ? worldMaxX : worldMinX
    return Math.round(clampX(candidate))
  }
  function randomDiscoveryType() {
    var roll = Math.random()
    return roll < 0.24 ? "leaf" : roll < 0.86 ? "pebble" : "star"
  }
  function currentHour() { return new Date().getHours() }
  function collectionSize() { return leavesFound + pebblesFound + starsFound }
  function isStory(name) {
    return ["edge-watch", "firefly", "polish", "leaf-toss", "stargaze", "collection-sort", "stretch", "lost-pebble", "listen"].indexOf(name) >= 0
  }
  function storyEligible(name) {
    if (name === "polish" || name === "lost-pebble") return pebblesFound > 0
    if (name === "leaf-toss") return leavesFound > 0
    if (name === "collection-sort") return collectionSize() >= 3
    if (name === "stargaze") return currentHour() >= 19 || currentHour() < 6
    return true
  }
  function episodeCooldown(name) {
    var base = name === "clock" ? 240000 : name === "discovery" ? 90000
      : name === "slide" ? 150000 : name === "slip" ? 210000
      : name === "stretch" ? 360000 : name === "firefly" ? 480000
      : name === "edge-watch" ? 540000 : name === "listen" ? 600000
      : name === "polish" || name === "leaf-toss" ? 720000
      : name === "lost-pebble" ? 840000 : name === "collection-sort" ? 900000
      : name === "stargaze" ? 1200000 : 180000
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
      if (reducedMotion && (name === "slide" || name === "slip" || name === "lost-pebble")) return
      if (!storyEligible(name) || !episodeReady(name) || recentEpisodes.slice(0, 3).indexOf(name) >= 0) {
        if (storyEligible(name) && episodeReady(name)) repeatAvoided++
        return
      }
      for (var index = 0; index < weight; index++) pool.push(name)
    }
    if (activityLevel === 2) {
      add("discovery", 2); add("clock", 1); add("slide", 3); add("slip", 3)
      add("edge-watch", 1); add("firefly", 2); add("stretch", 2); add("listen", 1)
      add("polish", 1); add("leaf-toss", 2); add("stargaze", 1); add("collection-sort", 1); add("lost-pebble", 2)
    } else {
      add("discovery", 3); add("clock", 2); add("slide", interactive ? 2 : 1); add("slip", 1)
      add("edge-watch", 2); add("firefly", 2); add("stretch", 2); add("listen", 1)
      add("polish", 1); add("leaf-toss", 1); add("stargaze", 2); add("collection-sort", 1); add("lost-pebble", 1)
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
    peekTimer.interval = 8000 + Math.floor(Math.random() * 10000)
    peekTimer.restart()
  }
  function scheduleSleepMarker() {
    if (!sleeping || barHidden || !horizontalBar || homeStoryName !== "") {
      sleepMarkerTimer.stop(); deepSleeping = false; return
    }
    sleepMarkerTimer.interval = deepSleeping
      ? 2200 + Math.floor(Math.random() * 1800)
      : 7000 + Math.floor(Math.random() * 9000)
    sleepMarkerTimer.restart()
  }
  function advanceSleepMarker() { deepSleeping = !deepSleeping; scheduleSleepMarker() }
  function beginEmergence(interactive) {
    rustling = false
    if (interactive !== undefined) personalityMood = interactive ? (pokeCount >= 2 ? "playful" : "curious") : "sleepy"
    outings++; saveState()
    var lingerChance = reducedMotion ? 0.20 : activityLevel === 2 ? 0.62 : 0.36
    outingActsRemaining = Math.random() < lingerChance ? (activityLevel === 2 && Math.random() < 0.18 ? 2 : 1) : 0
    journeyPhase = "outbound"; petX = homeX + 5; direction = 1
    poseFrame = isPenguin ? 3 : 0; action = "emerging"; poseTimer.interval = 155; poseTimer.restart()
  }
  function wakeAndWalk(interactive) {
    if (!placed || barHidden || !horizontalBar) return
    if (auditioning) { startConceptMotion(true); return }
    if (walking) { walkMotion.stop(); acknowledgeAnimation.restart(); return }
    roamTimer.stop(); peekTimer.stop(); peekAnimation.stop(); peeking = false
    curiosityAnimation.stop(); settleTurn.stop(); poseTimer.stop()
    if (sleeping) {
      cancelHomeStory()
      sleepMarkerTimer.stop(); deepSleeping = false
      personalityMood = interactive ? "curious" : activityLevel === 2 && Math.random() < 0.64 ? "playful" : "sleepy"
      if (interactive !== true) queueAutonomousEpisode()
      rustling = true; peekOpacity = 0.65; eyeOpen = 1; rustleAnimation.restart()
    }
    else beginEmergence(interactive)
  }
  function planRoute() {
    if (storyQueued === "edge-watch") finalX = Math.random() < 0.5 ? worldMinX + 6 : worldMaxX - 6
    else if (storyQueued === "listen") finalX = clampX(passageRightX + petWidth + 24)
    else if (storyQueued === "polish" || storyQueued === "collection-sort") finalX = clampX(homeX + 90 + Math.random() * 70)
    else if (["firefly", "leaf-toss", "lost-pebble", "stargaze"].indexOf(storyQueued) >= 0)
      finalX = Math.max(worldMinX + 70, Math.min(worldMaxX - 90, chooseDestination()))
    else finalX = chooseDestination()
    pace = (isGecko ? 118 : personalityMood === "playful" ? 135 : personalityMood === "curious" ? 108 : 88)
      + Math.random() * (isGecko ? 55 : 24)
    pauseOnRoute = Math.abs(finalX - petX) > 118 && Math.random() < (personalityMood === "sleepy" ? 0.28 : 0.58)
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
    discoveryVisible = true
  }
  function collectDiscovery() {
    if (!discoveryVisible || discoveryItem === "") return
    carriedItem = discoveryItem; discoveryVisible = false; discoveryItem = ""
  }
  function storeDiscovery() {
    if (carriedItem === "leaf") { leavesFound++; rememberEvent("Brought home a particularly interesting leaf.", 3) }
    else if (carriedItem === "pebble") { pebblesFound++; rememberEvent("Found another pebble. Excellent pebble.", 3) }
    else if (carriedItem === "star") { starsFound++; rememberEvent("Found a tiny star and carried it safely home.", 3) }
    carriedItem = ""; saveState()
  }
  function curiosityFinished() {
    if (finalCuriosity && isPenguin) {
      collectDiscovery()
      if (storyQueued !== "") startQueuedStory()
      else if (personalityMood === "playful" && episodeReady("slide") && Math.random() < (activityLevel === 2 ? 0.30 : 0.14)) startSlide()
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
  function startClockEpisode(suspicious) {
    if (!isPenguin || !placed || clockApproach.running || clockOcclusion.running || clockTransitOcclusion.running) return
    if (petX + petWidth < passageLeftX) { startClockTransit(doorwayX, 1); return }
    markEpisode(suspicious ? "retreat" : "clock")
    walkMotion.stop(); slideMotion.stop(); slipMotion.stop(); poseTimer.stop(); curiosityAnimation.stop()
    slideTimer.stop(); slipTimer.stop(); idleActionTimer.stop(); idleBlendAnimation.stop(); idleTransitionMotion.stop()
    discoveryVisible = false; discoveryItem = ""
    episodeName = suspicious ? "clock-retreat" : "clock-cross"
    personalityMood = suspicious ? "cautious" : "curious"
    clockTransit = false
    direction = -1; targetX = passageRightX + 3
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
    if (episodeName === "clock-retreat") {
      suspiciousRetreats++
      rememberEvent("Retreated behind the clock. Remains suspicious.", 2)
    } else {
      clockPassages++
      rememberEvent("Checked behind the clock. Time remains suspicious.", 2)
    }
    saveState()
    episodeName = ""; retreatQueued = false; animalOpacity = 1; direction = 1; petX = passageRightX + 3
    startReturn()
  }
  function startReturn() {
    journeyPhase = "returning"; pauseOnRoute = false
    if (isPenguin) { pendingDestination = doorwayX; poseFrame = 0; action = "starting"; poseTimer.interval = 110; poseTimer.restart() }
    else startLeg(doorwayX)
  }
  function beginEntering() {
    if (isPenguin) { poseFrame = 0; action = "settling"; poseTimer.interval = 165; poseTimer.restart() }
    else { poseFrame = 7; action = "entering"; poseTimer.interval = 145; poseTimer.restart() }
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
    storyPropGlyph = ""; storyPropOpacity = 0; storyPropScale = 1; storyPropRotation = 0
    storyPetOffset = 0
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
      "edge-watch": "Confirmed that the bar still has an edge.",
      "firefly": "Followed a tiny light until it vanished.",
      "polish": "Polished one pebble to a respectable shine.",
      "leaf-toss": "A leaf briefly became excellent entertainment.",
      "stargaze": "Stayed up to watch a very small star.",
      "collection-sort": "Rearranged the collection. Again.",
      "stretch": "Completed a surprisingly serious stretch.",
      "lost-pebble": "Recovered a pebble attempting an escape.",
      "listen": "Heard something behind the clock. Probably time."
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
      if (stage === 0) { idleFrame = 0; storyPropGlyph = "•"; storyPropX = petX + petWidth + 4; storyPropY = 6; storyPropOpacity = 0.9; storyPropScale = 0.8; storyDelay(520) }
      else if (stage === 1) { idleFrame = 1; storyPropX += direction * 22; storyPropY = 2; storyPropScale = 1.25; animal.sniffRotation = direction * 6; storyDelay(720) }
      else if (stage === 2) { idleFrame = 2; storyPropX -= direction * 13; storyPropY = 13; storyPropScale = 0.72; animal.sniffRotation = direction * -5; storyDelay(680) }
      else if (stage === 3) { idleFrame = 7; storyPropX += direction * 34; storyPropY = 4; storyPropScale = 1.05; animal.hopOffset = -3; storyDelay(760) }
      else if (stage === 4) { storyPropOpacity = 0; animal.hopOffset = 0; animal.sniffRotation = 0; storyDelay(480) }
      else finishStory()
    } else if (storyName === "polish") {
      if (stage === 0) { idleFrame = 3; storyPropGlyph = "●"; storyPropX = petX + petWidth - 5; storyPropY = 17; storyPropOpacity = 0.95; storyDelay(700) }
      else if (stage === 1) { idleFrame = 0; animal.sniffRotation = 6; storyPropRotation = 28; storyDelay(620) }
      else if (stage === 2) { idleFrame = 2; animal.sniffRotation = -5; storyPropRotation = -24; storyDelay(620) }
      else if (stage === 3) { idleFrame = 7; storyPropGlyph = "✦"; storyPropScale = 1.35; storyDelay(850) }
      else if (stage === 4) { storyPropOpacity = 0; animal.sniffRotation = 0; storyDelay(420) }
      else finishStory()
    } else if (storyName === "leaf-toss") {
      if (stage === 0) { idleFrame = 4; storyPropGlyph = "◆"; storyPropX = petX + petWidth - 2; storyPropY = 17; storyPropOpacity = 0.9; storyDelay(480) }
      else if (stage === 1) { idleFrame = 5; storyPropX += direction * 18; storyPropY = 1; storyPropRotation = 95; animal.hopOffset = -3; storyDelay(720) }
      else if (stage === 2) { idleFrame = 7; storyPropX -= direction * 10; storyPropY = 11; storyPropRotation = 190; animal.hopOffset = 0; storyDelay(620) }
      else if (stage === 3) { idleFrame = 5; storyPropX += direction * 15; storyPropY = 4; storyPropRotation = 285; animal.hopOffset = -2; storyDelay(680) }
      else if (stage === 4) { storyPropOpacity = 0; animal.hopOffset = 0; storyDelay(400) }
      else finishStory()
    } else if (storyName === "stargaze") {
      if (stage === 0) { idleFrame = 1; storyPropGlyph = "✦"; storyPropX = petX + petWidth + 8; storyPropY = 2; storyPropOpacity = 0.35; storyPropScale = 0.7; storyDelay(700) }
      else if (stage === 1) { idleFrame = 7; storyPropOpacity = 1; storyPropScale = 1.3; animal.sniffRotation = direction * -7; storyDelay(1500) }
      else if (stage === 2) { storyPropOpacity = 0.55; storyPropScale = 0.9; storyDelay(1100) }
      else if (stage === 3) { storyPropOpacity = 1; storyPropScale = 1.15; storyDelay(1300) }
      else if (stage === 4) { storyPropOpacity = 0; animal.sniffRotation = 0; storyDelay(500) }
      else finishStory()
    } else if (storyName === "collection-sort") {
      if (stage === 0) { idleFrame = 3; storyPropGlyph = pebblesFound > 0 ? "●" : "◆"; storyPropX = petX + petWidth - 3; storyPropY = 18; storyPropOpacity = 0.95; storyDelay(650) }
      else if (stage === 1) { idleFrame = 0; storyPropX += direction * 11; storyPropGlyph = leavesFound > 0 ? "◆" : "●"; animal.sniffRotation = 5; storyDelay(700) }
      else if (stage === 2) { idleFrame = 2; storyPropX += direction * 10; storyPropGlyph = starsFound > 0 ? "✦" : "●"; animal.sniffRotation = -5; storyDelay(700) }
      else if (stage === 3) { idleFrame = 7; storyPropX -= direction * 10; storyPropGlyph = "● ◆"; animal.sniffRotation = 0; storyDelay(900) }
      else if (stage === 4) { storyPropOpacity = 0; storyDelay(420) }
      else finishStory()
    } else if (storyName === "stretch") {
      if (stage === 0) { idleFrame = 6; animal.sniffRotation = direction * -4; storyDelay(780) }
      else if (stage === 1) { idleFrame = 3; animal.hopOffset = 2; storyDelay(620) }
      else if (stage === 2) { idleFrame = 4; animal.hopOffset = -2; animal.sniffRotation = direction * 5; storyDelay(720) }
      else if (stage === 3) { idleFrame = 7; animal.hopOffset = 0; animal.sniffRotation = 0; storyDelay(600) }
      else finishStory()
    } else if (storyName === "lost-pebble") {
      if (stage === 0) { idleFrame = 1; storyPropGlyph = "●"; storyPropX = petX + petWidth - 4; storyPropY = 18; storyPropOpacity = 1; storyDelay(520) }
      else if (stage === 1) { idleFrame = 2; storyPropX += direction * 58; storyPropRotation = 180; animal.sniffRotation = direction * 9; storyDelay(850) }
      else if (stage === 2) { idleFrame = 5; storyPetOffset = direction * 24; animal.hopOffset = -3; storyDelay(650) }
      else if (stage === 3) { idleFrame = 0; storyPropX -= direction * 13; storyPetOffset = direction * 38; animal.hopOffset = 0; storyDelay(700) }
      else if (stage === 4) { idleFrame = 7; storyPropOpacity = 0; storyPetOffset = 0; animal.sniffRotation = 0; storyDelay(520) }
      else finishStory()
    } else if (storyName === "listen") {
      if (stage === 0) { idleFrame = 0; storyPropGlyph = "···"; storyPropX = passageRightX + 3; storyPropY = 8; storyPropOpacity = 0.35; animal.sniffRotation = -6; storyDelay(900) }
      else if (stage === 1) { idleFrame = 1; storyPropOpacity = 0.9; animal.sniffRotation = 5; storyDelay(1200) }
      else if (stage === 2) { idleFrame = 2; storyPropScale = 1.25; animal.sniffRotation = -3; storyDelay(900) }
      else if (stage === 3) { idleFrame = 7; storyPropOpacity = 0; animal.sniffRotation = 0; storyDelay(550) }
      else finishStory()
    } else finishStory()
  }
  function cancelStory() {
    resetStoryVisuals(); storyQueued = ""; storyName = ""; storyStage = 0
  }
  function startHomeMoment() {
    if (!sleeping || rustling || snoozed || barHidden) { schedulePeek(); return }
    deepSleeping = false; sleepMarkerTimer.stop()
    var roll = Math.random()
    if (!isPenguin && roll < 0.48) { peekAnimation.restart(); return }
    homeStoryName = isPenguin
      ? roll < 0.25 ? "wake-look"
        : roll < 0.44 ? "preen"
        : roll < 0.65 ? "dream"
        : (currentHour() >= 20 || currentHour() < 6) && roll > 0.86 ? "night-dream"
        : "nest-tidy"
      : (currentHour() >= 20 || currentHour() < 6) && roll > 0.84 ? "night-dream"
        : roll < 0.74 ? "dream" : "nest-tidy"
    homeStoryStage = 0
    advanceHomeStory()
  }
  function homeStoryDelay(milliseconds) {
    homeMomentTimer.interval = milliseconds
    homeMomentTimer.restart()
  }
  function cancelHomeStory() {
    homeMomentTimer.stop(); homeStoryName = ""; homeStoryStage = 0
    homePoseFrame = 0
    storyPropGlyph = ""; storyPropOpacity = 0; storyPropScale = 1; storyPropRotation = 0
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
      if (stage === 0) { storyPropGlyph = "·"; storyPropX = homeX + petWidth - 5; storyPropY = 10; storyPropOpacity = 0.45; storyPropScale = 0.7; homeStoryDelay(650) }
      else if (stage === 1) { storyPropGlyph = "○"; storyPropX += 7; storyPropY = 5; storyPropOpacity = 0.8; storyPropScale = 0.9; homeStoryDelay(800) }
      else if (stage === 2) { storyPropGlyph = "z"; storyPropX += 6; storyPropY = 1; storyPropOpacity = 0.9; storyPropScale = 1.05; homeStoryDelay(900) }
      else if (stage === 3) { storyPropOpacity = 0; homeStoryDelay(400) }
      else finishHomeStory()
    } else if (homeStoryName === "nest-tidy") {
      if (stage === 0) { storyPropGlyph = favoriteItem === "pebbles" ? "●" : favoriteItem === "leaves" ? "◆" : favoriteItem === "stars" ? "✦" : "·"; storyPropX = homeX + petWidth - 8; storyPropY = 18; storyPropOpacity = 0.8; den.rustleRotation = -1.8; homeStoryDelay(480) }
      else if (stage === 1) { storyPropX += 9; storyPropRotation = 80; den.rustleRotation = 1.8; homeStoryDelay(520) }
      else if (stage === 2) { storyPropX -= 5; storyPropOpacity = 0; den.rustleRotation = -0.8; homeStoryDelay(450) }
      else finishHomeStory()
    } else if (homeStoryName === "night-dream") {
      if (stage === 0) { storyPropGlyph = "✦"; storyPropX = homeX + petWidth + 2; storyPropY = 3; storyPropOpacity = 0.25; storyPropScale = 0.65; homeStoryDelay(750) }
      else if (stage === 1) { storyPropOpacity = 0.95; storyPropScale = 1.2; homeStoryDelay(1100) }
      else if (stage === 2) { storyPropOpacity = 0.4; storyPropScale = 0.8; homeStoryDelay(850) }
      else if (stage === 3) { storyPropOpacity = 0; homeStoryDelay(420) }
      else finishHomeStory()
    } else finishHomeStory()
  }
  function curlUp() {
    cancelStory(); cancelHomeStory()
    action = "home"; journeyPhase = "home"; petX = doorwayX; poseFrame = 0; pokeCount = 0
    sleepFrame = 0; idleBeatsRemaining = 0; outingActsRemaining = 0; playfulQueued = false; retreatQueued = false; clockQueued = false; slipQueued = false
    episodeName = ""; clockTransit = false; clockTransitEpisode = ""; animalOpacity = 1; discoveryVisible = false; discoveryItem = ""; personalityMood = "sleepy"
    animal.sniffRotation = 0; animal.hopOffset = 0; animal.breathScale = 1
    peeking = false; rustling = false; peekOpacity = 0; scheduleRoam(); schedulePeek(); scheduleSleepMarker()
  }
  function goToSleep() {
    walkMotion.stop(); curiosityAnimation.stop(); acknowledgeAnimation.stop(); playfulAnimation.stop()
    rustleAnimation.stop(); settleTurn.stop(); poseTimer.stop(); conceptTravel.stop(); slideMotion.stop(); slideTimer.stop()
    slipMotion.stop(); slipTimer.stop(); clockApproach.stop(); clockOcclusion.stop(); clockTransitOcclusion.stop()
    idleActionTimer.stop(); idleBlendAnimation.stop(); idleTransitionMotion.stop(); curlUp()
  }
  function poke() {
    if (snoozed) cancelSnooze()
    var now = Date.now()
    pokeCount = now - lastPoke < 2200 ? Math.min(3, pokeCount + 1) : 1; lastPoke = now
    totalPokes++; saveState()
    if (sleeping) wakeAndWalk(true)
    else if (posing) {
      if (!reducedMotion && pokeCount >= 3 && isPenguin) retreatQueued = true
      else if (!reducedMotion && pokeCount >= 2 && isPenguin) playfulQueued = true
    }
    else {
      if (storyName !== "") cancelStory()
      walkMotion.stop(); curiosityAnimation.stop(); acknowledgeAnimation.stop(); playfulAnimation.stop()
      if (!reducedMotion && pokeCount >= 3 && isPenguin) startClockEpisode(true)
      else if (!reducedMotion && pokeCount >= 2 && isPenguin) startSlide()
      else if (pokeCount >= 2) playfulAnimation.restart(); else acknowledgeAnimation.restart()
    }
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
    var names = ["clock", "discovery", "slide", "slip", "retreat", "edge-watch", "firefly", "polish", "leaf-toss", "stargaze", "collection-sort", "stretch", "lost-pebble", "listen"]
    for (var index = 0; index < names.length; index++) {
      var timestamp = safeTimestamp(raw[names[index]], now + 60000)
      if (timestamp > 0) cleaned[names[index]] = timestamp
    }
    return cleaned
  }
  function episodeNames() {
    return ["clock", "discovery", "slide", "slip", "retreat", "edge-watch", "firefly", "polish", "leaf-toss", "stargaze", "collection-sort", "stretch", "lost-pebble", "listen"]
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
      lastDirectedEpisode = ["clock", "discovery", "slide", "slip", "retreat", "edge-watch", "firefly", "polish", "leaf-toss", "stargaze", "collection-sort", "stretch", "lost-pebble", "listen"].indexOf(storedEpisode) >= 0 ? storedEpisode : ""
      lastDirectedEpisodeAt = safeTimestamp(data.lastDirectedEpisodeAt, Date.now() + 60000)
      var storedActivity = Number(data.activity)
      activityLevel = isNaN(storedActivity) ? 1 : Math.max(0, Math.min(2, storedActivity))
      reducedMotion = data.reducedMotion === true
      introSeen = data.introSeen === true
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
    stateFile.setText(JSON.stringify({
      version: 9, species: speciesId, concept: conceptId, outings: outings, pokes: totalPokes,
      distance: distanceWalked, leaves: leavesFound, pebbles: pebblesFound,
      stars: starsFound, slides: slidesCompleted, slips: slipsCompleted,
      passages: clockPassages, retreats: suspiciousRetreats, recentEvent: recentEvent,
      recentEventAt: recentEventAt, recentEventPriority: recentEventPriority,
      episodeTimes: episodeTimes, lastDirectedEpisode: lastDirectedEpisode, lastDirectedEpisodeAt: lastDirectedEpisodeAt,
      recentEpisodes: recentEpisodes, episodeCounts: episodeCounts, repeatAvoided: repeatAvoided,
      activity: activityLevel, reducedMotion: reducedMotion, introSeen: introSeen,
      firstMetAt: firstMetAt, lastSeenDay: lastSeenDay, daysTogether: daysTogether, snoozeUntil: snoozeUntil
    }, null, 2) + "\n")
  }
  function cycleActivity() { activityLevel = (activityLevel + 1) % 3; saveState(); scheduleRoam() }
  function acknowledgeIntro() { if (!introSeen) { introSeen = true; saveState() } }
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
    if (button === Qt.RightButton) panelOpen = !panelOpen
    else if (button === Qt.MiddleButton) goToSleep()
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
  FileView {
    id: stateFile
    path: root.stateDirReady ? root.statePath : ""
    watchChanges: false
    atomicWrites: true
    printErrors: false
    // Read access is intentionally handled by stateReadProc above. FileView is
    // retained only for atomic writes after the bounded, no-follow load passes.
  }

  Timer {
    id: poseTimer; repeat: true
    onTriggered: {
      if (root.action === "emerging") {
        if (root.isPenguin && root.poseFrame > 0) { root.poseFrame--; root.petX += 8 }
        else if (root.isPenguin) { stop(); root.planRoute() }
        else if (root.poseFrame < 7) { root.poseFrame++; root.petX += 4; interval = root.poseFrame < 2 ? 210 : 135 }
        else { stop(); root.planRoute() }
      } else if (root.action === "starting") {
        if (root.poseFrame < 3) root.poseFrame++
        else { stop(); root.startLeg(root.pendingDestination) }
      } else if (root.action === "stopping") {
        if (root.poseFrame < 3) root.poseFrame++
        else { stop(); if (root.playfulQueued) { root.playfulQueued = false; root.startSlide() } else root.finishStoppedLeg() }
      } else if (root.action === "settling") {
        if (root.poseFrame < 3) { root.poseFrame++; root.petX -= 8 }
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
    ParallelAnimation {
      NumberAnimation { target: root; property: "petX"; to: root.passageRightX - root.petWidth * 0.48; duration: 270; easing.type: Easing.InCubic }
      NumberAnimation { target: root; property: "animalOpacity"; to: 0; duration: 235; easing.type: Easing.InCubic }
    }
    ScriptAction {
      script: {
        root.direction = -1
        root.petX = root.passageLeftX - root.petWidth * 0.42
        root.idleFrame = root.episodeName === "clock-retreat" ? 0 : 1
        root.action = "clockPeek"
      }
    }
    ParallelAnimation {
      NumberAnimation { target: root; property: "animalOpacity"; to: 1; duration: 300; easing.type: Easing.OutCubic }
      NumberAnimation { target: root; property: "petX"; to: root.passageLeftX - root.petWidth - 12; duration: 390; easing.type: Easing.OutCubic }
    }
    PauseAnimation { duration: root.episodeName === "clock-retreat" ? 1180 : 850 }
    SequentialAnimation {
      loops: root.episodeName === "clock-retreat" ? 2 : 1
      NumberAnimation { target: animal; property: "sniffRotation"; to: -4; duration: 100; easing.type: Easing.InOutSine }
      NumberAnimation { target: animal; property: "sniffRotation"; to: 3; duration: 130; easing.type: Easing.InOutSine }
    }
    ParallelAnimation {
      NumberAnimation { target: animal; property: "sniffRotation"; to: 0; duration: 120; easing.type: Easing.OutCubic }
      NumberAnimation { target: root; property: "animalOpacity"; to: 0; duration: 190; easing.type: Easing.InCubic }
      NumberAnimation { target: root; property: "petX"; to: root.passageLeftX - root.petWidth * 0.42; duration: 320; easing.type: Easing.InCubic }
    }
    ScriptAction { script: { root.petX = root.passageRightX + 3; root.direction = 1; root.action = "clockHidden" } }
    NumberAnimation { target: root; property: "animalOpacity"; to: 1; duration: 230; easing.type: Easing.OutCubic }
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
    ScriptAction { script: root.beginEmergence() }
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
    id: discoveryPulse; running: root.discoveryVisible; loops: Animation.Infinite
    NumberAnimation { target: discoveryMarker; property: "pulseScale"; to: 1.18; duration: 420; easing.type: Easing.InOutSine }
    NumberAnimation { target: discoveryMarker; property: "pulseScale"; to: 1; duration: 520; easing.type: Easing.InOutSine }
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
    function roam(): void { root.wakeAndWalk(true) }
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
      if (!root.isStory(name)) return
      root.goToSleep(); roamTimer.stop(); peekTimer.stop()
      root.storyQueued = name; root.episodeName = name; root.startQueuedStory()
    }
    function home(name: string): void {
      if (["wake-look", "preen", "dream", "nest-tidy", "night-dream"].indexOf(name) < 0) return
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
    function journal(): void { root.panelOpen = !root.panelOpen }
  }

  PanelWindow {
    id: habitat; screen: root.petScreen; visible: root.petScreen !== null && root.horizontalBar && !root.barHidden
    color: "transparent"; exclusionMode: ExclusionMode.Ignore
    // Match Omarchy's bar layer so fullscreen windows cover the companion too.
    WlrLayershell.namespace: "pebble"; WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
    anchors { top: root.barPosition !== "bottom"; bottom: root.barPosition === "bottom"; left: true; right: true }
    implicitHeight: root.barSize
    mask: Region {
      x: Math.round(root.auditioning ? conceptPet.x : root.sleeping ? den.x : animal.x)
      y: Math.round(root.auditioning ? conceptPet.y : root.sleeping ? den.y : animal.y)
      width: Math.round(root.auditioning ? conceptPet.width : root.sleeping ? den.width : animal.width)
      height: Math.round(root.auditioning ? conceptPet.height : root.sleeping ? den.height : animal.height)
    }

    Item {
      id: den
      property real rustleRotation: 0
      x: root.homeX
      y: Math.round((habitat.height - height) / 2)
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
            ? "idle-actions/" + root.homePoseFrame + ".png"
            : "sleep-loop/" + root.sleepFrame + ".png"
          : "habitat.png"))
        fillMode: Image.PreserveAspectFit
        smooth: false
        mipmap: false
        layer.enabled: true
        layer.effect: MultiEffect { colorization: root.isPenguin ? 0.03 : root.isGecko ? 0.08 : 0.18; colorizationColor: Color.bar.text }
      }
      Text {
        id: sleepMarker
        x: parent.width - 7; y: 0
        visible: root.sleeping && root.isPenguin && root.deepSleeping && !root.rustling && root.homeStoryName === ""
        text: "z"; color: Color.accent; font.pixelSize: 8; font.bold: true; z: 5
        SequentialAnimation on opacity {
          running: sleepMarker.visible; loops: Animation.Infinite
          NumberAnimation { from: 0.35; to: 0.95; duration: 1250; easing.type: Easing.InOutSine }
          NumberAnimation { from: 0.95; to: 0.35; duration: 1550; easing.type: Easing.InOutSine }
        }
      }
      MouseArea {
        anchors.fill: parent
        enabled: root.sleeping && !root.rustling
        acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
        onClicked: function(mouse) { root.handlePetClick(mouse.button) }
      }
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

    Text {
      id: discoveryMarker
      property real pulseScale: 1
      x: root.discoveryX
      y: Math.round((habitat.height - height) / 2 + 5)
      visible: root.discoveryVisible && !root.auditioning
      text: root.discoveryGlyph
      color: Color.accent
      font.pixelSize: 8
      font.bold: true
      scale: pulseScale
      opacity: 0.92
      z: 1
    }

    Text {
      id: storyProp
      x: root.storyPropX
      y: root.storyPropY
      visible: root.storyPropGlyph !== "" && !root.auditioning
      text: root.storyPropGlyph
      color: Color.accent
      font.pixelSize: 8
      font.bold: true
      opacity: root.storyPropOpacity
      scale: root.storyPropScale
      rotation: root.storyPropRotation
      z: 4
      Behavior on x { enabled: root.storyPropOpacity > 0; NumberAnimation { duration: 430; easing.type: Easing.InOutCubic } }
      Behavior on y { enabled: root.storyPropOpacity > 0; NumberAnimation { duration: 360; easing.type: Easing.InOutCubic } }
      Behavior on opacity { NumberAnimation { duration: 260; easing.type: Easing.InOutSine } }
      Behavior on scale { enabled: root.storyPropOpacity > 0; NumberAnimation { duration: 300; easing.type: Easing.InOutSine } }
      Behavior on rotation { enabled: root.storyPropOpacity > 0; NumberAnimation { duration: 420; easing.type: Easing.InOutCubic } }
    }

    Item {
      id: animal
      property real breathScale: 1
      property real sniffOffset: 0
      property real sniffRotation: 0
      property real hopOffset: 0
      x: root.petX + root.storyPetOffset; y: Math.round((habitat.height - height) / 2 + sniffOffset + hopOffset)
      width: root.petWidth; height: root.petHeight; rotation: sniffRotation; scale: breathScale
      visible: !root.sleeping
      opacity: root.animalOpacity
      z: 2
      transform: Scale { origin.x: animal.width / 2; origin.y: animal.height / 2; xScale: root.direction }

      component PetImage: Image {
        anchors.fill: parent; fillMode: Image.PreserveAspectFit; smooth: false; mipmap: false; cache: true
        layer.enabled: true
        layer.effect: MultiEffect { colorization: root.isPenguin ? 0.03 : root.isGecko ? 0.05 : 0.13; colorizationColor: Color.bar.text }
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
      Text {
        visible: root.carriedItem !== "" && root.journeyPhase === "returning"
        text: root.carriedGlyph
        color: Color.accent
        font.pixelSize: 8
        font.bold: true
        x: animal.width - 7
        y: animal.height - 11
        z: 4
      }
      MouseArea {
        anchors.fill: parent; acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
        onClicked: function(mouse) { root.handlePetClick(mouse.button) }
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
        acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
        onClicked: function(mouse) { root.handlePetClick(mouse.button) }
      }
    }
  }

  PopupCard {
    id: journal
    anchorItem: den
    bar: root.bar
    owner: root
    open: root.panelOpen
    contentWidth: 270
    contentHeight: 252

    Column {
      anchors.fill: parent
      spacing: 7
      Row {
        width: 246; height: 16
        Text { id: journalTitle; text: "PEBBLE'S JOURNAL"; color: Color.accent; font.pixelSize: 13; font.bold: true }
        Item { width: 246 - journalTitle.implicitWidth - localLabel.implicitWidth; height: 1 }
        Text { id: localLabel; text: "LOCAL"; color: Color.bar.text; opacity: 0.58; font.pixelSize: 8; font.bold: true }
      }
      Rectangle { width: 246; height: 1; color: Color.accent; opacity: 0.58 }
      Row {
        spacing: 6
        Rectangle { width: 5; height: 5; radius: 3; color: Color.accent; anchors.verticalCenter: parent.verticalCenter }
        Text { text: "NOW"; color: Color.accent; font.pixelSize: 8; font.bold: true; anchors.verticalCenter: parent.verticalCenter }
        Text { text: root.statusText; color: Color.bar.text; opacity: 0.86; font.pixelSize: 10; anchors.verticalCenter: parent.verticalCenter }
      }
      Rectangle {
        width: 246; height: 52; radius: 5; color: "transparent"
        border.width: 1; border.color: Color.accent
        Rectangle { anchors.fill: parent; anchors.margins: 1; radius: 4; color: Color.bar.text; opacity: 0.12 }
        Rectangle { x: 0; y: 0; width: 3; height: parent.height; radius: 2; color: Color.accent }
        Text {
          x: 11; y: 5; text: "LATEST MOMENT"
          color: Color.accent; font.pixelSize: 8; font.bold: true
        }
        Text {
          x: 11; y: 17; width: 226; height: 30
          text: root.recentEvent
          color: Color.bar.text; opacity: 1; font.pixelSize: 10; font.bold: true
          wrapMode: Text.WordWrap; verticalAlignment: Text.AlignVCenter
        }
      }
      Row {
        spacing: 5
        Rectangle { width: 3; height: 9; color: Color.accent; anchors.verticalCenter: parent.verticalCenter }
        Text { text: "MEMORIES  ·  " + root.bondName.toUpperCase(); color: Color.bar.text; opacity: 0.82; font.pixelSize: 9; font.bold: true }
      }
      Text {
        text: "● " + root.pebblesFound + " pebbles     ◆ " + root.leavesFound + " leaves     ✦ " + root.starsFound + " stars"
        color: Color.accent; font.pixelSize: 10; font.bold: true
      }
      Text {
        text: root.outings + " outings   ·   " + root.clockPassages + " passages   ·   " + root.totalPokes + " pokes"
        color: Color.bar.text; opacity: 0.68; font.pixelSize: 9
      }
      Row {
        spacing: 8
        Rectangle {
          width: 116; height: 30; radius: 6
          color: "transparent"
          border.width: 1; border.color: Color.accent
          Rectangle {
            anchors.fill: parent; anchors.margins: 1; radius: 5
            color: Color.accent
            opacity: primaryMouse.containsMouse ? 0.34 : 0.22
          }
          Text { anchors.centerIn: parent; text: root.sleeping ? "Explore" : "Go home"; color: Color.bar.text; font.pixelSize: 10; font.bold: true }
          MouseArea {
            id: primaryMouse; anchors.fill: parent; hoverEnabled: true
            onClicked: {
              if (root.sleeping) root.inviteExplore()
              else { root.panelOpen = false; root.goToSleep() }
            }
          }
        }
        Rectangle {
          width: 122; height: 30; radius: 6
          color: "transparent"
          border.width: snoozeMouse.containsMouse ? 1 : 0; border.color: Color.accent
          Rectangle { anchors.fill: parent; radius: parent.radius; color: snoozeMouse.containsMouse ? Color.accent : Color.bar.text; opacity: snoozeMouse.containsMouse ? 0.30 : 0.13 }
          Text { anchors.centerIn: parent; text: root.snoozed ? "Wake now" : "Snooze 1h"; color: Color.bar.text; font.pixelSize: 10 }
          MouseArea { id: snoozeMouse; anchors.fill: parent; hoverEnabled: true; onClicked: root.toggleSnooze() }
        }
      }
      Row {
        spacing: 8
        Rectangle {
          width: 119; height: 24; radius: 5; color: "transparent"
          border.width: activityMouse.containsMouse ? 1 : 0; border.color: Color.accent
          Rectangle { anchors.fill: parent; radius: parent.radius; color: activityMouse.containsMouse ? Color.accent : Color.bar.text; opacity: activityMouse.containsMouse ? 0.18 : 0.07 }
          Text { anchors.centerIn: parent; text: "Activity · " + root.activityName; color: Color.bar.text; opacity: 0.76; font.pixelSize: 9 }
          MouseArea { id: activityMouse; anchors.fill: parent; hoverEnabled: true; onClicked: { root.acknowledgeIntro(); root.cycleActivity() } }
        }
        Rectangle {
          width: 119; height: 24; radius: 5; color: "transparent"
          border.width: motionMouse.containsMouse || root.reducedMotion ? 1 : 0; border.color: Color.accent
          Rectangle { anchors.fill: parent; radius: parent.radius; color: motionMouse.containsMouse ? Color.accent : Color.bar.text; opacity: motionMouse.containsMouse ? 0.18 : 0.07 }
          Text { anchors.centerIn: parent; text: "Motion · " + root.motionName; color: Color.bar.text; opacity: 0.76; font.pixelSize: 9 }
          MouseArea { id: motionMouse; anchors.fill: parent; hoverEnabled: true; onClicked: { root.acknowledgeIntro(); root.toggleReducedMotion() } }
        }
      }
    }
  }
}
