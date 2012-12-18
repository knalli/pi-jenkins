class Base

  emitter: null

  constructor: (@emitter) ->

  getEmitter: -> @emitter

  emit: (event, data) ->
    data.event = event unless data.event
    @emitter.emit event, data

  log: (level, module, text) ->
    @emit "logger.#{level}.#{module}", level: level, module: module, text: text, timestamp: new Date()

  _deepClone: (object) -> JSON.parse JSON.stringify object


exports.Base = Base