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










Further Ideas
-------------------------------------------------

### Database (to be implemented later)

This connector is not implemented so far and will come in one of the next
releases. But in the example below I show how it will be used.

``` text
<<<mysql://user:password@host:port/database/table/id=15/field>>>
<<<mysql:///dataname/table/id=15/field>>>
<<<mysql:///dataname/select name from xxx where id=15>>>
```


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
