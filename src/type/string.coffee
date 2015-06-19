# String value validation
# =================================================

# Sanitize options allowed:
#
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
# - `optional` - the value must not be present (will return null)
# - `minLength` - minimum text length in characters
# - `maxLength` - maximum text length in characters
# - `values` - array of possible values (complete text)
# - `startsWith` - start of text
# - `endsWith` - end of text
# - `match` - string or regular expression which have to be matched
#   (or list of expressions)
# - `matchNot` - string or regular expression which is not allowed to
#   match (or list of expressions)

# Node modules
# -------------------------------------------------
debug = require('debug')('validator:string')
util = require 'util'
chalk = require 'chalk'
# alinex modules
object = require('alinex-util').object
# include classes and helper
check = require '../check'

# Type implementation
# -------------------------------------------------
exports.describe = (work, cb) ->
  text = 'A text entry. '
  text += check.optional.describe work
  text = text.replace /\. It's/, ' which is'
  if typeof work.pos.toString is 'boolean' and work.pos.toString
    text += "Objects will be converted to their string representation. "
  # remove characters
  remove = []
  remove.push "Control characters" unless work.pos.allowControls
  remove.push "HTML Tags" if work.pos.stripTags
  text += "#{remove.join ', '} will be removed. " if remove.length
  # upper/lowercase
  if work.pos.lowerCase? and work.pos.lowerCase is true
    text += "The text will get lower case. "
  if work.pos.upperCase? and work.pos.upperCase is true
    text += "The text will get upper case. "
  if work.pos.lowerCase? and work.pos.lowerCase is 'first'
    text += "The first letter will get lower case. "
  if work.pos.upperCase? and work.pos.upperCase is 'first'
    text += "The first letter will get upper case. "
  # replacements
  if work.pos.replace?
    text += "The following replacements will take place: "
    if Array.isArray work.pos.replace[0]
      for [pattern, replace] in work.pos.replace
        text += "#{pattern} => '#{replace}', "
      text = text.replace /, $/, '. '
    else
      [pattern, replace] = work.pos.replace
      text += "#{pattern} => '#{replace}'. "
  # trim and crop
  if work.pos.trim
    text += "Whitespace will be removed at start and end of the text. "
  if work.pos.crop?
    text += "The text will be cropped after #{work.pos.crop} characters. "
  # string length
  if work.pos.minLength? and work.pos.maxLength?
    text += "It has to be between #{work.pos.minLength} and #{work.pos.maxLength}
    characters long. "
  else if work.pos.minLength?
    text += "It has to be at least #{work.pos.minLength} characters long. "
  else if work.pos.maxLength?
    text += "It has to be not more than #{work.pos.maxLength} characters long. "
  # specific values
  if work.pos.values?
    text += "Only the values: #{work.pos.values.join ', '} are allowed. "
  # matching
  if work.pos.startsWith?
    text += "It has to start with #{work.pos.startsWith}... "
  if work.pos.endsWith?
    text += "It has to end with ...#{work.pos.endsWith}. "
  if work.pos.match?
    text += "The text should match: "
    if Array.isArray work.pos.match
      for entry in work.pos.match
        text += "#{entry}, "
      text = text.replace /, $/, '. '
    else
      text += "#{work.pos.match}. "
  if work.pos.matchNot?
    text += "The text shouldn't match: "
    if Array.isArray work.pos.matchNot
      for entry in work.pos.matchNot
        text += "#{entry}, "
      text = text.replace /, $/, '. '
    else
      text += "#{work.pos.matchNot}. "
  cb null, text

