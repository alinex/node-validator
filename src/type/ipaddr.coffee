###
IP Address
=================================================

Check options:
- `optional` - `Boolean` the value must not be present (will return null)
- `default` - `String` the value to use if none given
- `version` - `String` one of 'ipv4' or 'ipv6' and the value will be converted, if possible
- `format` - `String` compression method to use: 'short', 'long'
- `allow` - `Array` the allowed ip ranges
- `deny` - `Array` the denied ip ranges


Schema Specification
---------------------------------------------------
{@schema #selfcheck}
###


# Node Modules
# -------------------------------------------------
ipaddr = require 'ipaddr.js'
util = require 'alinex-util'
# include classes and helper
rules = require '../helper/rules'


# Setup
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


# Exported Methods
# -------------------------------------------------

# Describe schema definition, human readable.
#
# @param {function(Error, String)} cb callback to be called if done with possible error
# and the resulting text
exports.describe = (cb) ->
  text = 'A valid IP address as string. '
  text += rules.optional.describe.call this
  text = text.replace /\. It's/, ' which is'
  if @schema.version
    if @schema.version is 'ipv4'
      text += "Only IPv4 addresses are valid. "
    else
      text += "Only IPv6 addresses are valid. "
    if @schema.ipv4Mapping
      text += "IPv4 addresses may be automatically converted. "
  if @schema.deny
    text += "The IP address should not be in the ranges: '#{@schema.deny.join '\', \''}'. "
    if @schema.allow
      text += "But IP address in the ranges: '#{@schema.allow.join '\', \''}' are allowed. "
  else if @schema.allow
    text += "The IP address have to be in the ranges: '#{@schema.allow.join '\', \''}'. "
  switch @schema.format
    when 'short'
      text += 'An IPv6 address will be compressed as possible. '
    when 'long'
      text += 'An IPv6 address will be normalized with all octets visible. '
  cb null, text

# Check value against schema.
#
# @param {function(Error)} cb callback to be called if done with possible error
exports.check = (cb) ->
  # base checks
  skip = rules.optional.check.call this
  return cb skip if skip instanceof Error
  return cb() if skip
  # validate
  try
    ip = ipaddr.parse @value
  catch error
    return @sendError "The given value is no valid IP address", cb if error
  # check type of ip
  if @schema.version
    if @schema.version is 'ipv4'
      if ip.kind() is 'ipv6'
        if ip.isIPv4MappedAddress() and @schema.ipv4Mapping
          @debug "#{@name}: convert to ipv4"
          ip = ip.toIPv4Address()
        else
          return @sendError "The given value is no valid IPv#{@schema.version} address", cb
    else
      if ip.kind() is 'ipv4'
        unless @schema.ipv4Mapping
          return @sendError "The given value is no valid IPv#{@schema.version} address", cb
        @debug "#{@name}: convert to ipv4mapped"
        ip = ip.toIPv4MappedAddress()
  @value = if ip.kind() is 'ipv6'
    if @schema.format is 'long'
      ip.toNormalizedString()
    else
      ip.toString()
  else
    ip.toString()
  # check ranges
  if @schema.allow
    for entry in @schema.allow
      if specialRanges[entry]?
        for subentry in specialRanges[entry]
          [addr, bits] = subentry.split /\//
          if ip.match ipaddr.parse(addr), bits
            return @sendSuccess cb
      else
        [addr, bits] = entry.split /\//
        if ip.match ipaddr.parse(addr), bits
          return @sendSuccess cb
    # ip not in the allowed range
    unless @schema.deny
      return @sendError "The given ip address is not in the allowed ranges", cb
  if @schema.deny
    for entry in @schema.deny
      if specialRanges[entry]?
        for subentry in specialRanges[entry]
          [addr, bits] = subentry.split /\//
          if ip.match ipaddr.parse(addr), bits
            return @sendError "The given ip address is
              denied because in range #{entry}", cb
      else
        [addr, bits] = entry.split /\//
        if ip.match ipaddr.parse(addr), bits
          return @sendError "The given ip address is
            denied because in range #{entry}", cb
  # ip also not in the denied range so allowed again
  # done return resulting value
  @sendSuccess cb

# ### Selfcheck Schema
#
# Schema for selfchecking of this type
exports.selfcheck =
  title: "IP Address"
  description: "an ip address schema definition"
  type: 'object'
  allowedKeys: true
  keys: util.extend
    default:
      title: "Default Value"
      description: "the default value to use if nothing given"
      type: 'string'
      match: ///
        ^
        # ipv6 mask
        (
          # 1:2:3:4:5:6:7:8
          ([0-9a-fA-F]{1,4}:){7,7}[0-9a-fA-F]{1,4}
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
        )
        # ipv4 address
        |(
          ((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}
          (25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])
        )
        $
      ///
      optional: true
    version:
      title: "IP Type"
      description: "the ip address version to use. "
      type: 'string'
      values: ['ipv4', 'ipv6']
      optional: true
    ipv4Mapping:
      title: "Map IPv4 to IPv6"
      description: "the default value to use if nothing given"
      type: 'boolean'
      optional: true
    deny:
      title: "Deny Addresses"
      description: "a list of addresses or ranges to deny"
      type: 'array'
      optional: true
      entries:
        title: "Deny Address"
        description: "the address or range to deny"
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
      title: "Allow Addresses"
      description: "a list of addresses or ranges to allow"
      type: 'array'
      optional: true
      entries:
        title: "Allow Address"
        description: "the address or range to allow"
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
      title: "Format"
      description: "the display format tu use"
      type: 'string'
      default: 'short'
      values: ['short', 'long']
  , rules.baseSchema
