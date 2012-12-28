{BaseTaskAction} = require "#{__dirname}/../../base_task_action"
{TempFileHolder} = require "#{__dirname}/../../helpers/temp_file_holder"
{GoogleTranslatorTtsStrategy} = require "#{__dirname}/../../plugins/say/tts_strategies/google_translator"


class TextToSpeechAction extends BaseTaskAction

  constructor: ->
    @tempFileHolder = new TempFileHolder()

  configure: (app, task, config) ->
    super app, task, config
    @text = config.text

  initialize: ->
    super()
    @tts = new GoogleTranslatorTtsStrategy @tempFileHolder

  run: (scope) ->
    @tts.call text: "#{@text}", language: 'en'


exports.TextToSpeechAction = TextToSpeechAction