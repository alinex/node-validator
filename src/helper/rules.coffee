# General rules
# =================================================


# Node modules
# -------------------------------------------------
debug = require('debug')('validator:rules')
chalk = require 'chalk'
async = require 'async'
# alinex packages
util = require 'alinex-util'
# internal classes and helper
reference = require './reference'


# ### Is value empty?
isEmpty = (value) ->
  return true unless value?
#  switch
#    when Array.isArray value
#      if value.length is 0
#        return true
#    when typeof value is 'object'
#      if value.constructor.name is 'Object' and Object.keys(value).length is 0
#        return true
  false


# General checks
# -------------------------------------------------

# ### Optional and default checks
exports.optional =
  describe: (work) ->
    unless work.pos.optional or work.pos.default?
      return ''
    if work.pos.default
      value = if work.pos.default instanceof Function
        '[function]'
      else
        util.inspect work.pos.default
      return "It's optional and will be set to #{value}
      if not specified. "
    else
      return "It's optional."

  # Check if value is optional or use default.
  #
  # @param {function(Error, Boolean)} give error if value is not correct or `true`
  # as result if further check may be skipped (cause of allowed empty value)
  check: (cb) ->
    # check for value
    return cb null, false unless isEmpty @value # go on if value given
    if @schema.default? # use default and go on
      @value = @schema.default
      debug chalk.grey "#{@name}: use default #{@inspectValue()}"
      return cb null, false
    if @schema.optional # end this test without value
      delete @value
      debug chalk.grey "#{@name}: result #{@inspectValue()}"
      return cb null, true
    cb new Error "A value is needed"

  run: (work) ->
    # check for value
    return false unless isEmpty work.value # go on if value given
    if work.pos.default? # use default and go on
      work.value = work.pos.default
      return false
    return true if work.pos.optional # end this test without value
    throw new Error "A value is needed"

# ### selfcheck schema for base options
exports.base =
  title:
    type: 'string'
    optional: true
  description:
    type: 'string'
    optional: true
  key:
    type: 'regexp'
    optional: true
  type:
    type: 'string'
  optional:
    type: 'boolean'
    optional: true
