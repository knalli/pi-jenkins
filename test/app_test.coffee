fs = require 'fs'

{App} = require "#{__dirname}/../../lib/app"


exports['App'] =
  setUp: (done) ->
    @emitter = {on: -> console.info 'Event ON'}
    @app = new App @emitter
    done()

  tearDown: (done) ->
    done()

  'Empty tasks (undefined)': (test) ->
    app = @app
    test.equal app.getTasks().length, 0, 'List of configured tasks should be empty.'
    app._configureTasks undefined
    test.equal app.getTasks().length, 0, 'List of configured tasks should be empty.'
    test.done()

  'Empty tasks (null)': (test) ->
    app = @app
    test.equal app.getTasks().length, 0, 'List of configured tasks should be empty.'
    app._configureTasks null
    test.equal app.getTasks().length, 0, 'List of configured tasks should be empty.'
    test.done()

  'Empty tasks (empty array)': (test) ->
    app = @app
    test.equal app.getTasks().length, 0, 'List of configured tasks should be empty.'
    app._configureTasks []
    test.equal app.getTasks().length, 0, 'List of configured tasks should be empty.'
    test.done()

  'Empty tasks (empty object)': (test) ->
    app = @app
    test.equal app.getTasks().length, 0, 'List of configured tasks should be empty.'
    app._configureTasks {}
    test.equal app.getTasks().length, 0, 'List of configured tasks should be empty.'
    test.done()

  'Configure a task': (test) ->
    app = @app
    test.equal app.getTasks().length, 0, 'List of configured tasks should be empty.'
    tasks = [(
      event: 'eventname'
      actions: [(
        type: 'buildToSpeech'
      )]
    )]
    app._configureTasks tasks
    test.equal app.getTasks().length, 1, 'List of configured tasks should contain exactly this task.'
    test.done()

  'Configure a task with actions': (test) ->
    app = @app
    test.equal app.getTasks().length, 0, 'List of configured tasks should be empty.'
    tasks = [(
      event: 'eventname'
      actions: [(
        type: 'buildToSpeech'
      )]
    )]
    app.configure tasks: tasks
    test.equal app.getTasks().length, 1, 'List of configured tasks should contain exactly this task.'
    test.done()

