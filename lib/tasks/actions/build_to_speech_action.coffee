{BaseTaskAction} = require "#{__dirname}/../../base_task_action"
{TempFileHolder} = require "#{__dirname}/../../helpers/temp_file_holder"
{GoogleTranslatorTtsStrategy} = require "#{__dirname}/../../plugins/say/tts_strategies/google_translator"


class BuildToSpeechAction extends BaseTaskAction

  constructor: ->
    @tempFileHolder = new TempFileHolder()

  initialize: ->
    super()
    @tts = new GoogleTranslatorTtsStrategy @tempFileHolder

  run: (scope) ->
    @tts.call text: "Project #{scope.data.response.name} has currently state #{scope.data.state}.", language: 'en'


exports.BuildToSpeechAction = BuildToSpeechAction