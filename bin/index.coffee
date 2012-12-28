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
      text : 'The Raspberry PI is ready!'
    ), (
      type: 'CombineAudio'
      prefix: true
      using: 'mp3'
    ), (
      type: 'Cli'
      exec: MY_LOCAL_PLAYER
    )]
  ),(
    event: 'plugin.jenkins.job.init'
    actions: [(
      type: 'BuildToSpeech'
      language: 'en'
      using: 'google,festival'
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
      watchers:
        one:
          name: 'Jenkins Main Trunk'
          host: 'https://ci.jenkins-ci.org'
          path: '/view/Jenkins%20core/job/jenkins_main_trunk'
          build: 'lastBuild'
          interval: 60000
      listeners:
        one:
          event: 'plugin.jenkins.job.init'
          plugins: ['say']
          fn: (data) -> console.info "Project #{data.response.name} has currently state #{data.state}."
        two:
          event: 'plugin.jenkins.job.state'
          plugins: ['say']
          fn: (data) -> console.info "Project #{data.response.name} has changed to #{data.state}."
        three:
          event: 'plugin.jenkins.job.refresh'
          plugins: ['say']
          fn: (data) -> console.info "Project #{data.response.name} was refreshed."

app.start()