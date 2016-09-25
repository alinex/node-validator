###
Or
=================================================
Collection of types combined with logical or.


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
  text = "It has to be one of the following types: "
  text += rules.optional.describe.call this
  text = text.replace /: It's/, ' (optional):'
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
