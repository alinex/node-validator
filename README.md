# Alinex Validator

[![GitHub watchers](
  https://img.shields.io/github/watchers/alinex/node-validator.svg?style=social&label=Watch&maxAge=86400)](
  https://github.com/alinex/node-validator/subscription)
[![GitHub stars](
  https://img.shields.io/github/stars/alinex/node-validator.svg?style=social&label=Star&maxAge=86400)](
  https://github.com/alinex/node-validator)
[![GitHub forks](
  https://img.shields.io/github/forks/alinex/node-validator.svg?style=social&label=Fork&maxAge=86400)](
  https://github.com/alinex/node-validator)

[![npm package](
  https://img.shields.io/npm/v/alinex-validator.svg?maxAge=86400&label=latest%20version)](
  https://www.npmjs.com/package/alinex-validator)
[![latest version](
  https://img.shields.io/npm/l/alinex-validator.svg?maxAge=86400)](
  #license)
[![Travis status](
  https://img.shields.io/travis/alinex/node-validator.svg?maxAge=86400&label=test)](
  https://travis-ci.org/alinex/node-validator)
[![Codacy Badge](
  https://api.codacy.com/project/badge/Grade/6f53f689f1c447f3a9ce2ee8a3463fcb)](
  https://www.codacy.com/app/alinex/node-validator/dashboard)
[![Coverage status](
  https://img.shields.io/coveralls/alinex/node-validator.svg?maxAge=86400)](
  https://coveralls.io/r/alinex/node-validator)
[![Gemnasium status](
  https://img.shields.io/gemnasium/alinex/node-validator.svg?maxAge=86400)](
  https://gemnasium.com/alinex/node-validator)
[![GitHub issues](
  https://img.shields.io/github/issues/alinex/node-validator.svg?maxAge=86400)](
  https://github.com/alinex/node-validator/issues)

The ultimate validation library for javascript!

This module will help validating complex structures. And should be used on all external information.
Like configuration or user input. It's strength are very complex structures but as easily it works
with simple things. It's the best validator ever, see the comparison with others later.

- class based schema definitions
- multiple predefined types
- multiple options per type
- __check and transform__ values
- specialized in deep and complex data structures
- supports __dependency checks__ with references
- can give a human readable description
- command line interface (cli)
- including data loading
- precompile JSON config for any system

The core builds a __schema__ which is build as combination of different type instances from the schema
classes. This schema builder mechanism allows to setup complex structures with optimizations
and logical validation. It can be build step by step, cloned and redefined...

With such a schema you can directly __validate__ your data structure or use it to load and validate
data structure or to transform them into optimized JSON data files using the command line interface.
A schema can also describe itself human readable for users to describe what is needed.
If some value failed an error message is given with reference to the original value and the
description what failed and what is needed.

This library can help you make your life secure and easy but you should have to
define your data structure deeply, before. If you do so
you can trust and use the values as they are without further checks.
And you'll get the benefit of automatically optimized values and easy to use configuration files back.

You may also split up complex configuration files for any system into multiple files which are
combined together by the validator after each change.

__Read the complete documentation under
[https://alinex.gitbooks.io/validator](https://alinex.gitbooks.io/validator)__


## Usage

Install to use as module:

    npm install alinex-validator

or install it globally:

    npm install -g alinex-validator


### Create Schema

Now you can define your schema specification like:

```js
// config.schema.js

// @flow
import * as val from 'alinex-validator/dist/builder'

const schema = new val.Object()
  .key('title', new val.String().allow(['Dr.', 'Prof.']))
  .key('name', new val.String().min(3).required())
  .key('street', new val.String().min(3).required())
  .key('plz', new val.Number().required()
    .positive().max(99999)
    .format('00000'))
  .key('city', new val.String().required().min(3))

module.exports = schema
```

### Validating using API

```js
import validator from 'alinex-validator'

import schema from './config.schema.js'

validator.searchApp('myApp') // search in /etc/myApp or ~/.myApp
const data = validator.load('config/**/*.yml')

schema.validate(data)
  .then((data) => {
    console.log(data)
  })
  .catch((err) => {
    console.error(err.text())
  })
```

### Use the CLI

Transform into an optimized JSON structure:

    validator -i *.yml -s schema.js -o config.json

This will load all *.yml files in the current directory, validate it through the given schema and
store the resulting data structure to a JSON file.

This can be used to validate and optimize a configuration before using them. If you want to use this
in JavaScript you can use:

```js
import config from './config.json'
```

Read more in the complete [manual](https://alinex.gitbooks.io/validator)...


## License

(C) Copyright 2014-2017 Alexander Schilling

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

>  <http://www.apache.org/licenses/LICENSE-2.0>

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
