###
Array
=================================================
A list of something.

Sanitize options:
- `delimiter` - allow value text with specified list separator
 (it can also be an regular expression)

Check options:
- `notEmpty` - set to true if an empty array is not valid
- `minLength` - minimum number of entries
- `maxLength` - maximum number of entries
- `toArray` - convert scalar values into array

Validating children:
- `entries` - specification for all entries or as array for each element

Formatting options:
- `format` - one of 'simple', 'pretty', 'json'


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
Worker = require '../helper/worker'


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
    text += "The number of entries have to be between #{@schema.minLength}
      and #{@schema.maxLength}. "
  else if @schema.minLength?
    text += "At least #{@schema.minLength} elements should be given. "
  else if @schema.maxLength?
    text += "Not more than #{@schema.maxLength} elements are allowed. "
  # subchecks
  async.parallel [
    (cb) ->
      return cb() unless @schema.list?
      detail = "The following entries have a specific format:"
      max = @schema.list.length - 1
      async.map [0..max], (num, cb) ->
        # subchecks with new sub worker
        worker = new Worker "#{@name}#{num}", @schema.list[num], @context, @dir
        worker.describe (err, subtext) ->
          return cb err if err
          cb null, "\n- #{num}: #{subtext.replace /\n/g, '\n  '}"
      , (err, results) ->
        return cb err if err
        cb null, detail + results.join('') + '\n'
    (cb) ->
      return cb() unless @schema.entries?
      detail = "And all other entries have to be:\n- "
      # subchecks with new sub worker
      worker = new Worker "#{@name}#entries", @schema.entries, @context, @dir
      worker.describe (err, subtext) ->
        return cb err if err
        cb null, detail + "\nEntries should be: " + subtext
  ], (err, results) ->
    return cb err if err
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
  if typeof value is 'string' and @schema.delimiter?
    del = string.toRegExp @schema.delimiter
    debug "#{work.debug} use delimiter #{typeof del} #{util.inspect del}"
    work.value = value = value.split del
  if @schema.toArray and not Array.isArray value
    work.value = value = [value]
  # is array
  unless Array.isArray value
    return work.report (new Error "The value has to be an array"), cb
  if @schema.unique
    value = array.unique value
  # not empty
  if @schema.notEmpty and value.length is 0
    return work.report (new Error "An empty array/list is not allowed"), cb
  # min/macLength
  if @schema.minLength? and @schema.minLength is @schema.maxLength and (
    value.length isnt @schema.minLength)
    return work.report (new Error "Exactly #{@schema.minLength} entries are required"), cb
  else if @schema.minLength? and @schema.minLength > value.length
    return work.report (new Error "At least #{@schema.minLength} entries are required as list"), cb
  else if @schema.maxLength? and @schema.maxLength < value.length
    return work.report (new Error "Not more than #{@schema.maxLength} entries
    are allowed as list"), cb
  # values
  unless value.length
    # done return resulting value
    debug "#{work.debug} result #{util.inspect value ? null}"
    return cb null, value
  max = value.length - 1
  async.map [0..max], (num, cb) ->
    # find sub-check
    if @schema.list?[num]?
      sub = work.goInto ['list', num], [num]
    else if @schema.entries?
      sub = work.goInto ['entries'], [num]
    else
      name = work.spec.name ? 'value'
      path = work.path.concat num
      name += "/#{path.join '/'}"
      sub = work.goInto null, [num]
      sub.spec.schema =
        type: switch
          when Array.isArray value[num]
            'array'
          when typeof value[num] is 'object'
            'object'
          else
            'any'
        optional: true
      sub.path = []
      sub.pos = sub.spec.schema
    async.setImmediate ->
      check.run sub, cb
  , (err, value) ->
    return cb err if err
    # format value
    if @schema.format
      switch @schema.format
        when 'simple'
          value = value.join ', '
        when 'pretty'
          value = value.map((e) -> util.inspect e).join ', '
        when 'json'
          value = JSON.stringify value
    # done return resulting value
    debug "#{work.debug} result #{util.inspect value ? null}"
    cb null, value

exports.selfcheck = (schema, cb) ->
  check.run
    schema:
      type: 'object'
      allowedKeys: true
      keys: util.extend util.clone(check.base),
        default:
          type: 'array'
          optional: true
        delimiter:
          type: 'or'
          optional: true
          or: [
            type: 'string'
          ,
            type: 'object'
            instanceOf: RegExp
          ]
        toArray:
          type: 'boolean'
          optional: true
        unique:
          type: 'boolean'
          optional: true
        notEmpty:
          type: 'boolean'
          optional: true
        minLength:
          type: 'integer'
          optional: true
          min: 0
        maxLength:
          type: 'integer'
          optional: true
          min: '<<<minLength>>>'
        list:
          type: 'or'
          optional: true
          or: [
            type: 'object'
          ,
            type: 'array'
          ]
        entries:
          type: 'any'
          optional: true
        format:
          type: 'string'
          values: ['simple', 'pretty', 'json']
    value: schema
  , cb
