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

  run: (data) ->
    ###
      The internal index __idx ensure that the deferred scope can access the correct action item.
      Otherwise, the "current" action object is eventually not the scope's current one.
    ###
    promise = null
    scope = data: data
    for action in @actions
      if promise
        promise = promise.then ((lastResult) =>
          scope.lastResult = lastResult
          scope.__idx++
          Q.when @actions[scope.__idx].run scope
        ), ((err) =>
          @log 'warn', 'task.base', "Action #{@actions[scope.__idx]} performed not well: #{err}"
        )
      else
        scope.__idx = 0
        promise = Q.when action.run scope
    return promise


exports.BaseTask = BaseTask