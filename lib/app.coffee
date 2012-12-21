{Base} = require "#{__dirname}/base"
{Wrappers} = require "#{__dirname}/helpers/wrappers"
{BeanBuilder} = require "#{__dirname}/helpers/bean_builder"

class App extends Base

  plugins: null

  tasks: null
  taskBuilder: null

  constructor: (emitter) ->
    @plugins = {}
    @tasks = []
    super emitter
    @taskBuilder = new BeanBuilder basePath: "#{__dirname}/tasks", suffix: 'task'

  configure: (config) ->
    @_configureTasks config.tasks if config.tasks?.length
    @_configurePlugins config.plugins
    @_initializeTasks()
    return

  _configureTasks: (tasks) ->
    return unless tasks?.length
    @tasks = (@_buildTask task for task in tasks)
    return

  _buildTask: (config) ->
    task = @taskBuilder.build config
    if config.event
      @getEmitter().on config.event, (data) -> task.run data
    return task

  _initializeTasks: ->
    task.initialize() for task in @tasks
    return

  _configurePlugins: (plugins) ->
    for own pluginId, pluginConfig of plugins
      plugin = @_loadPlugin pluginId
      if plugin
        plugin.configure pluginConfig
    return

  ###
  Load implicitly a list of plugins.
  ###
  loadPlugins: (ids...) ->
    for id in ids
      @_loadPlugin id

  _loadPlugin: (id) ->
    return @plugins[id] if @plugins[id]?
    path = "#{__dirname}/plugins/#{id}"
    app = @
    try
      {Plugin} = require path
    catch e
      @log 'warn', 'app.pluginloader', "The plugin #{id} does not exist."
      return
    pluginObject = new Plugin app
    pluginObject.setState 'CREATED'
    unless pluginObject
      @log 'warn', 'app.pluginloader', "The plugin #{id} is not valid."
      return
    pluginObject.initialize()
    @plugins[id] = pluginObject
    @log 'info', 'app.pluginloader', "Plugin #{id} loaded."
    pluginObject

  getPlugin: (id, tryToLoad = false) ->
    @_loadPlugin id if !@plugins[id] and tryToLoad
    @plugins[id]

  getTasks: -> @tasks

  start: ->
    for own pluginId, plugin of @plugins
      plugin.start()

exports.App = App