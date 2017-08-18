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

| Feature | Joi | Alinex |
| ------- | --- | ------ |
| stop on error | option: `abortEarly` (true) | true |
| convert to required type | option: `convert` (true) | schema defined (true) |
| allow unknown keys | option: `allowUnknown` (false) | - |
| remove unknown keys | option: `skipUnknown` (false) | `objectSchema.removeUnknown` (false) |
| skip function value | option: `skipFunctions` (true) | - |
| override individual error messages | option: `language` | - |
| set default presence | option: `presence` (optional) | default always optional |
| reference context | option: `context` | `new Reference(context)` |
| disable defaults for validation | option: `noDefaults` (false) | - |
| reference to value | `ref(key)` | `new Reference().path(key)` |
| get subschema for path | `reach(schema, path)` | - |
| any type | `any` | `AnySchema` |
| any setting: allow | `any.allow(value)` | `anySchema.allow(value)` |
| any setting: valid | `any.valid(value)` | `anySchema.valid(value)` |
| any setting: invalid | `any.invalid(value)` | `anySchema.invalid(value)` |
| any setting: required | `any.required()` | `schema.required()` |
| any setting: optional | `any.optional()` | true unless `schema.required()` |
| any setting: forbidden | `any.forbidden()` | - |
| any setting: strip after validation | `any.strip()` | - |
| any setting: description | `any.description(value)` | `new Schema(title, description)` |
| any setting: notes | `any.notes(value)` | - |
| any setting: tags | `any.tags(value)` | - |
| any setting: meta | `any.meta(value)` | - |
| any setting: example | `any.example(value)` | - |
| any setting: unit | `any.unit(name)` | `numberSchema.unit(name).toUnit(name)` |
| any setting: options override | `any.options(value)` | - |
| any setting: default | `any.default(value)` | `schema.default(value)` |
