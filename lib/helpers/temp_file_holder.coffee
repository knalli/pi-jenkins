fs = require 'fs'
temp = require 'temp'
Q = require 'q'

class TempFileHolder

  items: null

  constructor: ->
    @items = {}

  write: (chunks) ->
    tempOptions = suffix: '.mp3'
    (Q.nfbind temp.open)(tempOptions).then (info) =>
      unless chunks?.length then throw new Error 'No data provided to write file'
      fd = info.fd
      for chunk in chunks
        fs.writeSync fd, chunk, 0, chunk.length, null
      fs.closeSync fd
      @items[info.path] = new Date().getTime()
      info.path

  delete: (path) ->
    if @items[path]
      @items[path] = undefined
      (Q.nfbind fs.unlink)(path)
    else
      Q.when(null).reject path


exports.TempFileHolder = TempFileHolder