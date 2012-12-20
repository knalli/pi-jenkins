{Base} = require "#{__dirname}/base"

class App extends Base

  plugins: null

  constructor: (emitter) ->
    @plugins = {}
    super emitter

  configure: (config) ->
    for own pluginId, pluginConfig of config.plugins
      plugin = @_loadPlugin pluginId
      if plugin
        plugin.configure pluginConfig

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

  start: ->
    for own pluginId, plugin of @plugins
      plugin.start()

exports.App = App