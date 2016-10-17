###
Array
=================================================
A list of something.

Sanitize options:
- `delimiter` - allow value text with specified list separator
 (it can also be an regular expression)

__Check options:__
- `notEmpty` - set to true if an empty array is not valid
- `minLength` - minimum number of entries
- `maxLength` - maximum number of entries
- `toArray` - convert scalar values into array

__Validating children:__
- `entries` - specification for all entries or as array for each element

__Formatting options:__
- `format` - one of 'simple', 'pretty', 'json'

      data = [1, 2, 3, 'a', {b: 1}, ['c', 9]]
      # simple -> "1, 2, 3, a, [object Object], c,9"
      # pretty -> "1, 2, 3, 'a', { b: 1 }, [ 'c', 9 ]"
      # json -> '[1,2,3,"a",{"b":1},["c",9]]'


Schema Specification
---------------------------------------------------
{@schema #selfcheck}
###


# Node Modules
# -------------------------------------------------
async = require 'async'
# alinex modules
util = require 'alinex-util'
{string, array} = util
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
  text = 'A list. '
  text += rules.optional.describe.call this
  text = text.replace /\. It's/, ' which is'
  if @schema.notEmpty
    text += "It's not allowed to be empty. "
  if @schema.delimiter?
    text += "You may also give a text or RegExp using '#{@schema.delimiter}'
      as separator for the individual entries. "
  if @schema.unique?
    text += "All values have to be unique. "
  if @schema.minLength? and @schema.maxLength?
    if @schema.minLength is @schema.maxLength
      text += "The number of entries have to be exactly #{@schema.minLength} elements. "
    else
      text += "The number of entries have to be between #{@schema.minLength}
        and #{@schema.maxLength} elements. "
  else if @schema.minLength?
    text += "At least #{@schema.minLength} elements should be given. "
  else if @schema.maxLength?
    text += "Not more than #{@schema.maxLength} elements are allowed. "
  # subchecks
  async.parallel [
    (cb) =>
      return cb() unless @schema.list?
      detail = "The following entries have a specific format: "
      max = @schema.list.length - 1
      async.map [0..max], (num, cb) =>
        # subchecks with new sub worker
        worker = @sub "#{@name}.#{num}", @schema.list[num]
        worker.describe (err, subtext) ->
          return cb err if err
          cb null, "\n- #{num}: #{subtext.replace /\n/g, '\n  '}"
      , (err, results) ->
        return cb err if err
        cb null, detail + results.join('') + '\n'
    (cb) =>
      return cb() unless @schema.entries?
      if @schema.list
        detail = "And all other entries have to be of type:\n> "
      else
        detail = "Each entry has to be of type:\n> "
      # subchecks with new sub worker
      worker = @sub "#{@name}#entries", @schema.entries
      worker.describe (err, subtext) ->
        return cb err if err
        cb null, detail + subtext.replace /\n/g, '\n> '
  ], (err, results) =>
    return cb err if err
    text = text.replace /A list\. Each entry have to be/, 'A list with each entry as'
    text = (text + results.join '').trim() + ' '
    if @schema.format?
      text += "The value will be formatted as #{@schema.format} list. "
    cb null, text

# Check value against schema.
#
# @param {function(Error)} cb callback to be called if done with possible error
exports.check = (cb) ->
  # base checks
  skip = rules.optional.check.call this
  return cb skip if skip instanceof Error
  return cb() if skip
  # string to array
  if typeof @value is 'string' and @schema.delimiter?
    del = string.toRegExp @schema.delimiter
    @debug "#{@name}: use delimiter #{typeof del} #{util.inspect del}" if @debug.enabled
    @value = @value.split del
  if @schema.toArray and not Array.isArray @value
    @value = [@value]
  # is array
  unless Array.isArray @value
    return @sendError "The value has to be an array", cb
  if @schema.unique
    @value = array.unique @value
  # not empty
  if @schema.notEmpty and @value.length is 0
    return @sendError "An empty array/list is not allowed", cb
  # min/macLength
  if @schema.minLength? and @schema.minLength is @schema.maxLength and (
    @value.length isnt @schema.minLength)
    return @sendError "Exactly #{@schema.minLength} entries are required", cb
  else if @schema.minLength? and @schema.minLength > @value.length
    return @sendError "At least #{@schema.minLength} entries are required as list", cb
  else if @schema.maxLength? and @schema.maxLength < @value.length
    return @sendError "Not more than #{@schema.maxLength} entries
    are allowed as list", cb
  # values
  unless @value.length
    # done return resulting value
    return @sendSuccess cb
  async.map [0..@value.length-1], (num, cb) =>
    # find sub-check
    if @schema.list?[num]?
      worker = @sub "#{@name}.#{num}", @schema.list[num], @value[num]
    else if @schema.entries?
      worker = @sub "#{@name}#entries.#{num}", @schema.entries, @value[num]
    else
      worker = @sub "#{@name}#.#{num}",
        type: switch
          when Array.isArray @value[num]
            'array'
          when typeof @value[num] is 'object'
            'object'
          else
            'any'
        optional: true
      , @value[num]
    # run the check on the named entry
    async.setImmediate ->
      worker.check (err) ->
        cb err, worker.value
  , (err, result) =>
    return cb err if err
    @value = result
    # format value
    if @schema.format
      switch @schema.format
        when 'simple'
          @value = @value.join ', '
        when 'pretty'
          @value = @value.map((e) -> util.inspect e).join ', '
        when 'json'
          @value = JSON.stringify @value
    # done return resulting value
    @sendSuccess cb

# ### Selfcheck Schema
#
# Schema for selfchecking of this type
exports.selfcheck =
  title: "Array"
  description: "the array schema definitions"
  type: 'object'
  allowedKeys: true
  keys: util.extend
    delimiter:
      title: "Delimiter"
      description: "the delimiter to split given string into list"
      type: 'or'
      optional: true
      or: [
        title: "Characters"
        description: "the characters to be used as explicit delimiter"
        type: 'string'
      ,
        title: "RegExp"
        description: "the expression to split into list"
        type: 'object'
        instanceOf: RegExp
      ]
    toArray:
      title: "To Array"
      description: "a flag to automatically pack other data into an array"
      type: 'boolean'
      optional: true
    unique:
      title: "Unique"
      description: "a flag to remove duplicate entries in list"
      type: 'boolean'
      optional: true
    notEmpty:
      title: "Not Empty"
      description: "a flag to not allow an empty list"
      type: 'boolean'
      optional: true
    minLength:
      title: "Minimum"
      description: "the minimum number of elements in list"
      type: 'integer'
      optional: true
      min: 0
    maxLength:
      title: "Maximum"
      description: "the maximum number of elements in list"
      type: 'integer'
      optional: true
      min: '<<<minLength>>>'
    list:
      title: "Specific Formats"
      description: "the schema for each element"
      type: 'array'
      optional: true
      entries:
        title: "Element Format"
        description: "the schema definition for a specific element"
        type: 'object'
        mandatoryKeys: ['type']
    entries:
      title: "Element Format"
      description: "the general schema definition for the entries"
      type: 'object'
      mandatoryKeys: ['type']
      optional: true
    format:
      title: "Format"
      description: "the type of output format to use"
      type: 'string'
      values: ['simple', 'pretty', 'json']
      optional: true
  , rules.baseSchema,
    default:
      title: "Default Value"
      description: "the default value to use if nothing given"
      type: 'array'
      optional: true
