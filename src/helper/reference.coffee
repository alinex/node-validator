###
References
=================================================
References point to values which are used instead. You can use references
within the structure data which is checked and also within the check conditions.
Not everything is possible, but a lot - see below.


Syntax
--------------------------------------------------
The syntax looks easy but has a lot of variations and possibilities.

    <<<source://path>>>
    <<<source://path | source://path | default>>>
    <<<source://path#{type:"integer"} | source://path | default>>>

Within the curly braces the source from which to retrieve the value is given.
The source is given in form of an URI.
Like you see in line two you may use multiple fallback URIs and also a default
value at last.
And at last in the third line you see how to add a special check condition
after an URI. If this fails the next URI is checked.

The path may also have different possibilities based on the `source` protocol
type.


Combine
--------------------------------------------------
You may also combine the resulting value(s) of the reference(s) into one
string:

    <<<host>>>:<<<port>>>

This will result in `localhost:8080` as example.

###


# Node Modules
# -------------------------------------------------
debug = require('debug')('validator:reference')
chalk = require 'chalk'
async = require 'async'
fspath = require 'path'
request = null # load on demand
exec = null # load on demand
vm = null # load on demand
# alinex modules
util = require 'alinex-util'
fs = null # load on demand
format = null # load on demand
# local helper
Worker = null # load later because of circular references

# Setup
# -------------------------------------------------
# MAXRETRY defines the time to wait till the references should be solved
TIMEOUT = 100 # checking every 10ms
MAXRETRY = 10 # waiting for 1 second at max

# defines specific type handler for some protocols
protocolMap =
  http: 'web'
  https: 'web'

# to ensure security a reference can only call references with lower precedence
typePrecedence =
  env: 5
  struct: 4
  context: 3
  file: 2
  cmd: 2
  web: 1


# External Methods
# -------------------------------------------------
# This methods will be called to support references in schema definition and
# values from the Worker instance.

# Check if there are references in the value or object's direct properties.
#
# @param {String} value to check for references
# @return {Boolean} `true` if a reference exists
exists = exports.exists = (value) ->
  # normal checking in string
  return false unless typeof value is 'string'
  Boolean value.match /<<<[^]*>>>/

# Check if there are references in the value or object's direct properties.
#
# @param {Array|Object} value to check for references
# @return {Boolean} `true` if a reference exists
existsObject = exports.existsObject = (value) ->
  # checking in arrays
  if Array.isArray value
    for e in value
      return true if typeof e is 'string' and e.match /<<<[^]*>>>/
    return false
  # checking in objects
  if typeof value is 'object'
    for _, e of value
      return true if typeof e is 'string' and e.match /<<<[^]*>>>/
    return false
  # normal checking in string
  return false unless typeof value is 'string'
  Boolean value.match /<<<[^]*>>>/

# Wait till reference is resolved.
#
# @param {Worker} worker to check value for references
# @param {Function(Error)} cb callback if reference is resolved or error if neither
exports.existsWait = (worker, cb) ->
  async.retry
    times: MAXRETRY
    interval: TIMEOUT
  , (cb) ->
    return cb() unless exists worker.value
    cb new Error "Reference #{worker.value} can not be resolved"
  , cb

# Replace references with there referenced values.
#
# @param {String|Array|Object} value to replaces references within
# @param {Worker} worker the current worker with
# - `path` position in structure where value comes from
# - `root.value` complete value object
# - `context` context additional object
# @param {Function(Error, value)} cb callback which is called with resulting value
# @param {Boolean} clone should the object be cloned instead of changed
exports.replace = (value, worker, cb, clone = false) ->
  return cb null, value unless existsObject value
  # for arrays and objects
  if typeof value is 'object'
    copy = if clone
      if Array.isArray value then [] else {}
    else value
    async.eachOf value, (e, k, cb) ->
      copy[k] ?= e # reference element if cloned
      return cb() unless existsObject e
      multiple e, "#{worker.path}/#{k}", worker.root, (err, result) ->
        return cb err if err
        copy[k] = result
        cb()
    , (err) ->
      return cb err if err
      cb null, copy
  # for strings
  else multiple value, worker.path, worker.root, cb


# Helper Methods
# -------------------------------------------------

