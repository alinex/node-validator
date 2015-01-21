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
# include classes and helper
rules = require '../rules'

module.exports = float =

  # Description
  # -------------------------------------------------
  describe:

    # ### Type Description
    type: (options) ->
      text = 'A simple text entry. '
      text += rules.describe.optional options
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
        text += "It has to be between #{options.minLength} and #{options.maxLength}
        characters long. "
      else if options.minLength?
        text += "It has to be at least #{options.minLength} characters long. "
      else if options.maxLength?
        text += "It has to be not more than #{options.maxLength} characters long. "
      if options.values?
        text += "Only the values: #{options.values.join ', '} are allowed. "
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
      text

  # Synchronous check
  # -------------------------------------------------
  sync:

    # ### Check Type
    type: (check, path, options, value) ->
      # first check input type
      value = rules.sync.optional check, path, options, value
      return value unless value?
      if options.tostring and typeof value is 'object'
        value = value.toString()
      unless typeof value is 'string'
        throw check.error path, options, value,
        new Error "A string is needed but got #{typeof value} instead"
      # sanitize
      unless options.allowControls
        value = value.replace /[\x00-\x09\x0B\x0C\x0E-\x1F\x7F]/g, ''
      if options.stripTags
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
        throw check.error path, options, value,
        new Error "The given string '#{value}' is too short at most
        #{options.minlength} characters are needed"
      if options.maxLength? and value.length > options.maxLength
        throw check.error path, options, value,
        new Error "The given string '#{value}' is too long for
          at least #{options.maxlength} characters are allowed"
      if options.values? and not (value in options.values)
        throw check.error path, options, value,
        new Error "The given string '#{value}' is not in the list of
          allowed phrases (#{options.values})"
      if options.startsWith? and value[..options.startsWith.length-1] isnt options.startsWith
        throw check.error path, options, value,
        new Error "The given string '#{value}' should start with '#{options.startsWith}'"
      if options.endsWith? and value[value.length-options.endsWith.length..] isnt options.endsWith
        throw check.error path, options, value,
        new Error "The given string '#{value}' should end with '#{options.endsWith}'"
      if options.match?
        if Array.isArray options.match
          success = true
          for match in options.match
            if match instanceof RegExp
              success = success and value.match match
            else
              success = success and ~value.indexOf match
          unless success
            throw check.error path, options, value,
            new Error "The given string '#{value}' should match against '#{options.match}'"
        else if options.match instanceof RegExp
          unless value.match options.match
            throw check.error path, options, value,
            new Error "The given string '#{value}' should match against '#{options.match}'"
        else if not ~value.indexOf options.match
          throw check.error path, options, value,
          new Error "The given string '#{value}' should contain '#{options.match}'"
      if options.matchNot?
        if Array.isArray options.matchNot
          success = true
          for match in options.matchNot
            if match instanceof RegExp
              success = success and not value.match match
            else
              success = success and not ~value.indexOf match
          unless success
            throw check.error path, options, value,
            new Error "The given string '#{value}' shouldn't match against '#{options.match}'"
        else if options.matchNot instanceof RegExp and value.matchNot options.match
          throw check.error path, options, value,
          new Error "The given string '#{value}' shouldn't match
          against '#{options.matchNot}'"
        else if ~value.indexOf options.matchNot
          throw check.error path, options, value,
          new Error "The given string '#{value}' shouldn't contain '#{options.matchNot}'"
      # done return resulting value
      value

  # Selfcheck
  # -------------------------------------------------
  selfcheck: (name, options) ->
    validator = require '../index'
    validator.check name,
      type: 'object'
      allowedKeys: true
      entries:
        type:
          type: 'string'
        title:
          type: 'string'
          optional: true
        description:
          type: 'string'
          optional: true
        optional:
          type: 'boolean'
          optional: true
        default:
          type: 'string'
          optional: true
        tostring:
          type: 'boolean'
          optional: true
        allowControls:
          type: 'boolean'
          optional: true
        stripTags:
          type: 'boolean'
          optional: true
        lowerCase:
          type: 'any'
          optional: true
          entries: [
            type: 'boolean'
          ,
            type: 'string'
            values: ['first']
          ]
        upperCase:
          type: 'any'
          optional: true
          entries: [
            type: 'boolean'
          ,
            type: 'string'
            values: ['first']
          ]
        replace:
          type: 'array'
          optional: true
          entries: [
            type: 'any'
            entries: [
              type: 'string'
            ,
              type: 'object'
              instanceOf: RegExp
            ,
              type: 'array'
              entries: [
                type: 'string'
              ,
                type: 'object'
                instanceOf: RegExp
              ]
            ]
          ,
            type: 'any'
            entries: [
              type: 'string'
            ,
              type: 'array'
              entries:
                type: 'string'
            ]
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
          min:
            reference: 'relative'
            source: '<minLength'
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
          type: 'any'
          optional: true
          entries: [
            type: 'string'
          ,
            type: 'object'
            instanceOf: RegExp
          ]
        matchNot:
          type: 'any'
          optional: true
          entries: [
            type: 'string'
          ,
            type: 'object'
            instanceOf: RegExp
          ]
    , options

