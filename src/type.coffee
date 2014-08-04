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
    if typeof value is 'string'
      debug "Boolean check '#{value}' for #{name}"
    else
      debug "Boolean check #{value} for #{name}"
    unless value?
      return done null, false, cb
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
# - `optional` - the value must not be present (will return null)
# - `tostring` - convert objects to string, first
# - `allowControls` - keep control characters in string instead of
#   stripping them (but keep \\r\\n)
# - `stripTags` - remove all html tags
# - `lowerCase` - set to `true` or `first`
# - `upperCase` - set to `true` or `first`
# - `replace` - replacements (list): string (only single replacement) or
#   regular expressions and replacements as inner array
# - `trim` - strip whitespace from the beginning and end
# - `crop` - crop text after number of characters
#
# Check options:
#
# - `minLength` - minimum text length in characters
# - `maxLength` - maximum text length in characters
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
    unless value?
      return done null, null, cb if options.optional
      return done new Error("A value is needed for #{name}."), null, cb
    if options.tostring and typeof value is 'object'
      value = value.toString()
    # first check input type
    unless typeof value is 'string'
      return done new Error("A string is needed for #{name} but got
        #{typeof value} instead."), null, cb
    # sanitize
    unless options.allowControls
      value = value.replace /[\x00-\x09\x0B\x0C\x0E-\x1F\x7F]/g, ''
    if options.stripTags?
      value = value.replace /<\/?[^>]+(>|$)/g, ''
    if options.lowerCase? and options.lowerCase is true
      value = value.toLowerCase()
    if options.upperCase? and options.upperCase is true
      value = value.toUpperCase()
    if options.lowerCase? and options.lowerCase is 'first'
      value = value.charAt(0).toLowerCase() + value[1..]
    if options.upperCase? and options.upperCase is 'first'
      value = value.charAt(0).toUpperCase() + value[1..]
    if options.replace?
      if Array.isArray options.replace[0]
        for [pattern, replace] in options.replace
          value = value.replace pattern, replace
      else
        [pattern, replace] = options.replace
        value = value.replace pattern, replace
    if options.trim
      value = value.trim()
    if options.crop?
      value = value.substring 0, options.crop
    # validate
    if options.minLength? and value.length < options.minLength
      return done new Error("The given string '#{value}' is too short for
        #{name}, at most #{options.minlength} characters are needed."), null, cb
    if options.maxLength? and value.length > options.maxLength
      return done new Error("The given string '#{value}' is too long for
        #{name}, at least #{options.maxlength} characters are allowed."), null, cb
    if options.values? and not (value in options.values)
      return done new Error("The given string '#{value}' is not in the list of
        allowed phrases (#{options.values}) for #{name}."), null, cb
    if options.startsWith? and value[..options.startsWith.length-1] isnt options.startsWith
      return done new Error("The given string '#{value}' should start with
        '#{options.startsWith}' for #{name}."), null, cb
    if options.endsWith? and value[value.length-options.endsWith.length..] isnt options.endsWith
      return done new Error("The given string '#{value}' should end with
        '#{options.endsWith}' for #{name}."), null, cb
    if options.match?
      if Array.isArray options.match
        success = true
        for match in options.match
          if match instanceof RegExp
            success = success and value.match match
          else
            success = success and ~value.indexOf match
        unless success
          return done new Error("The given string '#{value}' should match against
            '#{options.match}' for #{name}."), null, cb
      else if options.match instanceof RegExp and not value.match options.match
        return done new Error("The given string '#{value}' should match against
          '#{options.match}' for #{name}."), null, cb
      else if not ~value.indexOf options.match
        return done new Error("The given string '#{value}' should contain
          '#{options.match}' for #{name}."), null, cb
    if options.matchNot?
      if Array.isArray options.matchNot
        success = true
        for match in options.matchNot
          if match instanceof RegExp
            success = success and not value.match match
          else
            success = success and not ~value.indexOf match
        unless success
          return done new Error("The given string '#{value}' shouldn't match against
            '#{options.match}' for #{name}."), null, cb
      else if options.matchNot instanceof RegExp and value.matchNot options.match
        return done new Error("The given string '#{value}' shouldn't match against
          '#{options.matchNot}' for #{name}."), null, cb
      else if ~value.indexOf options.matchNot
        return done new Error("The given string '#{value}' shouldn't contain
          '#{options.matchNot}' for #{name}."), null, cb
    return done null, value, cb
  describe: (options = {}) ->
    text = ''
    if options.tostring
      text += "Objects will be converted to their string representation. "
    remove = []
    remove.push "Control characters" unless options.allowControls
    remove.push "HTML Tags" if options.stripTags
    text += "#{remove.join ', '} will be removed. " if remove
    if options.replace?
      text += "The following replacements will take place: "
      if Array.isArray options.replace[0]
        for [pattern, replace] in options.replace
          text += "#{pattern} => #{replace}, "
        text = text.replace /, $/, '. '
      else
        [pattern, replace] = options.replace
        text += "#{pattern} => #{replace}. "
    if options.trim
      text += "Whitespace will be removed at start and end of the text. "
    if options.crop?
      text += "The text will be cropped after #{options.crop} characters. "
    if options.lowerCase? and options.lowerCase is true
      text += "The text will get lower case. "
    if options.upperCase? and options.upperCase is true
      text += "The text will get upper case. "
    if options.lowerCase? and options.lowerCase is 'first'
      text += "The first letter will get lower case. "
    if options.upperCase? and options.upperCase is 'first'
      text += "The first letter will get upper case. "
    if options.minLength? and options.maxLength?
      text += "It has to be between #{options.minLength} and #{options.maxLength} characters long. "
    else if options.minLength?
      text += "It has to be at least #{options.minLength} characters long. "
    else if options.maxLength?
      text += "It has to be not more than #{options.maxLength} characters long. "
    if options.values?
      text += "Only the values: #{values.join ', '} are allowed. "
    if options.startsWith?
      text += "It has to start with #{options.startsWith}... "
    if options.endsWith?
      text += "It has to end with ...#{options.endsWith}. "
    if options.match?
      text += "The text should match: "
      if Array.isArray options.match
        for entry in options.match
          text += "'#{entry}', "
        text = text.replace /, $/, '. '
      else
        text += "'#{options.match}'. "
    if options.matchNot?
      text += "The text shouldn't match: "
      if Array.isArray options.matchNot
        for entry in options.matchNot
          text += "'#{entry}', "
        text = text.replace /, $/, '. '
      else
        text += "'#{options.matchNot}'. "
    if options.optional
      text += "The setting is optional. "
    text.trim()

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

