{Base} = require "#{__dirname}/base"

class App extends Base

  plugins: null

  constructor: (emitter) ->
    @plugins = {}
    super emitter

  configure: (config) ->
    for own pluginId, plugin of @plugins
      if config?.plugins[pluginId]?
        plugin.configure config.plugins[pluginId]

  loadPlugins: (ids...) ->
    for id in ids
      @loadPlugin id

  loadPlugin: (id) ->
    if @plugins[id]
      @log 'info', 'app.pluginloader', "Plugin #{id} was already loaded."
      return
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

  getPlugin: (id) -> @plugins[id]

  start: ->
    for own pluginId, plugin of @plugins
      plugin.start()

exports.App = App