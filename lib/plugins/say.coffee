http = require 'http'
fs = require 'fs'
temp = require 'temp'
Q = require 'q'
{exec} = require 'child_process'

{BasePlugin} = require "#{__dirname}/../base_plugin"


class TempFileHolder

  @store: (chunks) ->
    tempOptions = suffix: '.mp3'
    (Q.nfbind temp.open)(tempOptions).then (info) ->
      fd = info.fd
      for chunk in chunks
        fs.writeSync fd, chunk, 0, chunk.length, null
      fs.closeSync fd
      info.path


class GoogleTtsStrategy
  call: ({language, text}) ->
    deferred = Q.defer()
    options =
      hostname: 'translate.google.com'
      port: 80
      path: "/translate_tts?ie=UTF-8&tl=#{language}&q=#{encodeURIComponent text}"
      method: 'GET'
      headers:
        'User-Agent': 'Mozilla'
    request = http.request options, (response) =>
      chunks = []
      response.on 'data', (chunk) -> chunks.push chunk
      response.on 'end', => Q.when(TempFileHolder.store chunks).then deferred.resolve, deferred.reject
    request.on 'error', deferred.reject
    request.end()
    deferred.promise


class AfplayAudioPlayer
  call: ({path}) ->
    (Q.nfbind exec) "/usr/bin/afplay #{path}"

class SayPlugin extends BasePlugin

  name: "Say"
  id: "say"

  initialize: ->
    @registerEvents()
    super()

  registerEvents: ->
    @emitter.on "plugin.#{@id}.onmessage", (options) =>
      @convertTextToSpeech options

  convertTextToSpeech: ({text, strategy, converter, player}) ->
    promise = switch strategy
      when 'google'
        @log 'info', "plugin.#{@id}", "TTS Strategy '#{strategy}' will be used."
        s = new GoogleTtsStrategy
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
        when 'afplay'
          @log 'info', "plugin.#{@id}", "TTS Player '#{player}' will be used."
          p = new AfplayAudioPlayer
          p.call path: path
        else
          throw new Error "Illegal player"
    promise


exports.Plugin = SayPlugin