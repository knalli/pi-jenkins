class Base

  emitter: null

  configure: (@emitter) ->

  getEmitter: -> @emitter

  emit: (event, data) ->
    return unless @emitter
    data.event = event unless data.event
    @emitter.emit event, data

  log: (level, module, text) ->
    @emit "logger.#{level}.#{module}", level: level, module: module, text: text, timestamp: new Date()

  _deepClone: (object) -> JSON.parse JSON.stringify object


exports.Base = Base