# IP Address validation
# =================================================

# Check options:
#
# - `optional` - the value must not be present (will return null)
# - `default` - the value to use if none given
# - `format` - compression method to use: 'short', 'long'
# - `lowerCase` - make it upper case
# - `upperCase` - make it lowercase
# - `allow` - the allowed ip ranges
# - `deny` - the denied ip ranges

# Node modules
# -------------------------------------------------
debug = require('debug')('validator:ipv6')
util = require 'util'
chalk = require 'chalk'
rangeCheck = require 'range_check'
# include classes and helper
ValidatorCheck = require '../check'
rules = require '../rules'

suboptions = (options) ->
  settings =
    type: 'string'
    match: ///
      ^
      (                               # ffff:ffff:ffff:ffff:ffff:ffff:ffff:ffff
        ([0-9a-fA-F]{1,4}:){7,7}
        [0-9a-fA-F]{1,4}
      |                               # ffff:: - ffff:ffff:ffff:ffff:ffff:ffff:ffff::
        ([0-9a-fA-F]{1,4}:){1,7}:
      |                               # ffff::ffff - ffff:ffff:ffff:ffff:ffff:ffff::ffff
        ([0-9a-fA-F]{1,4}:){1,6}:
        [0-9a-fA-F]{1,4}
      |                               # ffff::ffff - ffff:ffff:ffff:ffff:ffff::ffff:ffff
        ([0-9a-fA-F]{1,4}:){1,5}
        (:[0-9a-fA-F]{1,4}){1,2}
      |                               # ffff::ffff - ffff:ffff:ffff:ffff::ffff:ffff:ffff
        ([0-9a-fA-F]{1,4}:){1,4}
        (:[0-9a-fA-F]{1,4}){1,3}
      |                               # ffff::ffff - ffff:ffff:ffff::ffff:ffff:Ffff:ffff
        ([0-9a-fA-F]{1,4}:){1,3}
        (:[0-9a-fA-F]{1,4}){1,4}
      |                               # ffff::ffff - ffff:ffff::ffff:ffff:ffff:ffff:ffff
        ([0-9a-fA-F]{1,4}:){1,2}
        (:[0-9a-fA-F]{1,4}){1,5}
      |                               # ffff::ffff - ffff::ffff:ffff:ffff:ffff:ffff:ffff
        [0-9a-fA-F]{1,4}:
        ((:[0-9a-fA-F]{1,4}){1,6})
      |                               # :: -  ::ffff:ffff:ffff:ffff:ffff:ffff:ffff
        :((:[0-9a-fA-F]{1,4}){1,7}|:)
      |                               #  fe80:%zzzz - fe80::ffff:ffff:ffff:ffff%zzzzz
        fe80:
        (:[0-9a-fA-F]{0,4}){0,4}
        %[0-9a-zA-Z]{1,}
      |                               #  :::i<pv4> -  ::ffff:0000:<ipv4>
        ::(
          ffff(:0{1,4}){0,1}:
        ){0,1}
        (                     # first number
          25[0-5]             # 250-255
          |2[0-4][0-9]        # or 200-249
          |[01]?[0-9][0-9]?   # or 000-199 also without leading 0
        )
        (                     # second to third number
          \.                  # using dot as separator
          (                   # number as before
            25[0-5]           # 250-255
            |2[0-4][0-9]      # or 200-249
            |[01]?[0-9][0-9]? # or 000-199 also without leading 0
          )
        ){3}                  # number 2..4
      )
      $
      ///
    lowerCase: options.lowerCase
    upperCase: options.upperCase
  switch options.format
    when 'short'
      settings.replace =  [
        [ /^0+(?=\w)/g, '' ]
        [ /:0+(?=\w)/g, ':' ]
        [ /(:0)+(?=:)/g, ':' ]
      ]
    when 'long'
      settings.replace = [
        [ /^(\d{1})(?=\.)/g, '00$1' ]
        [ /^(\d{2})(?=\.)/g, '0$1' ]
        [ /\.(\d{1})(?=\.)/g, '.00$1' ]
        [ /\.(\d{2})(?=\.)/g, '.0$1' ]
        [ /\.(\d{1})$/g, '.00$1' ]
        [ /\.(\d{2})$/g, '.0$1' ]
      ]
  settings

