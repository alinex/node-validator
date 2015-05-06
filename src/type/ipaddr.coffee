# IP Address validation
# =================================================

# Check options:
#
# - `optional` - the value must not be present (will return null)
# - `default` - the value to use if none given
# - `version` - one of 'ipv4' or 'ipv6' and the value will be converted, if possible
# - `format` - compression method to use: 'short', 'long'
# - `allow` - the allowed ip ranges
# - `deny` - the denied ip ranges

# Node modules
# -------------------------------------------------
debug = require('debug')('validator:ipaddr')
util = require 'util'
chalk = require 'chalk'
ipaddr = require 'ipaddr.js'
# include classes and helper
ValidatorCheck = require '../check'
rules = require '../rules'

specialRanges =
  unspecified: [
    '0.0.0.0/8'
    '0::/128' # RFC4291, here and after
  ]
  broadcast: [ '255.255.255.255/32' ]
  multicast: [
    '224.0.0.0/4' # RFC3171
    'ff00::/8'
  ]
  linklocal: [
    '169.254.0.0/16' # RFC3927
    'fe80::/10'
  ]
  loopback: [
    '127.0.0.0/8'
    '::1/128'
  ] # RFC5735
  private: [
    '10.0.0.0/8' # RFC1918
    '172.16.0.0/12' # RFC1918
    '192.168.0.0/16' # RFC1918
  ]
  # Reserved and testing-only ranges; RFCs 5735, 5737, 2544, 1700
  reserved: [
    '192.0.0.0/24'
    '192.88.99.0/24'
    '198.51.100.0/24'
    '203.0.113.0/24'
    '240.0.0.0/4'
    '2001:db8::/32' # RFC4291
  ]
  uniquelocal: [ 'fc00::/7' ]
  ipv4mapped:  [ '::ffff:0:0/96' ]
  rfc6145:     [ '::ffff:0:0:0/96' ] # RFC6145
  rfc6052:     [ '64:ff9b::/96' ] # RFC6052
  '6to4':      [ '2002::/16' ] # RFC3056
  teredo:      [ '2001::/32' ] # RFC6052, RFC6146
all = []
all.concat list for name, list of specialRanges
specialRanges.special = all


suboptions = (options) ->
  settings =
    type: 'string'
    # replace needed because ipaddr has bug with leading 0
    # https://github.com/whitequark/ipaddr.js/issues/16
    replace: [ /(^|[.:])0+(?=\d)/g, '$1' ]
  settings

module.exports =

  # Description
  # -------------------------------------------------
  describe:

    # ### Type Description
    type: (options) ->
      text = 'A valid IP address. '
      text += rules.describe.optional options
      if options.deny
        text += "The IP address should not be in the ranges #{options.deny.join ', '}. "
        if options.allow
          text += "But IP address in the ranges #{options.allow.join ', '} are allowed. "
      else if options.allow
        text += "The IP address have to be in the ranges #{options.allow.join ', '}. "
      switch options.format
        when 'short'
          text += 'The IPv6 address will be compressed as possible. '
        when 'long'
          text += 'The IPv6 address will be normalized with all octets visible. '
      text


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
      value = check.subcall path, suboptions(options), value
      # validate
      unless ipaddr.isValid value
        throw check.error path, options, value,
        new Error "The given value '#{value}' is no valid IPv6 or IPv4 address"
      ip = ipaddr.parse value
      debug "analyzed #{ip.kind()}", ip
      # format value
      if options.version
        if options.version is 'ipv4'
          if ip.kind() is 'ipv6'
            if ip.isIPv4MappedAddress()
              debug 'convert to ipv4'
              ip = ip.toIPv4Address()
            else
              throw check.error path, options, value,
              new Error "The given value '#{value}' is no valid IPv#{options.version} address"
        else
          if ip.kind() is 'ipv4'
            debug 'convert to ipv4mapped'
            ip = ip.toIPv4MappedAddress()
      if ip.kind() is 'ipv6'
        value = if options.format is 'long' then ip.toNormalizedString() else ip.toString()
      else
        value = ip.toString()
      # check ranges
      if options.allow
        for entry in options.allow
          if specialRanges[entry]?
            for subentry in specialRanges[entry]
              [addr, bits] = subentry.split /\//
              return value if ip.match ipaddr.parse(addr), bits
          else
            [addr, bits] = entry.split /\//
            return value if ip.match ipaddr.parse(addr), bits
        # ip not in the allowed range
        unless options.deny
          throw check.error path, options, value,
          new Error "The given ip address '#{value}' is not in the allowed ranges"
      if options.deny
        for entry in options.deny
          if specialRanges[entry]?
            for subentry in specialRanges[entry]
              [addr, bits] = subentry.split /\//
              if ip.match ipaddr.parse(addr), bits
                throw check.error path, options, value,
                new Error "The given ip address '#{value}' is denied because in range #{entry}"
          else
            [addr, bits] = entry.split /\//
            if ip.match ipaddr.parse(addr), bits
              throw check.error path, options, value,
              new Error "The given ip address '#{value}' is denied because in range #{entry}"
      # ip also not in the denied range so allowed again
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
        version:
          type: 'string'
          values: ['ipv4', 'ipv6']
          optional: true
        deny:
          type: 'array'
          optional: true
          entries:
            type: 'string'
        allow:
          type: 'array'
          optional: true
          entries:
            type: 'string'
        format:
          type: 'string'
          default: 'short'
          values: ['short', 'long']
    , options

