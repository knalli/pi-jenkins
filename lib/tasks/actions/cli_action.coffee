{Cli} = require "#{__dirname}/../../helpers/cli"
{BaseTaskAction} = require "#{__dirname}/../../base_task_action"


class CliAction extends BaseTaskAction

  exec: null

  initialize: ->
    super()

  configure: (app, task, config) ->
    super app, task, config
    {@exec} = config

  run: (scope) ->
    Cli.exec
      executable: @exec
      argument: scope.lastResult


exports.CliAction = CliAction