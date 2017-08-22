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
  https://img.shields.io/travis/alinex/node-validator.svg?maxAge=86400&label=develop)](
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

This module will help validating complex structures. And should be used on all
external information.

- easy build class based schema definitions
- multiple predefined types
- easy to extend schema types
- check value against schema
- supports sanitization and optimization
- also possible in deep and complex data structures
- can give a human readable description
- supports dependency checks
- transform schema and values

The schema based definition using instances of the predefined schema classes gives
the opportunity to define a detailed structure step by step. Later you can run the
check of this created schema structure on your data structure.

This is mostly used in configuration there it will preparse all settings and check
them before running and use them. It will give a detailed description of the problems
if there are some. It can also save the result as pure JavaScript files to be imported
at runtime without the necessary to recheck them.

This library can help you make your life secure and easy but you have to run
every external data through it using a detailed data description. If you do so
you can trust and use the values as they are without further checks.
And you'll get the benefit of automatically optimized values like for `handlebars`
type you get a ready to use handlebar function back.

__Read the complete documentation under
[https://alinex.gitbooks.io/validator](https://alinex.gitbooks.io/validator)__


## Usage

Coming soon...


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
