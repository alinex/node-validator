###
Reference Resolving
=================================================
This methods will be called to support references in schema definition and
values.
###


# Node Modules
# -------------------------------------------------
debug = require('debug')('validator:reference')
chalk = require 'chalk'
async = require 'async'

# exists
# value

# object
# objectClone


# Setup
# -------------------------------------------------
# MAXRETRY defines the time to wait till the references should be solved
MAXRETRY = 10000 # waiting for 10 seconds at max
TIMEOUT = 10 # checking every 10ms

# defines specific type handler for some protocols
protocolMap =
  http: 'web'
  https: 'web'

# to ensure security a reference can only call references with lower precedence
typePrecedence =
  env: 5
  struct: 4
  context: 3
  file: 2
  cmd: 2
  web: 1

# External Methods
# -------------------------------------------------

# Check if there are references in the object.
exists = exports.exists = (value) ->
  return false unless typeof value is 'string'
  Boolean value.match /<<<[^]*>>>/
