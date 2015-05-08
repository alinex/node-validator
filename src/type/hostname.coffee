# Domain name validation
# =================================================

# Check options:
#
# - `optional` - the value must not be present (will return null)


# Node modules
# -------------------------------------------------
debug = require('debug')('validator:hostname')
util = require 'util'
chalk = require 'chalk'
# include classes and helper
ValidatorCheck = require '../check'
rules = require '../rules'

suboptions =
  type: 'string'
  match: ///
    ^
    [a-zA-Z0-9]
    |[a-zA-Z0-9][a-zA-Z0-9\-_]{0,61}[a-zA-Z0-9]
    $
    ///

module.exports = hostname =

  # Description
  # -------------------------------------------------
  describe:

    # ### Type Description
    type: (options) ->
      text = 'A valid hostname. '
      text += rules.describe.optional options
      text = text.replace /\. It's/, ' which is'
      text += ValidatorCheck.describe suboptions

  # Synchronous check
  # -------------------------------------------------
  sync:

    # ### Check Type
    type: (check, path, options, value) ->
      debug "check #{util.inspect value} in #{check.pathname path}"
      , chalk.grey util.inspect options
      # first check input type
      value = rules.sync.optional check, path, options, value
      return value unless value?
      # validate
      check.subcall path, suboptions, value


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

