{BaseTaskAction} = require "#{__dirname}/../../base_task_action"
{TempFileHolder} = require "#{__dirname}/../../helpers/temp_file_holder"
{GoogleTranslatorTtsStrategy} = require "#{__dirname}/../../plugins/say/tts_strategies/google_translator"


class BuildToSpeechAction extends BaseTaskAction

  language: null

  textBuilders: null

  constructor: ->
    @tempFileHolder = new TempFileHolder()
    @textBuilders =
      'FAILURE->SUCCESS': (scope) ->
        "Congratulations, project #{scope.data.response.name} currently switches back from failed to stable."
      'UNSTABLE->SUCCESS': (scope) ->
        "Congratulations, project #{scope.data.response.name} currently switches back from unstable to stable."
      'SUCCESS->UNSTABLE': (scope) ->
        "Oops, project #{scope.data.response.name} has gone unstable."
      'FAILURE->UNSTABLE': (scope) ->
        "Well, project #{scope.data.response.name} is still unstable."
      'SUCCESS->FAILURE': (scope) ->
        "Oh no, project #{scope.data.response.name} has failed."
      'DEFAULT': (scope) ->
        "Project #{scope.data.response.name} has currently the state #{scope.data.state}."

  configure: (app, task, config) ->
    super app, task, config
    @language = config.language ? 'en'

  initialize: ->
    super()
    @tts = new GoogleTranslatorTtsStrategy @tempFileHolder

  run: (scope) ->
    textId = if scope.data.oldState then "#{scope.data.oldState}->#{scope.data.state}" else "#{scope.data.state}"
    textId = 'DEFAULT' unless @textBuilders[textId]
    @tts.call
      text: @textBuilders[textId](scope)
      language: @language


exports.BuildToSpeechAction = BuildToSpeechAction