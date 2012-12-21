{BaseTaskAction} = require "#{__dirname}/../../base_task_action"


class CombineAudioAction extends BaseTaskAction

  initialize: ->
    super()

  run: (scope) ->
    scope.lastResult


exports.CombineAudioAction = CombineAudioAction