fs = require 'fs'

{getResponseAsJSON} = require "#{__dirname}/../../lib/util/response_util"

exports['Util.getResponseAsJSON'] =
  setUp: (done) ->
    done()

  tearDown: (done) ->
    done()

  'Test JSON return': (test) ->
    callbacks = data: null, end: null
    requestMock =
      on: (event, callback) -> callbacks[event] = callback
    promise = getResponseAsJSON requestMock
    test.equal promise.isResolved(), false, 'Promise should not be resolved yet.'
    test.equal typeof callbacks.data, 'function', 'The "data" callback must be defined.'
    test.equal typeof callbacks.end, 'function', 'The "end" callback must be defined.'
    callbacks.data '{"abcd" : 1234}'
    callbacks.end()
    test.equal promise.isResolved(), true, 'Promise should be resolved.'
    test.equal promise.isFulfilled(), true, 'Promise should be fulfilled.'
    promise.then (response) ->
      test.equal JSON.stringify(response), JSON.stringify({abcd: 1234}), 'The result should match the orioginal response data.'
    promise.fin -> test.done()


  'Test exception (invalid JSON)': (test) ->
    callbacks = data: null, end: null
    requestMock =
      on: (event, callback) -> callbacks[event] = callback
    promise = getResponseAsJSON requestMock
    test.equal promise.isResolved(), false, 'Promise should not be resolved yet.'
    test.equal typeof callbacks.data, 'function', 'The "data" callback must be defined.'
    test.equal typeof callbacks.end, 'function', 'The "end" callback must be defined.'
    callbacks.data 'This is invalid JSON object'
    callbacks.end()
    test.equal promise.isResolved(), true, 'Promise should be resolved.'
    test.equal promise.isFulfilled(), false, 'Promise should not be fulfilled.'
    promise.then null, (exception) ->
      test.equal typeof exception, 'object', 'The result should be an error.'
      test.equal exception.getMessage(), '[SyntaxError: Unexpected token T]', 'The result should be the error message.'
    promise.fin -> test.done()


