#!/usr/bin/env coffee

{App} = require '../lib/app'
{Cli} = require '../lib/helpers/cli'

Q = require 'q'
{EventEmitter2} = require 'eventemitter2'

MY_LOCAL_PLAYER = '/usr/bin/afplay'

app = new App(new EventEmitter2 wildcard: true, maxListeners: 50)

# Logging
(->
  emitter = app.getEmitter()

  emitter.on 'logger.**', (data) ->
    console.info "[#{data.level}] [#{data.timestamp}] #{data.module}: #{data.text}"

  emitter.on 'plugin.jenkins.**', (data) ->
    console.info "[Jenkins Job (#{data.event})] [#{data.response.name}] #{data.state}: #{data.response.number}"
)()

# The internal Raspberry PI audio output channel clicks on output. This is a temporarily hack to fix this issue.
(->
  fn = ->
    promise = Cli.exec executable: MY_LOCAL_PLAYER, argument: "#{__dirname}/../resources/blank_mp3_point1sec.mp3"
    promise.then ->
      setTimeout fn, 3000
  setTimeout fn, 3000
)()

app.configure
  tasks: [(
    event: 'app.started'
    actions: [(
      type: 'TextToSpeech'
      language: 'en'
      using: 'google,festival'
      text: 'The Raspberry PI is ready!'
    ), (
      type: 'CombineAudio'
      prefix: true
      using: 'mp3'
    ), (
      type: 'Cli'
      exec: MY_LOCAL_PLAYER
    )]
  ), (
    event: 'plugin.jenkins.job.init'
    actions: [(
      type: 'BuildToSpeech'
      language: 'en'
      using: 'google,festival'
    ), (
      type: 'LogBuildTable'
    ), (
      type: 'CombineAudio'
      prefix: true
      using: 'mp3'
    ), (
      type: 'Cli'
      exec: MY_LOCAL_PLAYER
    )]
  ), (
    event: 'plugin.jenkins.job.state'
    actions: [(
      type: 'BuildToSpeech'
      language: 'en'
      using: 'google,festival'
    ), (
      type: 'LogBuildTable'
    ), (
      type: 'CombineAudio'
      prefix: true
      using: 'mp3'
    ), (
      type: 'Cli'
      exec: MY_LOCAL_PLAYER
    )]
  )]
  plugins:
    jenkins:
      autoDiscovery:
        pattern: '.*'
        host: 'http://localhost:8000'
        jobDefaultInterval: 10000

app.start()