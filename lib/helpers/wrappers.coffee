_s = require 'underscore.string'


class Wrappers
  @camelize: (string) -> _s.camelize string
  @classify: (string) -> _s.classify string
  @underscored: (string) -> _s.underscored string


exports.Wrappers = Wrappers
