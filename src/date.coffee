# Validator for simple types
# =================================================

debug = require('debug')('validator:date')
{number} = require 'alinex-util'
validator = require './index'

# Send value and return it
# -------------------------------------------------
# This helps supporting both return values and callbacks at the same time.
done = (err, value, cb = ->) ->
  cb err, value
  err ? value

# Interval
# -------------------------------------------------
#
# Sanitize options allowed:
#
# - `unit` - (string) type of unit to convert if not integer given
# - `round` - (bool) rounding of float can be set to true for arithmetic rounding
#   or use `floor` or `ceil` for the corresponding methods
#
# Check options:
#
# - `optional` - the value must not be present (will return null)
# - `min` - (integer) the smalles allowed number
# - `max` - (integer) the biggest allowed number
exports.interval =
  check: (name, value, options = {}, cb) ->
    debug "Interval check '#{value}' for #{name}", options
    unless value?
      return done null, null, cb if options.optional
      return done new Error("A value is needed for #{name}."), null, cb
    # sanitize
    if typeof value is 'string'
      parsed = number.parseMSeconds value
      if isNaN parsed
        return done new Error("The given value '#{value}' is not parse able as
          interval for #{name}."), null, cb
      unit = options.unit ? 'ms'
      unless unit is 'ms'
        parsed /= switch unit
          when 's'
            1000
          when 'm'
            1000 * 60
          when 'h'
            1000 * 60 * 60
          when 'd'
            1000 * 60 * 60 * 24
#      parsed /= 1000 unless unit is 'ms'
#      parsed /= 60 unless unit in ['s','ms']
#      parsed /= 60 unless unit in ['s','ms','m']
#      parsed /= 24 unless unit in ['s','ms','m', 'h']
      value = parsed
    if options.round
      value = switch options.round
        when 'ceil' then Math.ceil value
        when 'floor' then Math.floor value
        else Math.round value
    # validate
    suboptions =
      check: if options.round? then 'type.integer' else 'type.float'
    suboptions.min = options.min if options.min?
    suboptions.max = options.max if options.max?
    value = validator.check name, value, suboptions
    # done return resulting value
    return done null, value, cb
  describe: (options = {}) ->
    text = 'An time interval is needed, here. '
    text += "If defined as a text you may use a combination of values with the
      units: ms, s, m, h, d. "
    if options.unit
      text += "The result will be given as the number of #{options.unit}. "
    if options.round
      type = switch options.round
        when 'to ceil' then Math.ceil value
        when 'to floor' then Math.floor value
        else 'arithḿetic'
      text += "Value will be rounded #{type}. "
    if options.min? and options.max?
      text += "The value should be between #{options.min} and #{options.max}. "
    else if options.min?
      text += "The value should be greater than #{options.min}. "
    else if options.max?
      text += "The value should be lower than #{options.max}. "
    if options.optional
      text += "The setting is optional. "
    text.trim()
