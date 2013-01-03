{GpioAction} = require "./gpio_action"

class JenkinsLightsAction extends GpioAction

  configure: (app, task, config) ->
    super app, task, config
    @configureLights
      RED:
        pin: 1
      YELLOW:
        pin: 2
      GREEN:
        pin: 3
    @configureActions
      'actions':
        'FAILURE->SUCCESS': (scope) ->
          RED: 'off', YELLOW: 'off', GREEN: 'on'
        'UNSTABLE->SUCCESS': (scope) ->
          RED: 'off', YELLOW: 'off', GREEN: 'on'
        'SUCCESS->UNSTABLE': (scope) ->
          RED: 'off', YELLOW: 'on', GREEN: 'off'
        'FAILURE->UNSTABLE': (scope) ->
          RED: 'off', YELLOW: 'on', GREEN: 'off'
        'SUCCESS->FAILURE': (scope) ->
          RED: 'on', YELLOW: 'off', GREEN: 'off'
      'default': (scope) ->
        RED: 'on', YELLOW: 'on', GREEN: 'on'

  getActionIdByScope: (scope) ->
    if scope.data.oldState then "#{scope.data.oldState}->#{scope.data.state}" else "#{scope.data.state}"

exports.JenkinsLightsAction = JenkinsLightsAction