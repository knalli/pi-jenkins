{BaseTaskAction} = require "#{__dirname}/../../base_task_action"


class BuildToSpeechAction extends BaseTaskAction

  constructor: (config, app, task)->
    super config, app, task

  initialize: ->
    super()


exports.BuildToSpeechAction = BuildToSpeechAction