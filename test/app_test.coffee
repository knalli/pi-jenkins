fs = require 'fs'

{App} = require "#{__dirname}/../../lib/app"


exports['App'] =
  setUp: (done) ->
    @emitter =
      on: ->
      emit: ->
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

  'Load a plugin': (test) ->
    app = @app
    test.equal app.getPlugins().length, 0, 'Number of configured plugins should be "0".'
    app.loadPlugins 'say'
    test.equal app.getPlugins().length, 1, 'Number of configured plugins should be "1".'
    test.equal app.getPlugins()[0].getId(), 'say', 'The plugin should be "say".'
    test.equal app.getPlugin('say').getId(), 'say', 'The plugin should be "say".'
    test.done()

  'Load a plugin (which does not exist)': (test) ->
    app = @app
    test.equal app.getPlugins().length, 0, 'Number of configured plugins should be "0".'
    test.equal app.getPlugin('say'), null, 'The plugin should not be found.'
    test.equal app.getPlugins().length, 0, 'Number of configured plugins should be "0".'
    test.equal app.getPlugin('say', true).getId(), 'say', 'The plugin should be "say".'
    test.equal app.getPlugins().length, 1, 'Number of configured plugins should be "1".'
    test.done()

