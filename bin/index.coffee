#!/usr/bin/env coffee

{App} = require '../lib/app'
{EventEmitter2} = require 'eventemitter2'

MY_LOCAL_PLAYER = '/usr/bin/afplay'

app = new App(new EventEmitter2 wildcard: true)

# Logging
(->
  emitter = app.getEmitter()

  emitter.on 'logger.**', (data) ->
    console.info "[#{data.level}] [#{data.timestamp}] #{data.module}: #{data.text}"

  emitter.on 'plugin.jenkins.**', (data) ->
    console.info "[Jenkins Job (#{data.event})] [#{data.response.name}] #{data.state}: #{data.response.number}"
)()

app.loadPlugins 'jenkins', 'say'

app.configure
  'plugins':
    'jenkins':
      'watchers':
        'one':
          'name': 'Jenkins Main Trunk'
          'host': 'https://ci.jenkins-ci.org'
          'path': '/view/Jenkins%20core/job/jenkins_main_trunk'
          'build': 'lastBuild'
          'interval': 60000
      'listeners':
        'one':
          'event': 'plugin.jenkins.job.init'
          'plugins': ['say']
          'fn': (data) ->
            @say.convertTextToSpeech
              text: "Project #{data.response.name} has state #{data.state ? 'unknown'}."
              strategy: 'google'
              player: 'cli'
              playerArg: MY_LOCAL_PLAYER
        'two':
          'event': 'plugin.jenkins.job.state'
          'plugins': ['say']
          'fn': (data) ->
            @say.convertTextToSpeech
              text: "Project #{data.response.name} has changed to #{data.state ? 'unknown'}."
              strategy: 'google'
              player: 'cli'
              playerArg: MY_LOCAL_PLAYER
        'three':
          'event': 'plugin.jenkins.job.refresh'
          'plugins': ['say']
          'fn': (data) ->
            @say.convertTextToSpeech text: "Project #{data.response.name} was refreshed."
              strategy: 'google'
              player: 'cli'
              playerArg: MY_LOCAL_PLAYER

app.start()