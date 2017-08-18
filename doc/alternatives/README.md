# Alternatives

Beside this module a lot of others exist which do mainly the same. With these pages I will give an
overview and comparison against them.


## JSON Schema based

[JSON Schema](http://json-schema.org/) allows to annotate and validate JSON documents.
The schema itself is build using JSON like the Alinex Validator did before.

- [Ajv](https://github.com/epoberezkin/ajv) is known as a very fast implementation of a JSON Schema
based validation
- [JSV](https://www.npmjs.com/package/JSV) is an extendable JSON Schema compliant implementation.
- [z-schema](https://www.npmjs.com/package/z-schema) is another implementation

## Function based

- [Joi](https://github.com/hapijs/joi) comes from the Hapi server component

## Other

[Object Schema](https://www.npmjs.com/package/object-schemata) simply validates data objects with
a schema including:
- a help message
- a validator function
- a transformer function

[Typed](https://www.npmjs.com/package/fully-typed) basically checks against specific types but has
also some settings to define value ranges...

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
