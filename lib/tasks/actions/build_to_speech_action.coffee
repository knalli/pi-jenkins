{BaseTaskAction} = require "#{__dirname}/../../base_task_action"
{TempFileHolder} = require "#{__dirname}/../../helpers/temp_file_holder"
{GoogleTranslatorTtsStrategy} = require "#{__dirname}/../../plugins/say/tts_strategies/google_translator"


class BuildToSpeechAction extends BaseTaskAction

  language: null

  constructor: ->
    @tempFileHolder = new TempFileHolder()

  configure: (app, task, config) ->
    super app, task, config
    @language = config.language ? 'en'

  initialize: ->
    super()
    @tts = new GoogleTranslatorTtsStrategy @tempFileHolder

  run: (scope) ->
    @tts.call
      text: "Project #{scope.data.response.name} has currently state #{scope.data.state}."
      language: @language


exports.BuildToSpeechAction = BuildToSpeechAction