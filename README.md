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


Install
-------------------------------------------------

The easiest way is to let npm add the module directly:

    > npm install alinex-validator --save

[![NPM](https://nodei.co/npm/alinex-validator.png?downloads=true&stars=true)](https://nodei.co/npm/alinex-validator/)


Usage
-------------------------------------------------

To use the validator you have to first include it:

``` coffee
validator = require 'alinex-validator'
```

All checks are called with:

- a `source` which should specify where the value comes from and is used in error
  reporting.
- the `value` to check
- an `options` array which specifies what to check
- and optionally a `callback` function

Most checks are synchronous and may be called synchronously or asynchronously.
Only if an asynchronous check is called synchronously it will throw an Error.

The checks are split up into several packages to load on demand.

__Synchronous call:__

``` coffee
value = validator.check 'test', value,
  type: 'integer'
  min: 0
  max: 100
```

You get the value directly back but if something goes wrong or the check fails
it will throw an error which you could catch.

__Asynchronous call:__

``` coffee
validator.check 'test', value,
  type: 'integer'
  min: 0
  max: 100
, (err, value) ->
  if err
    # error handling
  else
    # do something with value
```

Here you will get the error directly in the callback in the default manner
of asynchronous calls.

### Only test

If you won't change the value it is possible to call a simplified form:

``` coffee
if validator.is 'test', value,
    type: 'integer'
    min: 0
    max: 100
  # do something
```

### Get description

This method may be used to get a human readable description of how a value
has to be to validate.

``` coffee
console.log validator.describe
  type: 'integer'
  min: 0
  max: 100
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

Optional values
-------------------------------------------------
All types (excluding boolean) support the `optional` parameter, which makes an
entry in the data structure optional.
If not given it will be set to null or the value given with `default`.

- `optional` - the value must not be present (will return null)
- `default` - value used if optional and no value given

The `default` option automatically makes the setting optional.


References
-------------------------------------------------
It is also possible to use references instead of values in the validation rules
or values.

References are written as object with:

- `REF` - the only needed key which contain a list of reference locations
- `VAL` - specifies a default value if no reference found
- `FUNC` - can additionally be used with a function optimizing the value
  it will be called with the value and the path it comes from

Reference locations are objects with:

- `source` - the type of references (struct, data, env, file)
- `path` - the path to the reference (source specific)
- `type` - if a check should be done give the type...

Other keys may follow specific to the type checks.

__STRUCT references__

They are used to specify another element in the value structure. The path specifies
where to find it. If you use this source type you won't need the checks within the
reference because the values will already get checked. The validator will guaranty
that values are used as reference after they are checked.

The path is calculated from the viewpoint of the current parent element. That means
giving a name it will look at the sibling node but you may go up/down the tree:

- `xxx` - to specify the value sibling value from the given one
- `/xxx.yyy` - to specify a value from the structure by absolute path
- `/xxx.*.yyy` - specify a value in any of the subelements of xxx
- `/xxx.**.yyy` - specify a value in any of the subelements also multiple levels deep
- `/xxx.zz*.yyy` - specify a value in any of the subelements which start with zz
- `<xxx.yyy` - to specify the value based from the parent of the operating object
- `<<xxx.yyy` - to specify the value based from the grandparent of the operating object

__DATA references__

The DATA values may be given as additional data to the validator. If so you may
access it with the same path specifier as for `struct` but paths are always absolute
here.

__ENV references__

You can also use some environment settings as reference. For this source type only
give the name of the environment variable as path. But keep in mind to better check
the type of it's content, too.

__FILE references__

And at last you can read the content of a simple text file as value. The path points
to the file and have to be an absolute path.
Maybe you have to do some type checks here, too.

In this type of references the system will cache the file contents for a short time
to prevent multiple read and gain better performance.

### How it works

Use it everywhere you may need it but prevent round referencing in which it reference
itself through other references.

__In check definitions__

Before doing a check or a subcheck it's options are checked for references if there
is one:

- go through the reference list
- get the reference and do the accompanying check (if there is one)
- use this as an value if it is found and succeeded in check
- if not go on to the next reference from the list
- if no value found use the default value
- if an operation is given run it with the value
- give back the resulting reference check

__In value structures__

Every value will be checked if it is a reference. If so it will:

- go through the reference list
- get the reference and do the accompanying check (if there is one)
- use this as an value if it is found and succeeded in check
- if not go on to the next reference from the list
- if no value found use the default value
- if an operation is given run it with the value
- go on to the validation check with the resulting value

__Default value__

A value will be searched in each given reference till one is found. If nothing
found the `VAL` setting is used or nothing.

### Example in definition

If used in check definitions it may need a second validation round but this is done
automatically in the background. Mostly you may need the references as comparing
value for some checks or as an default value.

``` coffee
validator.check 'test', value,
  type: 'object'
  title: 'Range'
  description: 'the range to use'
  entries:
    min:
      type: 'integer'
    max:
      type: 'integer'
      min:
        REF: [
          source: 'env'
          path: 'MINVAL'
          type: 'integer'
          min: 0
        ,
          source: 'struct'
          path: 'min'
        ]
        FUNC: (val) -> val + 1
```

The above check condition will check that the given `max` value is at least one
above the `min` value.

### Example in check values

Within the values the use is the same.

``` coffee
validator.check 'test',
  database: 'test'
  host:
    REF: [
      source: 'env'
      path: 'MYSQL_HOST'
    ]
    VAL: 'localhost'
  user:
    REF: [
      source: 'env'
      path: 'MYSQL_USER'
    ]
    VAL: 'localhost'
  password:
    REF: [
      source: 'env'
      path: 'MYSQL_PASS'
    ,
      source: 'env'
      path: 'MYSQL_PAsSWORD'
    ,
      source: 'file'
      path: '/etc/mysql/access.password'
    ]
```

This also shows that one or more references can be added and also with different
reference types.

Descriptive reporting
-------------------------------------------------
To get even more descriptive reporting it is possible to set a title and abstract
for the given field in the configuration. This will be used in error reporting
and `describe()` calls.

``` coffee
validator.check 'test', value,
  type: 'float'
  title: 'Overall Timeout'
  description: 'time in milliseconds the whole test may take'
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
different types. This will help you to find problems in your development.
To do this you have to add it in your tests:

__Mocha coffee example:__

``` coffee
# ...
it "should has correct validator rules", ->
  validator.selfcheck 'config', MyObject.config
# ...
```


Basic Check Types
-------------------------------------------------

### boolean

The value has to be a boolean. The value will be true for 1, 'true', 'on',
'yes' and it will be considered as false for 0, 'false', 'off', 'no', null and
undefined.
Other values are not allowed.

__Validate options:__

- `class` - (boolean) only a class or only a normal function is valid

__Example:__

``` coffee
value = Validator.check 'verboseMode', value,
  type: 'boolean'
```

### function

The value has to be a function.
Other values are not allowed.

__Options:__ None

__Example:__

``` coffee
value = Validator.check 'callback', value,
  type: 'function'
```

### string

This will test for strings and have lots of sanitize and optimization filters
and also different check settings to use.

__Sanitize options:__

- `tostring` - convert objects to string, first
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

### integer

To test for integer values which may be sanitized.

__Sanitize options:__

- `sanitize` - (bool) remove invalid characters
- `unit` - (string) unit to convert to if no number is given
- `round` - (bool) rounding of float can be set to true for arithmetic rounding
  or use `floor` or `ceil` for the corresponding methods

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
- `round` - (int) number of decimal digits to round to

__Check options:__

- `min` - (numeric) the smalles allowed number
- `max` - (numeric) the biggest allowed number

### array

__Sanitize options:__

- `delimiter` - allow value text with specified list separator
  (it can also be an regular expression)

__Check options:__

- `notEmpty` - set to true if an empty array is not valid
- `minLength` - minimum number of entries
- `maxLength` - maximum number of entries

__Validating children:__

- `entries` - specification for all entries or as array for each element

### object

For all complex data structures you use the object type which checks for named
arrays.

__Options:__

- `instanceOf` - (class) only objects of given class type are allowed
- `mandatoryKeys` - (list) the list of elements which are mandatory
- `allowedKeys` - (list) gives a list of elements which are also allowed
   or true to use the list from entries definition
- `entries` - specification for all entries or specific to the key name

So you have three different ways to specify objects. First you may have class
instances as the object. Then you only can use the `instanceOf` check.

``` coffee
value = Validator.check 'callback', value,
  type: 'object'
  instanceOf: RegExp
```

Next you may have an object in which you only want to specify what attributes
it should have but not checking the attribute values:

``` coffee
value = Validator.check 'callback', value,
  type: 'object'
  mandatoryKeys: ['name']
  allowedKeys: ['mail', 'phone']
```

If you don't specify `allowedKeys` more attributes with other names are possible.

And the last and most complex situation is a deep checking structure:

``` coffee
value = Validator.check 'callback', value,
  type: 'object'
  allowedKeys: true
  entries:
    name:
      type: 'string'
    mail:
      type: 'string'
      optional: true
    phone:
      type: 'string'
      optional: true
```

Here `allowedKeys` will check that no attributes are used which are not specified
in the entries. Which attribute is optional may be specified within the attributes
specification. That means this check is the same as above but also checks that the
three attributes are strings.

### any

This is used to give some alternatives from which at least one check have to
succeed. The first one succeeding will work.

__Option:__

- `entries` - (array) with different check alternatives

### and

This is used to give multiple rules which will be executed in a series and
all have to succeed.

__Option:__

- `entries` - (array) with multiple check rules


Additional Check Types
-------------------------------------------------

### byte

To test for byte values which may contain prefixes like `18M` or `6.2 GB`.

__Sanitize options:__

- `unit` - (string) unit to convert to if no number is given: B, kB, Byte, b, bps, bits, ...

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
  # first do the validation
  value = validator.check 'test',
    type: 'handlebars'
  , 'hello {{name}}'
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
- `round` - (bool) rounding of float can be set to true for arithmetic rounding
  or use `floor` or `ceil` for the corresponding methods

__Check options:__

- `min` - (integer) the smalles allowed number
- `max` - (integer) the biggest allowed number

### ipaddr

The value has to be a IP address.

__Check options:__

- `version` - one of 'ipv4' or 'ipv6' and the value will be converted, if possible
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

- `round` - (int) number of decimal digits to round to

__Check options:__

- `min` - (numeric) the smalles allowed number
- `max` - (numeric) the biggest allowed number

### regexp

Check that the given value is a regular expression. If a text is given it will be
compiled into an regular expression.


Complete Example
-------------------------------------------------

The following check structure comes from an coffee script program which
checks it's configuration file.

``` coffee
title: "Monitoring Configuration"
type: 'object'
allowedKeys: ['runat', 'contacts', 'email']
entries:
  runat:
    title: "Location"
    description: "the location of this machine to run only tests which have
      the same location or no location at all"
    type: 'string'
    optional: true
  contacts:
    title: "Contacts"
    description: "the possible contacts to be referred from controller for
      email alerts"
    type: 'object'
    entries:
      type: 'any'
      entries: [
        title: "Contact Group"
        description: "the list of references in the group specifies the individual
          contacts"
        type: 'array'
        entries:
          type: 'string'
      ,
        title: "Contact Details"
        description: "the name and email address for a specific contact"
        type: 'object'
        mandatoryKeys: ['email']
        allowedKeys: ['name']
        entries:
          type: 'string'
      ]
```


Package structure
-------------------------------------------------
The validator is implemented as `index` which has the public available methods,
`helper` which is used for all data exchange and calls the real check
implementations.


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
