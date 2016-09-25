###
And
=================================================
Collection of types combined with logical and.

This checks will be done in series to allow each one to possibly change the value
and give it on.


Schema Specification
---------------------------------------------------
{@schema #selfcheck}
###


# Node Modules
# -------------------------------------------------
async = require 'async'
# alinex modules
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
  text = "All of the following checks have to succeed:"
  text += rules.optional.describe.call this
  text = text.replace /\. It's/, ' which is'
  # check all possibilities
  async.map [0..@schema.and.length-1], (num, cb) =>
    # subchecks with new sub worker
    worker = @sub "#{@name}##{num}", @schema.and[num]
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
  async.eachSeries [0..@schema.and.length-1], (num, cb) =>
    # subchecks with new sub worker
    worker = @sub "#{@name}##{num}", @schema.and[num], @value
    worker.check (err) =>
      return cb err if err
      @value = worker.value
      cb()
  , (err) =>
    return cb err if err
    @sendSuccess cb

# ### Selfcheck Schema
#
# Schema for selfchecking of this type
exports.selfcheck =
  title: "And"
  description: "multiple schema definitions"
  type: 'object'
  allowedKeys: true
  keys: util.extend
    and:
      type: 'array'
      entries:
        type: 'object'
        mandatoryKeys: ['type']
  , rules.baseSchema,
    default:
      title: "Default Value"
      description: "the default value to use if nothing given"
      type: 'any'
      optional: true
