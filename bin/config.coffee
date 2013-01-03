module.exports =
  audioPlayer: '/usr/bin/afplay'
  onJenkinsStartSuccess : 'Jenkins server will now be monitored! Go - go - go!'
  onJenkinsStartFailure : 'The Jenkins server cannot be found - Sorry dudes.'
  jenkinsOptions:
    autoDiscovery:
      pattern: '.*'
      host: 'http://localhost:8000'
      jobDefaultInterval: 10000
