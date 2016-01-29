# Email validation
# =================================================
# There are a lot of crazy üossibilities in the RFC2822 which  specifies the Email
# format. Perhaps it came from letting different existing email systems represented
# their account, to encompass anything that was valid before.
#
# So this check will not aim to allow all emails allowed through RFC but only
# those which are reasonable and commonly used.

# Check options:
#
# - `lowerCase` domain and gmail addresses completely
# - `normalize` (boolean) remove tags, alternative domains and subdomains
# - `checkServer` (boolean) also check for working email servers

# Node modules
# -------------------------------------------------
debug = require('debug')('validator:email')
util = require 'util'
chalk = require 'chalk'
# alinex modules
object = require('alinex-util').object
# include classes and helper
check = require '../check'

subcheck =
  type: 'string'
  minLength: 5

normalize = (host) ->
  return switch
    when host.match /^g(oogle)?mail\.com$/i
      (local, host) ->
        [local.replace(/\.|\+.*$/g, ''), 'gmail.com']
    else
      (local, host) ->
        [local.replace(/\+.*$/g, ''), host.replace(/.*?(\w+\.\w+)$/, '$1')]

# Type implementation
# -------------------------------------------------
exports.describe = (work, cb) ->
  text = 'A reasonable working email address. '
  text += check.optional.describe work
  text = text.replace /\. It's/, ' which is'
  # subcheck
  name = work.spec.name ? 'value'
  if work.path.length
    name += "/#{work.path.join '/'}"
  subcheck.lowerCase = work.pos.lowerCase
  # no error in string describe possible, so go on
  if work.pos.lowerCase
    text += "It will be lowercased. "
  if work.pos.normalize
    text += "Extended formats like additional domains, subdomains and tags which
    mostly belong to the same mailbox will be removed. "
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
  # validate using subcheck
  name = work.spec.name ? 'value'
  if work.path.length
    name += "/#{work.path.join '/'}"
  subcheck.lowerCase = work.pos.lowerCase
  check.run
    name: name
    value: work.value
    schema: subcheck
  , (err, value) ->
    return cb err if err
    # validate
    [local, host] = parts = value.split /@/
    if parts.length isnt 2
      return work.report (new Error "The address is not a valid format, too few or
      much @-signs."), cb
    if local.length > 64
      return work.report (new Error "The local mailbox name is too long (64 chars max)."), cb
    # check hostname
    check.run
      name: name + ':host'
      value: host
      schema:
        type: 'hostname'
    , (err, host) ->
      return cb err if err
      # normalize
      [local, host] = normalize(host) local, host
      # done everything ok
      cb null, "#{local}@#{host}"

      # don't check for localhost
      # find mx records
      #functions.getMxRecord(hostname).then ((mxRecords) ->
      # check email exchange server
      #functions.checkMailExchanger(mxRecord, options.externalIpAddress).then((data) ->
      # find a record
      #return functions.checkEmailExchangerForARecord(hostname, options)

exports.selfcheck = (schema, cb) ->
  check.run
    schema:
      type: 'object'
      allowedKeys: true
      keys: object.extend {}, check.base,
        default: subcheck
        lowerCase:
          type: 'boolean'
          optional: true
        normalize:
          type: 'boolean'
          optional: true
    value: schema
  , cb
