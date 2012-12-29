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

  autoDiscoveryOptions: false

  configure: (app, config) ->
    super app, config
    @addWatchers config.watchers if config.watchers
    @configureAutoDiscovery config.autoDiscovery if config.autoDiscovery

  configureAutoDiscovery: ({pattern, host, jobDefaultInterval}) ->
    jobNamePattern = if pattern is true
      /.*/
    else if typeof pattern is 'string'
      try
        new RegExp pattern
      catch exception
        @log 'warn', "plugin.#{@id}", "The regular expression \"#{pattern}\" is not valid."
    return unless jobNamePattern
    @autoDiscoveryOptions =
      pattern: jobNamePattern
      host: host
      sslEnabled: host[..4] is 'https'
      jobDefaultInterval: jobDefaultInterval ? 60000

  start: ->
    @workerPool = chainGang.create workers: @options.maxWorkers
    #@workerPool.on 'add', (name) => @log 'info', @name, "Watcher #{name} has beed added."
    #@workerPool.on 'starting', (name) => @log 'info', @name, "Watcher #{name} has beed started."
    #@workerPool.on 'finished', (name) => @log 'info', @name, "Watcher #{name} has been finished."
    #@workerPool.on 'finished', (job) => @log 'info', @name, "Watcher #{job.name} has been timed out."
    if @autoDiscoveryOptions
      @discoverAllJobs(@autoDiscoveryOptions).then =>
        setInterval (=> @checkWatchers()), @options.mainLoopInterval
    else
      setInterval (=> @checkWatchers()), @options.mainLoopInterval
    super()

  stop: ->
    clearInterval @mainLoop
    super()

  discoverAllJobs: (options) ->
    deferred = Q.defer()
    url = "#{options.host}/api/json"
    @log 'info', "plugin.#{@id}", "Starting auto discovery mode using pattern #{options.pattern} ad url #{url}..."
    (if options.sslEnabled then https else http).get url, (response) =>
      onSuccess = (json) =>
        for job in json.jobs
          watcherConfig =
            name: job.name
            host: options.host
            path: "/job/#{job.name}"
            build: 'lastCompletedBuild'
            interval: options.jobDefaultInterval
          @_addWatcher watcherConfig
        deferred.resolve()
      Q.when(ResponseUtils.getResponseAsJSON response).then onSuccess, deferred.reject
    deferred.promise

  addWatchers: (watchers) ->
    for own id, watcher of watchers
      @_addWatcher watcher, id

  _addWatcher: (watcher, id) ->
    watcher.id = if id then id else "#{watcher.host}::#{watcher.path}::#{watcher.build}"
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
    url = "#{watcher.host}#{if watcher.path[..0] is '/' then watcher.path else '/' + watcher.path}/#{watcher.build}/api/json"
    (if watcher.sslEnabled then https else http).get url, (response) =>
      @log 'info', "plugin.#{@id}", "Response GET #{url}..."
      onSuccess = (json) =>
        oldResponse = watcher.response
        newResponse =
          building: json.building is true
          state: if !json.result and json.building is true then 'BUILDING' else json.result
          number: json.number
          name: json.fullDisplayName
          timestamp: json.timestamp
          culprits: (culprit.fullName for culprit in json.culprits?)
          changesets: (item for item in json.changeSet?.items?)
        unless oldResponse
          watcher.response = newResponse
          data =
            state: newResponse.state
            response: newResponse
            jobName: watcher.name
          @emit 'plugin.jenkins.job.init', data
        else if newResponse.state isnt 'BUILDING' and oldResponse.state isnt newResponse.state
          watcher.response = newResponse
          data =
            state: newResponse.state
            oldState: oldResponse.state
            response: newResponse
            jobName: watcher.name
          @emit 'plugin.jenkins.job.state', data
        else
          data =
            state: newResponse.state
            response: newResponse
            jobName: watcher.name
          @emit 'plugin.jenkins.job.refresh', data
        deferred.resolve watcher
      onFailure = (err) ->
        deferred.reject err, watcher
      Q.when(ResponseUtils.getResponseAsJSON response).then onSuccess, onFailure
    deferred.promise


exports.JenkinsPlugin = JenkinsPlugin