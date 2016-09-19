###
Object
=================================================
An complex object.

Sanitize options:
- `flatten` - flatten hierarchical values

Check options:
- `instanceOf` - only objects of given class type are allowed
- `mandatoryKeys` - the list of elements which are mandatory
- `allowedKeys` - gives a list of elements which are also allowed
  or true to use the list from entries definition

Validating children:
- `entries` - specification for entries


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
Worker = require '../helper/worker'


# Exported Methods
# -------------------------------------------------

# Describe schema definition, human readable.
#
# @param {function(Error, String)} cb callback to be called if done with possible error
# and the resulting text
exports.describe = (cb) ->
  # combine into message
  text = 'An object. '
  text += rules.optional.describe.call this
  text = text.replace /\. It's/, ' which is'
  # flat
  if @schema.flatten
    text += "Hierarchical paths will be flattened together. "
  # instanceof
  if @schema.instanceOf?
    text += "The object has to be an instance of class #{@schema.instanceOf.name}. "
  text = text.replace /object\. The object/, 'object which'
  # mandatoryKeys
  mandatoryKeys = @schema.mandatoryKeys ? []
  if mandatoryKeys and typeof mandatoryKeys is 'boolean'
    # use from entries and keys
    mandatoryKeys = []
    if @schema.keys?
      mandatoryKeys = mandatoryKeys.concat Object.keys @schema.keys
    if @schema.entries?
      for entry in @schema.entries
        mandatoryKeys.push entry.key if entry.key?
  if mandatoryKeys.length
    text += "The following keys have to be present: #{mandatoryKeys.join ', '}. "
  # allowedKeys
  allowedKeys = @schema.allowedKeys ? []
  if allowedKeys and typeof allowedKeys is 'boolean'
    # use from entries and keys
    allowedKeys = []
    if @schema.keys?
      allowedKeys = allowedKeys.concat Object.keys @schema.keys
    if @schema.entries?
      for entry in @schema.entries
        allowedKeys.push entry.key if entry.key
  if allowedKeys.length
    # remove the already mandatory ones
    list = allowedKeys.filter (e) -> not (e in mandatoryKeys)
    if list.length
      text += "And the following keys are allowed: #{list.join ', '}. "
  # subchecks
  async.parallel [
    (cb) =>
      # help for specific key names
      return cb() unless @schema.keys?
      detail = "The following entries have a specific format: "
      async.map Object.keys(@schema.keys), (key, cb) =>
        # subchecks with new sub worker
        worker = new Worker "#{@name}.#{key}", @schema.keys[key], @context
        worker.describe (err, subtext) ->
          return cb err if err
          cb null, "\n- #{key}: #{subtext.replace /\n/g, '\n  '}"
      , (err, results) ->
        return cb err if err
        cb null, detail + results.join('') + '\n'
    (cb) =>
      # help for pattern matched key names
      return cb() unless @schema.entries?
      detail = "And all other keys which are: "
      async.map [0..@schema.entries.length-1], (num, cb) =>
        rule = @schema.entries[num]
        if rule.key?
          ruletext = "\n- matching #{rule.key}: "
        else
          ruletext = "\n- other keys: "
        # subchecks with new sub worker
        worker = new Worker "#{@name}##{num}", @schema.entries[num], @context
        worker.describe (err, subtext) ->
          return cb err if err
          cb null, ruletext + subtext.replace /\n/g, '\n  '
      , (err, results) ->
        return cb err if err
        cb null, detail + results.join('') + '\n'
  ], (err, results) ->
    return cb err if err
    cb null, (text + results.join '').trim() + ' '