# Replace multiple references in text entry.
#
# @param {String} value to replace references
# @param {String} path position in structure where value comes from
# @param {Worker} worker the root worker with
# - `value` complete value object
# - `context` context additional object
# - `checked` the list of validated entries
# @param {Function(Error, value)} cb callback which is called with resulting value
multiple = (value, path, worker, cb) ->
  path = path[1..] if path[0] is '/'
  debug "/#{path} replace #{util.inspect value}..." if debug.enabled
  list = value.split /(<<<[^]*?>>>)/
  list = [list[1]] if list.length is 3 and list[0] is '' and list[2] is ''
  # step over multiple references
  async.map list, (v, cb) ->
    return cb null, v unless ~v.indexOf '<<<' # no reference
    v = v[3..-4] # replace <<< and >>>
    alternatives v, path, worker, cb
  , (err, results) ->
    return cb err if err
    # reference only value
    if results.length is 1
      if debug.enabled
        debug "/#{path} #{util.inspect value} is replaced by #{util.inspect results[0]}"
      return cb null, results[0]
    # combine reference together
    result = results.join ''
    if debug.enabled
      debug "/#{path} #{util.inspect value} is replaced by #{util.inspect result}"
    cb null, result

# Resolve alternative sources which are separated by ` | ` and the first possible
# alternative should be used.
#
# @param {String} value to replace references
# @param {String} path position in structure where value comes from
# @param {Worker} worker the root worker with
# - `value` complete value object
# - `context` context additional object
# - `checked` the list of validated entries
# @param {Function(Error, value)} cb callback which is called with resulting value
alternatives = (value, path, worker, cb) ->
  if debug.enabled
    debug chalk.grey "/#{path} resolve #{util.inspect value}..."
  first = true
  async.map value.split(/\s+\|\s+/), (alt, cb) ->
    # automatically set first element to `struct` if no other protocol set
    alt = "struct://#{alt}" if first and not ~alt.indexOf '://'
    first = false
    # split uri into anchored separated paths
    list = util.string.rtrim alt, '#'
    .split /#/
    # return default value
    if list.length is 1 and not ~alt.indexOf '://'
      if debug.enabled
        debug chalk.grey "/#{path} #{alt} -> use as default value".replace /\n/, '\\n'
      return cb null, alt
    # read value from given uri parts
    read list, path, worker, (err, result) ->
      return cb err if err
      if debug.enabled
        debug chalk.grey "/#{path} #{alt} -> #{util.inspect result}".replace /\n/, '\\n'
      cb null, result
  , (err, results) ->
    return cb err if err
    # use first alternative
    for result in results
      return cb null, result if result?
    cb()

