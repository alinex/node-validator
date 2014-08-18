# String value validation
# =================================================

# Node modules
# -------------------------------------------------
async = require 'async'
util = require 'util'
# include classes and helper
helper = require '../helper'
reference = require '../reference'

# Sanitize and validate
# -------------------------------------------------
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
exports.check = (source, options, value, work, cb) ->
  if options.tostring and typeof value is 'object'
    value = value.toString()
  # first check input type
  unless typeof value is 'string'
    return helper.result "A string is needed but got #{typeof value}
      instead", source, options, null, cb
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
  # check optional, again
  result = helper.optional source, options, value, cb
  return result unless result is false
  # validate
  if options.minLength? and value.length < options.minLength
    return helper.result "The given string '#{value}' is too short at
      most #{options.minlength} characters are needed", source, options, null, cb
  if options.maxLength? and value.length > options.maxLength
    return helper.result "The given string '#{value}' is too long for
      at least #{options.maxlength} characters are allowed", source, options, null, cb
  if options.values? and not (value in options.values)
    return helper.result "The given string '#{value}' is not in the list of
      allowed phrases (#{options.values})", source, options, null, cb
  if options.startsWith? and value[..options.startsWith.length-1] isnt options.startsWith
    return helper.result "The given string '#{value}' should start with
      '#{options.startsWith}'", source, options, null, cb
  if options.endsWith? and value[value.length-options.endsWith.length..] isnt options.endsWith
    return helper.result "The given string '#{value}' should end with
      '#{options.endsWith}'", source, options, null, cb
  if options.match?
    if Array.isArray options.match
      success = true
      for match in options.match
        if match instanceof RegExp
          success = success and value.match match
        else
          success = success and ~value.indexOf match
      unless success
        return helper.result "The given string '#{value}' should match against
          '#{options.match}'", source, options, null, cb
    else if options.match instanceof RegExp and not value.match options.match
      return helper.result "The given string '#{value}' should match against
        '#{options.match}'", source, options, null, cb
    else if not ~value.indexOf options.match
      return helper.result "The given string '#{value}' should contain
        '#{options.match}'", source, options, null, cb
  if options.matchNot?
    if Array.isArray options.matchNot
      success = true
      for match in options.matchNot
        if match instanceof RegExp
          success = success and not value.match match
        else
          success = success and not ~value.indexOf match
      unless success
        return helper.result "The given string '#{value}' shouldn't match against
          '#{options.match}'", source, options, null, cb
    else if options.matchNot instanceof RegExp and value.matchNot options.match
      return helper.result "The given string '#{value}' shouldn't match against
        '#{options.matchNot}'", source, options, null, cb
    else if ~value.indexOf options.matchNot
      return helper.result "The given string '#{value}' shouldn't contain
        '#{options.matchNot}'", source, options, null, cb
  # done return resulting value
  return helper.result null, source, options, value, cb

# Description
# -------------------------------------------------
exports.describe = (options) ->
  text = 'This should be text entry. '
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
  text.trim()

