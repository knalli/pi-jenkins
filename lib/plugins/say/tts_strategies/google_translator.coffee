http = require 'http'
Q = require 'q'


class GoogleTranslatorTtsStrategy

  fileHolder: null

  constructor: (@fileHolder) ->

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
      response.on 'end', => Q.when(@fileHolder.write chunks).then deferred.resolve, deferred.reject
    request.on 'error', deferred.reject
    request.end()
    deferred.promise


exports.GoogleTranslatorTtsStrategy = GoogleTranslatorTtsStrategy