# Check value against schema.
#
# @param {function(Error)} cb callback to be called if done with possible error
exports.check = (cb) ->
  # base checks
  skip = rules.optional.check.call this
  return cb skip if skip instanceof Error
  return cb() if skip
  # flatten
  if @schema.flatten
    @value = flatten @value
  # instanceof
  if @schema.instanceOf?
    unless @value instanceof @schema.instanceOf
      return @sendError "An object of #{@schema.instanceOf.name} is needed as value", cb
  # is object
  if typeof @value isnt 'object' or Array.isArray @value
    return @sendError "The value has to be an object", cb
  # check object keys
  usedKeys = Object.keys @value
  mandatoryKeys = @schema.mandatoryKeys ? []
  if typeof mandatoryKeys is 'boolean'
    # use from entries and keys
    mandatoryKeys = []
    if @schema.keys?
      mandatoryKeys = mandatoryKeys.concat Object.keys @schema.keys
    if @schema.entries?
      for entry in @schema.entries
        mandatoryKeys.push entry.key if entry.key?
  allowedKeys = @schema.allowedKeys ? []
  if typeof allowedKeys is 'boolean'
    # use from entries and keys
    allowedKeys = []
    if @schema.keys?
      allowedKeys = allowedKeys.concat Object.keys @schema.keys
    if @schema.entries?
      for entry in @schema.entries
        allowedKeys.push entry.key if entry.key
  keys = util.array.unique usedKeys.concat mandatoryKeys, allowedKeys
  # values
  async.each keys, (key, cb) =>
    return cb() if key instanceof RegExp # skip expressions here
    # get subcheck with new sub worker
    if @schema.keys?[key]? and typeof @schema.keys[key] is 'object'
      # defined directly with key
      worker = new Worker "#{@name}.#{key}", @schema.keys[key], @context, @value[key]
    else if @schema.entries?
      for rule, i in @schema.entries
        if rule.key?
          # defined with wntries match
          continue unless key.match rule.key
          worker = new Worker "#{@name}#entries-#{i}.#{key}", @schema.entries[i],
          @context, @value[key]
          break
        else
          # defined with general rule
          worker = new Worker "#{@name}#entries-#{i}.#{key}", @schema.entries[i],
          @context, @value[key]
    # undefined
    unless worker
      worker = new Worker "#{@name}#.#{key}",
        type: switch
          when Array.isArray @value[key]
            'array'
          when typeof @value[key] is 'object'
            'object'
          else
            'any'
        optional: true
      , @context, @value[key]
    # run the check on the named entry
    async.setImmediate =>
      worker.check (err) =>
        return cb err if err
        if worker.value
          @value[key] = worker.value
        else
          delete @value[key]
        cb()
  , (err) =>
    return cb err if err
    # check mandatoryKeys
    for mandatory in mandatoryKeys
      if mandatory instanceof RegExp
        fail = true
        for key of @value
          if key.match mandatory
            fail = false
            break
        if fail
          return @sendError "The mandatory key '#{key}' is missing", cb
      else
        unless @value[mandatory]? or @schema.keys?[mandatory]?.optional
          return @sendError "The mandatory key '#{mandatory}' is missing", cb
    # check allowedKeys
    if allowedKeys.length
      for key of @value
        isAllowed = false
        for allow in allowedKeys
          if key is allow or (allow instanceof RegExp and key.match allow)
            isAllowed = true
            break
        unless isAllowed
          for allow in mandatoryKeys
            if key is allow or (allow instanceof RegExp and key.match allow)
              isAllowed = true
              break
        unless isAllowed
          return @sendError "The key '#{key}' is not allowed", cb
    # done return resulting value
    @sendSuccess cb

# ### Selfcheck Schema
#
# Schema for selfchecking of this type
exports.selfcheck =
  title: "Object"
  description: "the object schema definitions"
  type: 'object'
  allowedKeys: true
  keys: util.extend
    default:
      title: "Default Value"
      description: "the default value to use if nothing given"
      type: 'object'
      optional: true
    flatten:
      title: "Flatten"
      description: "a flag to flatten the object structure"
      type: 'boolean'
      optional: true
    instanceOf:
      title: "Class Check"
      description: "the class, the object have to be instantiated from"
      type: 'function'
      optional: true
    mandatoryKeys:
      title: "Mandatory Keys"
      description: "the definition of mandatory keys"
      type: 'or'
      optional: true
      or: [
        title: "All Mandatory"
        description: "the value `true` marks all schema defined keys mandatory"
        type: 'boolean'
      ,
        title: "Mandatory List"
        description: "the list of mandatory keys"
        type: 'array'
        entries:
          title: "Mandatory Key"
          description: "the key which have to be present"
          type: 'or'
          or: [
            title: "Key Name"
            description: "the name of the mandatory key"
            type: 'string'
          ,
            title: "Key Map"
            description: "a RegExp to detect mandatory keys to which at least one should match"
            type: 'regexp'
          ]
      ]
    allowedKeys:
      title: "Allowed Keys"
      description: "the definition of allowed keys"
      type: 'or'
      optional: true
      or: [
        title: "No more Allowed"
        description: "the value `true` marks only the schema defined keys as allowed"
        type: 'boolean'
      ,
        title: "Allowed List"
        description: "the list of allowed keys"
        type: 'array'
        entries:
          title: "Allowed Key"
          description: "the key which may be present"
          type: 'or'
          or: [
            title: "Key Name"
            description: "the name of the allowed key"
            type: 'string'
          ,
            title: "Key Map"
            description: "a RegExp to detect allowed keys to which should match"
            type: 'regexp'
          ]
      ]
    entries:
      title: "Entries"
      description: "an alternative definition of key's types without the name"
      type: 'array'
      mandatoryKeys: ['type']
      optional: true
    keys:
      title: "Keys"
      description: "the definition of each key's types"
      type: 'object'
      mandatoryKeys: ['type']
      optional: true
  , rules.baseSchema


# Helper
# -------------------------------------------------

# Flatten object structure into single depth.
#
# @param {Object} obj instance to be flattened
flatten = (obj) ->
  n = {}
  for k, v of obj
    return obj unless typeof v is 'object'
    for j, w of v
      return obj unless typeof w is 'object'
    v = flatten v
    n["#{k}-#{j}"] = w for j, w of v
  n
