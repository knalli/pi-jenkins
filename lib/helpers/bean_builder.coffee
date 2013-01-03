{Wrappers} = require "#{__dirname}/wrappers"


class BeanBuilder

  basePath: null
  suffix: null
  createObjectCallback: null
  useSingletons: false

  instances: null

  constructor: ({@basePath, @suffix, @createObjectCallback, @useSingletons}) ->
    if @suffix[0] is '_'
      @suffix = @suffix[1..]
    @instances = {}
    @useSingletons = @useSingletons is true

  build: (config) ->
    throw new Error 'No task defined.' unless config
    suffixLength = @suffix.length
    config.type = Wrappers.underscored(config.type ? 'default')
    config.type = "#{config.type}_#{@suffix}" unless config.type[-suffixLength..] is "_#{@suffix}"
    className = Wrappers.classify config.type
    if (@useSingletons or config.singleton) and @instances[className]
      instance = @instances[className]
      instance.reconfigure config if instance.reconfigure config
      return instance
    filePath = "#{@basePath}/#{config.type}"
    requiredScope = require filePath
    Clazz = requiredScope[className]
    throw new Error "Type #{className} was not found in file #{filePath}." unless Clazz
    instance = if typeof @createObjectCallback is 'function'
      @createObjectCallback Clazz, config
    else
      new Clazz
    instance._idType = config.type
    # Shadow copy of this instance for singleton usage.
    if (@useSingletons or config.singleton)
      @instances[className] = instance
    instance


exports.BeanBuilder = BeanBuilder