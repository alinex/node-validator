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

  # Describe the optional setting human readable.
  #
  # @return {String} the result text
  describe: ->
    unless @schema.optional or @schema.default?
      return ''
    if @schema.default
      value = if @schema.default instanceof Function
        '[function]'
      else
        util.inspect @schema.default
      return "It's optional and will be set to #{value} if not specified. "
    else
      return "It's optional."

  # Check if value is optional or use default.
  #
  # @return [Boolean] `true` if further check may be skipped (cause of allowed empty value)
  # @throw {Error} if value is not correct
  check: ->
    # check for value
    return false unless isEmpty @value # go on if value given
    if @schema.default? # use default and go on
      @value = @schema.default
      debug chalk.grey "#{@name}: use default #{@inspectValue()}"
      return false
    if @schema.optional # end this test without value
      delete @value
      debug chalk.grey "#{@name}: result #{@inspectValue()}"
      return true
    new Error "A value is needed"




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
