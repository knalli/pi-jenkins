Q = require 'q'
http = require 'http'
https = require 'https'
chainGang = require 'chain-gang'

{BasePlugin} = require "#{__dirname}/../base_plugin"
ResponseUtils = require "#{__dirname}/../util/response_util"

DEFAULT_INTERVAL = 5000

class JenkinsPlugin extends BasePlugin

  name: "Jenkins"
  id: "jenkins"

  watchers: []
  workerPool: null

  mainLoop: null

  options:
    mainLoopInterval: 1000
    maxWorkers: 3

  configure: (config) ->
    @addWatchers config.watchers if config.watchers
    super config

  start: ->
    @workerPool = chainGang.create workers: @options.maxWorkers
    #@workerPool.on 'add', (name) => @log 'info', @name, "Watcher #{name} has beed added."
    #@workerPool.on 'starting', (name) => @log 'info', @name, "Watcher #{name} has beed started."
    #@workerPool.on 'finished', (name) => @log 'info', @name, "Watcher #{name} has been finished."
    #@workerPool.on 'finished', (job) => @log 'info', @name, "Watcher #{job.name} has been timed out."
    setInterval (=> @checkWatchers()), @options.mainLoopInterval
    super()

  stop: ->
    clearInterval @mainLoop
    super()

  addWatchers: (watchers) ->
    for own id, watcher of watchers
      @_addWatcher watcher, id

  _addWatcher: (watcher, id) ->
    watcher.id = if id then id else "#{watcher.host}#{watcher.path}#{watcher.build}"
    watcher.createdDate = new Date()
    watcher.createdTimestamp = watcher.createdDate.getTime()
    watcher.sslEnabled = watcher.host[..4] is 'https'
    watcher.interval = DEFAULT_INTERVAL unless watcher.interval
    watcher.nextTimestamp = 0
    @watchers.push watcher

  checkWatchers: () ->
    timestampOfNow = new Date().getTime()
    for watcher in @watchers when watcher.nextTimestamp < timestampOfNow
      watcher.nextTimestamp = timestampOfNow + watcher.interval
      task = @buildTask watcher
      @workerPool.add task, watcher.id

  buildTask: (watcher) ->
    (job) => Q.when(@runWatcher watcher).fin job.finish false, watcher

  runWatcher: (watcher) ->
    #@log 'info', @name, "Running task for watcher #{watcher.id}..."
    deferred = Q.defer()
    url = "#{watcher.host}/#{watcher.path}/#{watcher.build}/api/json"
    (if watcher.sslEnabled then https else http).get url, (response) =>
      @log 'info', "plugin.#{@id}", "Response GET for watcher #{watcher.id}..."
      onSuccess = (json) =>
        oldResponse = watcher.response
        newResponse =
          building: json.building is true
          state: if !json.result and json.building is true then 'BUILDING' else json.result
          number: json.number
          name: json.fullDisplayName
          timestamp: json.timestamp
          culprits: (culprit.fullName for culprit in json.culprits)
        unless oldResponse
          watcher.response = newResponse
          @emit 'plugin.jenkins.job.init', state: newResponse.state, response: newResponse
        else if newResponse.state isnt 'BUILDING' and oldResponse.state isnt newResponse.state
          watcher.response = newResponse
          @emit 'plugin.jenkins.job.state', state: newResponse.state, oldState: oldResponse.state, response: newResponse
        else
          @emit 'plugin.jenkins.job.refresh', state: newResponse.state, response: newResponse
        deferred.resolve watcher
      onFailure = (err) ->
        deferred.reject err, watcher
      Q.when(ResponseUtils.getResponseAsJSON response).then onSuccess, onFailure
    deferred.promise


exports.Plugin = JenkinsPlugin