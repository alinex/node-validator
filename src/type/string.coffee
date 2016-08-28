###
String
=================================================
Checking text entries against multiple rules.

Sanitize options allowed:
- `toString` - `Boolean` convert objects to string, first
- `allowControls` - `Boolean` keep control characters in string instead of
  stripping them (but keep \\r\\n)
- `stripTags` - `Boolean` remove all html tags
- `lowerCase` - `Boolean|String` set to `true` or `first`
- `upperCase` - `Boolean|String` set to `true` or `first`
- `replace` - `Array` replacements: string (only single replacement) or
  regular expressions and replacements as inner array
- `trim` - `Boolean` strip whitespace from the beginning and end
- `crop` - `Integer` crop text after number of characters

Check options:
- `optional` - `Boolean` the value must not be present (will return null)
- `minLength` - `Integer` minimum text length in characters
- `maxLength` - `Integer` maximum text length in characters
- `values` - `Array|Object|String` array of possible values (complete text)
- `startsWith` - `String` start of text
- `endsWith` - `String` end of text
- `match` - `String|RegExp` string or regular expression which have to be matched
  (or list of expressions)
- `matchNot` - `String|RegExp` string or regular expression which is not allowed to
  match (or list of expressions)

#3 Character Case

Instead of setting to `lowerCase` or `upperCase` you can also set both. If you
set one to `true` and the other to `first` you can make all lowercase but first
character uppercase or the other way.


