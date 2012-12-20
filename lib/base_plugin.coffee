{Base} = require "#{__dirname}/base"

class BasePlugin extends Base

  name: null

  id: null

  emitter: null

  state: null

  constructor: (@app) ->
    super @app.getEmitter()

  getName: -> @name

  getId: -> @id

  setState: (state) ->
    oldState = @state
    @state = state
    @logState 'info', state, oldState

  initialize: ->
    @setState 'INITIALIZED'

  start: ->
    @setState 'STARTED'

  stop: ->
    @setState 'STOPPED'

  configure: (config) ->
    @addListeners config.listeners if config.listeners
    @setState 'CONFIGURED'

  addListeners: (listeners) ->
    for own id, listener of listeners
      @_addListener listener, id

  _addListener: (listener, id) ->
    listener.id = if id then id else "#{new Date().getTime()}"
    @log 'info', "plugin.#{@getId()}", "Add event #{listener.event} (id=#{listener.id})."
    @emitter.on listener.event, (args...) =>
      scope = app: @app
      for pluginId in listener.plugins
        plugin = @app.getPlugin pluginId, true
        unless plugin then @log 'error', "plugin.#{@getId()}", "The plugin #{pluginId} could not be found."
        scope[pluginId] = plugin
      listener.fn.apply scope, args

  logState: (level, newState, oldState) ->
    if oldState
      @log level, "plugin.#{@getId()}", "The plugin changed its state: #{oldState} => #{newState}"
    else
      @log level, "plugin.#{@getId()}", "The plugin changed its state: #{newState}"

  logMessage: (level, message) ->
    @log level, "plugin.#{@getId()}", message

exports.BasePlugin = BasePlugin