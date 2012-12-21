{BaseTask} = require "#{__dirname}/../base_task"


class DefaultTask extends BaseTask

  constructor: (config, app) ->
    super config, app

  run: ->


exports.DefaultTask = DefaultTask