Schema Specification
---------------------------------------------------
{@schema #selfcheck}
###


# Node Modules
# -------------------------------------------------
debug = require('debug')('validator:string')
# alinex modules
util = require 'alinex-util'
# include classes and helper
rules = require '../helper/rules'


# Exported Methods
# -------------------------------------------------

# Type specific debug method.
exports.debug = debug

# Describe schema definition, human readable.
#
# @param {function(Error, String)} cb callback to be called if done with possible error
# and the resulting text
exports.describe = (cb) ->
  text = 'A text entry. '
  text += rules.optional.describe.call this
  text = text.replace /\. It's/, ' which is'
  if typeof @schema.toString is 'boolean' and @schema.toString
    text += "Objects will be converted to their string representation. "
  # remove characters
  remove = []
  remove.push "Control characters" unless @schema.allowControls
  remove.push "HTML Tags" if @schema.stripTags
  text += "#{remove.join ', '} will be removed. " if remove.length
  # upper/lowercase
  if @schema.lowerCase? and @schema.lowerCase is true
    text += "The text will get lower case. "
  if @schema.upperCase? and @schema.upperCase is true
    text += "The text will get upper case. "
  if @schema.lowerCase? and @schema.lowerCase is 'first'
    text += "The first letter will get lower case. "
  if @schema.upperCase? and @schema.upperCase is 'first'
    text += "The first letter will get upper case. "
  # replacements
  if @schema.replace?
    text += "The following replacements will take place: "
    if Array.isArray @schema.replace[0]
      for [pattern, replace] in @schema.replace
        text += "#{pattern} => '#{replace}', "
      text = text.replace /, $/, '. '
    else
      [pattern, replace] = @schema.replace
      text += "#{pattern} => '#{replace}'. "
  # trim and crop
  if @schema.trim
    text += "Whitespace will be removed at start and end of the text. "
  if @schema.crop?
    text += "The text will be cropped after #{@schema.crop} characters. "
  # string length
  if @schema.minLength? and @schema.maxLength?
    text += "It has to be between #{@schema.minLength} and #{@schema.maxLength}
    characters long. "
  else if @schema.minLength?
    text += "It has to be at least #{@schema.minLength} characters long. "
  else if @schema.maxLength?
    text += "It has to be not more than #{@schema.maxLength} characters long. "
  # specific values
  if list = @schema.values
    if typeof list is 'string'
      list = list.split /,\s*/
    else if typeof list is 'object' and not Array.isArray list
      list = Object.keys list
    text += "Only the values: #{list} are allowed. "
  # matching
  if @schema.startsWith?
    text += "It has to start with #{@schema.startsWith}... "
  if @schema.endsWith?
    text += "It has to end with ...#{@schema.endsWith}. "
  if @schema.match?
    text += "The text should match: "
    if Array.isArray @schema.match
      for entry in @schema.match
        text += "#{entry}, "
      text = text.replace /, $/, '. '
    else
      text += "#{@schema.match}. "
  if @schema.matchNot?
    text += "The text shouldn't match: "
    if Array.isArray @schema.matchNot
      for entry in @schema.matchNot
        text += "#{entry}, "
      text = text.replace /, $/, '. '
    else
      text += "#{@schema.matchNot}. "
  cb null, text

# Check value against schema.
#
# @param {function(Error)} cb callback to be called if done with possible error
exports.check = (cb) ->
  # base checks
  skip = rules.optional.check.call this
  return cb skip if skip instanceof Error
  return cb() if skip
  # first check input type
  if @schema.toString and typeof @schema.toString isnt 'function'
    @value = @value.toString()
  unless typeof @value is 'string'
    return @sendError "A string is needed but got #{typeof @value} instead", cb
  # sanitize
  unless @schema.allowControls
    @value = @value.replace /[\x00-\x09\x0B\x0C\x0E-\x1F\x7F]/g, ''
  if @schema.stripTags
    @value = @value.replace /<\/?[^>]+(>|$)/g, ''
  # upper/lowercase
  if @schema.lowerCase? and @schema.lowerCase is true
    @value = @value.toLowerCase()
  if @schema.upperCase? and @schema.upperCase is true
    @value = @value.toUpperCase()
  if @schema.lowerCase? and @schema.lowerCase is 'first'
    @value = @value.charAt(0).toLowerCase() + @value[1..]
  if @schema.upperCase? and @schema.upperCase is 'first'
    @value = @value.charAt(0).toUpperCase() + @value[1..]
  # replacements
  if @schema.replace?
    if Array.isArray @schema.replace[0]
      for [pattern, replace] in @schema.replace
        @value = @value.replace pattern, replace
    else
      [pattern, replace] = @schema.replace
      @value = @value.replace pattern, replace
  # trim and crop
  if @schema.trim
    @value = @value.trim()
  if @schema.crop?
    @value = @value.substring 0, @schema.crop
  # string length
  if @schema.minLength? and @value.length < @schema.minLength
    return @sendError "The given string '#{@value}' is too short at least
    #{@schema.minLength} characters are needed", cb
  if @schema.maxLength? and @value.length > @schema.maxLength
    return @sendError "The given string is too long, not more than #{@schema.maxLength}
    characters are allowed", cb
  # specific values
  if list = @schema.values
    if typeof list is 'string'
      list = list.split /,\s*/
    else if typeof list is 'object' and not Array.isArray list
      list = Object.keys list
    unless Array.isArray(list) and @value in list
      return @sendError "The given string is not in the list of allowed phrases (#{list})", cb
  if @schema.startsWith? and @value[..@schema.startsWith.length-1] isnt @schema.startsWith
    return @sendError "The given string should start with '#{@schema.startsWith}'", cb
  if @schema.endsWith? and @value[@value.length - @schema.endsWith.length..] isnt @schema.endsWith
    return @sendError "The given string should end with '#{@schema.endsWith}'", cb
  # matching
  if @schema.match?
    if Array.isArray @schema.match
      success = true
      for match in @schema.match
        match = new RegExp match unless match instanceof RegExp
        success = success and @value.match match
      unless success
        return @sendError "The given string should match against '#{@schema.match}'", cb
    else if @schema.match instanceof RegExp
      unless @value.match @schema.match
        return @sendError "The given string should match against '#{@schema.match}'", cb
    else if not ~@value.indexOf @schema.match
      return @sendError "The given string should contain '#{@schema.match}'", cb
  if @schema.matchNot?
    if Array.isArray @schema.matchNot
      success = true
      for match in @schema.matchNot
        match = new RegExp match unless match instanceof RegExp
        success = success and not @value.match match
      unless success
        return @sendError "The given strinG shouldn't match against '#{@schema.match}'", cb
    else if @schema.matchNot instanceof RegExp
      if @value.match @schema.matchNot
        return @sendError "The given string shouldn't match against '#{@schema.matchNot}'", cb
    else if ~@value.indexOf @schema.matchNot
      return @sendError "The given string shouldn't contain '#{@schema.matchNot}'", cb
  # done checking and sanuitizing
  @sendSuccess cb

# ### Selfcheck Schema
#
# Schema for selfchecking of this type
exports.selfcheck =
  title: "String"
  description: "a string schema definition"
  type: 'object'
  allowedKeys: true
  keys: util.extend rules.baseSchema,
    default:
      title: "Default Value"
      description: "the default value to use if nothing given"
      type: 'string'
      optional: true
    toString:
      title: "To String"
      description: "a switch to transform objects into string using the `toString()` method"
      type: 'boolean'
      optional: true
    allowControls:
      title: "Allow Controls"
      description: "a flag defining that controls are allowed if set to `true`"
      type: 'boolean'
      optional: true
    stripTags:
      title: "Strip Tags"
      description: "a flag defining if all MTML tags should be removed"
      type: 'boolean'
      optional: true
    lowerCase:
      title: "Lower Case"
      description: "the flag to transform first or all characters to lower case"
      type: 'or'
      optional: true
      or: [
        title: "Lower Case All"
        description: "the flag to transform all characters to lower case if set to `true`"
        type: 'boolean'
      ,
        title: "Lower Case First"
        description: "a flag if set to `first` it will transform the first character to lower case"
        type: 'string'
        values: ['first']
      ]
    upperCase:
      title: "Upper Case"
      description: "the  flag to transform first or all characters to upper case"
      type: 'or'
      optional: true
      or: [
        title: "Upper Case All"
        description: "the flag to transform all characters to upper case if set to `true`"
        type: 'boolean'
      ,
        title: "Lower Case First"
        description: "a flag if set to `first` it will transform the first character to upper case"
        type: 'string'
        values: ['first']
      ]
    replace:
      title: "Replacement"
      description: "a part to be replaced"
      type: 'or'
      or: [
        title: "One Replacement"
        description: "the replacement to be done"
        type: 'array'
        list:
          0:
            title: "RegExp Match"
            description: "the regular expression to be matched"
            type: 'object'
            instanceOf: RegExp
          1:
            title: "Replacement String"
            description: "the replacement for each match"
            type: 'string'
      ,
        title: "Multiple Replacements"
        description: "a list of replacements to be done"
        type: 'array'
        entries:
          title: "One Replacement"
          description: "the replacement to be done"
          type: 'array'
          list:
            0:
              title: "RegExp Match"
              description: "the regular expression to be matched"
              type: 'object'
              instanceOf: RegExp
            1:
              title: "Replacement String"
              description: "the replacement for each match"
              type: 'string'
      ]
    trim:
      title: "Trim"
      description: "a flag set to `true` to trim whitespace from the start and end"
      type: 'boolean'
      optional: true
    crop:
      title: "Crop Length"
      description: "the maximum text length, if greater it will be cut"
      type: 'integer'
      optional: true
      min: 1
    minLength:
      title: "Minimum Length"
      description: "the minimum character length of the text"
      type: 'integer'
      optional: true
      min: 0
    maxLength:
      title: "Maximum Length"
      description: "the maximum character length of the text"
      type: 'integer'
      optional: true
      min: '<<<min>>>'
    values:
      title: "Value List"
      description: "the list of possible values for this element"
      type: 'or'
      optional: true
      or: [
        title: "List of Values"
        description: "the list of all possible values"
        type: 'array'
        minLength: 1
        entries:
          title: "Possible Value"
          description: "a possible value"
          type: 'string'
      ,
        title: "Object of Values"
        description: "an object from which one of the keys have to be set as value"
        type: 'object'
        minLength: 1
      ,
        title: "Comma List of Values"
        description: "a comma separated list of possible values"
        type: 'string'
      ]
    startsWith:
      title: "Starts With"
      description: "the text has to start with the given phrase"
      type: 'string'
      optional: true
    endsWith:
      title: "Ends With"
      description: "the text has to end with the given phrase"
      type: 'string'
      optional: true
    match:
      title: "Matches"
      description: "the text have to match this regular expression"
      type: 'or'
      optional: true
      or: [
        title: "List of Matches"
        description: "a list of matches to succeed"
        type: 'array'
        entries:
          title: "One Match"
          description: "the match to succeed"
          type: 'or'
          or: [
            title: "RegExp String"
            description: "the match to be checked for success"
            type: 'string'
          ,
            title: "RegExp String"
            description: "the match to be checked for success"
            type: 'object'
            instanceOf: RegExp
          ]
      ,
        title: "One Match"
        description: "the match to succeed"
        type: 'or'
        or: [
          title: "RegExp String"
          description: "the match to be checked for success"
          type: 'string'
        ,
          title: "RegExp Object"
          description: "the match to be checked for success"
          type: 'object'
          instanceOf: RegExp
        ]
      ]
    matchNot:
      title: "Negative Matches"
      description: "the text should not match this regular expression"
      type: 'or'
      optional: true
      or: [
        title: "List of Negative Matches"
        description: "a list of matches which should not succeed"
        type: 'array'
        entries:
          title: "One Negative Match"
          description: "the match which should not succeed"
          type: 'or'
          or: [
            title: "RegExp String"
            description: "the match to be checked for failure"
            type: 'string'
          ,
            title: "RegExp String"
            description: "the match to be checked for failure"
            type: 'object'
            instanceOf: RegExp
          ]
      ,
        title: "One Match"
        description: "the match which should not succeed"
        type: 'or'
        or: [
          title: "RegExp String"
          description: "the match to be checked for failure"
          type: 'string'
        ,
          title: "RegExp Object"
          description: "the match to be checked for failure"
          type: 'object'
          instanceOf: RegExp
        ]
      ]