# This method is called with all the uri parts as value list and will search the
# real value of the first uri part, pass it on to the second search as data and so
# on. The result will be from the last uri path.
#
# @param {Array} list to replace references
# @param {String} path position in structure where value comes from
# @param {Worker} worker the root worker with
# - `value` complete value object
# - `context` context additional object
# - `checked` the list of validated entries
# @param {Function(Error, value)} cb callback which is called with resulting value
# @param {String} last type of handler used to get data element
# @param {Object} data resolved data from previous read
read = (list, path, worker, cb, last, data) ->
  # get type of uri part
  src = list.shift()
  return cb null, worker.value unless src # empty anchor return complete structure
  # detect protocol
  [proto, loc] = src.split /:\/\//
  loc ?= proto
  proto = switch proto[0]
    when '{' then 'check'
    when '%' then 'split'
    when '/' then 'match'
    when '$' then 'parse'
    else
      if src.match /^\d/ then 'range'
      else unless ~src.indexOf '://'  then 'object'
      else proto
  if proto is 'parse' and ~loc.indexOf '$join'
    proto = 'join'
  # return if not possible without data (incorrect use)
  if src[0..proto.length-1] isnt proto and not data?
    return cb new Error "Incorrect use of #{proto} without data from previous element"
  # add automatic conversion of data if needed
  switch
    when typeof data is 'string'
      switch proto
        when 'range'
          list.unshift src
          proto = 'split'
          loc = '%\n'
        when 'object'
          list.unshift src
          proto = 'parse'
          loc = '$auto'
    when Array.isArray data
      switch proto
        when 'object', 'split', 'match'
          list.unshift src
          proto = 'join'
          loc = '$join'
  # check for impossible result data
  if (
    (not Array.isArray(data) and proto in ['range', 'join']) or
    (typeof data isnt 'string' and proto in ['split', 'match', 'parse']) or
    (typeof data isnt 'object' and proto is 'object')
    )
      if debug.enabled
        debug chalk.magenta "/#{path} stop at part #{proto}://#{loc} because wrong
        result type".replace /\n/, '\\n'
      return cb()
  proto = proto.toLowerCase()
  # find type handler
  type = protocolMap[proto] ? proto
  # check for correct handler
  unless handler[type]?
    return cb new Error "No handler for protocol #{proto} references defined"
  # check precedence for next uri
  if last? and typePrecedence[type] > typePrecedence[last?]
    return cb new Error "#{type}-reference can not be called from #{last}-reference
    for security reasons"
  if debug.enabled
    debug chalk.grey "/#{path} evaluating #{proto}://#{loc}".replace /\n/, '\\n'
  # run type handler and return if nothing found
  handler[type] proto, loc, data, path, worker, (err, result) ->
    if err
      if debug.enabled
        debug chalk.magenta "/#{path} #{proto}://#{loc} -> failed: #{err.message}".replace /\n/, '\\n'
      return cb err
    unless result # no result so stop this uri
      if list.length and debug.enabled # more to do
        debug chalk.grey "/#{path} #{proto}://#{loc} -> undefined".replace /\n/, '\\n'
      return cb()
    if list.length and debug.enabled # more to do
      debug chalk.grey "/#{path} #{proto}://#{loc} -> #{util.inspect result}".replace /\n/, '\\n'
    # no reference in result
    return cb null, result unless list.length # stop if last entry of uri path
    # process next list entry
    read list, path, worker, cb, type, result

# Search for data using relative or absolute path specification.
#
# @param {String} loc path to search
# @param {String} current path position in structure
# @param {Object} data complete value object
# @param {Worker} worker the root worker with
# - `checked` the list of validated entries
# @param {Function(Error, value)} cb callback which is called with resulting value
pathSearch = (loc, path = '', data, worker, cb) ->
  # direct search
  q = fspath.resolve "/#{path}", loc
  # retry read till there is no reference found or timeout
  async.retry
    times: MAXRETRY
    interval: TIMEOUT
  , (cb) ->
    result = util.object.pathSearch data, q
    if exists result
      return cb new Error "Reference pointing to #{q} can not be resolved"
    if result and worker? and not (q[1..] in worker.checked)
      return cb new Error "Referenced value at #{q} is not validated"
    cb null, result
  , (err, result) ->
    if err
      debug chalk.magenta "/#{path} has a circular reference at #{q}" if debug.enabled
      return cb err
    if result
      debug chalk.grey "/#{path} succeeded data read at #{q}" if debug.enabled
      return cb null, result
    debug chalk.grey "/#{path} failed data read at #{q}" if debug.enabled
    # search neighbors by sub call on parent
    if ~path.indexOf '/'
      return pathSearch loc, fspath.dirname(path), data, worker, cb
    else if path
      return pathSearch loc, null, data, worker, cb
    # neither found
    cb()

# ### Recursively join array of arrays together
arrayJoin = (data, splitter) ->
  glue = if splitter.length is 1 then splitter[0] else splitter.shift()
  result = ''
  for v in data
    v = arrayJoin v, splitter if Array.isArray v
    result += glue if result
    result += v
  result


