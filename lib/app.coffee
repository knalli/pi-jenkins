{Base} = require "#{__dirname}/base"
{Wrappers} = require "#{__dirname}/helpers/wrappers"
{BeanBuilder} = require "#{__dirname}/helpers/bean_builder"


class App extends Base

  plugins: null
  pluginBuilder: null

  tasks: null
  taskBuilder: null

  constructor: (@emitter) ->
    @plugins = []
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
    for own pluginId, config of plugins
      config.type = pluginId
      plugin = @_loadPlugin pluginId
      plugin.configure @, config
    return

  ###
  Load implicitly a list of plugins.
  ###
  loadPlugins: (ids...) ->
    for id in ids
      @_loadPlugin id

  _findPluginsById: (id) ->
    (plugin for plugin in @plugins when plugin.getId() is id)

  _loadPlugin: (id) ->
    matchedPlugins = @_findPluginsById id
    return if matchedPlugins?.length
    plugin = @_buildPlugin type: id
    @plugins.push plugin
    plugin.initialize()
    return plugin

  _buildPlugin: (config) ->
    plugin = @pluginBuilder.build config
    plugin.configure @, config
    return plugin

  getPlugin: (id, tryToLoad = false) ->
    @_loadPlugin(id) if tryToLoad and @_findPluginsById(id).length < 1
    @_findPluginsById(id)[0]

  getTasks: -> @tasks

  getPlugins: -> @plugins

  start: ->
    plugin.start() for plugin in @plugins

  stop: ->
    plugin.stop() for plugin in @plugins

exports.App = App