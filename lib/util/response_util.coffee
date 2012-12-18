Q = require 'q'

getResponseAsString = (response) ->
  deferred = Q.defer()
  data = ''
  response.on 'data', (chunk) -> data += chunk
  response.on 'end', () -> deferred.resolve data
  deferred.promise

getResponseAsJSON = (response) ->
  deferred = Q.defer()
  data = ''
  response.on 'data', (chunk) -> data += chunk
  response.on 'end', () ->
    try
      json = JSON.parse data
      deferred.resolve json
    catch ex
      deferred ex
  deferred.promise

exports.getResponseAsString = getResponseAsString
exports.getResponseAsJSON = getResponseAsJSON