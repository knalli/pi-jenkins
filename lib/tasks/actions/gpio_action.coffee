{BaseTaskAction} = require "#{__dirname}/../../base_task_action"
{TempFileHolder} = require "#{__dirname}/../../helpers/temp_file_holder"
{GoogleTranslatorTtsStrategy} = require "#{__dirname}/../../plugins/say/tts_strategies/google_translator"

# https://github.com/JamesBarwell/rpi-gpio.js
gpio = require 'rpi-gpio'

class GpioAction extends BaseTaskAction

  lights: null

  lightActions: null

  lightActionDefault: null

  setLight: (light, switchedOn) ->
    gpio.write @lights[light].pin, (switchedOn is true)

  configure: (app, task, config) ->
    super app, task, config

  configureLights: (@lights) ->

  configureActions: (config) ->
    @lightActions = config.actions
    @lightActionDefault = config['default']

  initialize: ->
    super()
    gpio.on 'change', (channel, value) =>
      @log 'info', "logger.action.gpio.change", "Channel #{channel} value is now #{value}"
    @initializePins()

  initializePins: () ->
    gpio.reset()
    gpio.setMode gpio.MODE_BCM
    for own ledId, ledConfig of @lights
      gpio.setup ledConfig.pin, gpio.DIR_OUT

  runAction: (actionId, scope) ->
    actionDefintionFn = @lightActions[actionId] or @lightActionDefault
    actions = actionDefintionFn scope
    for own ledId, ledMode of actions
      gpio.write @lights[ledId].pin, (ledMode is 'on')
    return

  getActionIdByScope: (scope) -> 'UNKNOWN'

  run: (scope) ->
    actionId = @getActionIdByScope scope
    @runAction actionId, scope
    @returnPreviousResult scope


exports.GpioAction = GpioAction
exports.gpio = gpio