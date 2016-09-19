# General rules
# =================================================


# Node modules
# -------------------------------------------------
chalk = require 'chalk'
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
      @debug chalk.grey "#{@name}: use default #{@inspectValue()}"
      return false
    if @schema.optional # end this test without value
      delete @value
      @debug chalk.grey "#{@name}: result #{@inspectValue()}"
      return true
    @sendError "A value is needed", (err) ->
      err

# ### selfcheck schema for base options
# These are common for all types.
exports.baseSchema =
  title:
    title: "Title"
    description: "the title used to describe the element"
    type: 'string'
    optional: true
  description:
    title: "Description"
    description: "the free description of the element"
    type: 'string'
    optional: true
  key:
    title: "Binding to Keyname"
    description: "the mapping to which key names in an object this element belongs"
    type: 'regexp'
    optional: true
  type:
    title: "Type"
    description: "the type of element"
    type: 'string'
  optional:
    title: "Optional"
    description: "a flag defining if this element is optional"
    type: 'boolean'
    optional: true
