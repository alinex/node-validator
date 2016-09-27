###
Email
=================================================
There are a lot of crazy possibilities in the [RFC2822](https://www.ietf.org/rfc/rfc2822.txt)
which  specifies the Email format. Perhaps it came from letting different existing
email systems represented their account, to encompass anything that was valid before.

So this check will not aim to allow all emails allowed through RFC but only
those which are reasonable and commonly used.

__Sanitize options:__
- `lowerCase` domain and gmail addresses completely
- `normalize` `Boolean` remove tags, alternative domains and subdomains

__Check options:__
- `checkServer` - `Boolean` also check for working email servers
- `denyBlacklisted` - `Boolean` deny all mail servers which are currently blacklisted
- `denyGraylistes` - `Boolean` deny all mail servers which are on the untrusted lists (graylists)


Schema Specification
---------------------------------------------------
{@schema #selfcheck}
###


# Node Modules
# -------------------------------------------------
async = require 'async'
chalk = require 'chalk'
fs = require 'fs'
util = require 'alinex-util'
dns = null # load on demand
request = null # load on demand
format = null # load on demand
# include classes and helper
rules = require '../helper/rules'
dnsbl = # loaded on demand
dnsgl = # loaded on demand


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
  if @schema.blacklisted
    text += "Don't allow mail servers which are one one of the public blacklists. "
  if @schema.untrusted
    text += "Deny all mail servers which are marked as untrusted and often used for spam. "
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
  if @schema.lowerCase
    @value = @value.toLowerCase()
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
  worker = @sub "#{@name}#hostname",
    type: 'hostname'
  , host
  worker.check (err) =>
    return cb err if err
    @value = "#{local}@#{host}"
    # done everything ok
    return @sendSuccess cb unless @schema.checkServer
    return @sendSuccess cb if host is 'localhost'
    # check server
    getMyIP (err, ip) =>
      if err
        @debug chalk.magenta "#{@name}: could not detect own ip address"
        return @sendSuccess cb
      # find mx records
      dns ?= require 'dns'
      dns.resolveMx host, (err, list) =>
#        checkMailServer.call this, addresses, ip, (ok) =>
#          return @sendSuccess cb if ok
#          # find a-record
#          dns.resolve host, (err, addresses) =>
#
#            ], (err)
#            checkMailServer.call this, addresses, ip, (ok) =>
#              return @sendSuccess cb if ok
#              @sendError "No correct responding mail server
#              could be detected for this domain", cb
        # check each server entry
        unless list?
          return @sendError "Could not find nameserver entry for mail server", cb
        list = list.sort (a, b) -> a.priority - b.priority
        .map (e) -> e.exchange
        async.parallel [
          # check for existing mailserver
          (cb) => checkMailServer.call this, list, ip, cb
          # check for blacklisted
          (cb) => checkBlacklisted.call this, list, ip, cb
          # check for untrusted
          (cb) => checkGraylistes.call this, list, ip, cb
        ], (err) =>
          return @sendError err.message, cb if err
          @sendSuccess cb


# ### Selfcheck Schema
#
# Schema for selfchecking of this type
exports.selfcheck =
  title: "Email"
  description: "an email schema definition"
  type: 'object'
  allowedKeys: true
  keys: util.extend
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
    denyBlacklisted:
      title: "Deny Blacklisted Server"
      description: "a flag to deny all mail addresses of servers which are currently on
      any blacklist"
      type: 'boolean'
      optional: true
    denyGraylistes:
      title: "Deny Graylistes Server"
      description: "a flag to deny also mail addresses of untrusted servers which users
      are unverified"
      type: 'boolean'
      optional: true
  , rules.baseSchema,
    default:
      title: "Default Value"
      description: "the default value to use if nothing given"
      type: 'string'
      minLength: 5
      optional: true


# Helper
# -------------------------------------------------

# @param {String} host hostname to normalize
# @return {Function(local, host)} which will normalize local and host part of address
normalize = (host) ->
  return switch
    when host.match /^g(oogle)?mail\.com$/i
      (local) ->
        [local.replace(/\.|\+.*$/g, ''), 'gmail.com']
    else
      (local, host) ->
        [local.replace(/\+.*$/g, ''), host.toLowerCase()]
        #.replace(/.*?(\w+\.\w+)$/, '$1')]

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
  unless list?.length
    return cb new Error "No correct responding mail server could be detected for this domain"
  net = require 'net'
  async.detect list, (domain, cb) =>
    @debug chalk.grey "#{@name}: check mail server under #{domain}"
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
  , (err, res) ->
    return cb() if res
    cb new Error "No correct responding mail server could be detected for this domain"

checkBlacklisted = (list, ip, cb) ->
  return cb() unless @schema.denyBlacklisted
  loadDnsbl (err) =>
    return cb err if err
    async.each list, (host, cb) =>
      @debug chalk.gray "#{@name}: check #{host} in blacklists"
      dns.resolve host, (err, addresses) =>
        if err
          @debug chalk.magenta err.message
          return cb()
        # each address
        async.each addresses, (address, cb) ->
          # reverse ip
          reverse = address.split '.'
          .reverse()
          .join '.'
          # each list entry
          async.each dnsbl, (bl, cb) ->
            # dns lookup
            dns.resolve "#{reverse}.#{bl.zone}", (err) ->
              return cb() if err
              cb new Error "Server #{host} (#{address}) is found on #{bl.name} list
              check at #{bl.url}"
          , cb
        , cb
    , cb

checkGraylistes = (list, ip, cb) ->
  return cb() unless @schema.denyGraylisted
  loadDnsgl (err) =>
    return cb err if err
    async.each list, (host, cb) =>
      @debug chalk.gray "#{@name}: check #{host} in graylists"
      dns.resolve host, (err, addresses) =>
        if err
          @debug chalk.magenta err.message
          return cb()
        # each address
        async.each addresses, (address, cb) ->
          # reverse ip
          reverse = address.split '.'
          .reverse()
          .join '.'
          # each list entry
          async.each dnsgl, (bl, cb) ->
            # dns lookup
            dns.resolve "#{reverse}.#{bl.zone}", (err) ->
              return cb() if err
              cb new Error "Server #{host} (#{address}) is found on #{bl.name} list
              check at #{bl.url}"
          , cb
        , cb
    , cb

loadDnsbl = (cb) ->
  return cb() if dnsbl
  # load blacklist
  format ?= require 'alinex-format'
  fs.readFile "#{__dirname}/data/blacklists.yaml", 'UTF8', (err, content) ->
    return cb err if err
    format.parse content, 'yaml', (err, data) ->
      return cb err if err
      v.name = k for k, v of data
      dnsbl = data
      cb()

loadDnsgl = (cb) ->
  return cb() if dnsgl
  # load blacklist
  format ?= require 'alinex-format'
  fs.readFile "#{__dirname}/data/graylists.yaml", 'UTF8', (err, content) ->
    return cb err if err
    format.parse content, 'yaml', (err, data) ->
      return cb err if err
      v.name = k for k, v of data
      dnsgl = data
      cb()