# Protocoll Handlers
# -------------------------------------------------
# All handler are called with the same api. This contains all data which may be used
# in any handler.
#
# @param {String} proto protokoll name to use (type of handler)
# @param {String} loc location to extract
# @param {Object} data allready read data from previous read
# @param {String} base base location where to search references
# @param {Worker} worker the root worker with
# - `value` complete value object
# - `context` context additional object
# - `checked` the list of validated entries
# @param {Function(Error, result)} cb callback which is called with the resulting object
handler =

  ###
  Data Sources
  -------------------------------------------------------------
  The following examples shows the different possible data sources with their URI
  syntax and usage.

  #3 Value Structure

  The `struct` protocol is used to search for the value in the current data structure.

  If you don't use a protocol on the first alternative it is assumed as structure
  call so you may use the shortcut:

      <<<name>>>            # shortcut
      <<<struct://name>>>   # same result

  But this is really only possible in the first alternative because in each other
  it will be assumed as default value.

  __Absolute path__

      <<<struct:///absolute/field>>>
      <<<struct:///absolute/field.0>>>

  Like in the first line you give the path to the value which will be used. In the
  second line `field` is an array and the first value of it will be used.

  __Relative path__

      <<<struct://relative/field>>>
      <<<struct://../relative/field>>>

  This will search for the `relative` node in the current path backwards and
  then for the `field` subentry  which value is used. It will look for the
  neighbor elements, the parent and it'S neighborts and so on back to root.

  In relative paths you can also make backreferences like in the filesystem. So
  line 2 makes no difference but line 3 of the examples goes one level up.

  __Matching__

  See below in the path locator description for the more complex search patterns.

  __Subchecks__

  Here you may also go into a file which is referenced:

      <<<struct://file#address.info#1>>>

  Searches for a field named 'file', if it is defined as type 'file' it is already
  red. Then the above call will go to the element 'address.info' and extracts the
  first line of it.
  ###

  # Read from value structure.
  #
  struct: (proto, loc, data, base, worker, cb) ->
    pathSearch loc, base, worker.value, worker, cb

  ###
  #3 Context

  Additional to the validating structure which have to be completely checked an
  additional context structure may be given. The values therein are not validated
  but can be used in the references.

  This allows you to reference to already validated or system internal information.

      <<<context:///absolute/* /min>>>

  The syntax is nearly the same as for the value structure but relative paths makes
  no sense because you don't have a base position in the structure.

  This is also used if you want to reference some part of the value from the schema
  definition. You can check for a valid name which is defined elsewhere in the value
  structure like follows:

  Schema:

      templates:
        type: 'object'
        entries: [
          type: 'handlebars'
        ]
      default:
        type: 'string'
        list: '<<<context:///templates>>>'

  context:

      templates:
        first: "Wellcome {{name}}"
        ongoing: "Hello {{name}}"
      default: 'ongoing'

  The context may also contain other information like the 'currentDir' to be used
  in the 'file' and 'command' protocols.
  ###

  # Read from additional context.
  #
  context: (proto, loc, data, base, worker, cb) ->
    pathSearch loc, null, worker.context, null, cb

  ###
  #3 Environment

  The following syntax allows to read from an environment variable which may be
  set on start of the program or before.

      <<<env://MY_HOME>>>

  This uses the content of the `MY_HOME` environment variable.
  ###

  # Accessing environment variables.
  #
  env: (proto, loc, data, base, worker, cb) ->
    cb null, process.env[loc]

  ###
  #3 File Paths

  File paths should be given absolute because relative paths are calculated from
  the current working directory. But you can set the used base directory as context
  setting 'currentDir', too.

      <<<file:///etc/myvalue>>>
      <<<file:///etc/myvalue#14>>>
      <<<file:///etc/myvalue#14/5-8>>>
      <<<file:///etc/myvalue#name/min>>>

  This will load the content of a text file (line 1) or use only line number 14
  of the file. separated by a colon you can also specify which column (character)
  range to use.
  And in the last example line the file has to contain some type of
  structured information from which the given element path will be used.
  ###

  # Reading from locale or mounted file system.
  #
  # To specify a specific directory as current directory it can be set as context
  # variable: `currentDir`
  file: (proto, loc, data, base, worker, cb) ->
    fs ?= require 'alinex-fs'
    loc = fspath.resolve worker.context.currentDir, loc if worker.context?.currentDir?
    fs.realpath loc, (err, path) ->
      if err
        return cb() if err.code is 'ENOENT'
        return cb err
      fs.readFile path, 'utf-8', cb

  ###
  #3 Web Ressources

  Only use a valid URL therefore:

      <<<http://any.server.com/service>>>

  It is not allowed to use a # anchor in the URL.
  But you may use the `#` anchor to access a specific line or structured element.

  Possible protocols are:

  - http like `http://domain:port/...`
  - https like `https://domain:port/...`

  And you may connect to UNIX Sockets like `http://unix:/absolute/unix.socket:/request/path`
  but the paths have to be absoulte.
  ###

  # Reading from web ressources using http and https.
  #
  web: (proto, loc, data, base, worker, cb) ->
    request ?= require 'request'
    request
      uri: "#{proto}://#{loc}"
      followAllRedirects: true
    , (err, response, body) ->
      # error checking
      if err
        return cb() if err.message.match /\bENOTFOUND\b/
        return cb err
      if response.statusCode isnt 200
        return cb() if response.statusCode is 404
        return cb new Error "Server send wrong return code: #{response.statusCode}"
      return cb() unless body?
      cb null, body

  ###
  #3 Command

  The complete path will be execute as if it is typed into the command line on
  the current directory or the one given in `work.dir`.

      <<<cmd://date>>>
      <<<cmd:///user/local/bin/date>>>
      <<<cmd://df -h>>>

  It will use the value returned on STDOUT.

  Note: If you use pipes remove the space before or behind, because if you have
  both it is recognized as alternative reference.

      <<<cmd://cat test/data/poem| head -1>>>
  ###

  # Reading from web ressources using http and https.
  #
  cmd: (proto, loc, data, base, worker, cb) ->
    exec ?= require('child_process').exec
    opt = {}
    opt.cwd = worker.context.currentDir if worker.context?.currentDir?
    exec loc, opt, (err, result) ->
      return cb err if err
      cb null, result.trim()

  ###
  Path Locator
  -----------------------------------------------------------
  They may be used directly as the path in `struc` references or as anchor to
  get a subvalue (region).

  #3 Subsearch

  Multiple anchors are possible to specify a next subsearch like:

    <<<struct:///absolute.field#1>>>
    <<<file:///data/book.yml#publishing.notice#2-4>>>

  That means then either a # character comes up the search will use this value
  and uses the rest of the path on this.

  It is also possible to inject references through the referenced field like:

    <<<struct://file#address.info#1>>>
    file = <<<file:///myconfig.yml>>>

  This means that the `file` element of the structure will be used and as this
  is also a reference the value of this will first be retrieved by the reference to
  the `myconfig.yml` file. Then the result comes back the main path will be followed
  and the specific element is used.

  But to keep the system secure not any context can be used in another one. The
  Following list shows the precedence and can only be used top to bottom.

  1. environment
  2. struct
  3. context
  4. file, command
  5. web
  6. value structure or range in value are always possible

  Within the same level references between both are possible.

  This keeps the security, so that a user can not compromise the system by injecting
  references to extract internal data.

  To use the resulting value as datasource and only use some part of it you may
  first convert it if it is a text entry. If nothing of the following is specified
  but a range or object selection comes it will be automatically converted
  using defaults.
  ###

  ###
  #3 Split

  A split generates a two-dimensional array (rows and columns) out of a simple text.
  It is used for range selections.

      %\n - split in lines and characters
      %\n//\t - split by newline and tab
      %\n//\t - split by newline and tab
      %\n//;\\s* - csv like reader with optional spaces

  The separator may be a simple string or an regular expression (as string).
  The resulting array has:

      [0] = null
      [1][0] = row 1 as text
      [1][1] = text of row 1, column 1
      ...

  If no other path follows better always add a `#` at the end to prevent problems
  if last separsator is a whitespace.
  ###

  # Splitting of strings.
  #
  split: (proto, loc, data, base, worker, cb) ->
    splitter = loc[1..].split('//').map (s) -> new RegExp s
    splitter.push '' if splitter.length is 1
    result = data.split(splitter[0]).map (t) ->
      col = t.split splitter[1]
      col.unshift t
      col
    result.unshift null
    cb null, result

  ###
  #3 Match

  Alternatively to splits you may use an regular expression on your text. You can
  use range selections also, but without column specifier.

      /.../ - give an regular expression `/g` is used automatically

  The resulting array has the found results in elements 1..n.
  ###

  # #### Matching strings
  match: (proto, loc, data, base, worker, cb) ->
    re = loc.match /\/([^]*)\/(i?)/
    re = new RegExp re[1], "#{re[2]}g"
    cb null, data.match re

  ###
  #3 Parse

  Additional to the two methods above this can do complex transformations into
  object structures to do object selections later.

      $js - parse javascript to object
      $json - JSON to object
      $yaml - YAML to object
      $xml - XML to object
      ...and more
      $auto - try to autodetect correct parser

  See [formatter](http://alinex.github.io/node-formatter) for all possible formats
  and examples of them.
  ###

  # #### Special parsing of string
  parse: (proto, loc, data, base, worker, cb) ->
    format ?= require 'alinex-format'
    formatType = loc[1..]
    formatType = null if formatType is 'auto'
    format.parse data, formatType, (err, result) ->
      cb null, result

  ###
  #3 Range Selection

  If the given value is a text it will be splitted into lines and characters.

  Within a text element you may use the following ranges:

      3 - specific row as string
      3-5 - specific row range as array
      3,5 - specific row and column as array
      3,5-8 - specific column range in row as array
      1-2,5-8 - specific row and column range as array
      3[2] - specific element (2nd element of third line) as string
      3[2-4] - specific elements (2nd to 4th element of third line) as array
      3[2-4,8],4[2] - and all combined ;-)

  The result may be a single value, an array or an array of arrays depending on the
  selected result.
  ###

  # #### Range selection in array
  range: (proto, loc, data, base, worker, cb) ->
    # split multiple specifiers
    rows = loc.match ///
      \d+ # first row
      (?:-\d+)? # end of row range
      (?:\[[^\]]+\])? # column specification
      ///g #path.split ','
    result = []
    # go over rows
    for row in rows
      row = row.match ///
        (\d+) # first row
        (?:-(\d+))? # end of row range
        (?:\[([^\]]+)\])? # column specification
        /// #path.split ','
      row.from = parseInt row[1]
      row.to = if row[2]? then parseInt row[2] else row.from
      cols = row[3]?.split ','
      if cols? and Array.isArray data[1]
        # get columns
        for drow in data[row.from..row.to]
          rrows = []
          for col in cols
            col = col.match ///
              (\d+) # first column
              (?:-(\d+))? # end of column range
              /// #path.split ','
            col.from = parseInt col[1]
            col.to = if col[2]? then parseInt col[2] else col.from
            rrows = rrows.concat drow[col.from..col.to]
          result.push rrows
      else
        # get single row
        for drow in data[row.from..row.to]
          result.push drow[0]
    return cb() unless result.length
    result = result[0] if result.length is 1
    result = result[0] if result.length is 1
    cb null, result

  ###
  #3 Object Selection

  If it is a structured information you may specify the path by name:

      name - get first element with this name
      group/sub/name - get element with path

  You can search by using asterisk as directory placeholder or a double asterisk to
  go multiple level depth:

      name/* /min - within any subelement
      name/* /* /min - within any subelement (two level depth)
      name/** /min - within any subelement in any depth

  You may also use regexp notation to find the correct element:

      name/test[AB]/min - pattern match with one missing character
      name/test\d+/min - pattern match with multiple missing characters

  See the [Mozilla Developer Network](https://developer.mozilla.org/de/docs/Web/
  JavaScript/Reference/Global_Objects/RegExp)
  for the possible syntax but without modifier.
  ###

  # #### Path selection in object
  object: (proto, loc, data, base, worker, cb) ->
    cb null, util.object.pathSearch data, loc

  ###
  #3 Join

  As opposite to split and match the results maybe joined together into a single
  string using some separators.

      $join , - using , as separator
      $join \n//, - using newline for first level and , as separator below
      name/test\d+/min - pattern match with multiple missing characters

  If no other path follows better always add a `#` at the end to prevent problems
  if last separsator is a whitespace.
  ###

  # #### Join array together
  join: (proto, loc, data, base, worker, cb) ->
    loc = loc[6..]
    splitter = if loc then loc.split '//' else [', ']
    cb null, arrayJoin data, splitter

  ###
  #3 Checks

  It is possible to validate a value within the path using the validator itself.

      {type: 'integer'}

  Therefore this part of the path have to be a javascript object.
  ###

  # Value checks.
  #
  check: (proto, loc, data, base, worker, cb) ->
    # get the check schema reading as js
    vm ?= require 'vm'
    schema = vm.runInNewContext "x=#{loc}"
    # instantiate new object
    Worker ?= require './worker'
    worker = new Worker "reference-#{loc}", schema, null, data
    # run the check
    worker.check (err) ->
      return cb err if err
      cb null, worker.value
