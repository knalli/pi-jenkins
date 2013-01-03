Q = require 'q'

{Base} = require "#{__dirname}/base"
{Wrappers} = require "#{__dirname}/helpers/wrappers"
{BeanBuilder} = require "#{__dirname}/helpers/bean_builder"


class BaseTask extends Base

  app: null

  actions: null
  actionBuilder: null

  constructor: ->
    @actions = []
    @actionBuilder = new BeanBuilder basePath: "#{__dirname}/tasks/actions", suffix: 'action'

  configure: (@app, config) ->
    super @app.getEmitter()
    @_configureActions config.actions if config.actions?.length

  _configureActions: (actions) ->
    @actions = (@_buildAction action for action in actions)
    return

  initialize: ->
    for action in @actions
      action.initialize()
    return

  _buildAction: (config) ->
    action = @actionBuilder.build config
    action.configure @app, @, config
    return action

  run: (data)->
    promise = null
    scope = data: data
    for action in @actions
      if promise
        promise.then ((lastResult) ->
          scope.lastResult = lastResult
          Q.when action.run scope
        ), ((err) =>
          @log 'warn', 'task.base', "Action #{action} performed not well.", err
        )
      else
        promise = Q.when action.run scope
    return promise


exports.BaseTask = BaseTask