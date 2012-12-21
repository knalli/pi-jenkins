{Wrappers} = require "#{__dirname}/wrappers"


class BeanBuilder

  constructor: ({@basePath, @suffix}) ->
    if @suffix[0] is '_'
      @suffix = @suffix[1..]

  build: (config) ->
    throw new Error 'No task defined.' unless config
    suffixLength = @suffix.length
    config.type = Wrappers.underscored(config.type ? 'default')
    config.type = "#{config.type}_#{@suffix}" unless config.type[-suffixLength..] is "_#{@suffix}"
    className = Wrappers.classify config.type
    filePath = "#{@basePath}/#{config.type}"
    requiredScope = require filePath
    Clazz = requiredScope[className]
    throw new Error "Type #{className} was not found in file #{filePath}." unless Clazz
    new Clazz config, @


exports.BeanBuilder = BeanBuilder