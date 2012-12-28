pad = require 'pad'
dateFormat = require 'dateformat'
timeago = require 'timeago'

{BaseTaskAction} = require "#{__dirname}/../../base_task_action"


class LogBuildTableAction extends BaseTaskAction

  table: null

  constructor: ->
    super()
    @table = []

  run: (scope) ->
    item = (item for item in @table when item.job is scope.data.jobName)[0]
    unless item
      item = job: scope.data.jobName
      @table.push item
    item.build = scope.data.response.number
    item.oldBuild = if scope.data.oldResponse then scope.data.oldResponse.number
    item.timestamp = scope.data.response.timestamp
    item.state = scope.data.response.state
    item.oldState = if scope.data.oldResponse then scope.data.oldResponse.state
    item.building = scope.data.response.building
    @logTable @table
    scope.lastResult

  logTable: (table) ->
    console.log "Currently active job monitors"
    console.log "+---+-#{pad '', 18, '-'}-+-#{pad '', 5, '-'}-+-#{pad '', 20, '-'}-+-#{pad '', 30, '-'}-+-#{pad '', 30, '-'}-+"
    console.log "+   | #{pad 'Job', 18} | #{pad 'Build', 5} | #{pad 'State', 20} | #{pad 'Last Updated', 60 + 3} |"
    console.log "+---+-#{pad '', 18, '-'}-+-#{pad '', 5, '-'}-+-#{pad '', 20, '-'}-+-#{pad '', 30, '-'}-+-#{pad '', 30, '-'}-+"
    if table.length
      for row in table
        colState = row.state
        if row.oldState then colState += " <- #{row.oldState}"
        console.log "+ #{if row.building is true then '*' else ' '} | #{pad row.job, 18} | #{pad 5, "#{row.build}"} | #{pad colState, 20} | #{pad "#{dateFormat row.timestamp}", 30} | #{pad "#{timeago new Date row.timestamp}", 30} |"
        console.log "+---+-#{pad '', 18, '-'}-+-#{pad '', 5, '-'}-+-#{pad '', 20, '-'}-+-#{pad '', 30, '-'}-+-#{pad '', 30, '-'}-+"
    else
      console.log "+   | #{pad 'Empty', 18} | #{pad ' ', 5} | #{pad ' ', 20} | #{pad ' ', 60 + 3}"
      console.log "+---+-#{pad '', 18, '-'}-+-#{pad '', 5, '-'}-+-#{pad '', 20, '-'}-+-#{pad '', 30, '-'}-+-#{pad '', 30, '-'}-+"


exports.LogBuildTableAction = LogBuildTableAction