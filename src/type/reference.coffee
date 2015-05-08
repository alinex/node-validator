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
debug = require('debug')('validator:reference')
util = require 'util'
chalk = require 'chalk'
# include classes and helper
ValidatorCheck = require '../check'
rules = require '../rules'

suboptions = (options) ->
  settings =
    type: 'object'
    mandatoryKeys: ['REF']
    allowedKeys: ['VAL','FUNC']
    entries:
      REF:
        type: 'array'
        notEmpty: true
        entries:
          type: 'object'
          entries:
            source:
              type: 'string'
              lowerCase: true
              values: ['struct', 'data', 'env', 'file']
            path:
              type: 'string'
      FUNC:
        type: 'function'
  settings

module.exports =

  # Description
  # -------------------------------------------------
  describe:

    # ### Type Description
    type: (options) ->
      text = 'A reference to a value. '




      text


  # Synchronous check
  # -------------------------------------------------
  sync:

    # ### Check Type
    type: (check, path, options, value) ->
      debug "check #{util.inspect value} in #{check.pathname path}"
      , chalk.grey util.inspect options
      # make basic check for reference or not
      # validate reference
      # find reference
      # do the reference checks
      # run the operation
      # return resulting value


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
            match: ///
              ^
              unspecified|broadcast|multicast|linklocal|loopback|private
              |reserved|uniquelocal|ipv4mapped|rfc(6145|6052)|6to4|teredo|special
              |( # ipv6 mask
                |([0-9a-fA-F]{1,4}:){7,7}[0-9a-fA-F]{1,4}          # 1:2:3:4:5:6:7:8
                |([0-9a-fA-F]{1,4}:){1,7}:                         # 1::                              1:2:3:4:5:6:7::
                |([0-9a-fA-F]{1,4}:){1,6}:[0-9a-fA-F]{1,4}         # 1::8             1:2:3:4:5:6::8  1:2:3:4:5:6::8
                |([0-9a-fA-F]{1,4}:){1,5}(:[0-9a-fA-F]{1,4}){1,2}  # 1::7:8           1:2:3:4:5::7:8  1:2:3:4:5::8
                |([0-9a-fA-F]{1,4}:){1,4}(:[0-9a-fA-F]{1,4}){1,3}  # 1::6:7:8         1:2:3:4::6:7:8  1:2:3:4::8
                |([0-9a-fA-F]{1,4}:){1,3}(:[0-9a-fA-F]{1,4}){1,4}  # 1::5:6:7:8       1:2:3::5:6:7:8  1:2:3::8
                |([0-9a-fA-F]{1,4}:){1,2}(:[0-9a-fA-F]{1,4}){1,5}  # 1::4:5:6:7:8     1:2::4:5:6:7:8  1:2::8
                |[0-9a-fA-F]{1,4}:((:[0-9a-fA-F]{1,4}){1,6})       # 1::3:4:5:6:7:8   1::3:4:5:6:7:8  1::8
                |:((:[0-9a-fA-F]{1,4}){1,7}|:)                     # ::2:3:4:5:6:7:8  ::2:3:4:5:6:7:8 ::8       ::
                |fe80:(:[0-9a-fA-F]{0,4}){0,4}%[0-9a-zA-Z]{1,}     # fe80::7:8%eth0   fe80::7:8%1     (link-local IPv6 addresses with zone index)
                |::(ffff(:0{1,4}){0,1}:){0,1}
                  ((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}
                  (25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])          # ::255.255.255.255   ::ffff:255.255.255.255  ::ffff:0:255.255.255.255  (IPv4-mapped IPv6 addresses and IPv4-translated addresses)
                |([0-9a-fA-F]{1,4}:){1,4}:
                  ((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}
                  (25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])          # 2001:db8:3:4::192.0.2.33  64:ff9b::192.0.2.33 (IPv4-Embedded IPv6 Address)
              )\/(12[0-8]|(1[01][0-9]){0,1}[0-9])                   # /128
              |( # ipv4 mask
                ((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}
                (25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])            # 255.255.255.255
              )\/(3[0-2]|[12]{0,1}[0-9])                            # /32
              $
            ///
        allow:
          type: 'array'
          optional: true
          entries:
            type: 'string'
            match: ///
              ^
              unspecified|broadcast|multicast|linklocal|loopback|private
              |reserved|uniquelocal|ipv4mapped|rfc(6145|6052)|6to4|teredo|special
              |( # ipv6 mask
                |([0-9a-fA-F]{1,4}:){7,7}[0-9a-fA-F]{1,4}          # 1:2:3:4:5:6:7:8
                |([0-9a-fA-F]{1,4}:){1,7}:                         # 1::                              1:2:3:4:5:6:7::
                |([0-9a-fA-F]{1,4}:){1,6}:[0-9a-fA-F]{1,4}         # 1::8             1:2:3:4:5:6::8  1:2:3:4:5:6::8
                |([0-9a-fA-F]{1,4}:){1,5}(:[0-9a-fA-F]{1,4}){1,2}  # 1::7:8           1:2:3:4:5::7:8  1:2:3:4:5::8
                |([0-9a-fA-F]{1,4}:){1,4}(:[0-9a-fA-F]{1,4}){1,3}  # 1::6:7:8         1:2:3:4::6:7:8  1:2:3:4::8
                |([0-9a-fA-F]{1,4}:){1,3}(:[0-9a-fA-F]{1,4}){1,4}  # 1::5:6:7:8       1:2:3::5:6:7:8  1:2:3::8
                |([0-9a-fA-F]{1,4}:){1,2}(:[0-9a-fA-F]{1,4}){1,5}  # 1::4:5:6:7:8     1:2::4:5:6:7:8  1:2::8
                |[0-9a-fA-F]{1,4}:((:[0-9a-fA-F]{1,4}){1,6})       # 1::3:4:5:6:7:8   1::3:4:5:6:7:8  1::8
                |:((:[0-9a-fA-F]{1,4}){1,7}|:)                     # ::2:3:4:5:6:7:8  ::2:3:4:5:6:7:8 ::8       ::
                |fe80:(:[0-9a-fA-F]{0,4}){0,4}%[0-9a-zA-Z]{1,}     # fe80::7:8%eth0   fe80::7:8%1     (link-local IPv6 addresses with zone index)
                |::(ffff(:0{1,4}){0,1}:){0,1}
                  ((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}
                  (25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])          # ::255.255.255.255   ::ffff:255.255.255.255  ::ffff:0:255.255.255.255  (IPv4-mapped IPv6 addresses and IPv4-translated addresses)
                |([0-9a-fA-F]{1,4}:){1,4}:
                  ((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}
                  (25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])          # 2001:db8:3:4::192.0.2.33  64:ff9b::192.0.2.33 (IPv4-Embedded IPv6 Address)
              )\/(12[0-8]|(1[01][0-9]){0,1}[0-9])                   # /128
              |( # ipv4 mask
                ((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}
                (25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])            # 255.255.255.255
              )\/(3[0-2]|[12]{0,1}[0-9])                            # /32
              $
            ///
        format:
          type: 'string'
          default: 'short'
          values: ['short', 'long']
    , options