exports.run = (work, cb) ->
  debug "#{work.debug} with #{util.inspect work.value} as #{work.pos.type}"
  debug "#{work.debug} #{chalk.grey util.inspect work.pos}"
  # base checks
  try
    return cb() if check.optional.run work
  catch err
    return work.report err, cb
  value = work.value
  # first check input type
  if work.pos.toString and typeof work.pos.toString isnt 'function'
    value = value.toString()
  unless typeof value is 'string'
    return work.report (new Error "A string is needed but got #{typeof value} instead"), cb
  # sanitize
  unless work.pos.allowControls
    value = value.replace /[\x00-\x09\x0B\x0C\x0E-\x1F\x7F]/g, ''
  if work.pos.stripTags
    value = value.replace /<\/?[^>]+(>|$)/g, ''
  # upper/lowercase
  if work.pos.lowerCase? and work.pos.lowerCase is true
    value = value.toLowerCase()
  if work.pos.upperCase? and work.pos.upperCase is true
    value = value.toUpperCase()
  if work.pos.lowerCase? and work.pos.lowerCase is 'first'
    value = value.charAt(0).toLowerCase() + value[1..]
  if work.pos.upperCase? and work.pos.upperCase is 'first'
    value = value.charAt(0).toUpperCase() + value[1..]
  # replacements
  if work.pos.replace?
    if Array.isArray work.pos.replace[0]
      for [pattern, replace] in work.pos.replace
        value = value.replace pattern, replace
    else
      [pattern, replace] = work.pos.replace
      value = value.replace pattern, replace
  # trim and crop
  if work.pos.trim
    value = value.trim()
  if work.pos.crop?
    value = value.substring 0, work.pos.crop
  # string length
  if work.pos.minLength? and value.length < work.pos.minLength
    return work.report (new Error "The given string '#{value}' is too short at most
    #{work.pos.minlength} characters are needed"), cb
  if work.pos.maxLength? and value.length > work.pos.maxLength
    return work.report (new Error "The given string '#{value}' is too long for
      at least #{work.pos.maxlength} characters are allowed"), cb
  # specific values
  if work.pos.values? and not (value in work.pos.values)
    return work.report (new Error "The given string '#{value}' is not in the list of
      allowed phrases (#{work.pos.values})"), cb
  if work.pos.startsWith? and value[..work.pos.startsWith.length-1] isnt work.pos.startsWith
    return work.report (new Error "The given string '#{value}' should start with
    '#{work.pos.startsWith}'"), cb
  if work.pos.endsWith? and value[value.length-work.pos.endsWith.length..] isnt work.pos.endsWith
    return work.report (new Error "The given string '#{value}' should end with
    '#{work.pos.endsWith}'"), cb
  # matching
  if work.pos.match?
    if Array.isArray work.pos.match
      success = true
      for match in work.pos.match
        if match instanceof RegExp
          success = success and value.match match
        else
          success = success and ~value.indexOf match
      unless success
        return work.report (new Error "The given string '#{value}' should match
        against '#{work.pos.match}'"), cb
    else if work.pos.match instanceof RegExp
      unless value.match work.pos.match
        return work.report (new Error "The given string '#{value}' should match
        against '#{work.pos.match}'"), cb
    else if not ~value.indexOf work.pos.match
      return work.report (new Error "The given string '#{value}' should contain
      '#{work.pos.match}'"), cb
  if work.pos.matchNot?
    if Array.isArray work.pos.matchNot
      success = true
      for match in work.pos.matchNot
        if match instanceof RegExp
          success = success and not value.match match
        else
          success = success and not ~value.indexOf match
      unless success
        return work.report (new Error "The given string '#{value}' shouldn't match
        against '#{work.pos.match}'"), cb
    else if work.pos.matchNot instanceof RegExp
      if value.match work.pos.matchNot
        return work.report (new Error "The given string '#{value}' shouldn't match
        against '#{work.pos.matchNot}'"), cb
    else if ~value.indexOf work.pos.matchNot
      return work.report (new Error "The given string '#{value}' shouldn't contain
      '#{work.pos.matchNot}'"), cb
  # done return resulting value
  debug "#{work.debug} result #{util.inspect value}"
  cb null, value

exports.selfcheck = (schema, cb) ->
  check.run
    schema:
      type: 'object'
      allowedKeys: true
      keys: object.extend {}, check.base,
        default:
          type: 'string'
          optional: true
        toString:
          type: 'boolean'
          optional: true
        allowControls:
          type: 'boolean'
          optional: true
        stripTags:
          type: 'boolean'
          optional: true
        lowerCase:
          type: 'or'
          optional: true
          or: [
            type: 'boolean'
          ,
            type: 'string'
            values: ['first']
          ]
        upperCase:
          type: 'or'
          optional: true
          or: [
            type: 'boolean'
          ,
            type: 'string'
            values: ['first']
          ]
        replace:
          type: 'or'
          or: [
            type: 'array'
            list:
              0:
                type: 'object'
                instanceOf: RegExp
              1:
                type: 'string'
          ,
            type: 'array'
            entries:
              type: 'array'
              list:
                0:
                  type: 'object'
                  instanceOf: RegExp
                1:
                  type: 'string'
          ]
        trim:
          type: 'boolean'
          optional: true
        crop:
          type: 'integer'
          optional: true
          min: 1
        minLength:
          type: 'integer'
          optional: true
          min: 0
        maxLength:
          type: 'integer'
          optional: true
          min: '<<<min>>>'
        values:
          type: 'array'
          optional: true
          entries:
            type: 'string'
        startsWith:
          type: 'string'
          optional: true
        endsWith:
          type: 'string'
          optional: true
        match:
          type: 'or'
          optional: true
          or: [
            type: 'string'
          ,
            type: 'object'
            instanceOf: RegExp
          ]
        matchNot:
          type: 'or'
          optional: true
          or: [
            type: 'string'
          ,
            type: 'object'
            instanceOf: RegExp
          ]
    value: schema
  , cb


