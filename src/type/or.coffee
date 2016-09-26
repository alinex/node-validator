###
Or
=================================================
This is used to give some alternatives from which at least one check have to
succeed. The first one succeeding will work.

__Option:__

- `or` - (array) with different check alternatives

__Example:__

You may allow numeric and special format input:

``` coffee
validator.check
  name: 'test'        # name to be displayed in errors (optional)
  value: input        # value to check
  schema:             # definition of checks
    type: 'or'
    or: [
      type: 'float'
    ,
      type: 'string'
      match: ///
        ^\s*      # start with possible spaces
        [+-]?     # sign possible
        \s*\d+(\.\d*)? # float number
        \s*%?     # percent sign with spaces
        \s*$      # end of text with spaces
        ///
    ]
, (err, result) ->
  # do something
```

With this type you can also use different option alternatives:

``` coffee
validator.check
  name: 'test'        # name to be displayed in errors (optional)
  value: input        # value to check
  schema:             # definition of checks
    type: 'or'
    or: [
      type: 'object'
      allowedKeys: true
      keys:
        type:
          type: 'string'
          lowerCase: true
          values: ['mysql']
        port:
          type: 'integer'
          default: 3306
        # ...
    ,
      type: 'object'
      allowedKeys: true
      keys:
        type:
          type: 'string'
          lowerCase: true
          values: ['postgres']
        port:
          type: 'integer'
          default: 5432
        # ...
    ]
, (err, result) ->
  # do something
```

In the example above only the default port is changed, but you may also add different
options.


Schema Specification
---------------------------------------------------
{@schema #selfcheck}
###


# Node Modules
# -------------------------------------------------
async = require 'async'
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
  # combine into message
  text = "It has to be __one of__ the following types: "
  text += rules.optional.describe.call this
  text = text.replace /: It's optional./, ' (optional):'
  # check all possibilities
  async.map [0..@schema.or.length-1], (num, cb) =>
    # subchecks with new sub worker
    worker = @sub "#{@name}##{num}", @schema.or[num]
    worker.describe (err, subtext) ->
      return cb err if err
      cb null, "\n- #{subtext.replace /\n/g, '\n  '}"
  , (err, results) ->
    return cb err if err
    text += results.join('') + '\n'
    cb null, text

# Check value against schema.
#
# @param {function(Error)} cb callback to be called if done with possible error
exports.check = (cb) ->
  # base checks
  skip = rules.optional.check.call this
  return cb skip if skip instanceof Error
  return cb() if skip
  # run async checks
  error = []
  async.map [0..@schema.or.length-1], (num, cb) =>
    # subchecks with new sub worker
    worker = @sub "#{@name}##{num}", @schema.or[num], @value
    worker.check (err) ->
      if err
        error[num] = err
        return cb()
      cb null, worker.value
  , (err, results) =>
    for result in results
      continue unless result?
      @value = result
      return @sendSuccess cb
    # check response
    @sendError "None of the alternatives are matched
    (#{error.map((e) -> e.message).join('/ ').trim()})", cb

# ### Selfcheck Schema
#
# Schema for selfchecking of this type
exports.selfcheck =
  title: "Or"
  description: "alternative schema definitions"
  type: 'object'
  allowedKeys: true
  keys: util.extend
    or:
      title: "Alternatives"
      description: "the list of alternatives for the value"
      type: 'array'
      list:
        title: "Alternative"
        description: "an alternative for the value"
        type: 'object'
        mandatoryKeys: ['type']
  , rules.baseSchema,
    default:
      title: "Default Value"
      description: "the default value to use if nothing given"
      type: 'any'
      optional: true
