#!/usr/bin/env coffee

config = require './config'
{App} = require './../lib/app'
{Cli} = require './../lib/helpers/cli'

Q = require 'q'
{EventEmitter2} = require 'eventemitter2'

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
    event: 'plugin.jenkins.start.succeeded'
    actions: [(
      type: 'TextToSpeech'
      language: 'en'
      using: 'google,festival'
      text: config.onJenkinsStartSuccessText
    ), (
      type: 'CombineAudio'
      ffmpeg: config.ffmpeg
      using: 'mp3'
      prependFile: config.onJenkinsStartSuccessAudio
    ), (
      type: 'Cli'
      exec: config.audioPlayer
    )]
  ), (
    event: 'plugin.jenkins.start.failed'
    actions: [(
      type: 'TextToSpeech'
      language: 'en'
      using: 'google,festival'
      text: config.onJenkinsStartFailureText
    ), (
      type: 'CombineAudio'
      ffmpeg: config.ffmpeg
      using: 'mp3'
      prependFile: config.onJenkinsStartFailureAudio
    ), (
      type: 'Cli'
      exec: config.audioPlayer
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
      type: 'JenkinsLights'
    ), (
      type: 'CombineAudio'
      ffmpeg: config.ffmpeg
      prefix: true
      using: 'mp3'
    ), (
      type: 'Cli'
      exec: config.audioPlayer
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
      ffmpeg: config.ffmpeg
      prefix: true
      using: 'mp3'
    ), (
      type: 'Cli'
      exec: config.audioPlayer
    )]
  )]
  plugins:
    jenkins: config.jenkinsOptions

app.start()