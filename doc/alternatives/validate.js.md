# Validate.js

[Validate.js](https://validatejs.org/) uses a constraint setting as JavaScript
Object including injected reporting functions. It has the ability to customize the message of each
validation.

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

## Feature comparison

The following table shows all Validate.js features and the identical or nearest way to reach the
same using alinex-validator.

> The code examples are only pseudo code to make it shorter

| validate.js V 0.11.1 | Alinex |
| --- | ------ |
| `date` | `date.type('date')` |
| `datetime` | `date` |
| `datetime.earliest=val` | `date.min(val)` |
| `datetime.latest=val` | `date.max(val)` |
| `datetime.dateOnly` | `date.type('date')` |
| `email` | `email` |
| `equality=ref` | `any.allow(Reference().path(ref))` |
| `exclusion=list` | `any.deny(list)` |
| `format=pattern` | `string.match(pattern)` |
| `inclusion.list` | `any.allow(list)` |
| `length.is=num` | `string.length(num)` |
| `length.minimum=num` | `string.min(num)` |
| `length.maximum=num` | `string.max(num)` |
| `numerically` | `number` |
| `numerically.onlyInteger` | `number.integer()` |
| `numerically.strict` | don't use `number.sanitize()` |
| `numerically.greaterThan=num` | `number.greater(num)` |
| `numerically.greaterThanOrEqualTo=num` | `number.min(num)` |
| `numerically.equalTo=num` | `number.allow(num)` |
| `numerically.lessThan=num` | `number.less(num)` |
| `numerically.lessThanOrEqualTo=num` | `number.max(num)` |
| `numerically.divisibleBy=num` | `number.multiple(num)` |
| `numerically.odd` | `logic.deny(number.multiple(2))` |
| `numerically.even` | `number.multiple(2)` |
| `presence` | `schema.required()` |
| `url` | `url` |
| `capitalize()` | `string.upperCase('first')` |
| `cleanAttributes()` | `object.removeUnknown()` |
| `contains(list)` | `any.allow(list)` |
| `isArray()` | `array` |
| `isBoolean` | `boolean` |
| `isDate()` | `date` |
| `isDefined()` | `schema.stripEmpty()` |
| `isFunction()` | `function` |
| `isHash()` | `preset.md5` or `preset.sha1` |
| `isInteger()` | `number.integer()` |
| `isNumber()` | `number` |
| `isObject()` | `object` |
| `isPromise()` | - |
| `isString()` | `string` |
| `prettify()` | - |
