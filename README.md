Package: alinex-validator
=================================================

[![Build Status] (https://travis-ci.org/alinex/node-validator.svg?branch=master)](https://travis-ci.org/alinex/node-validator)
[![Coverage Status] (https://coveralls.io/repos/alinex/node-validator/badge.png?branch=master)](https://coveralls.io/r/alinex/node-validator?branch=master)
[![Dependency Status] (https://gemnasium.com/alinex/node-validator.png)](https://gemnasium.com/alinex/node-validator)

This module will help validating complex structures. And may be used for all
external information.

- check value against options configuration
- understandable errors
- easy checking of values
- may check complex structures
- can give a human readable description

The validation rules are really simple, but they will get more complex as your
data structure gains complexity.

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

    var validator = require('alinex-validator');

All checks are called with:

- a `source` which should specify where the value comes from and is used in error
  reporting.
- the `value` to check
- an `options` array which specifies what to check
- and optionally a `callback` function

Most checks are synchronous and may be called synchronously or asynchronously.
Only if an asynchronous check is called synchronously it will throw an Error.

Synchronous call:

    var value = validator.check('test', value, {
      type: 'integer',
      min: 0,
      max: 100
    });

Asynchronous call:

    validator.check('test', value, {
      type: 'integer',
      min: 0,
      max: 100
    }, function(err, value) {
      if (err) {
        // error handling
      } else  {
        // do something with value
      }
    });

The checks are split up into several packages to load on demand.

### Only test

If you won't change the value it is possible to call a simplified form:

    if (validator.is('test', value, {
      type: 'integer',
      min: 0,
      max: 100
    })) {
      // do something
    };

### Get description

This method may be used to get a human readable description of how a value
has to be to validate.

    console.log validator.describe({
      type: 'integer',
      min: 0,
      max: 100
    });


Optional values
-------------------------------------------------
All types (excluding boolean) support the `optional` parameter, which makes an
entry in the data structure optional.
If not given it will be set to null or the value given with `default`.

- `optional` - the value must not be present (will return null)
- `default` - value used if optional and no value given

The `default` option automatically includes the `optional` option.


References
-------------------------------------------------
It is also possible to use references instead of values in the validation rules.
They are written as object with:

- `reference` - the type of reference: absolute, relative, external
- `source` - the path to get the value
- `operation` - function which will be used on retrieved value

External references will be checked against the data element given to the validator.


Descriptive reporting
-------------------------------------------------
To get even more descriptive reporting it is possible to set a title and abstract
for the given field in the configuration. This will be used in error reporting
and `describe()` calls.

    validator.check('test', value, {
      type: 'float',
      title: 'Overall Timeout',
      description: 'time in milliseconds the whole test may take',
      min: 500
    }, function(err, value) {
      if (err) {
        // there will be the error
      } else  {
        // do something with value
      }
    });

This may result in the following error:

> Failed: The value is to low, it has to be at least 500 in test.timeout for "Overall Timeout".
> It should contain the time in milliseconds the whole test may take.


Selfchecking Options
-------------------------------------------------
It is also possible to let your complex options be validated against the
different types. This will help you to find problems in your development.
To do this you have to add it in your tests:

__Mocha coffee example:__

    ...
    it "should has correct validator rules", ->
      validator.selfcheck 'config', MyObject.config
    ...


Possible Types
-------------------------------------------------

### boolean

The value has to be a boolean. The value will be true for 1, 'true', 'on',
'yes' and it will be considered as false for 0, 'false', 'off', 'no', null and
undefined.
Other values are not allowed.

__Validate options:__

- `class` - (boolean) only a class or only a normal function is valid

__Example:__

    var value = Validator.check('verboseMode', value, {
      type: 'boolean'
    });

### function

The value has to be a function.
Other values are not allowed.

__Options:__ None

__Example:__

    var value = Validator.check('callback', value, {
      type: 'function'
    });

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
- `round` - (int) number of decimal digits to round to

__Check options:__

- `min` - (numeric) the smalles allowed number
- `max` - (numeric) the biggest allowed number

### byte

To test for byte values which may contain prefixes like `18M` or `6.2 GB`.

__Validate options:__

- `min` - (integer) the smalles allowed number
- `max` - (integer) the biggest allowed number

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

__Check options:__

- `instanceOf` - only objects of given class type are allowed
- `mandatoryKeys` - the list of elements which are mandatory
- `allowedKeys` - gives a list of elements which are also allowed
   or true to use the list from entries definition

__Validating children:__

- `entries` - specification for all entries or specific to the key name

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

### percent

Nearly the same as float but values which are given as string using the % sign
like 50% are converted to floats like 0.5.

__Sanitize options:__

- `round` - (int) number of decimal digits to round to

__Check options:__

- `min` - (numeric) the smalles allowed number
- `max` - (numeric) the biggest allowed number


Complete Example
-------------------------------------------------

The following check structure comes from an coffee script program which
checks it's configuration file.

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


Package structure
-------------------------------------------------
The validator is implemented as `index` which has the public available methods,
`helper` which is used for all data exchange and calls and the real check
implementations.


License
-------------------------------------------------

Copyright 2014 Alexander Schilling

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

>  <http://www.apache.org/licenses/LICENSE-2.0>

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
