import "../styles/index.scss"

import _ from "underscore"
import $ from "jquery"

import ace from "ace-builds"
import "ace-builds/src-noconflict/mode-html"
import "ace-builds/src-noconflict/theme-vibrant_ink"
import "ace-builds/src-noconflict/ext-searchbox"
import "ace-builds/src-noconflict/ext-error_marker"

class App
  POWER_MODE_ACTIVATION_THRESHOLD: 200
  STREAK_TIMEOUT: 10 * 1000

  MAX_PARTICLES: 500
  PARTICLE_NUM_RANGE: [5..12]
  PARTICLE_GRAVITY: 0.075
  PARTICLE_SIZE: 8
  PARTICLE_ALPHA_FADEOUT: 0.96
  PARTICLE_VELOCITY_RANGE:
    x: [-2.5, 2.5]
    y: [-7, -3.5]

  PARTICLE_COLORS:
    "text": [255, 255, 255]
    "text.xml": [255, 255, 255]
    "keyword": [0, 221, 255]
    "variable": [0, 221, 255]
    "meta.tag.tag-name.xml": [0, 221, 255]
    "keyword.operator.attribute-equals.xml": [0, 221, 255]
    "constant": [249, 255, 0]
    "constant.numeric": [249, 255, 0]
    "support.constant": [249, 255, 0]
    "string.attribute-value.xml": [249, 255, 0]
    "string.unquoted.attribute-value.html": [249, 255, 0]
    "entity.other.attribute-name.xml": [129, 148, 244]
    "comment": [0, 255, 121]
    "comment.xml": [0, 255, 121]

  EXCLAMATION_EVERY: 10
  EXCLAMATIONS: ["Super!", "Radical!", "Fantastic!", "Great!", "OMG",
  "Whoah!", ":O", "Nice!", "Splendid!", "Wild!", "Grand!", "Impressive!",
  "Stupendous!", "Extreme!", "Awesome!"]

  currentStreak: 0
  finishCount: 0
  powerMode: false
  particles: []
  particlePointer: 0
  lastDraw: 0

  constructor: ->
    @$streakCounter = $ ".streak-container .counter"
    @$streakBar = $ ".streak-container .bar"
    @$exclamations = $ ".streak-container .exclamations"
    @$reference = $ ".reference-screenshot-container"
    @$nameTag = $ ".name-tag"
    @$result = $ ".result"
    @$editor = $ "#editor"
    @canvas = @setupCanvas()
    @canvasContext = @canvas.getContext "2d"
    @$finish = $ ".finish-button"
    @$finishDialog = $ ".finish-dialog"
    @$resetDialog = $ ".reset-dialog"
    @$snitchContainer = $ ".snitch-container"
    @$snitchCounts = $ ".snitch-count"
    @$resultSnitch = $ ".result-snitch"
    @$nameDialog = $ ".name-dialog"
    @$nameInput = $ ".name-input"

    @$body = $ "body"

    @debouncedSaveContent = _.debounce @saveContent, 300
    @debouncedEndStreak = _.debounce @endStreak, @STREAK_TIMEOUT
    @throttledShake = _.throttle @shake, 100, trailing: false
    @throttledSpawnParticles = _.throttle @spawnParticles, 25, trailing: false

    @editor = @setupAce()
    @loadContent()
    @editor.focus()

    @editor.getSession().on "change", @onChange
    $(window).on "beforeunload", -> "Hold your horses!"
    $(window).on "resize", @onResize

    $(".instructions-container, .instructions-button").on "click", @onClickInstructions
    $(".assets-container, .assets-button").on "click", @onClickAssets
    @$reference.on "click", @onClickReference
    @$finish.on "click", @onClickFinish
    $(".finish-cancel-button").on "click", => @$finishDialog[0].close()
    $(".finish-confirm-button").on "click", @onClickFinishConfirm
    $(".reset-button").on "click", => @$resetDialog[0].showModal()
    $(".reset-cancel-button").on "click", => @$resetDialog[0].close()
    $(".reset-confirm-button").on "click", @onClickResetConfirm
    @$nameTag.on "click", => @getName true
    @$nameDialog[0].addEventListener "close", @onNameDialogClose

    @getName()

    @finishCount = parseInt(localStorage["finishCount"] or 0, 10)
    @renderFinishCount()

    window.requestAnimationFrame @onFrame

  setupAce: ->
    ace.config.set "workerPath", "./assets/workers"
    editor = ace.edit "editor"

    editor.setShowPrintMargin false
    editor.setHighlightActiveLine false
    editor.setFontSize 20
    editor.setTheme "ace/theme/vibrant_ink"
    editor.getSession().setMode "ace/mode/html"
    editor.session.setFoldStyle "manual"
    editor.setOption "behavioursEnabled", false
    editor.setOption "enableBasicAutocompletion", false
    editor.setOption "enableLiveAutocompletion", false

    editor

  setupCanvas: ->
    canvas = $(".canvas-overlay")[0]
    @resizeCanvas canvas
    canvas

  resizeCanvas: (canvas = @canvas) ->
    canvas.width = window.innerWidth
    canvas.height = window.innerHeight

  onResize: =>
    @resizeCanvas()

  getName: (forceUpdate) ->
    saved = localStorage["name"]
    if saved and not forceUpdate
      @$nameTag.text saved
      return
    @$nameInput.val(saved or "")
    @$nameDialog[0].showModal()
    @$nameInput[0].select()

  onNameDialogClose: =>
    name = @$nameInput.val().trim()
    if name
      localStorage["name"] = name
      @$nameTag.text name
    else if not localStorage["name"]
      @$nameDialog[0].showModal()

  loadContent: ->
    return unless (content = localStorage["content"])
    @editor.setValue content, -1

  saveContent: =>
    localStorage["content"] = @editor.getValue()

  onFrame: (time) =>
    @drawParticles time - @lastDraw
    @lastDraw = time
    window.requestAnimationFrame @onFrame

  increaseStreak: ->
    @currentStreak++
    @showExclamation() if @currentStreak > 0 and @currentStreak % @EXCLAMATION_EVERY is 0

    if @currentStreak >= @POWER_MODE_ACTIVATION_THRESHOLD and not @powerMode
      @activatePowerMode()

    @refreshStreakBar()

    @renderStreak()

  endStreak: ->
    @currentStreak = 0
    @renderStreak()
    @deactivatePowerMode()

  renderFinishCount: ->
    @$snitchCounts.text @finishCount
    @$snitchContainer.toggle @finishCount > 0

  renderStreak: ->
    @$streakCounter
      .text @currentStreak
      .removeClass "bump"

    _.defer =>
      @$streakCounter.addClass "bump"

  refreshStreakBar: ->
    @$streakBar.css
      "transform": "scaleX(1)"
      "transition": "none"

    _.defer =>
      @$streakBar.css
        "transform": ""
        "transition": "all #{@STREAK_TIMEOUT}ms linear"

  showExclamation: ->
    $exclamation = $("<span>")
      .addClass "exclamation"
      .text _.sample(@EXCLAMATIONS)

    @$exclamations.prepend $exclamation
    setTimeout ->
      $exclamation.remove()
    , 3000

  getCursorPosition: ->
    {left, top} = @editor.renderer.$cursorLayer.getPixelPosition()
    left += @editor.renderer.gutterWidth + 4
    top -= @editor.renderer.scrollTop
    {x: left, y: top}

  spawnParticles: (type) ->
    return unless @powerMode

    {x, y} = @getCursorPosition()
    numParticles = _(@PARTICLE_NUM_RANGE).sample()
    color = @getParticleColor type
    _(numParticles).times =>
      @particles[@particlePointer] = @createParticle x, y, color
      @particlePointer = (@particlePointer + 1) % @MAX_PARTICLES

  getParticleColor: (type) ->
    @PARTICLE_COLORS[type] or [255, 255, 255]

  createParticle: (x, y, color) ->
    x: x
    y: y + 10
    alpha: 1
    color: color
    velocity:
      x: @PARTICLE_VELOCITY_RANGE.x[0] + Math.random() *
        (@PARTICLE_VELOCITY_RANGE.x[1] - @PARTICLE_VELOCITY_RANGE.x[0])
      y: @PARTICLE_VELOCITY_RANGE.y[0] + Math.random() *
        (@PARTICLE_VELOCITY_RANGE.y[1] - @PARTICLE_VELOCITY_RANGE.y[0])

  drawParticles: (timeDelta) =>
    @canvasContext.clearRect 0, 0, @canvas.width, @canvas.height

    for particle in @particles
      continue if particle.alpha <= 0.1

      particle.velocity.y += @PARTICLE_GRAVITY
      particle.x += particle.velocity.x
      particle.y += particle.velocity.y
      particle.alpha *= @PARTICLE_ALPHA_FADEOUT

      @canvasContext.fillStyle = "rgba(#{particle.color.join ", "}, #{particle.alpha})"
      @canvasContext.fillRect(
        Math.round(particle.x - @PARTICLE_SIZE / 2)
        Math.round(particle.y - @PARTICLE_SIZE / 2)
        @PARTICLE_SIZE
        @PARTICLE_SIZE
      )

  shake: ->
    return unless @powerMode

    intensity = 1 + 2 * Math.random() * Math.floor(
      (@currentStreak - @POWER_MODE_ACTIVATION_THRESHOLD) / 100
    )
    x = intensity * (if Math.random() > 0.5 then -1 else 1)
    y = intensity * (if Math.random() > 0.5 then -1 else 1)

    @$editor.css "margin", "#{y}px #{x}px"

    setTimeout =>
      @$editor.css "margin", ""
    , 75

  activatePowerMode: =>
    @powerMode = true
    @$body.addClass "power-mode"

  deactivatePowerMode: =>
    @powerMode = false
    @$body.removeClass "power-mode"

  onClickInstructions: =>
    $("body").toggleClass "show-instructions"
    @editor.focus() unless $("body").hasClass "show-instructions"

  onClickAssets: =>
    $("body").toggleClass "show-assets"
    @editor.focus() unless $("body").hasClass "show-assets"

  onClickReference: =>
    @$reference.toggleClass "active"
    @editor.focus() unless @$reference.hasClass("active")

  onClickFinish: =>
    @$finishDialog[0].showModal()

  onClickFinishConfirm: =>
    @$finishDialog[0].close()
    @finishCount++
    localStorage["finishCount"] = @finishCount
    @renderFinishCount()
    @$result[0].contentWindow.postMessage(@editor.getValue(), "*")
    @$result.show()
    @$resultSnitch.toggle @finishCount > 1

  onClickResetConfirm: =>
    @$resetDialog[0].close()
    localStorage.removeItem "content"
    localStorage.removeItem "name"
    localStorage.removeItem "finishCount"
    @editor.setValue "", -1
    @finishCount = 0
    @renderFinishCount()
    @$result.hide()
    @$resultSnitch.hide()
    @endStreak()
    @getName()

  onChange: (e) =>
    @debouncedSaveContent()
    insertTextAction = e.action is "insert"
    if insertTextAction
      @increaseStreak()
      @debouncedEndStreak()

    @throttledShake()

    pos = if insertTextAction then e.end else e.start

    token = @editor.session.getTokenAt pos.row, pos.column

    _.defer =>
      @throttledSpawnParticles(token.type) if token

$ -> new App
