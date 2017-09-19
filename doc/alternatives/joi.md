# Joi

The validator [Joi](https://github.com/hapijs/joi) comes from the Hapi server
component. It uses a function based schema creation.

```js
const Joi = require('joi');

const schema = Joi.object().keys({
    username: Joi.string().alphanum().min(3).max(30).required(),
    password: Joi.string().regex(/^[a-zA-Z0-9]{3,30}$/),
    access_token: [Joi.string(), Joi.number()],
    birthyear: Joi.number().integer().min(1900).max(2013),
    email: Joi.string().email()
}).with('username', 'birthyear').without('password', 'access_token');

// Return result.
const result = Joi.validate({ username: 'abc', birthyear: 1994 }, schema);
// result.error === null -> valid
```

It has a really good API which is clear to use with lots of possibilities also
like references.

## Feature comparison

The following table shows all Joi features and the identical or nearest way to reach the same using
alinex-validator.

> The code examples are only pseudo code to make it shorter

| Joi V 10.6.0 | Alinex |
| --- | ------ |
| option: `abortEarly` (true) | true |
| option: `convert` (true) | schema defined (true) |
| option: `allowUnknown` (false) | - |
| option: `skipUnknown` (false) | `object.removeUnknown` (false) |
| option: `skipFunctions` (true) | - |
| option: `language` (overwrite errors) | - |
| option: `presence` (optional) | default always optional |
| option: `context` | `ref(context)` |
| option: `noDefaults` (false) | - |
| `ref(key)` | `ref().path(key)` |
| `reach(schema, path)` | `schema(path)` |
| `any` | `any` |
| `any.allow(value)` | `any.allow(value)` |
| `any.valid(value)` | `any.valid(value)` |
| `any.invalid(value)` | `any.invalid(value)` |
| `any.required()` | `any.required()` |
| `any.optional()` | true unless `any.required()` |
| `any.forbidden()` | maybe use `any.denyUnknown()` |
| `any.strip()` | - |
| `any.description(value)` | `any(title, description)` |
| `any.notes(value)` | - |
| `any.tags(value)` | - |
| `any.meta(value)` | - |
| `any.example(value)` | - |
| `any.unit(name)` | `number.unit(name).toUnit(name)` |
| `any.options(value)` | - |
| `any.default(value)` | `any.default(value)` |
| `any.concat(schema)` | `logic.allow(schema1).or(schema2)` |
| `any.when` | use alternative schemas with `logic.allow(schema1).or(schema2)` |
| `any.label(name)` | `any(title)` |
| `any.raw()` | `any.raw()` |
| `any.empty(schema)` | `any.stripEmpty()` |
| `any.error(err)` | - |
| `array` | `array` |
| `array.sparse()` | default and can be removed by setting `array.filter()` |
| `array.single()` | `array.toArray()` |
| `array.items(schema)` | `array.item(schema)` |
| `array.items(schema, schema)` | `array.unordered().item(schema).item(schema)` |
| `array.ordered(schema, schema)` | `array.item(schema).item(schema)` |
| `array.min(limit)` | `array.min(limit)` |
| `array.max(limit)` | `array.max(limit)` |
| `array.length(limit)` | `array.length(limit)` |
| `array.unique(comparator)` | `array.unique()` |
| `boolean` | `boolean` |
| `boolean.truthy(list)` | `boolean.truthy(list)` |
| `boolean.falsy(list)` | `boolean.falsy(list)` |
| `boolean.insensitive()` | `boolean.insensitive()` |
| `binary` | included in `any` |
| `binary.encoding(enc)` | - |
| `binary.min(length)` | - |
| `binary.max(length)` | - |
| `binary.length(length)` | - |
| `date` | `date` |
| `date.min(date)` | `date.min(date)` |
| `date.max(date)` | `date.max(date)` |
| `date.iso()` | `date.format('ISO8601')` |
| `date.timestamp()` | `date.format('milliseconds')` |
| `date.timestamp('unix')` | `date.format('seconds')` |
| `func` | `function` |
| `func.arity(length)` | `function.length(limit)` |
| `func.minArity(length)` | `function.min(length)` |
| `func.maxArity(length)` | `function.max(length)` |
| `func.ref()` | - |
| `number` | `number` |
| `number.min(limit)` | `number.min(limit)` |
| `number.max(limit)` | `number.max(limit)` |
| `number.greater(limit)` | `number.greater(limit)` |
| `number.less(limit)` | `number.less(limit)` |
| `number.integer()` | `number.integer()` |
| `number.precision(limit)` | `number.round(precision)` |
| `number.multiple(base)` | `number.multiple(base)` |
| `number.positive()` | `number.positive()` |
| `number.negative()` | `number.negative()` |
| `object` | `object` |
| `object.keys(schemaMap)` | `object.key(name, schema).key(name, schema)` |
| `object.min(limit)` | `object.min(limit)` |
| `object.max(limit)` | `object.max(limit)` |
| `object.length(limit)` | `object.length(limit)` |
| `object.pattern(re, schema)` | `object.key(re, schema)` |
| `object.and(peers)` | `object.and(peers)` |
| `object.nand(peers)` | `object.nand(peers)` |
| `object.or(peers)` | `object.or(peers)` |
| `object.xor(peers)` | `object.xor(peers)` |
| `object.with(key, peers)` | `object.with(key, peers)` |
| `object.without(key, peers)` | `object.without(key, peers)` |
| `object.rename(from, to)` | `object.move(from, to)` |
| `object.assert(ref, schema)` | `logic.if(schema(ref))` |
| `object.unknown()` | `object.removeUnknown()` |
| `object.type(constructor)` | - |
| `object.schema()` | - |
| `object.requiredKeys()` | `object.requiredKeys()` |
| `object.forbiddenKeys()` | `object.forbiddenKeys()` |
| `object.optionalKeys()` | define keys and use `object.denyUnknown()` |
| `string` | `string` |
| `string.insensitive()` | done through regexp |
| `string.min(limit)` | `string.min(limit)` |
| `string.max(limit)` | `string.max(limit)` |
| `string.truncate()` | `string.truncate()` |
| `string.creditCard()` | - |
| `string.length(limit)` | `string.length(limit)` |
| `string.regex(re)` | `string.match(re)` |
| `string.replace(re, text)` | `string.replace(re, text)` |
| `string.alphanum()` | `string.alphanum()` |
| `string.token()` | `string.match(/^[A-Za-z0-9_]*$/)` |
| `string.email()` | `email` |
| `string.ip()` | `ip` |
| `string.uri()` | `url` |
| `string.guid()` | - |
| `string.hex()` | `string.hex()` |
| `string.base64()` | - |
| `string.hostname()` | `domain` |
| `string.lowercase()` | `string.lowercase()` |
| `string.uppercase()` | `string.uppercase()` |
| `string.trim()` | `string.trim()` |
| `string.isoDate()` | `date.format('ISO8601')` |
| `alternatives` | `logic` |
| `alternatives.try([schema1, schema2])` | `logic.allow(schema1).or(schema2)` |
| `alternatives.when('b', { is: 5, then: Joi.string(), otherwise: Joi.number() })` | `logic.if(any(ref.path(b)).allow(5)) .then(string).else(number))` |
| `lazy(fn)` | naturally possible |

This may help to decide what to use and how to transform a schema. Not included is what alinex
can do and Joi can't.
