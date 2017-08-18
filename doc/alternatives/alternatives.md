# Alternatives

Beside this module a lot of others exist which do mainly the same. With these pages I will give an
overview and comparison against them.


## JSON Schema

Some of the validators are based on a schema defined using a JSON structure.
[JSON Schema](http://json-schema.org/) allows to annotate and validate JSON documents.
The schema itself is build using JSON like the Alinex Validator did before.

A schema looks like:

```json
{
  "$schema": "http://json-schema.org/draft-04/schema#",
  "title": "Product",
  "description": "A product from Acme's catalog",
  "type": "object",
  "properties": {
    "id": {
      "description": "The unique identifier for a product",
      "type": "integer"
    }
  },
  "required": ["id"]
}
```

### Ajv

[Ajv](https://github.com/epoberezkin/ajv) is known as a very fast implementation of a JSON Schema
based validation.

```js
import Ajv from 'ajv'

const schema = ... // load schema definition
const data = ... // load data structure

const ajv = new Ajv() // options can be passed, e.g. {allErrors: true}
const validate = ajv.compile(schema)
const valid = validate(data)
if (!valid) console.log(validate.errors)
```

### JSV

[JSV](https://www.npmjs.com/package/JSV) is an extendable JSON Schema compliant implementation.

```js
import JSV from 'JSV'

const schema = ... // load schema definition
const data = ... // load data structure

const env = JSV.createEnvironment()
const report = env.validate(data, schema)

if (report.errors.length === 0) {
	//JSON is valid against the schema
}
```

### z-schema

[z-schema](https://www.npmjs.com/package/z-schema) is another implementation:

```js
import ZSchema from 'z-schema'

const validator = new ZSchema()
validator.validate(json, schema, function (err, valid) {
    ...
})

const json = {};
const schema = { "$ref": "http://json-schema.org/draft-04/schema#" };

const valid = validator.validate(json, schema, (err, valid) => {
  // do something
})
```


## Object Schema

[Object Schema](https://www.npmjs.com/package/object-schemata) simply validates data objects with
a schema including:
- a help message
- a validator function
- a transformer function


## Typed

[Typed](https://www.npmjs.com/package/fully-typed) basically checks against specific types but has
also some settings to define value ranges...


## Simple Validators

The following validators are very simple and have only some checks:

- https://www.npmjs.com/package/aproba
- https://www.npmjs.com/package/valida





- https://github.com/tmpfs/async-validate
- https://www.npmjs.com/package/async-validator

- https://www.npmjs.com/package/Validator
- https://www.npmjs.com/package/validator
- https://www.npmjs.com/package/validator.js
- https://www.npmjs.com/package/validatorjs

See the following sections for short descriptions and comparisons.





## Validator.js

[Validator.js](https://validatejs.org/) uses a constraint setting as JavaScript
Object including injected reporting functions.

```js
var constraints = {
  username: {
    presence: true,
    exclusion: {
      within: ["nicklas"],
      message: "'%{value}' is not allowed"
    }
  },
  password: {
    presence: true,
    length: {
      minimum: 6,
      message: "must be at least 6 characters"
    }
  }
};

validate({password: "bad"}, constraints);
// => {
//   "username": ["Username can't be blank"],
//   "password": ["Password must be at least 6 characters"]
// }
```

This is a more basic way with less possibilities. A lot have to be programmed here
each time again.


## comparison

| Feature       | Alinex 2 | Alinex 3 |
| ------------- |:--------:|:--------:|
