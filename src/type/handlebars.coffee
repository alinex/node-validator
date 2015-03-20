# Domain name validation
# =================================================

# Check options:
#
# - `optional` - the value must not be present (will return null)


# Node modules
# -------------------------------------------------
debug = require('debug')('validator:handlebars')
util = require 'util'
chalk = require 'chalk'
handlebars = require 'handlebars'
# include classes and helper
ValidatorCheck = require '../check'
rules = require '../rules'

module.exports =

  # Description
  # -------------------------------------------------
  describe:

    # ### Type Description
    type: (options) ->
      text = 'A valid text which may contain handlebar syntax and variables. '
      text += rules.describe.optional options

  # Asynchronous check
  # -------------------------------------------------
  sync:
    # ### Check Type
    type: (check, path, options, value) ->
      debug "check #{util.inspect value} in #{check.pathname path}"
      , chalk.grey util.inspect options
      # first check input type
      value = rules.sync.optional check, path, options, value
      return value unless value?
      # sanitize
      unless typeof value is 'string'
        throw check.error path, options, value,
        new Error "The given value '#{value}' is no integer as needed"
      # compile if handlebars syntax found
      if value.match /\{\{.*?\}\}/
        debug "compile handlebars"
        value = handlebars.compile value
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
    , options

