{Cli} = require "#{__dirname}/../../helpers/cli"
{BaseTaskAction} = require "#{__dirname}/../../base_task_action"

temp = require 'temp'
Q = require 'q'


class CombineAudioAction extends BaseTaskAction

  ffmpeg: null

  appendFile: null

  prependFile: null

  configure: (app, task, config) ->
    super app, task, config
    {@ffmpeg, @appendFile, @prependFile} = config

  run: (scope) ->
    unless @ffmpeg then return @returnPreviousResult(scope)
    unless @appendFile or @prependFile then return @returnPreviousResult(scope)
    prependFile = @prependFile
    appendFile = @appendFile
    @convertToInterMediateFormat(prependFile).then (file) =>
      prependFile = file
      @convertToInterMediateFormat(appendFile).then (file) =>
        appendFile = file
        @convertToInterMediateFormat(scope.lastResult).then (file) =>
          @runCli file, prependFile, appendFile

  runCli: (file, prependFile, appendFile) ->
    tempOptions = suffix: '.mp3'
    tempFile = temp.openSync tempOptions
    tempFilePath = tempFile.path
    concattedFiles = []
    concattedFiles.push prependFile if prependFile
    concattedFiles.push file
    concattedFiles.push appendFile if appendFile
    Cli.exec(
      executable: @ffmpeg
      argument: "-y -i \"concat:#{concattedFiles.join '|'}\" -acodec copy #{tempFilePath}"
    ).then () -> tempFilePath

  convertToInterMediateFormat: (file) ->
    return Q.when null unless file
    tempOptions = suffix: '.mp3'
    tempFile = temp.openSync tempOptions
    tempFilePath = tempFile.path
    Cli.exec(
      executable: @ffmpeg
      argument: "-y -i \"#{file}\" -f mp3 -ab 128k -ar 44100 -ac 2 #{tempFilePath}"
    ).then () -> tempFilePath


exports.CombineAudioAction = CombineAudioAction