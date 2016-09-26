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
