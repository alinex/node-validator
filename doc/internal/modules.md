# Technologies

This module is mainly __asynchronous through promises__. That makes it possible to
also include remote calls or file reads deep in the structure.


## Modules

Within this module especially the following foreign modules are used in production.

For the validation:
- [striptags](https://github.com/ericnorris/striptags/blob/master/README.md)
  to remove the HTML/XML tags from a string
- [numeral](http://numeraljs.com/)
  used to format numbers
- [convert-units](https://github.com/ben-ng/convert-units)
  used for unit support in numbers
- [moment-timezone](https://momentjs.com/)
  used to parse, check and format date and time
- [chrono-node](https://www.npmjs.com/package/chrono-node)
  natural language date parsing
- [ipaddr.js](https://www.npmjs.com/package/ipaddr.js)
  IP address parsing, checking and conversion
- [minimatch](https://www.npmjs.com/search?q=minimatch)
  glob like pattern matching
- [punycode](https://www.npmjs.com/package/punycode)
  conversion of international domain names

For the core system:
- [yargs](http://yargs.js.org/)
  command line parsing
- [glob](https://www.npmjs.com/search?q=glob)
  support for glob pattern loading of data
- [request-promise-native](https://github.com/request/request-promise-native/blob/master/README.md)
  load data from web
- [ssh2](https://www.npmjs.com/package/ssh2)
  load data from remote host

Structural helper:
- [alinex-core](http://alinex.github.io/node-alinex/README.md.html)
  process error management
- [alinex-format](http://alinex.github.io/node-util/README.md.html)
  support different configuration formats for parsing
- [alinex-util](http://alinex.github.io/node-util/README.md.html)
  for some functions in array and object manipulation
- [debug](https://www.npmjs.com/search?q=debug)
  debugging through environment setting
- [chalk](https://www.npmjs.com/package/chalk)
  colorful output
- [es6-promisify](https://www.npmjs.com/package/es6-promisify)
  support for `util.promisify` which comes with NodeJS 8

Seldom or only for specific options used modules are loaded on demand instead of on initializing.
