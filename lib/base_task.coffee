{Wrappers} = require "#{__dirname}/helpers/wrappers"


class BaseTask

  config: null
  app: null

  actions: null

  constructor: ->
    @actions = []

  configure: (@app, @config) ->
    @_configureActions @config.actions if @config.actions?.length

  _configureActions: (actions) ->
    @actions = (@_buildAction action for action in actions)
    return

  initialize: ->
    action.initialize() for action in @actions
    return

  _buildAction: (config) ->
    config.type = Wrappers.underscored(config.type ? 'default')
    config.type = "#{config.type}_action" unless config.type[-7..] is '_action'
    className = Wrappers.classify config.type
    filePath = "#{__dirname}/tasks/actions/#{config.type}"
    requiredScope = require filePath
    Clazz = requiredScope[className]
    throw new Error "Type #{className} was not found in file #{filePath}." unless Clazz
    new Clazz config, @app, @

  run: ->


exports.BaseTask = BaseTask