# Domain name validation
# =================================================

# Check options:
#
# - `optional` - the value must not be present (will return null)


# Node modules
# -------------------------------------------------
debug = require('debug')('validator:hostname')
util = require 'util'
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
      text = 'This should be a valid hostname. '
      text += rules.describe.optional options
      text += ValidatorCheck.describe suboptions
      text

  # Synchronous check
  # -------------------------------------------------
  sync:

    # ### Check Type
    type: (check, path, options, value) ->
      debug "check #{util.inspect value} in #{check.pathname path}", util.inspect(options).grey
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

