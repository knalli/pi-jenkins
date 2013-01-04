module.exports =
  audioPlayer: '/usr/bin/afplay'
  ffmpeg: '/opt/local/bin/ffmpeg'
  onJenkinsStartSuccessText: 'Jenkins server will now be monitored! Go - go - go!'
  onJenkinsStartSuccessAudio: 'resources/win31.mp3'
  onJenkinsStartFailureText: 'The Jenkins server cannot be found - Sorry dudes.'
  onJenkinsStartFailureAudio: 'resources/zonk.mp3'
  jenkinsOptions:
    autoDiscovery:
      pattern: '.*'
      host: 'http://localhost:8000'
      jobDefaultInterval: 10000
