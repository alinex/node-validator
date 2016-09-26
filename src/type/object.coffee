###
Object
=================================================
For all complex data structures you use the object type which checks for named
arrays or instance objects.

This is the most complex validation form because it has different checks and
uses subchecks on each entry.

Sanitize options:
- `flatten` - flatten hierarchical values

Check options:
- `instanceOf` - `Class` only objects of given class type are allowed
- `flatten` - `Boolean` flatten deep structures
- `mandatoryKeys` - `Àrray` the list of elements which are mandatory
- `allowedKeys` - `Array` gives a list of elements which are also allowed
  or true to use the list from entries definition

Validating children:
- `entries` - `Object` specification for entries
- `keys` - `Object` specification for all entries per each key name

So you have two different ways to specify objects. First you can use the `instanceOf`
check. Or specify a data object.

The `mandatoryKeys` and `allowedKeys` may both contain normal strings for complete
key names and also regular expressions to match multiple. In case of using it
in the mandatoryKeys field at least one matching key have to be present.
And as you may suspect the `mandatoryKeys` are automatically also `allowedKeys`.
If `mandatoryKeys` or `allowedKeys` are set to true instead of a list all of the
specified keys in entries or keys are meant.

The `keys` specify the subcheck for each containing object attribute. If they are
not optional or contain a default entry they will be seen also as mandatory field.

The `entries` list do the same as the `keys` section but works using key matching
on multiple entires. If an object attribute matches multiple entries-rules the
first will be used.

__Examples:__

The follwoing will check for an instance:

``` coffee
validator.check
  name: 'test'        # name to be displayed in errors (optional)
  value: input        # value to check
  schema:             # definition of checks
    type: 'object'
    instanceOf: RegeExp
, (err, result) ->
  # do something
```

Or you may specify the data object structure:

``` coffee
validator.check
  name: 'test'        # name to be displayed in errors (optional)
  value: input        # value to check
  schema:             # definition of checks
    type: 'object'
    mandatoryKeys: ['name']
    allowedKeys: ['mail', 'phone']
    entries: [
      type: 'string'
    ]
, (err, result) ->
  # do something
```

Here all object values have to be strings.

``` coffee
validator.check
  name: 'test'        # name to be displayed in errors (optional)
  value: input        # value to check
  schema:             # definition of checks
    type: 'object'
    mandatoryKeys: ['name']
    entries: [
      key: /^num-\d+/
      type: 'integer'
    ,
      type: 'string'
    ]
, (err, result) ->
  # do something
```

And here the keys matching the key-check (starting with 'num-...') have to be
integers and all other strings.

If you don't specify `allowedKeys` more attributes with other names are possible.

And the most complex situation is a deep checking structure with checking each
key for its specifics:

``` coffee
validator.check
  name: 'test'        # name to be displayed in errors (optional)
  value: input        # value to check
  schema:             # definition of checks
    type: 'object'
    allowedKeys: true
    keys:
      name:
        type: 'string'
      mail:
        type: 'string'
        optional: true
      phone:
        type: 'string'
        optional: true
, (err, result) ->
  # do something
```

Here `allowedKeys` will check that no attributes are used which are not specified
in the entries. Which attribute is optional may be specified within the attributes
specification. That means this check is the same as above but also checks that the
three attributes are strings.

If you specify `entries` and `keys`, the entries check will only be used as default
for all keys which has no own specification.

Another option is to flatten the structure before checking it:

``` coffee
# value to check
input =
  first:
    num: { one: 1, two: 2 }
  second:
    num: { one: 1, two: 2 }
    name: { anna: 1, berta: 2 }
# run the validation
validator.check
  name: 'test'        # name to be displayed in errors (optional)
  value: input        # value to check
  schema:             # definition of checks
    type: 'object'
    flatten: true
, (err, result) ->
  # do something
```

This will give you the following result:

``` coffee
result =
  'first-num': { one: 1, two: 2 }
  'second-num': { one: 1, two: 2 }
  'second-name': { anna: 1, berta: 2 }
```


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
  text = 'An object. '
  text += rules.optional.describe.call this
  text = text.replace /\. It's/, ' which is'
  # flat
  if @schema.flatten
    text += "Hierarchical paths will be flattened together. "
  # instanceof
  if @schema.instanceOf?
    text += "The object has to be an instance of class `#{@schema.instanceOf.name}`. "
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
    text += "The following keys have to be present: `#{mandatoryKeys.join '`, `'}`. "
    text = text.replace /object\. The following/, ' object with the following'
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
      text += "The following keys are allowed: `#{list.join '`, `'}`. "
      text = text.replace /object\. The following keys are/, ' object with the following keys'
  # subchecks
  async.parallel [
    (cb) =>
      # help for specific key names
      return cb() unless @schema.keys?
      detail = "The following entries have a specific format:"
      async.map Object.keys(@schema.keys), (key, cb) =>
        # subchecks with new sub worker
        worker = @sub "#{@name}.#{key}", @schema.keys[key]
        worker.describe (err, subtext) ->
          return cb err if err
          cb null, "\n\n`#{key}`\n:   #{subtext.replace /\n/g, '\n    '}"
      , (err, results) ->
        return cb err if err
        cb null, detail + results.join('') + '\n'
    (cb) =>
      # help for pattern matched key names
      return cb() unless @schema.entries?
      if @schema.keys
        detail = "And all other keys have to be: "
      else
        detail = "The entries have to be: "
      async.map [0..@schema.entries.length-1], (num, cb) =>
        rule = @schema.entries[num]
        if rule.key?
          ruletext = "\n- matching #{rule.key}: "
        else
          ruletext = "\n- other keys: "
        # subchecks with new sub worker
        worker = @sub "#{@name}##{num}", @schema.entries[num]
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
      worker = @sub "#{@name}.#{key}", @schema.keys[key], @value[key]
    else if @schema.entries?
      for rule, i in @schema.entries
        if rule.key?
          # defined with wntries match
          continue unless key.match rule.key
          worker = @sub "#{@name}#entries-#{i}.#{key}", @schema.entries[i], @value[key]
          break
        else
          # defined with general rule
          worker = @sub "#{@name}#entries-#{i}.#{key}", @schema.entries[i], @value[key]
    # undefined
    unless worker
      worker = @sub "#{@name}#.#{key}",
        type: switch
          when Array.isArray @value[key]
            'array'
          when typeof @value[key] is 'object'
            'object'
          else
            'any'
        optional: true
      , @value[key]
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
    flatten:
      title: "Flatten"
      description: "a flag to flatten the object structure"
      type: 'boolean'
      optional: true
    instanceOf:
      title: "Class Check"
      description: "the class, the object to be instantiated from"
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
          description: "the key which to be present"
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
      optional: true
  , rules.baseSchema,
    default:
      title: "Default Value"
      description: "the default value to use if nothing given"
      type: 'object'
      optional: true


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
