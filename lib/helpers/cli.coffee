Q = require 'q'
{exec} = require 'child_process'

class Cli
  @exec: ({executable, argument}) ->
    cli = if typeof executable is 'function' then executable(argument) else "#{executable} #{argument}"
    (Q.nfbind exec) cli


exports.Cli = Cli