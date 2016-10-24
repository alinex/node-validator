###
Controller - API Usage
=================================================
To make all checks and also I/O specific optimizations available these checks
are primarily asynchronous. While there are also synchronous variants available
to the outside for simplicity better use the asynchronous ones because the other
uses more cpu performance.
###


# Node modules
# -------------------------------------------------
debug = require('debug')('validator')
chalk = require 'chalk'
deasync = require 'deasync'
# alinex packages
util = require 'alinex-util'
# internal classes and helper
Worker = require './helper/worker'


# External Methods
# -------------------------------------------------

###
This will directly return the description of how the value has to be.

``` coffee
validator.describe
  name: 'test'        # name to be displayed in errors (optional)
  schema:             # definition of checks
    type: 'integer'
, (err, text) ->
  return cb err if err
  console.log "Configuration:\n" + text
```

See the possibilities in [schema definition](helper/index.md).

@param {Object} spec specification for validation
- `name` - `String` descriptive name of the data
- `schema` - `Object` structure to check
- `context` - `Object` additional data structure
@param {function(Error, String)} cb callback with descriptive text or an error if
something went wrong
@see {@link describeSync}
###
exports.describe = (spec, cb) ->
  # check the given data
  throw new Error "No callback method given" unless typeof cb is 'function'
  return cb new Error "No schema definition given" unless spec.schema
  # optimize data
  name = spec.name ? 'value'
  schema = util.clone spec.schema
  schema.title ?= "#{util.string.ucFirst name} Data"
  debug "#{name} initialize to describe #{schema.title}" if debug.enabled
  # instantiate new object
  worker = new Worker name, schema, spec.context
  # run the check
  worker.describe (err, text) ->
    debug "#{name}: failed with: #{err.message}" if err and debug.enabled
    cb err, text

###
This will directly return the description of how the value has to be.

``` coffee
schema = validator.describeSync
  name: 'test'        # name to be displayed in errors (optional)
  schema:             # definition of checks
    type: 'integer'
```

See the possibilities in [schema definition](helper/index.md).
@name describeSync()
@param {Object} spec specification for validation
- `name` - `String` descriptive name of the data
- `schema` - `Object` structure to check
- `context` - `Object` additional data structure
@return {String} descriptive text
@throw {Error} if something went wrong
@see {@link describe}
###
exports.describeSync = deasync exports.describe

###
This will check the given value, sanitize it and return the new value or an
Error to the callback.

``` coffee
validator.check
  name: 'test'        # name to be displayed in errors (optional)
  value: input        # value to check
  schema:             # definition of checks
    type: 'integer'
  context: null       # additional data (optional)
, (err, result) ->
  # do something
```

See the possibilities in [schema definition](helper/index.md).

@param {Object} spec specification for validation
- `name` - `String` descriptive name of the data
- `schema` - `Object` structure to check
- `context` - `Object` additional data structure
- `value` - original value (not changed)
@param {function(Error, Mixed)} cb callback with optimized value or an error if
something is wrong with the value as far as possible to sanitize
###
exports.check = (spec, cb) ->
  # check the given data
  throw new Error "No callback method given" unless typeof cb is 'function'
  return cb new Error "No schema definition given" unless spec.schema
  # optimize data
  name = spec.name ? 'value'
  schema = util.clone spec.schema
  schema.title ?= "#{util.string.ucFirst name} Data"
  value = util.clone spec.value
  # check schema on debug
  if debug.enabled and not spec.selfcheck
    try
      debug chalk.grey "#{name} check schema"
      exports.selfcheckSync schema
    catch error
      debug chalk.magenta "#{name} schema not valid: #{error.message}"
  # instantiate new object
  debug "#{name} initialize to check as #{schema.title}" if debug.enabled
  worker = new Worker name, schema, spec.context, value
  # run the check
  worker.check (err) ->
    if debug.enabled
      debug if err
        "#{name}: failed with: #{err.message}"
      else
        "#{name}: succeeded"
    cb err, worker.value

###
This will check the given value, sanitize it and return the new value or an
Error to the callback.

``` coffee
input = validator.checkSync
  name: 'test'        # name to be displayed in errors (optional)
  value: input        # value to check
  schema:             # definition of checks
    type: 'integer'
  context: null       # additional data (optional)
```

See the possibilities in [schema definition](helper/index.md).

@name checkSync()
@param {Object} spec specification for validation
- `name` - `String` descriptive name of the data
- `schema` - `Object` structure to check
- `context` - `Object` additional data structure
- `value` - original value (not changed)
@return {String} optimized value
@throw {Error} if something went wrong
###
exports.checkSync = deasync exports.check

###
The method will check and optimize the schema definition.
This is neccessary to evaluate higher class definitions. But it may
also be used in tests to check the validator check options if they are valid.

``` coffee
validator.selfcheck
  type: 'integer'     # definition of checks
, (err, schema) ->
  # do something with optimized schema
```

See the possibilities in [schema definition](helper/index.md).

@param {Object} schema structure to check
@param {function(Error, Mixed)} cb callback with the checked schema or an error if
something is wrong
###
exports.selfcheck = (schema, cb) ->
  exports.check
    name: 'schema'
    schema: Worker.load(schema.type).selfcheck
    value: schema
    selfcheck: true
  , cb

###
This may be used in tests to check the validator check options if they are valid.

``` coffee
try
  schema = validator.selfcheckSync
    type: 'integer'     # definition of checks
catch error
  # something in schema is not allowed
```

See the possibilities in [schema definition](helper/index.md).

@name selfcheckSync()
@param {Object} schema structure to check
@return {String} checked schema
@throw {Error} if something went wrong
###
exports.selfcheckSync = deasync exports.selfcheck
