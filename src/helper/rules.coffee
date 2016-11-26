# General rules
# =================================================


# Node modules
# -------------------------------------------------
chalk = require 'chalk'
util = require 'alinex-util'


# General checks
# -------------------------------------------------

# Optional and default checks
exports.optional =

  # #3 optional.describe()
  #
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
      return "It's optional and will be set to `#{value}` if not specified. "
    else
      return "It's optional. "

  # #3 optional.check()
  #
  # Check if value is optional or use default.
  #
  # @return [Boolean] `true` if further check may be skipped (cause of allowed empty value)
  # @throw {Error} if value is not correct
  check: ->
    # check for value
    return false if @value? # go on if value given
    if @schema.default? # use default and go on
      @value = @schema.default
      @debug chalk.grey "#{@name}: use default #{@inspectValue()}" if @debug.enabled
      return false
    if @schema.optional # end this test without value
      delete @value
      @debug chalk.grey "#{@name}: result #{@inspectValue()}" if @debug.enabled
      return true
    @sendError "A value is needed", (err) ->
      err

# Selfcheck schema for base options.
# These are common for all types and are added into the selfcheck schema for each
# individual check.
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
