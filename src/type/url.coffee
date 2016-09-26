###
URL
=================================================
Checking text for a valid URL.

Sanitize options:
- `toAbsoluteBase` - `String` convert to absolute with given base
- `removeQuery` - `Boolean` remove query and hash from url

Check options:
- `hostsAllowed` - `String|RegExp` list of allowed hosts by string or regexp
- `hostsDenied` - `String|RegExp` list of denied hosts by string or regexp
- `allowProtocols` - `Array` lust of allowed protocols
- `allowRelative` - `Boolean` to allow also relative urls


Schema Specification
---------------------------------------------------
{@schema #selfcheck}
###


# Node Modules
# -------------------------------------------------
url = require 'url'
util = require 'alinex-util'
# include classes and helper
rules = require '../helper/rules'


# Exported Methods
# -------------------------------------------------

# Describe schema definition, human readable.
#
# @param {function(Error, String)} cb callback to be called if done with possible error
# and the resulting text
exports.describe = (cb) ->
  text = 'A valid url (unified resource locator). '
  text += rules.optional.describe.call this
  text = text.replace /\. It's/, ' which is'
  if @schema.toAbsoluteBase
    text += "It will be made absolute from '#{@schema.toAbsoluteBase}'. "
  if @schema.removeQuery
    text += "Existing query parameters are removed. "
  if @schema.hostsAllowed
    text += "Only the hosts matching #{@schema.hostsAllowed} are allowed. "
  if @schema.hostsDenied
    text += "But hosts matching #{@schema.hostsAllowed} are not allowed. "
  if @schema.allowProtocols
    text += "The protocol have to be: #{@schema.allowProtocols}. "
  unless @schema.allowRelative
    text += "Relative URLs are also allowed. "
  cb null, text

# Check value against schema.
#
# @param {function(Error)} cb callback to be called if done with possible error
exports.check = (cb) ->
  # base checks
  skip = rules.optional.check.call this
  return cb skip if skip instanceof Error
  return cb() if skip
  # first check input type
  unless typeof @value is 'string'
    return @sendError "The url has to be a string object but got #{typeof @value} instead", cb
  # transform
  if @schema.toAbsoluteBase
    @value = url.resolve @schema.toAbsoluteBase, @value
  parts = url.parse @value
  if @schema.removeQuery
    delete parts.search
    delete parts.hash
  # check the hostname
  if parts.host
    delete parts.host
    if @schema.hostsAllowed
      success = true
      @schema.hostsAllowed = [@schema.hostsAllowed] unless Array.isArray @schema.hostsAllowed
      for match in @schema.hostsAllowed
        if match instanceof RegExp
          success = success and parts.hostname.match match
        else
          success = success and ~parts.hostname.indexOf match
      unless success
        return @sendError "The hostname '#{parts.hostname}' should match against
        '#{@schema.hostsAllowed}'", cb
    if @schema.hostsDenied
      success = true
      @schema.hostsDenied = [@schema.hostsDenied] unless Array.isArray @schema.hostsDenied
      for match in @schema.hostsDenied
        if match instanceof RegExp
          success = success and not parts.hostname.match match
        else
          success = success and not ~parts.hostname.indexOf match
      unless success
        return @sendError "The hostname '#{parts.hostname}' should not match
        against '#{@schema.hostsDenied}'", cb
  # check allowed protocols
  if @schema.allowProtocols
    unless parts.protocol
      return @sendError "The protocol is missing", cb
    unless parts.protocol.replace(/:/, '') in @schema.allowProtocols
      return @sendError "The protocol #{parts.protocol} is not allowed, only
      #{@schema.allowProtocols}", cb
  unless @schema.allowRelative or parts.hostname
    return @sendError "Relative URLs are not allowed", cb
  @value = url.format parts
  # done checking and sanuitizing
  @sendSuccess cb

# ### Selfcheck Schema
#
# Schema for selfchecking of this type
exports.selfcheck =
  title: "URL"
  description: "an url schema definition"
  type: 'object'
  allowedKeys: true
  keys: util.extend
    toAbsoluteBase:
      title: "Absolute"
      description: "the base URL to make it absolute"
      type: 'url'
      optional: true
    removeQuery:
      title: "Remove Query"
      description: "a flag if set to `true` will remove the query string part"
      type: 'boolean'
      optional: true
    hostsAllowed:
      title: "Allowed Hosts"
      description: "the hosts allowed in the URL (white list)"
      type: 'or'
      optional: true
      or: [
        title: "Allowed Hosts List"
        description: "a list of all allowed hosts"
        type: 'array'
        toArray: true
        minLength: 1
        entries:
          title: "Allowed Host"
          description: "an allowed host name"
          type: 'hostname'
      ,
        title: "Valid Hosts Match"
        description: "a regular expression for valid hosts"
        type: 'regexp'
      ]
    hostsDenied:
      title: "Disallowed Hosts"
      description: "the hosts disallowed in the URL (black list)"
      type: 'or'
      optional: true
      or: [
        title: "Disallowed Hosts List"
        description: "a list of all disallowed hosts"
        type: 'array'
        toArray: true
        minLength: 1
        entries:
          title: "Disallowed Host"
          description: "a disallowed host name"
          type: 'hostname'
      ,
        title: "Invalid Hosts Match"
        description: "a regular expression for invalid hosts"
        type: 'regexp'
      ]
    allowProtocols:
      title: "Allowed Protocols"
      description: "a list of allowed protocols"
      type: 'array'
      toArray: true
      minLength: 1
      optional: true
    allowRelative:
      title: "Allow Relative URL"
      description: "a flag if set to `true` will also allow relative URLs"
      type: 'boolean'
      optional: true
  , rules.baseSchema,
    default:
      title: "Default Value"
      description: "the default value to use if nothing given"
      type: 'url'
      allowRelative: true
      optional: true
