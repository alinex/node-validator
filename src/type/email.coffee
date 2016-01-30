# Email validation
# =================================================
# There are a lot of crazy possibilities in the RFC2822 which  specifies the Email
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
async = require 'alinex-async'
# include classes and helper
check = require '../check'

# Subchecks
# -------------------------------------------------
subcheck =
  type: 'string'
  minLength: 5

# Host specific normalization
# -------------------------------------------------
normalize = (host) ->
  return switch
    when host.match /^g(oogle)?mail\.com$/i
      (local) ->
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
      value = "#{local}@#{host}"
      return cb null, value unless work.pos.checkServer
      return cb null, value if host is 'localhost'
      # check server
      getMyIP (err, ip) ->
        if err
          debug chalk.magenta "could not detect own ip address"
          return cb null, value
        # find mx records
        dns = require 'dns'
        dns.resolveMx host, (err, addresses) ->
          checkMailServer addresses, ip, (ok) ->
            return cb null, value if ok
            # find a-record
            dns.resolve host, (err, addresses) ->
              checkMailServer addresses, ip, (ok) ->
                return cb null, value if ok
                return work.report (new Error "No correct responding mail server
                could be detected for this domain."), cb

# Schema check
# -------------------------------------------------
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
        checkServer:
          type: 'boolean'
          optional: true
    value: schema
  , cb


# Helper
# -------------------------------------------------
# ### get own IP
# for later mail server checks
myIP = null
getMyIP = (cb) ->
  return cb myIP if myIP
  request = require 'request'
  request 'http://ipinfo.io/ip', (err, response, body) ->
    return cb err if err
    if not err and response.statusCode is 200
      cb null, body.trim()
    else
      cb new Error 'could not get IP address'

# ### contact the server
checkMailServer = (list, ip, cb) ->
  return cb false unless list?.length
  net = require 'net'
  # check email exchange server
  list = list.sort (a, b) -> a.priority - b.priority
  .map (e) -> e.exchange
  async.detect list, (domain, cb) ->
    debug chalk.grey "check mail server under #{domain}"
    res = ''
    client = net.connect
      port: 25
      host: domain
    , ->
      client.write "HELO #{ip}\r\n"
      client.end()
    client.on 'data', (data) ->
      res += data.toString()
    client.on 'error', (err) ->
      debug chalk.magenta err
    client.on 'end', ->
      debug chalk.grey l for l in res.split /\n/
      cb res?.length > 0
  , cb
