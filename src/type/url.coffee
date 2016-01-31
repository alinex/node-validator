# URL validation
# =================================================

# Check options:
#
# - `toAbsoluteBase` - convert to absolute with given base
# - `removeQuery` - (boolean) remove query and hash from url
# - `hostsAllowed` - list of allowed hosts by string or regexp
# - `hostsDenied` - list of denied hosts by string or regexp
# - `allowProtocols` - lust of allowed protocols
# - `allowRelative` - (boolean) to allow also relative urls


# Node modules
# -------------------------------------------------
debug = require('debug')('validator:url')
util = require 'util'
chalk = require 'chalk'
url = require 'url'
# alinex modules
object = require('alinex-util').object
# include classes and helper
check = require '../check'


# Type implementation
# -------------------------------------------------
exports.describe = (work, cb) ->
  text = 'A valid url (unified resource locator). '
  text += check.optional.describe work
  text = text.replace /\. It's/, ' which is'
  if work.pos.toAbsoluteBase
    text += "It will be made absolute from '#{work.pos.toAbsoluteBase}'. "
  if work.pos.removeQuery
    text += "Existing query parameters are removed. "
  if work.pos.hostsAllowed
    text += "Only the hosts matching #{work.pos.hostsAllowed} are allowed. "
  if work.pos.hostsDenied
    text += "But hosts matching #{work.pos.hostsAllowed} are not allowed. "
  if work.pos.allowProtocols
    text += "The protocol have to be: #{work.pos.allowProtocols}. "
  unless work.pos.allowRelative
    text += "Relative URLs are also allowed. "
  cb null, text

exports.run = (work, cb) ->
  debug "#{work.debug} with #{util.inspect work.value} as #{work.pos.type}"
  debug "#{work.debug} #{chalk.grey util.inspect work.pos}"
  # base checks
  try
    if check.optional.run work
      debug "#{work.debug} result #{util.inspect work.value ? null}"
      return cb()
  catch err
    return work.report err, cb
  # split into parts
  value = work.value
  unless typeof work.value is 'string'
    return work.report (new Error "The url has to be a string object."), cb
  if work.pos.toAbsoluteBase
    value = url.resolve work.pos.toAbsoluteBase, value
  parts = url.parse value
  if work.pos.removeQuery
    delete parts.search
    delete parts.hash
  # check the hostname
  if parts.host
    delete parts.host
    if work.pos.hostsAllowed
      success = true
      work.pos.hostsAllowed = [work.pos.hostsAllowed] unless Array.isArray work.pos.hostsAllowed
      for match in work.pos.hostsAllowed
        if match instanceof RegExp
          success = success and parts.hostname.match match
        else
          success = success and ~parts.hostname.indexOf match
      unless success
        return work.report (new Error "The hostname '#{parts.hostname}' should match
        against '#{work.pos.hostsAllowed}'"), cb
    if work.pos.hostsDenied
      success = true
      work.pos.hostsDenied = [work.pos.hostsDenied] unless Array.isArray work.pos.hostsDenied
      for match in work.pos.hostsDenied
        if match instanceof RegExp
          success = success and not parts.hostname.match match
        else
          success = success and not ~parts.hostname.indexOf match
      unless success
        return work.report (new Error "The hostname '#{parts.hostname}' should not match
        against '#{work.pos.hostsDenied}'"), cb
  # check allowed protocols
  if work.pos.allowProtocols
    unless parts.protocol
      return work.report (new Error "The protocol is missing."), cb
    unless parts.protocol.replace(/:/, '') in work.pos.allowProtocols
      return work.report (new Error "The protocol #{parts.protocol} is not allowed."), cb
  unless work.pos.allowRelative or parts.hostname
    return work.report (new Error "Relative URLs are not allowed."), cb
  value = url.format parts
  return cb null, value

exports.selfcheck = (schema, cb) ->
  check.run
    schema:
      type: 'object'
      allowedKeys: true
      keys: object.extend {}, check.base,
        default:
          type: 'url'
          optional: true
        toAbsoluteBase:
          type: 'url'
          optional: true
        removeQuery:
          type: 'boolean'
          optional: true
        hostsAllowed:
          type: 'or'
          optional: true
          or: [
            type: 'string'
          ,
            type: 'regexp'
          ]
        hostsDenied:
          type: 'or'
          optional: true
          or: [
            type: 'string'
          ,
            type: 'regexp'
          ]
        allowProtocols:
          type: 'array'
          toArray: true
          optional: true
        allowRelative:
          type: 'boolean'
          optional: true
    value: schema
  , cb
