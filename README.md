Package: alinex-validator
=================================================

[![Build Status] (https://travis-ci.org/alinex/node-validator.svg?branch=master)](https://travis-ci.org/alinex/node-validator)
[![Dependency Status] (https://gemnasium.com/alinex/node-validator.png)](https://gemnasium.com/alinex/node-validator)

This module will help validating complex structures. And may be used for all
external information.

- check value against configuration
- easy checking of values
- may check complex structures
- understandable errors
- can give a human readable description

The validation rules are really simple, but they will get more complex as your
data structure gains complexity. But if you know the basic rules it's all
a composition of some simple structures.

This library can help you make your life secure and easy but you have to run
every external data through it using a detailed data description. If you do so
you can trust and use the values and get also the benefit that they are optimized
as with the `handlebars` type you get a ready to use handlebar function back.

It is one of the modules of the [Alinex Universe](http://alinex.github.io/node-alinex)
following the code standards defined there.

Also see the last [changes](Changelog.md).


Install
-------------------------------------------------

The easiest way is to let npm add the module directly:

``` bash
npm install alinex-validator --save
```

[![NPM](https://nodei.co/npm/alinex-validator.png?downloads=true&stars=true)](https://nodei.co/npm/alinex-validator/)

But you can also get the sources from github and install the subpackages using
npm:

``` bash
git clone git://github.com/alinex/node-validator alinex-validator
cd alinex-validator
npm install
```

Usage
-------------------------------------------------

This library is implemented completely asynchronous, to allow io-operations
and others within the validation.

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

To get a human readable description:

``` coffee
message = validator.describe
  name: 'test'        # name to be displayed in errors (optional)
  schema: schema      # definition of checks
  pos: ''             # position which to describe (optional)
  depth: 2            # level of depth to describe (optional)
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

And to be portable you can also export the schema in other formats but you may
loose some information:

``` coffee
jsonSchema = validator.toJson schema
```

Schema Definition
-------------------------------------------------

The Schema definition is defined as object with the concrete specification as
attributes. The common attributes are:

- title - gives a short title for the element
- description - has a more descriptive information
- type - check type
- key - used in object's entries to give a regexp matchhing the keys for which
  the rule is specified.

In it's easiest way the schema definition includes only a type:

``` coffee
schema =
  type: 'integer'
```

Or with the above descriptive fields:

``` coffee
schema =
  title: "Max runs"
  description: 'The number of runs which may occur.'
  type: 'integer'
```

Further each type has it's own additional attributes which may be set to
specify how it works.

``` coffee
address =
  type: 'object'
  allowedKeys: true
  entries:
    name:
      type: 'string'
    street:
      type: 'string'
    city:
      type: 'string'
    country:
      type: 'string'
    email:
      type: 'string'
```

### Compositing

As your structure gets more and more complex it may help you keep the overview
if you divide by setting some parts to variables first before compositing all
together:

``` coffee
address =
  type: 'object'
  allowedKeys: true
  entries:
    name:
      type: 'string'
    street:
      type: 'string'
    city:
      type: 'string'
    country:
      type: 'string'
    email:
      type: 'string'

console.log validator.is 'audiocd', value,
  type: 'object'
  allowedKeys: true
  entries:
    title:
      type: 'string'
    publisher: address
    artists:
      type: 'array'
      notEmpty: true
      entries: address
    composer: address
```

The above example shows how to composite a complex structure out of parts and
how to reuse the same elements.

### Optional values

All types (excluding boolean) support the `optional` parameter, which makes an
entry in the data structure optional.
If not given it will be set to null or the value given with `default`.

- `optional` - the value must not be present (will return null)
- `default` - value used if optional and no value given

The `default` option automatically makes the setting optional.


References
-------------------------------------------------
References point to values which are used on their place. You can use references
within the structure data which is checked and also within the check conditions.
Not everything is possible, but a lot - see below.

### Syntax

The syntax looks easy but has a lot of variations and possibilities.

``` text
<<<source://path>>>
<<<source://path | source://path | default>>>
<<<source://path#{type:"integer"} | source://path | default>>>
```

Within the curly braces the source from which to retrieve the value is given.
The source is given in form of an URI.
Like you see in line two you may use multiple fallback URIs and also a default
value at last.
And at last in the third line you see how to add a special check condition
after an URI. If this fails the next URI is checked.

The path may also have different possibilities based on the `source` protocol
type.

### Combine

You may also combine the resulting value(s) of the reference(s) into one
string:

``` text
<<<host>>>:<<<port>>>
```

This will result in `localhost:8080` as example.

### Data Sources

The following are the diffferent data sources to use.

#### Value Structure

The `struct` protocol is used to search for the value in the current data structure.

__Absolute path__

``` text
<<<struct:///absolute/field>>>
<<<struct:///absolute/field.0>>>
```

Like in the first line you give the path to the value which will be used. In the
second line `field` is an array and the first value of it will be used.

__Relative path__

``` text
<<<struct://relative/field>>>
<<<struct://./relative/field>>>
<<<struct://../relative/field>>>
```

This will search for the `relative` node in the current path backwards and
then for the `field` subentry  which value is used. It will look for the
neighbor elements, the parent and it'S neighborts and so on back to root.

In relative paths you can also make backreferences like in the filesystem. So
line 2 makes no difference but line 3 of the examples goes one level up.

__Matching__

See below in the path locator description for the more complex search pattern.

__Subchecks__

Here you may also go into a file which is referenced:

<<<struct://file#address.info#1>>>

Searches for a field, reads the file path there, loads the file and gets the first
line.

#### Context

Additional to the validating structure which have to be completely checked an
additional context structure may be given. The values therein are not validated
but can be used in the references.

This allows you to reference to already validated or system internal information.

``` text
<<<context:///absolute/*/min>>>
```

The syntax is nearly the same as for the value structure but relative paths makes
no sense because you don't have a base position in the structure.

#### Environment

The following syntax allows to read from an environment variable which may be
set on start of the program or before.

``` text
<<<env://MY_HOME>>>
```

This uses the content of the `MY_HOME` environment variable.

#### File

File paths should be given absolute because relative paths are calculated from
the current working directory.

``` text
<<<file:///etc/myvalue>>>
<<<file:///etc/myvalue#14>>>
<<<file:///etc/myvalue#14/5-8>>>
<<<file:///etc/myvalue#name/min>>>
```

This will load the content of a text file (line 1) or use only line number 14
of the file. separated by a colon you can also specify which column (character)
range to use.
And in the last example line the file has to contain some type of
structured information from which the given element path will be used.

#### Web Ressources

Only use a valid URL therefore:

``` text
<<<http://any.server.com/service>>>
```

It is not allowed to use a # anchor in the URL.
But you may use the `#` anchor to access a specific line or structured element.

Possible protocols are:

- http://domain:port/...
- https://domain:port/...

And you may connect to UNIX Sockets like `http://unix:/absolute/unix.socket:/request/path`
but the paths have to be absoulte.


#### Command

The complete path will be execute as if it is typed into the command line on
the current directory or the one given in `work.dir`.

``` text
<<<cmd://date>>>
<<<cmd:///user/local/bin/date>>>
<<<cmd://df -h>>>
```

It will use the value returned on STDOUT.

Note: If you use pipes remove the space before or behind, because if you have
both it is recognized as alternative reference.

``` text
<<<cmd://cat test/data/poem| head -1>>>
```

#### Database (to be implemented later)

``` text
<<<mysql://user:password@host:port/database/table/field?id=15>>>
<<<mysql:///dataname/table/id=15/field>>>
<<<mysql:///dataname/select name from xxx where id=15>>>
```


### Path Locator

They may be used directly as the path in `struc` references or as anchor to
get a subvalue (region).

__Subsearch__

Multiple anchors are possible to specify a next subsearch like:

``` text
<<<struct:///absolute.field#1>>>
<<<file:///data/book.yml#publishing.notice#2-4>>>
```

That means then either a # character comes up the search will use this value
and uses the rest of the path on this.

It is also possible to inject references through the referenced field like:

``` text
<<<struct://file#address.info#1>>>
file = <<<file:///myconfig.yml>>>
```

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

__Split__

A split generates a two-dimensional array (rows and columns) out of a simple text.
It is used for range selections.

``` text
%\n - split in lines and characters
%\n//\t - split by newline and tab
%\n//\t - split by newline and tab
%\n//;\\s* - csv like reader with optional spaces
```

The separator may be a simple string or an regular expression (as string).
The resulting array has:

``` text
[0] = null
[1][0] = row 1 as text
[1][1] = text of row 1, column 1
...
```

If no other path follows better always add a `#` at the end to prevent problems
if last separsator is a whitespace.

__Match__

Alternatively to splits you may use an regular expression on your text. You can
use range selections also, but without column specifier.

``` text
/.../ - give an regular expression `/g` is used automatically
```

The resulting array has the found results in elements 1..n.

__Parse__

Additional to the two methods above this can do complex transformations into
object structures to do object selections later.

``` text
$js - parse javascript to object
$json - JSON to object
$yaml - YAML to object
$xml - XML to object
```

__Range Selection__

If the given value is a text it will be splitted into lines and characters.

Within a text element you may use the following ranges:

``` text
3 - specific row as string
3-5 - specific row range as array
3,5 - specific row and column as array
3,5-8 - specific column range in row as array
1-2,5-8 - specific row and column range as array
3[2] - specific element (2nd element of third line) as string
3[2-4] - specific elements (2nd to 4th element of third line) as array
3[2-4,8],4[2] - and all combined ;-)
```

The result may be a single value, an array or an array of arrays depending on the
selected result.

__Object Selection__

If it is a structured information you may specify the path by name:

``` text
name - get first element with this name
name/*/min - within any subelement
name/*/*/min - within any subelement (two level depth)
name/**/min - within any subelement in any depth
name/test?/min - pattern match with one missing character
name/test*/min - pattern match with multiple missing characters
```

You may also use regexp notation to find the correct element:

``` text
name/test[AB]/min - pattern match with one missing character
name/test\d+/min - pattern match with multiple missing characters
```

See the [Mozilla Developer Network](https://developer.mozilla.org/de/docs/Web/JavaScript/Reference/Global_Objects/RegExp)
for the possible syntax but without modifier.

__join__

As opposite to split and match the results maybe joined together into a single
string using some separators.

``` text
$join , - using , as separator
$join \n//, - using newline for first level and , as separator below
name/test\d+/min - pattern match with multiple missing characters
```

If no other path follows better always add a `#` at the end to prevent problems
if last separsator is a whitespace.


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
- `values` - array of possible values (complete text)
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

### array

__Sanitize options:__

- `delimiter` - allow value text with specified list separator
  (it can also be an regular expression)
- `toArray` - will convert single values into array with one element

__Check options:__

- `notEmpty` - set to true if an empty array is not valid
- `minLength` - minimum number of entries
- `maxLength` - maximum number of entries

__Validating children:__

- `entries` - default specification for all entries
- `list` - specification for entries per each key number

### object

For all complex data structures you use the object type which checks for named
arrays or instance objects.

This is the most complex validation form because it has different checks and
uses subchecks on each entry.

__Options:__

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

Alternative-/Multiple Checks
-------------------------------------------------

### or

This is used to give some alternatives from which at least one check have to
succeed. The first one succeeding will work.

__Option:__

- `or` - (array) with different check alternatives

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

### file

Check the value as valid file or directory entry.

__Sanitize options:__

- `basedir` - (string) relative paths are calculated from this directory
- `resolve` - (bool) should the given value be resolved to a full path

__Check options:__

- `exists` - (bool) true to check for already existing entry
- `find` - (array or function) list of directories in which to search for the file
  The function should return an array if called without parameters.
- `filetype` - (string) check against inode type: f, file, d, dir, directory, l, link

### handlebars

You may also add a text which may contain [handlebars](http://handlebarsjs.com/)
syntax. This will be compiled into a function which if called with the context
object will return the resulting text.

``` coffee
validator.check
  name: 'test'        # name to be displayed in errors (optional)
  value: 'hello {{name}}' # value to check
  schema:             # definition of checks
    type: 'handlebars'
, (err, result) ->
  # then use it
  console.log value
    name: 'alex'
  # this will output 'hello alex'
```

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

The value has to be a IP address.

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

### regexp

Check that the given value is a regular expression. If a text is given it will be
compiled into an regular expression.


Package structure
-------------------------------------------------
The validator is implemented as `index` which has the public available methods,
`check` is used for the real check calls and each type has it's own module
with the implementation loaded on demand (type-subfolder).


License
-------------------------------------------------

Copyright 2014-2015 Alexander Schilling

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

>  <http://www.apache.org/licenses/LICENSE-2.0>

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
