# Validator for simple types
# =================================================

debug = require('debug')('validator:type')
validator = require './index'

# Send value and return it
# -------------------------------------------------
# This helps supporting both return values and callbacks at the same time.
done = (err, value, cb = ->) ->
  cb err, value
  err ? value

# Boolean value
# -------------------------------------------------
# No options allowed.
exports.boolean =
  check: (name, value, options, cb) ->
    debug "Boolean check '#{value}' for #{name}"
    switch typeof value
      when 'boolean'
        return done null, value, cb
      when 'string'
        switch value.toLowerCase()
          when 'true', '1', 'on', 'yes'
            return done null, true, cb
          when 'false', '0', 'off', 'no'
            return done null, false, cb
      when 'number'
        switch value
          when 1
            return done null, true, cb
          when 0
            return done null, false, cb
      else
        return done new Error("No boolean value given for #{name}."), null, cb
    done new Error("The value '#{value}' is no boolean for #{name}."), null, cb
  describe: (options) ->
    "The value has to be a boolean. The value will be true for 1, 'true', 'on',
    'yes' and it will be considered as false for 0, 'false', 'off', 'no', '.
    Other values are not allowed."

# String value
# -------------------------------------------------
# Sanitize options allowed:
#
# - `allowControls` - keep control characters in string instead of
#   stripping them (but keep \\r\\n)
# - `replace` - list of replacements: string (only single replacement) or
#   regular expressions and replacements as inner array
# - `stripTags` - remove all html tags
# - `trim` - strip whitespace from the beginning and end
# - `crop` - crop text after number of characters
#
# Check options:
#
# - `minLength` - minimum text length in characters
# - `maxLength` - maximum text length in characters
# - `whitelist` - characters which are allowed (as one text string)
# - `blacklist` - characters which are disallowed (as one text string)
# - `values` - array of possible values (complete text)
# - `startsWith` - start of text
# - `endsWith` - end of text
# - `match` - string or regular expression which have to be matched
#   (or list of expressions)
# - `matchNot` - string or regular expression which is not allowed to
#   match (or list of expressions)
exports.string =
  check: (name, value, options = {}, cb) ->
    debug "String check '#{value}' for #{name}", options
    # first check input type
    unless typeof value is 'string'
      return done new Error("A string is needed for #{name} but got
        #{typeof value} instead."), null, cb
    # sanitize
    unless options.allowControls
      value = value.replace /[\x00-\x09\x0B\x0C\x0E-\x1F\x7F]/g, ''
    if options.replace?
      for [pattern, replace] in options.replace
        value = value.replace pattern, replace
    if options.stripTags
      value = value.replace /<\/?[^>]+(>|$)/g, ''
    if options.trim
      value = value.trim()
    if options.crop
      value = value.substring 0, options.crop
    # validate



    return done null, value, cb
  describe: (options = {}) ->

# Integer value
# -------------------------------------------------

integerMax =
  4: 7 # (Math.pow 2, 4-1)-1
  8: 127 # (Math.pow 2, 8-1)-1
  byte: 127
  16: 32767
  short: 32767
  32: 2147483647
  long : 2147483647
  64: 9223372036854775807
  quad: 9223372036854775807

# - `sanitize` - (bool) remove invalid characters
# - `type` - (integer|string) the integer is of given type
#   (4, 8, 16, 32, 64, 'byte', 'short','long','quad')
# - `unsigned` - (bool) the integer has to be positive
# - `minRange` - (integer) the smalles allowed number
# - `maxRange` - (integer) the biggest allowed number
# - `allowFloat` - (bool) integer in float notation allowed
# - `round` - (bool) arithmetic rounding of float
# - `allowOctal` - (bool) true to accept also octal numbers starting with
#   with '0'
# - `allowHex` - (bool) true to accept also hexadecimal numbers starting
#    with '0x' or '0X'
exports.integer =
  check: (name, value, options, cb) ->
  describe: (options) ->

