class BaseTaskAction

  config: null
  app: null
  task: null

  constructor: ->

  configure: (@app, @task, config) ->

  initialize: ->

  run: (scope) ->
    null


exports.BaseTaskAction = BaseTaskAction