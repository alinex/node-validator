Alinex Validator: Readme
=================================================

[![GitHub watchers](
  https://img.shields.io/github/watchers/alinex/node-validator.svg?style=social&label=Watch&maxAge=2592000)](
  https://github.com/alinex/node-validator/subscription)<!-- {.hidden-small} -->
[![GitHub stars](
  https://img.shields.io/github/stars/alinex/node-validator.svg?style=social&label=Star&maxAge=2592000)](
  https://github.com/alinex/node-validator)
[![GitHub forks](
  https://img.shields.io/github/forks/alinex/node-validator.svg?style=social&label=Fork&maxAge=2592000)](
  https://github.com/alinex/node-validator)<!-- {.hidden-small} -->
<!-- {p:.right} -->

[![npm package](
  https://img.shields.io/npm/v/alinex-validator.svg?maxAge=2592000&label=latest%20version)](
  https://www.npmjs.com/package/alinex-validator)
[![latest version](
  https://img.shields.io/npm/l/alinex-validator.svg?maxAge=2592000)](
  #license)<!-- {.hidden-small} -->
[![Travis status](
  https://img.shields.io/travis/alinex/node-validator.svg?maxAge=2592000&label=develop)](
  https://travis-ci.org/alinex/node-validator)
[![Coveralls status](
  https://img.shields.io/coveralls/alinex/node-validator.svg?maxAge=2592000)](
  https://coveralls.io/r/alinex/node-validator?branch=master)
[![Gemnasium status](
  https://img.shields.io/gemnasium/alinex/node-validator.svg?maxAge=2592000)](
  https://gemnasium.com/alinex/node-validator)
[![GitHub issues](
  https://img.shields.io/github/issues/alinex/node-validator.svg?maxAge=2592000)](
  https://github.com/alinex/node-validator/issues)<!-- {.hidden-small} -->


This module will help validating complex structures. And should be used on all
external information.

- check value against configuration
- easy checking of values and complex structures
- in detail checks for different data types
- can give a human readable description
- also supports dependency checks within the structure
- usable for value formating, too

The validation rules are really simple, but they will get more complex as your
data structure gains complexity. But if you know the basic rules it's all
a composition of some simple structures. Like you will see below.

This library can help you make your life secure and easy but you have to run
every external data through it using a detailed data description. If you do so
you can trust and use the values as they are without further checks.
And you'll get the benefit of automatically optimized values like for `handlebars`
type you get a ready to use handlebar function back.

> It is one of the modules of the [Alinex Namespace](https://alinex.github.io/code.html)
> following the code standards defined in the [General Docs](https://alinex.github.io/develop).

__Read the complete documentation under
[https://alinex.github.io/node-codedoc](https://alinex.github.io/node-codedoc).__
<!-- {p: .hidden} -->


Install
-------------------------------------------------

[![NPM](https://nodei.co/npm/alinex-validator.png?downloads=true&downloadRank=true&stars=true)
 ![Downloads](https://nodei.co/npm-dl/alinex-validator.png?months=9&height=3)
](https://www.npmjs.com/package/alinex-validator)

The easiest way is to let npm add the module directly to your modules
(from within you node modules directory):

``` sh
npm install alinex-validator --save
```

And update it to the latest version later:

``` sh
npm update alinex-validator --save
```

Always have a look at the latest changes in the {@link Changelog.md}


Usage
-------------------------------------------------

This library is implemented completely asynchronous, to allow io based checks
and references within the structure.

To use the validator you have to first include it:

``` coffee
validator = require 'alinex-validator'
```

The main method will validate and sanitize the value or value structure:

``` coffee
validator.check
  name: 'test'        # name to be displayed in errors (optional)
  value: input        # value to check
  schema: schema      # definition of checks
  context: null       # additional data (optional)
, (err, result) ->
  # do something
```

The checks are completely asynchronous because they may contain some IO checks.

To get a human readable description call:

``` coffee
message = validator.describe
  name: 'test'        # name to be displayed in errors (optional)
  schema: schema      # definition of checks
, (err, text) ->
  # do something
```

This will get the description un markdown format.

Within your tests you may check your schema configurations:

``` coffee
validator.selfcheck
  name: 'test'        # name to be displayed in errors
  schema: schema      # definition to check
, (err) ->
  # do something
```










Ideas
-------------------------------------------------

#### Database (to be implemented later)

This connector is not implemented so far and will come in one of the next
releases. But in the example below I show how it will be used.

``` text
<<<mysql://user:password@host:port/database/table/id=15/field>>>
<<<mysql:///dataname/table/id=15/field>>>
<<<mysql:///dataname/select name from xxx where id=15>>>
```


Descriptive reporting
-------------------------------------------------
To get even more descriptive reporting it is possible to set a title and abstract
for the given field in the configuration. This will be used in error reporting
and `describe()` calls.

``` coffee
validator.check 'test', value,
  title: 'Overall Timeout'
  description: 'Time in milliseconds the whole test may take.'
  type: 'float'
  min: 500
, (err, value) ->
  if err
    # there will be the error
  else
    # do something with value
```

This may result in the following error:

> Failed: The value is to low, it has to be at least 500 in test.timeout for "Overall Timeout".
> It should contain the time in milliseconds the whole test may take.


Selfchecking
-------------------------------------------------
It is also possible to let your complex options be validated against the
different types. This will help you to find problems in development state.
To do this you have to add it in your tests:

__Mocha coffee example:__

``` coffee
# ...
it "should has correct validator rules", (cb) ->
  validator.selfcheck
    name: 'test'        # name to be displayed in errors
    schema: schema      # definition of checks
  , (err) ->
    expect(err).to.not.exist
# ...
```


Basic Check Types
-------------------------------------------------

The type `any` is only used internally and matches any value. It is used as default
if nothing is specified for an value and makes the checks homogeneous.

### boolean

The value has to be a boolean. The value will be true for 1, 'true', 'on',
'yes', '+' and it will be considered as false for 0, 'false', 'off', 'no',
'-', null and undefined.
Other values are not allowed.

__Validate options:__

- `class` - (boolean) only a class or only a normal function is valid

__Format options:__

- `format` - (list) with the values for false and true

__Example:__

``` coffee
validator.check
  name: 'test'        # name to be displayed in errors (optional)
  value: input        # value to check
  schema:             # definition of checks
    type: 'boolean'
, (err, result) ->
  # do something
```

### function

The value has to be a function.
Other values are not allowed.

__Options:__ none

__Example:__

``` coffee
validator.check
  name: 'test'        # name to be displayed in errors (optional)
  value: input        # value to check
  schema:             # definition of checks
    type: 'function'
, (err, result) ->
  # do something
```

### string

This will test for strings and have lots of sanitize and optimization filters
and also different check settings to use.

__Sanitize options:__

- `toString` - convert objects to string, first
- `allowControls` - keep control characters in string instead of
  stripping them (but keep \\r\\n)
- `stripTags` - remove all html tags
- `lowerCase` - set to `true` or `first`
- `upperCase` - set to `true` or `first`
- `replace` - replacement or list with each replacement to contain of [search,
  replacement text] while search may be a string or RegExp
- `trim` - strip whitespace from the beginning and end
- `crop` - crop text after number of characters

__Validate options:__

- `minLength` - minimum text length in characters
- `maxLength` - maximum text length in characters
- `values` - array of possible values (complete text) or object keys
- `startsWith` - start of text
- `endsWith` - end of text
- `match` - string or regular expression which have to be matched
  (or list of expressions)
- `matchNot` - string or regular expression which is not allowed to
  match (or list of expressions)

__Example:__

``` coffee
validator.check
  name: 'test'        # name to be displayed in errors (optional)
  value: input        # value to check
  schema:             # definition of checks
    type: 'string'
    lowerCase: true
    upperCase: 'first'
    values: ['One', 'Two', 'Three']
, (err, result) ->
  # do something
```

### integer

To test for integer values which may be sanitized.

__Sanitize options:__

- `sanitize` - (bool) remove invalid characters
- `unit` - (string) unit to convert to if no number is given
- `round` - (bool or string) rounding of float can be set to true for arithmetic
  rounding or use `floor` or `ceil` for the corresponding methods

__Validate options:__

- `min` - (integer) the smalles allowed number
- `max` - (integer) the biggest allowed number
- `inttype` - (integer|string) the integer is of given type
  (4, 8, 16, 32, 64, 'byte', 'short','long','quad', 'safe')
- `unsigned` - (bool) the integer has to be positive

__Format options:__

- `toUnit` - (string) unit used for output, my be combined with format and locale
- `format` - (string) pattern how to format numbers (see [numeral.js](http://numeraljs.com))
- `locale` - (string) locale to use in format like 'de'

### float

Nearly the same as for integer values but here are floats allowed, too.

__Sanitize options:__

- `sanitize` - (bool) remove invalid characters
- `unit` - (string) unit to convert to if no number is given
- `round` - (bool or string) rounding of float can be set to true for arithmetic
  rounding or use `floor` or `ceil` for the corresponding methods
- `decimals` - (int) number of decimal digits to round to

__Check options:__

- `min` - (numeric) the smalles allowed number
- `max` - (numeric) the biggest allowed number

__Format options:__

- `toUnit` - (string) unit used for output, my be combined with format and locale
- `format` - (string) pattern how to format numbers (see [numeral.js](http://numeraljs.com))
- `locale` - (string) locale to use in format like 'de'

### array

__Sanitize options:__

- `delimiter` - allow value text with specified list separator
  (it can also be an regular expression)
- `toArray` - will convert single values into array with one element

__Check options:__

- `unique` - set to true to have only unique values
- `notEmpty` - set to true if an empty array is not valid
- `minLength` - minimum number of entries
- `maxLength` - maximum number of entries

__Validating children:__

- `entries` - default specification for all entries
- `list` - specification for entries per each key number

__Format options:__

- `format` - transform to string using one of the formats 'simple', 'pretty' or 'json'

``` text
data = [1, 2, 3, 'a', {b: 1}, ['c', 9]]
# simple -> "1, 2, 3, a, [object Object], c,9"
# pretty -> "1, 2, 3, 'a', { b: 1 }, [ 'c', 9 ]"
# json -> '[1,2,3,"a",{"b":1},["c",9]]'
```

### object

For all complex data structures you use the object type which checks for named
arrays or instance objects.

This is the most complex validation form because it has different checks and
uses subchecks on each entry.

__Options:__

- `flatten` - (boolean) flatten deep structures
- `instanceOf` - (class) only objects of given class type are allowed
- `mandatoryKeys` - (list or boolean) the list of elements which are mandatory
- `allowedKeys` - (list or boolean) gives a list of elements which are
   also allowed or true to use the list from entries definition or an regular
   expression
- `entries` - specification for multiple entries based on match and default
- `keys` - specification for all entries per each key name

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


Alternative-/Multiple Checks
-------------------------------------------------

### or

This is used to give some alternatives from which at least one check have to
succeed. The first one succeeding will work.

__Option:__

- `or` - (array) with different check alternatives

__Example:__

You may allow numeric and special format input:

``` coffee
validator.check
  name: 'test'        # name to be displayed in errors (optional)
  value: input        # value to check
  schema:             # definition of checks
    type: 'or'
    or: [
      type: 'float'
    ,
      type: 'string'
      match: ///
        ^\s*      # start with possible spaces
        [+-]?     # sign possible
        \s*\d+(\.\d*)? # float number
        \s*%?     # percent sign with spaces
        \s*$      # end of text with spaces
        ///
    ]
, (err, result) ->
  # do something
```

With this type you can also use different option alternatives:

``` coffee
validator.check
  name: 'test'        # name to be displayed in errors (optional)
  value: input        # value to check
  schema:             # definition of checks
    type: 'or'
    or: [
      type: 'object'
      allowedKeys: true
      keys:
        type:
          type: 'string'
          lowerCase: true
          values: ['mysql']
        port:
          type: 'integer'
          default: 3306
        # ...
    ,
      type: 'object'
      allowedKeys: true
      keys:
        type:
          type: 'string'
          lowerCase: true
          values: ['postgres']
        port:
          type: 'integer'
          default: 5432
        # ...
    ]
, (err, result) ->
  # do something
```

In the example above only the default port is changed, but you may also add different
options.

### and

This is used to give multiple rules which will be executed in a series and
all have to succeed.

__Option:__

- `and` - (array) with multiple check rules

With this it is possible to use a string-check to sanitize and then use an
other test to finalize the value like:

``` coffee
validator.check
  name: 'test'        # name to be displayed in errors (optional)
  value: input        # value to check
  schema:             # definition of checks
    type: 'and'
    and: [
      type: 'string'
      toString: true
      replace: [/,/g, '.']
    ,
      type: 'float'
    ]
, (err, result) ->
  # do something
```

This allows to give float numbers in the european format: xx,x

Additional Check Types
-------------------------------------------------

### byte

To test for byte values which may contain prefixes like `18M` or `6.2 GB`.

__Sanitize options:__

- `unit` - (string) unit to convert to if no number is given: B, kB, Byte, b, bps, bits, ...
- `round` - (bool or string) rounding of float can be set to true for arithmetic
  rounding or use `floor` or `ceil` for the corresponding methods
- `decimals` - (int) number of decimal digits to round to

__Validate options:__

- `min` - (integer) the smalles allowed number
- `max` - (integer) the biggest allowed number

### datetime

Check for date and time.

This validator will parse the given format using different technologies in nearly
all common formats:

- ISO 8601 datetimes
  - '2013-02-08'
  - '2013-W06-5'
  - '2013-039'
  - '2013-02-08 09'
  - '2013-02-08T09'
  - '2013-02-08 09:30'
  - '2013-02-08T09:30'
  - '2013-02-08 09:30:26'
  - '2013-02-08T09:30:26'
  - '2013-02-08 09:30:26.123'
  - '2013-02-08 24:00:00.00'
- ISO 8601 time only
- ISO 8601 date only
  - '2013-02-08 09'
  - '2013-W06-5 09'
  - '2013-039 09'
- ISO 8601 with timezone
  - '2013-02-08 09+07:00'
  - '2013-02-08 09-0100'
  - '2013-02-08 09Z'
  - '2013-02-08 09:30:26.123+07:00'
- natural language: 'today', 'tomorrow', 'yesterday', 'last friday'
- named dates
  - '17 August 2013'
  - '19 Aug 2013'
  - '20 Aug. 2013'
  - 'Sat Aug 17 2013 18:40:39 GMT+0900 (JST)'
- relative dates
  - 'This Friday at 13:00'
  - '5 days ago'
- specials: 'now'

__Parse options:__

- `range` - (boolean) parsing ranges contains two dates (start/end)
- `timezone` - (string) specify timezone if none given

__Check options:__

- `min` - (datetime) time has to be at or after this
- `max` - (datetime) time has to be at or before this

__Format options:__

- `part` - 'date', 'time' or 'datetime'
- `format` - how the output should be formatted
- `locale` - country specific format to use (ISO language code)
- `toTimezone` - (string) show in given timezone

__Output formats__

If not specified it is a Date object.

If `format = 'unix'` it will be an unix timestamp (seconds since January 1, 1970).

For all other format settings a corresponding output string will be generated. Use
the aliases like ISO8601, RFC1123, RFC2822, RFC822, RFC1036 are supported and any
[moment.js](http://momentjs.com/docs/#/displaying/) format.

Also see the interval validator for time ranges without context.

The timezones may be 'America/Toronto', 'EST' or 'Eastern Standard Time' for example.

### emails

There are a lot of crazy possibilities in the RFC2822 which  specifies the Email
format. Perhaps it came from letting different existing email systems represented
their account, to encompass anything that was valid before.

So this check will not aim to allow all emails allowed through RFC but only
those which are reasonable and commonly used.

__Sanitize options:__

- `lowerCase` domain and gmail addresses completely
- `normalize` (boolean) remove tags, alternative domains and subdomains

__Check options:__

- `checkServer` (boolean) also check for working email servers

### file

Check the value as valid file or directory entry.

__Sanitize options:__

- `basedir` - (string) relative paths are calculated from this directory
- `resolve` - (bool) should the given value be resolved to a full path

__Check options:__

- `exists` - (bool) true to check for already existing entry
- `find` - (array or function) list of directories in which to search for the file
  The function should return an array if called without parameters.
- `filetype` - (string) check against inode type: f, file, d, dir, directory, l, link,
  p, pipe, fifo, s, socket

### handlebars

You may also add a text which may contain [handlebars syntax](http://alinex.github.io/develop/lang/handlebars.html)
This will be compiled into a function which if called with the context
object will return the resulting text.

``` coffee
validator.check
  name: 'test'        # name to be displayed in errors (optional)
  value: 'hello {{name}}' # value to check
  schema:             # definition of checks
    type: 'handlebars'
, (err, result) ->
  # then use it
  console.log result
    name: 'alex'
  # this will output 'hello alex'
```

Within the handlebars templates you may use:

- [builtin helpers](http://alinex.github.io/develop/lang/handlebars.html#built-in-helpers)
- additional [handlebars](http://alinex.github.io/node-handlebars) helpers

### hostname

The value has to be a valid hostname definition.

### interval

A time interval may be given:

- directly as number
- in a string with days, minutes and seconds: `1d 3h 12m 10s 400ms`
- in a time format: `03:20`, `02:18:10.5`

__Sanitize options:__

- `unit` - (string) type of unit to convert if not integer given
- `round` - (bool or string) rounding of float can be set to true for arithmetic
  rounding or use `floor` or `ceil` for the corresponding methods
- `decimals` - (int) number of decimal digits to round to

__Check options:__

- `min` - (integer) the smalles allowed number
- `max` - (integer) the biggest allowed number

### ipaddr

The value has to be an IP address.

__Check options:__

- `version` - one of 'ipv4' or 'ipv6' and the value will be converted, if possible
- `ipv4Mapping` - (boolean) set to true to allow mapping ipv4 addresses in both
  directions to succeed version specification if possible.
- `allow` - the allowed ip ranges
- `deny` - the denied ip ranges

__Sanitize options:__

- `format` - compression method to use: 'short', 'long'

The addresses may be converted from IPv6 to IPv4 and from IPv4 to IPv6 if possible.

Ranges for `deny` and `allow` may contain a list of multiple IP ranges which are
given in with the IP address and the significant bits behind: '127.0.0.1/8' or as
a range name.
Range names are: unspecified, broadcast, multicast, linklocal, loopback, private,
reserved, uniquelocal, ipv4mapped, rfc6145, rfc6052, 6to4, teredo.
Or use the range 'special' to specify all of the named ranges.

|  has allow  |  has deny | in allow | in deny | in both | in other |
|-------------|-----------|----------|---------|---------|----------|
|   no        |   no      |    -     |    -    |    -    |   ok     |
|   yes       |   no      |    ok    |    -    |    -    |   fail   |
|   no        |   yes     |    -     |   fail  |    -    |   ok     |
|   yes       |   yes     |    ok    |   fail  |    ok   |   ok     |

The output will always be without leading '0' and by default compressed to the short
form for IPv6 addresses. To get the long form use the 'format' option.

### percent

Nearly the same as float but values which are given as string using the % sign
like 50% are converted to floats like 0.5.

__Sanitize options:__

- `round` - (bool or string) rounding of float can be set to true for arithmetic
  rounding or use `floor` or `ceil` for the corresponding methods
- `decimals` - (int) number of decimal digits to round to

__Check options:__

- `min` - (numeric) the smalles allowed number
- `max` - (numeric) the biggest allowed number

__Format options:__

- `format` - (string) pattern how to format percent value (see [numeral.js](http://numeraljs.com))
- `locale` - (string) locale to use in format like 'de'

### port

The value has to be a TCP/UDP port number.

__Check options:__

- `allow` - the allowed ports or ranges
- `deny` - the denied ports or ranges

The ports can also be given as standardized names as known in the /etc/services
list.

Ranges for `deny` and `allow` may contain a list of multiple ports or ranges. Ranges
are 'system', 'registered' and 'dynamic' representing the three range parts.

The table shows how the result is detected if both given:

|  has allow  |  has deny | in allow | in deny | in both | in other |
|-------------|-----------|----------|---------|---------|----------|
|   no        |   no      |    -     |    -    |    -    |   ok     |
|   yes       |   no      |    ok    |    -    |    -    |   fail   |
|   no        |   yes     |    -     |   fail  |    -    |   ok     |
|   yes       |   yes     |    ok    |   fail  |    ok   |   ok     |

### regexp

Check that the given value is a regular expression. If a text is given it will be
compiled into an regular expression.

### url

Check the given string for a valid url.

__Sanitize options:__

- `toAbsoluteBase` - convert to absolute with given base
- `removeQuery` - (boolean) remove query and hash from url

__Check options:__

- `hostsAllowed` - list of allowed hosts by string or regexp
- `hostsDenied` - list of denied hosts by string or regexp
- `allowProtocols` - lust of allowed protocols
- `allowRelative` - (boolean) to allow also relative urls


Package structure
-------------------------------------------------
The validator is implemented as `index` which has the public available methods,
`check` is used for the real check calls and each type has it's own module
with the implementation loaded on demand (type-subfolder).


License
-------------------------------------------------

(C) Copyright 2014-2016 Alexander Schilling

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

>  <http://www.apache.org/licenses/LICENSE-2.0>

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
