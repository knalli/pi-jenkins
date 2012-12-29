#!/usr/bin/env coffee

{App} = require '../lib/app'
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