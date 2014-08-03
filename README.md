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

- a `name` which should specify where the value comes from and is used in error
  reporting.
- the `value` to check
- an `options` array which specifies what to check
- and optionally a `callback` function

Most checks are synchronous and may be called synchronously or asynchronously.
Only if an asynchronous check is called synchronously it will throw an Error.

Synchronous call:

    var value = Validator.check('test', value, {
      type: 'type.integer',
      options: {
        minvalue: 0,
        maxvalue: 100
      }
    });

Asynchronous call:

    Validator.check('test', value, {
      type: 'type.integer',
      options: {
        minvalue: 0,
        maxvalue: 100
      }
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

    if (Validator.is('test', value, {
      type: 'type.integer',
      options: {
        minvalue: 0,
        maxvalue: 100
      }
    })) {
      // do something
    };

### Get description

This method may be used to get a human readable description of how a value
has to be to validate.

    console.log Validator.describe({
      type: 'type.integer',
      options: {
        minvalue: 0,
        maxvalue: 100
      }
    });


Type checks
-------------------------------------------------
This package contains the basic checks which consists of some of the basic
language types with different options.

### type.boolean

The value has to be a boolean. The value will be true for 1, 'true', 'on',
'yes' and it will be considered as false for 0, 'false', 'off', 'no', '.
Other values are not allowed.

__Options:__ None

__Example:__

    var value = Validator.check('verboseMode', value, {
      type: 'type.boolean'
    });

### type.string

This will test for strings and have lots of sanitize and optimization filters
and also different check settings to use.

__Sanitize options:__

- `allowControls` - keep control characters in string instead of
  stripping them (but keep \\r\\n)
- `replace` - list of replacements: string (only single replacement) or
  regular expressions and replacements as inner array
- `stripTags` - remove all html tags
- `trim` - strip whitespace from the beginning and end
- `crop` - crop text after number of characters
- `lowercase` - set to `true` or `first`
- `uppercase` - set to `true` or `first`

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

### type.integer
### type.float
### type.list
### type.enum
### type.set
### type.hash


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
