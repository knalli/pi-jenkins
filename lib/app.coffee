{Base} = require "#{__dirname}/base"
{Wrappers} = require "#{__dirname}/helpers/wrappers"
{BeanBuilder} = require "#{__dirname}/helpers/bean_builder"

class App extends Base

  plugins: null
  pluginBuilder: null

  tasks: null
  taskBuilder: null

  constructor: (@emitter) ->
    @plugins = {}
    @tasks = []
    @pluginBuilder = new BeanBuilder basePath: "#{__dirname}/plugins", suffix: 'plugin'
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
    task.configure @, config
    if config.event
      @getEmitter().on config.event, (data) -> task.run data
    return task

  _initializeTasks: ->
    task.initialize() for task in @tasks
    return

  _configurePlugins: (plugins) ->
    for own pluginId, pluginConfig of plugins
      pluginConfig.type = pluginId
      plugin = @_loadPlugin pluginId
      plugin.configure @, pluginConfig
    return

  ###
  Load implicitly a list of plugins.
  ###
  loadPlugins: (ids...) ->
    for id in ids
      @_loadPlugin id

  _loadPlugin: (id) ->
    return @plugins[id] if @plugins[id]?
    plugin = @_buildPlugin type: id
    @plugins[id] = plugin
    plugin.initialize()
    return plugin

  _buildPlugin: (config) ->
    plugin = @pluginBuilder.build config
    plugin.configure @, config
    return plugin

  getPlugin: (id, tryToLoad = false) ->
    @_loadPlugin id if !@plugins[id] and tryToLoad
    @plugins[id]

  getTasks: -> @tasks

  getPlugins: -> (plugin for own pluginId, plugin of @plugins)

  start: ->
    for own pluginId, plugin of @plugins
      plugin.start()

exports.App = App