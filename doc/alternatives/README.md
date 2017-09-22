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

## String based Schema

[validatorjs](https://www.npmjs.com/package/validatorjs) is defined by a single string definition
per element

## Method based

[Joi](https://github.com/hapijs/joi) comes from the Hapi server component see more on the next
pages

## Object based

[Validate.js](https://validatejs.org/) uses a constraint setting as JavaScript
Object including injected reporting functions.

## Function based

[Object Schema](https://www.npmjs.com/package/object-schemata) simply validates data objects with
a schema including:
- a help message
- a user defined validator function
- a user defined transformer function

## Simple Validators

[Typed](https://www.npmjs.com/package/fully-typed) basically checks against specific types but has
also some settings to define value ranges...

[Valida](https://www.npmjs.com/package/valida) a collection of a few validation methods.

[Aproba](https://www.npmjs.com/package/aproba)

[Valido](https://www.npmjs.com/package/valido)

[Validotron](https://www.npmjs.com/package/validotron)

## Comparison Top 3

Here a basic comparison of alinex-validator against others is shown. You may also find more detailed
comparisons under each alternative's description (sub page). The values gives a hint, how complete in percent
the impleentation is.

| Type     | Alinex | Joi  | validatorjs |
| -------- | ------:| ----:| -----------:|
| Any        | 100% | 100% |        100% |
| Boolean    | 100% |  80% |         80% |
| String     |  90% |  90% |         60% |
| Number     | 100% |  70% |         40% |
| Array      | 100% | 100% |         10% |
| Object     |  90% |  90% |         70% |
| Function   | 100% | 100% |          0% |
| Date       | 100% |  20% |         30% |
| Logic      | 100% |  80% |         40% |
| Port       | 100% |   0% |          0% |
| IP         | 100% |  10% |          0% |
| Domain     | 100% |  10% |          0% |
| Email      | 100% |  20% |         20% |
| URL        | 100% |  40% |         40% |
| RegExp     | 100% |   0% |          0% |

| Feature  | Alinex | Joi  | validatorjs |
| -------- | ------:| ----:| -----------:|
| References | 100% |  20% |         20% |
| -> file    | 100% |   0% |          0% |
| -> cmd     | 100% |   0% |          0% |
| -> web     | 100% |   0% |          0% |
| Loading    | 100% |   0% |          0% |
| -> file    | 100% |   0% |          0% |
| i18n       |   5% |    ? |           ? |

The percentage values are an assumption how far the support of some type in comparison to the
complete possibilities in any of them goes.
