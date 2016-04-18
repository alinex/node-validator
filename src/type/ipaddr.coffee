# IP Address validation
# =================================================

# Check options:
#
# - `optional` - the value must not be present (will return null)
# - `default` - the value to use if none given
# - `version` - one of 'ipv4' or 'ipv6' and the value will be converted, if possible
# - `format` - compression method to use: 'short', 'long'
# - `allow` - (list) the allowed ip ranges
# - `deny` - (list) the denied ip ranges

# Node modules
# -------------------------------------------------
debug = require('debug')('validator:ipaddr')
chalk = require 'chalk'
ipaddr = require 'ipaddr.js'
# alinex modules
util = require 'alinex-util'
# include classes and helper
check = require '../check'

# Configuration
# -------------------------------------------------
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
  ipv4mapped: [ '::ffff:0:0/96' ]
  rfc6145: [ '::ffff:0:0:0/96' ] # RFC6145
  rfc6052: [ '64:ff9b::/96' ] # RFC6052
  '6to4': [ '2002::/16' ] # RFC3056
  teredo: [ '2001::/32' ] # RFC6052, RFC6146
all = []
all.concat list for name, list of specialRanges
specialRanges.special = all

# Type implementation
# -------------------------------------------------
exports.describe = (work, cb) ->
  text = 'A valid IP address as string. '
  text += check.optional.describe work
  text = text.replace /\. It's/, ' which is'
  if work.pos.version
    if work.pos.version is 'ipv4'
      text += "Only IPv4 addresses are valid. "
    else
      text += "Only IPv6 addresses are valid. "
    if work.pos.ipv4Mapping
      text += "IPv4 addresses may be automatically converted. "
  if work.pos.deny
    text += "The IP address should not be in the ranges: '#{work.pos.deny.join '\', \''}'. "
    if work.pos.allow
      text += "But IP address in the ranges: '#{work.pos.allow.join '\', \''}' are allowed. "
  else if work.pos.allow
    text += "The IP address have to be in the ranges: '#{work.pos.allow.join '\', \''}'. "
  switch work.pos.format
    when 'short'
      text += 'An IPv6 address will be compressed as possible. '
    when 'long'
      text += 'An IPv6 address will be normalized with all octets visible. '
  cb null, text

