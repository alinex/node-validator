###
Email
=================================================
There are a lot of crazy possibilities in the RFC2822 which  specifies the Email
format. Perhaps it came from letting different existing email systems represented
their account, to encompass anything that was valid before.

So this check will not aim to allow all emails allowed through RFC but only
those which are reasonable and commonly used.

Check options:
- `lowerCase` domain and gmail addresses completely
- `normalize` `Boolean` remove tags, alternative domains and subdomains
- `checkServer` `Boolean` also check for working email servers


Schema Specification
---------------------------------------------------
{@schema #selfcheck}
###


# Node Modules
# -------------------------------------------------
async = require 'async'
chalk = require 'chalk'
dns = null # load on demand
request = null # load on demand
util = require 'alinex-util'
# include classes and helper
rules = require '../helper/rules'
Worker = require '../helper/worker'


# Exported Methods
# -------------------------------------------------

# Describe schema definition, human readable.
#
# @param {function(Error, String)} cb callback to be called if done with possible error
# and the resulting text
exports.describe = (cb) ->
  text = 'A reasonable working email address. '
  text += rules.optional.describe.call this
  text = text.replace /\. It's/, ' which is'
  # no error in string describe possible, so go on
  if @schema.lowerCase
    text += "It will be lowercased. "
  if @schema.normalize
    text += "Extended formats like additional domains, subdomains and tags which
    mostly belong to the same mailbox will be removed. "
  cb null, text

# Check value against schema.
#
# @param {function(Error)} cb callback to be called if done with possible error
exports.check = (cb) ->
  # base checks
  skip = rules.optional.check.call this
  return cb skip if skip instanceof Error
  return cb() if skip
  # check value
  unless typeof @value is 'string'
    return @sendError "A string is needed but got #{typeof @value} instead", cb
  # string length
  if @value.length < 5
    return @sendError "The given string '#{@value}' is too short at least
    5 characters are needed", cb
  # validate parts
  [local, host] = parts = @value.split /@/
  if parts.length isnt 2
    return @sendError "The address is not a valid format, too few or much @-signs", cb
  if local.length > 64
    return @sendError "The local mailbox name is too long (64 chars max)", cb
  # normalize hostname
  if @schema.normalize
    [local, host] = normalize(host) local, host
  # check hostname
  worker = new Worker "#{@name}#hostname",
    type: 'hostname'
  , @context, @value
  worker.check (err) =>
    return cb err if err
    # done everything ok
    @value = "#{local}@#{host}"
    return @sendSuccess cb unless @schema.checkServer
    return @sendSuccess cb if host is 'localhost'
    # check server
    getMyIP (err, ip) =>
      if err
        @debug chalk.magenta "#{@name}: could not detect own ip address"
        return @sendSuccess cb
      # find mx records
      dns ?= require 'dns'
      dns.resolveMx host, (err, addresses) =>
        checkMailServer.call this, addresses, ip, (ok) =>
          return @sendSuccess cb if ok
          # find a-record
          dns.resolve host, (err, addresses) =>
            checkMailServer.call this, addresses, ip, (ok) =>
              return @sendSuccess cb if ok
              @sendError "No correct responding mail server
              could be detected for this domain", cb

# ### Selfcheck Schema
#
# Schema for selfchecking of this type
exports.selfcheck =
  title: "Email"
  description: "an email schema definition"
  type: 'object'
  allowedKeys: true
  keys: util.extend rules.baseSchema,
    default:
      title: "Default Value"
      description: "the default value to use if nothing given"
      type: 'string'
      minLength: 5
    lowerCase:
      title: "Lower Case"
      description: "a flag to transform to lower case letters"
      type: 'boolean'
      optional: true
    normalize:
      title: "Normalize"
      description: "a flag to normalize some common email address variants to their base"
      type: 'boolean'
      optional: true
    checkServer:
      title: "Check Server"
      description: "a flag to also check the MX record of the destination host if possible"
      type: 'boolean'
      optional: true


# Helper
# -------------------------------------------------

myIP = null # for later mail server checks

# Get local ip address if not already done
# @param {Function(Error, String)} cb callback giving the resulting host IP
getMyIP = (cb) ->
  return cb null, myIP if myIP
  request ?= require 'request'
  request 'http://ipinfo.io/ip', (err, response, body) ->
    return cb err if err
    if not err and response.statusCode is 200
      cb null, body.trim()
    else
      cb new Error 'could not get IP address'

# @param {Array<Object>} list ns records
# @param {String} ip local ip address
# @param {Function(Boolean)} cb callback with `true` if server has a ns record
checkMailServer = (list, ip, cb) ->
  return cb false unless list?.length
  net = require 'net'
  # check email exchange server
  list = list.sort (a, b) -> a.priority - b.priority
  .map (e) -> e.exchange
  async.detect list, (domain, cb) =>
    @debug chalk.grey "#{name}: check mail server under #{domain}"
    res = ''
    client = net.connect
      port: 25
      host: domain
    , ->
      client.write "HELO #{ip}\r\n"
      client.end()
    client.on 'data', (data) ->
      res += data.toString()
    client.on 'error', (err) =>
      @debug chalk.magenta err
    client.on 'end', =>
      @debug chalk.grey l for l in res.split /\n/
      cb null, res?.length > 0
  , (err, res) -> cb res

# @param {String} host hostname to normalize
# @return {Function(local, host)} which will normalize local and host part of address
normalize = (host) ->
  return switch
    when host.match /^g(oogle)?mail\.com$/i
      (local) ->
        [local.replace(/\.|\+.*$/g, ''), 'gmail.com']
    else
      (local, host) ->
        [local.replace(/\+.*$/g, ''), host.replace(/.*?(\w+\.\w+)$/, '$1')]