optionCheck = (options) ->
  if options.deny
    if typeof options.deny is 'string'
      options.deny = [options.deny]
    list = []
    for value in options.deny
      if value is 'private'
        list.push '10.0.0.0/8', '172.16.0.0/12', '192.168.0.0/16'
      else list.push value
    options.deny = list
  if options.allow
    if typeof options.allow is 'string'
      options.allow = [options.allow]
    list = []
    for value in options.allow
      if value is 'private'
        list.push '10.0.0.0/8', '172.16.0.0/12', '192.168.0.0/16'
      else list.push value
    options.allow = list
  options

###
  v6:
    type: 'string'
    match: ///
      ///
###

module.exports =

  # Description
  # -------------------------------------------------
  describe:

    # ### Type Description
    type: (options) ->
      options = optionCheck options
      text = 'A valid ip version 4 address. '
      text += rules.describe.optional options
      text += ValidatorCheck.describe suboptions options

  # Synchronous check
  # -------------------------------------------------
  sync:

    # ### Check Type
    type: (check, path, options, value) ->
      options = optionCheck options
      debug "check #{util.inspect value} in #{check.pathname path}"
      , chalk.grey util.inspect options
      # first check input type
      value = rules.sync.optional check, path, options, value
      return value unless value?
      # validate
      value = check.subcall path, suboptions(options), value
      if options.deny
        return value unless rangeCheck.inRange value, options.deny
        if options.allow
          return value if rangeCheck.inRange value, options.allow
          throw check.error path, options, value,
          new Error "The given ip address '#{value}' is not in the valid range.
          Denied is #{options.deny.join ', '} but allowed is #{options.allow.join ', '}."
        throw check.error path, options, value,
        new Error "The given ip address '#{value}' is not in the valid range.
        Denied is #{options.deny.join ', '}."
      if options.allow
        return value if rangeCheck.inRange value, options.allow
        throw check.error path, options, value,
        new Error "The given ip address '#{value}' is not in the valid range.
        Allowed is only #{options.allow.join ', '}."
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
        lowerCase:
          type: 'boolean'
          optional: true
        upperCase:
          type: 'boolean'
          optional: true
        compress:
          type: 'boolean'
          optional: true
        deny:
          type: 'any'
          optional: true
          entries: [
            type: 'string'
            match: ///
              ^
              private
              |
              (                     # first number
                25[0-5]             # 250-255
                |2[0-4][0-9]        # or 200-249
                |[01]?[0-9][0-9]?   # or 000-199 also without leading 0
              )
              (                     # second to third number
                \.                  # using dot as separator
                (                   # number as before
                  25[0-5]           # 250-255
                  |2[0-4][0-9]      # or 200-249
                  |[01]?[0-9][0-9]? # or 000-199 also without leading 0
                )
              ){3}                  # number 2..4
              \/\d+                 # give netmask
              $
              ///
          ,
            type: 'array'
            entries:
              type: 'string'
              match: ///
                ^
                private
                |
                (                     # first number
                  25[0-5]             # 250-255
                  |2[0-4][0-9]        # or 200-249
                  |[01]?[0-9][0-9]?   # or 000-199 also without leading 0
                )
                (                     # second to third number
                  \.                  # using dot as separator
                  (                   # number as before
                    25[0-5]           # 250-255
                    |2[0-4][0-9]      # or 200-249
                    |[01]?[0-9][0-9]? # or 000-199 also without leading 0
                  )
                ){3}                  # number 2..4
                \/\d+                 # give netmask
                $
                ///
          ]
        allow:
          type: 'any'
          optional: true
          entries: [
            type: 'string'
            match: ///
              ^
              private
              |
              (                     # first number
                25[0-5]             # 250-255
                |2[0-4][0-9]        # or 200-249
                |[01]?[0-9][0-9]?   # or 000-199 also without leading 0
              )
              (                     # second to third number
                \.                  # using dot as separator
                (                   # number as before
                  25[0-5]           # 250-255
                  |2[0-4][0-9]      # or 200-249
                  |[01]?[0-9][0-9]? # or 000-199 also without leading 0
                )
              ){3}                  # number 2..4
              \/\d+                 # give netmask
              $
              ///
          ,
            type: 'array'
            entries:
              type: 'string'
              match: ///
                ^
                private
                |
                (                     # first number
                  25[0-5]             # 250-255
                  |2[0-4][0-9]        # or 200-249
                  |[01]?[0-9][0-9]?   # or 000-199 also without leading 0
                )
                (                     # second to third number
                  \.                  # using dot as separator
                  (                   # number as before
                    25[0-5]           # 250-255
                    |2[0-4][0-9]      # or 200-249
                    |[01]?[0-9][0-9]? # or 000-199 also without leading 0
                  )
                ){3}                  # number 2..4
                \/\d+                 # give netmask
                $
                ///
          ]
    , options