exports.run = (work, cb) ->
  debug "#{work.debug} with #{util.inspect work.value} as #{work.pos.type}"
  debug "#{work.debug} #{chalk.grey util.inspect work.pos}"
  # base checks
  try
    if check.optional.run work
      debug "#{work.debug} result #{util.inspect value ? null}"
      return cb()
  catch error
    return work.report error, cb
  value = work.value
  # first check input type
  name = work.spec.name ? 'value'
  if work.path.length
    name += "/#{work.path.join '/'}"
  check.run
    name: name
    value: work.value
    schema:
      type: 'string'
  , (err, value) ->
    return cb err if err
    # validate
    unless ipaddr.isValid value
      return work.report (new Error "The given value '#{value}' is no valid IPv6
        or IPv4 address"), cb
    ip = ipaddr.parse value
    debug "analyzed #{ip.kind()}", ip
    # format value
    if work.pos.version
      if work.pos.version is 'ipv4'
        if ip.kind() is 'ipv6'
          if ip.isIPv4MappedAddress() and work.pos.ipv4Mapping
            debug 'convert to ipv4'
            ip = ip.toIPv4Address()
          else
            return work.report (new Error "The given value '#{value}' is no valid
              IPv#{work.pos.version} address"), cb
      else
        if ip.kind() is 'ipv4'
          unless work.pos.ipv4Mapping
            return work.report (new Error "The given value '#{value}' is no valid
              IPv#{work.pos.version} address"), cb
          debug 'convert to ipv4mapped'
          ip = ip.toIPv4MappedAddress()
    if ip.kind() is 'ipv6'
      value = if work.pos.format is 'long' then ip.toNormalizedString() else ip.toString()
    else
      value = ip.toString()
    # check ranges
    if work.pos.allow
      for entry in work.pos.allow
        if specialRanges[entry]?
          for subentry in specialRanges[entry]
            [addr, bits] = subentry.split /\//
            if ip.match ipaddr.parse(addr), bits
              debug "#{work.debug} result #{util.inspect value ? null}"
              return cb null, value
        else
          [addr, bits] = entry.split /\//
          if ip.match ipaddr.parse(addr), bits
            debug "#{work.debug} result #{util.inspect value ? null}"
            return cb null, value
      # ip not in the allowed range
      unless work.pos.deny
        return work.report (new Error "The given ip address '#{value}' is not in
          the allowed ranges"), cb
    if work.pos.deny
      for entry in work.pos.deny
        if specialRanges[entry]?
          for subentry in specialRanges[entry]
            [addr, bits] = subentry.split /\//
            if ip.match ipaddr.parse(addr), bits
              return work.report (new Error "The given ip address '#{value}' is
                denied because in range #{entry}"), cb
        else
          [addr, bits] = entry.split /\//
          if ip.match ipaddr.parse(addr), bits
            return work.report (new Error "The given ip address '#{value}' is
              denied because in range #{entry}"), cb
    # ip also not in the denied range so allowed again
    # done return resulting value
    debug "#{work.debug} result #{util.inspect value ? null}"
    cb null, value

exports.selfcheck = (schema, cb) ->
  check.run
    schema:
      type: 'object'
      allowedKeys: true
      keys: util.extend util.clone(check.base),
        default:
          type: 'string'
          optional: true
        version:
          type: 'string'
          values: ['ipv4', 'ipv6']
          optional: true
        ipv4Mapping:
          type: 'boolean'
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
              # ipv6 mask
              |(
                # 1:2:3:4:5:6:7:8
                |([0-9a-fA-F]{1,4}:){7,7}[0-9a-fA-F]{1,4}
                # 1::                              1:2:3:4:5:6:7::
                |([0-9a-fA-F]{1,4}:){1,7}:
                # 1::8             1:2:3:4:5:6::8  1:2:3:4:5:6::8
                |([0-9a-fA-F]{1,4}:){1,6}:[0-9a-fA-F]{1,4}
                # 1::7:8           1:2:3:4:5::7:8  1:2:3:4:5::8
                |([0-9a-fA-F]{1,4}:){1,5}(:[0-9a-fA-F]{1,4}){1,2}
                # 1::6:7:8         1:2:3:4::6:7:8  1:2:3:4::8
                |([0-9a-fA-F]{1,4}:){1,4}(:[0-9a-fA-F]{1,4}){1,3}
                # 1::5:6:7:8       1:2:3::5:6:7:8  1:2:3::8
                |([0-9a-fA-F]{1,4}:){1,3}(:[0-9a-fA-F]{1,4}){1,4}
                # 1::4:5:6:7:8     1:2::4:5:6:7:8  1:2::8
                |([0-9a-fA-F]{1,4}:){1,2}(:[0-9a-fA-F]{1,4}){1,5}
                # 1::3:4:5:6:7:8   1::3:4:5:6:7:8  1::8
                |[0-9a-fA-F]{1,4}:((:[0-9a-fA-F]{1,4}){1,6})
                # ::2:3:4:5:6:7:8  ::2:3:4:5:6:7:8 ::8       ::
                |:((:[0-9a-fA-F]{1,4}){1,7}|:)
                # fe80::7:8%eth0   fe80::7:8%1     (link-local IPv6 addresses with zone index)
                |fe80:(:[0-9a-fA-F]{0,4}){0,4}%[0-9a-zA-Z]{1,}
                # ::255.255.255.255   ::ffff:255.255.255.255  ::ffff:0:255.255.255.255
                # (IPv4-mapped IPv6 addresses and IPv4-translated addresses)
                |::(ffff(:0{1,4}){0,1}:){0,1}
                  ((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}
                  (25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])
                # 2001:db8:3:4::192.0.2.33  64:ff9b::192.0.2.33 (IPv4-Embedded IPv6 Address)
                |([0-9a-fA-F]{1,4}:){1,4}:
                  ((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}
                  (25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])
              # /128
              )\/(12[0-8]|(1[01][0-9]){0,1}[0-9])
              # ipv4 mask 255.255.255.255/32
              |(
                ((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}
                (25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])
              )\/(3[0-2]|[12]{0,1}[0-9])
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
              # ipv6 mask
              |(
                # 1:2:3:4:5:6:7:8
                |([0-9a-fA-F]{1,4}:){7,7}[0-9a-fA-F]{1,4}
                # 1::                              1:2:3:4:5:6:7::
                |([0-9a-fA-F]{1,4}:){1,7}:
                # 1::8             1:2:3:4:5:6::8  1:2:3:4:5:6::8
                |([0-9a-fA-F]{1,4}:){1,6}:[0-9a-fA-F]{1,4}
                # 1::7:8           1:2:3:4:5::7:8  1:2:3:4:5::8
                |([0-9a-fA-F]{1,4}:){1,5}(:[0-9a-fA-F]{1,4}){1,2}
                # 1::6:7:8         1:2:3:4::6:7:8  1:2:3:4::8
                |([0-9a-fA-F]{1,4}:){1,4}(:[0-9a-fA-F]{1,4}){1,3}
                # 1::5:6:7:8       1:2:3::5:6:7:8  1:2:3::8
                |([0-9a-fA-F]{1,4}:){1,3}(:[0-9a-fA-F]{1,4}){1,4}
                # 1::4:5:6:7:8     1:2::4:5:6:7:8  1:2::8
                |([0-9a-fA-F]{1,4}:){1,2}(:[0-9a-fA-F]{1,4}){1,5}
                # 1::3:4:5:6:7:8   1::3:4:5:6:7:8  1::8
                |[0-9a-fA-F]{1,4}:((:[0-9a-fA-F]{1,4}){1,6})
                # ::2:3:4:5:6:7:8  ::2:3:4:5:6:7:8 ::8       ::
                |:((:[0-9a-fA-F]{1,4}){1,7}|:)
                # fe80::7:8%eth0   fe80::7:8%1     (link-local IPv6 addresses with zone index)
                |fe80:(:[0-9a-fA-F]{0,4}){0,4}%[0-9a-zA-Z]{1,}
                # ::255.255.255.255   ::ffff:255.255.255.255  ::ffff:0:255.255.255.255
                # (IPv4-mapped IPv6 addresses and IPv4-translated addresses)
                |::(ffff(:0{1,4}){0,1}:){0,1}
                  ((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}
                  (25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])
                # 2001:db8:3:4::192.0.2.33  64:ff9b::192.0.2.33 (IPv4-Embedded IPv6 Address)
                |([0-9a-fA-F]{1,4}:){1,4}:
                  ((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}
                  (25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])
              # /128
              )\/(12[0-8]|(1[01][0-9]){0,1}[0-9])
              # ipv4 mask 255.255.255.255/32
              |(
                ((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}
                (25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])
              )\/(3[0-2]|[12]{0,1}[0-9])
              $
            ///
        format:
          type: 'string'
          default: 'short'
          values: ['short', 'long']
    value: schema
  , cb
