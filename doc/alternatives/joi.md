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

| Feature | Joi | Alinex |
| ------- | --- | ------ |
| stop on error | option: `abortEarly` (true) | true |
| convert to required type | option: `convert` (true) | schema defined (true) |
| allow unknown keys | option: `allowUnknown` (false) | - |
| remove unknown keys | option: `skipUnknown` (false) | `object.removeUnknown` (false) |
| skip function value | option: `skipFunctions` (true) | - |
| override individual error messages | option: `language` | - |
| set default presence | option: `presence` (optional) | default always optional |
| reference context | option: `context` | `new Reference(context)` |
| disable defaults for validation | option: `noDefaults` (false) | - |
| reference to value | `ref(key)` | `new Reference().path(key)` |
| get subschema for path | `reach(schema, path)` | - |
| any type | `any` | `Schema` |
| any set: allow list | `any.allow(value)` | `any.allow(value)` |
| any set: valid entry | `any.valid(value)` | `any.valid(value)` |
| any set: invalid entry | `any.invalid(value)` | `any.invalid(value)` |
| any set: required | `any.required()` | `schema.required()` |
| any set: optional | `any.optional()` | true unless `schema.required()` |
| any set: forbidden | `any.forbidden()` | - |
| any set: strip after validation | `any.strip()` | - |
| any set: description | `any.description(value)` | `new Schema(title, description)` |
| any set: notes | `any.notes(value)` | - |
| any set: tags | `any.tags(value)` | - |
| any set: meta | `any.meta(value)` | - |
| any set: example | `any.example(value)` | - |
| any set: unit | `any.unit(name)` | `number.unit(name).toUnit(name)` |
| any set: options override | `any.options(value)` | - |
| any set: default | `any.default(value)` | `schema.default(value)` |
| any set: concat two schemas | `any.concat(schema)` | `logic.allow(schema1).or(schema2)` |
| any set: when condition | `any.when` | use alternative schemas with `logic.allow(schema1).or(schema2)` |
| any set: set label | `any.label(name)` | `new Schema(title)` |
| any set: return original value | `any.raw()` | - |
| any set: remove empty values | `any.empty(schema)` | `schema.stripEmpty()` |
| any set: individual error | `any.error(err)` | - |
| array type | `array` | `ArraySchema` |
| array set: allow undefined values | `array.sparse()` | default and can be removed by setting `array.stripEmpty()` |
| array set: single value as array | `array.single()` | `array.toArray()` |
| array set: items schema | `array.items(schema)` | `array.item(schema)` |
| array set: unordered item schemas | `array.items(schema, schema)` | `array.unordered().item(schema).item(schema)` |
| array set: ordered item schemas | `array.ordered(schema, schema)` | `array.item(schema).item(schema)` |
| array set: min elements | `array.min(limit)` | `array.min(limit)` |
| array set: max elements | `array.max(limit)` | `array.max(limit)` |
| array set: number elements | `array.length(limit)` | `array.length(limit)` |
| array set: need unique values | `array.unique(comparator)` | `array.unique()` |
| boolean type | `boolean` | `boolean` |
| boolean set: truthy value | `boolean.truthy(list)` | `boolean.truthy(list)` |
| boolean set: falsy value | `boolean.falsy(list)` | `boolean.falsy(list)` |
| boolean set: insensitive check | `boolean.insensitive()` | `boolean.insensitive()` |
| binary type | `binary` | included in `any` |
| binary set: encoding | `binary.encoding(enc)` | - |
| binary set: min | `binary.min(length)` | - |
| binary set: max | `binary.max(length)` | - |
| binary set: length | `binary.length(length)` | - |
| date type | `date` | `date` |
| date set: min | `date.min(date)` | `date.min(date)` |
| date set: max | `date.max(date)` | `date.max(date)` |
| date set: should be iso date | `date.iso()` | `date.format('ISO8601')` |
| date set: timestamp in milliseconds | `date.timestamp()` | `date.format('milliseconds')` |
| date set: timestamp in seconds | `date.timestamp('unix')` | `date.format('seconds')` |
| func type | `func` | - |
| func set: number of arguments | `func.arity` | - |
| func set: min number of arguments | `func.minArity` | - |
| func set: max number of arguments | `func.maxArity` | - |
| func set: function should be a reference | `func.ref()` | - |
| type number | `number` | `number` |
| number set: min | `number.min(limit)` | `number.min(limit)` |
| number set: max | `number.max(limit)` | `number.max(limit)` |
| number set: greater | `number.greater(limit)` | `number.greater(limit)` |
| number set: less | `number.less(limit)` | `number.less(limit)` |
| number set: integer | `number.integer()` | `number.integer()` |
| number set: max precision | `number.precision(limit)` | `number.round(precision)` |
| number set: multiple | `number.multiple(base)` | `number.multiple(base)` |
| number set: positive | `number.positive()` | `number.positive()` |
| number set: negative | `number.negative()` | `number.negative()` |
| object type | `object` | `object` |
| object set: key schema | `object.keys(schemaMap)` | `object.key(name, schema).key(name, schema)` |
| object set: min elements | `object.min(limit)` | `object.min(limit)` |
| object set: max elements | `object.max(limit)` | `object.max(limit)` |
| object set: number of elements | `object.length(limit)` | `object.length(limit)` |
| object set: pattern schema | `object.pattern(re, schema)` | `object.key(re, schema)` |
| object set: 'and' keys | `object.and(peers)` | `object.and(peers)` |
| object set: 'nand' keys | `object.nand(peers)` | `object.nand(peers)` |
| object set: 'or' keys | `object.or(peers)` | `object.or(peers)` |
| object set: 'xor' keys | `object.xor(peers)` | `object.xor(peers)` |
| object set: 'with' keys | `object.with(key, peers)` | `object.with(key, peers)` |
| object set: 'without' keys | `object.without(key, peers)` | `object.without(key, peers)` |
| object set: rename key | `object.rename(from, to)` | - |
| object set: assert | `object.assert(ref, schema)` | - |
| object set: unknown keys | `object.unknown()` | `object.removeUnknown()` |
| object set: is type of | `object.type(constructor)` | - |
| object set: be a schema | `object.schema()` | - |
| object set: required keys | `object.requiredKeys()` | `object.requiredKeys()` |
| object set: forbidden keys | `object.forbiddenKeys()` | `object.forbiddenKeys()` |
| object set: optional keys | `object.optionalKeys()` | - |
| string type | `string` | `string` |
| string set: insensitive matching | `string.insensitive()` | done through regexp |
| string set: min length | `string.min(limit)` | `string.min(limit)` |
| string set: max length | `string.max(limit)` | `string.max(limit)` |
| string set:  | `string` | `string` |
| string set:  | `string` | `string` |
| string set:  | `string` | `string` |
| string set:  | `string` | `string` |
| string set:  | `string` | `string` |
| string set:  | `string` | `string` |
| string set:  | `string` | `string` |
| string set:  | `string` | `string` |
|  |  |  |

This may help to decide what to use and how to transform a schema.
