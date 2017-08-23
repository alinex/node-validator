# Ideas

Here you find a collection of further ideas which may be realized as soon as anybody needs them.

General
- allow using JSON Schema
- RDBMS data loader URIspecific file

Reference
- RDBMS as reference base
- SFTP as reference base
- SSH as reference base

Array
- array.filter(schema).sanitize() fail or remove all which not validate
- array.exclude(schema).sanitize() fail or remove all which validate

Object
- move() change key name (Joi rename)
- copy()

Number
- locale support parse/format

File
- min/max/greater/less as filesize (validatorjs)

Specific Types
- email (joi, validatorjs)
- ip (joi)
- creditcard (joi)
- uri (joi, validatorjs)
- hostname (joi)
- handlebars

Logic
- when(ref, schemaCheck, ifValue, elseValue) (joi alternative.when)
- object.when(a, v, [b,c]) // if a equal v then b,c required (validatorjs require-if)
- object.whenNot (validatorjs require-unless)
- // if any/all of a,b then required or disallowed c,d
