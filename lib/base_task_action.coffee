class BaseTaskAction

  config: null
  app: null
  task: null

  constructor: ->

  configure: (@app, @task, config) ->

  initialize: ->

  returnPreviousResult: ({lastResult}) -> lastResult

  run: (scope) ->
    @returnPreviousResult scope


exports.BaseTaskAction = BaseTaskAction