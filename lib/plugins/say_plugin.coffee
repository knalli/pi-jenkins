http = require 'http'
Q = require 'q'
{exec} = require 'child_process'

{BasePlugin} = require "#{__dirname}/../base_plugin"
{Cli} = require "#{__dirname}/../helpers/cli"
{TempFileHolder} = require "#{__dirname}/../helpers/temp_file_holder"
{GoogleTranslatorTtsStrategy} = require "#{__dirname}/say/tts_strategies/google_translator"


tempFileHolder = new TempFileHolder()


class SayPlugin extends BasePlugin

  name: "Say"
  id: "say"

  initialize: ->
    @registerEvents()
    super()

  registerEvents: ->
    @emitter.on "plugin.#{@id}.onmessage", (options) =>
      @convertTextToSpeech options

  convertTextToSpeech: ({text, strategy, converter, player, playerArg}) ->
    promise = switch strategy
      when 'google'
        @log 'info', "plugin.#{@id}", "TTS Strategy '#{strategy}' will be used."
        s = new GoogleTranslatorTtsStrategy tempFileHolder
        s.call text: text, language: 'en'
      else
        throw new Error "Illegal strategy"
    promise.then (path) =>
      switch converter
        when 'X'
          @log 'info', "plugin.#{@id}", "TTS Converter '#{converter}' will be used."
        else
        # no converter used, so use the original file
          path
    promise.then (path) =>
      switch player
        when 'cli'
          @log 'info', "plugin.#{@id}", "TTS Player '#{player}' will be used."
          Cli.exec executable: playerArg, argument: path
          path
        else
          throw new Error "Illegal player"
    promise.then (path) =>
      tempFileHolder.remove path if path
      path
    promise


exports.SayPlugin = SayPlugin