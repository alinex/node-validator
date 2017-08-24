# Ideas

Here you find a collection of further ideas which may be realized as soon as anybody needs them.

General
- allow using JSON Schema
- RDBMS data loader URIspecific file
- value in constructor will be used instead of data.value

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
- requiredIf(schema)
- forbiddenIf(schema)

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
- if(schema) // like and but with different values
- then(schema)
- else(schema)

- is required and forbidden allowed here?



required_if:anotherfield,value
The field under validation must be present and not empty if the anotherfield field is equal to any value.

logic.allow(schema(ref().path(anotherfield)))
.if(any.allow(value))
.then(schema.required())
