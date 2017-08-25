# validatorjs

The [validatorjs](https://www.npmjs.com/package/validatorjs) is defined by a single string definition
per element.


```js
var Validator = require('validatorjs');

var data = {
    name: 'John',
    email: 'johndoe@gmail.com',
    age: 28
};
var rules = {
    name: 'required',
    email: 'required|email',
    age: 'min:18'
};

var validation = new Validator(data, rules);

validation.passes(); // true
validation.fails(); // false
```

The rules object contains a definition string for each element or sub element. This may contain
multiple rules using '|' as separator and `<rule>:<value>` settings.

## Feature comparison

The following table shows all validatorjs features and the identical or nearest way to reach the
same using alinex-validator.

> The code examples are only pseudo code to make it shorter

| validatorjs V 3.13.3 | Alinex |
| --- | ------ |
| `accepted` need boolean true | `boolean.valid(true)` |
| `after:date` | `date.greater(date)` |
| `after_or_equal:date` | `date.min(date)` |
| `alpha` | `string.match(/^[a-zA-Z]*$/)` |
| `alpha_dash` | `string.match(/^[a-zA-Z-_]*$/)` |
| `alpha_num` | `string.alphanum()` |
| `array` | `array` |
| `before:date` | `date.less(date)` |
| `before_or_equal:date` | `date.max(date)` |
| `between:min,max` for string | `string.min(min).max(max)` |
| `between:min,max` for number | `number.min(min).max(max)` |
| `between:min,max` for files | - |
| `boolean` | `boolean.tolerant()` |
| `confirmed` need matching field xxx_confirmation | `xxx_confirmation = any.allow(ref().path('../xxx'))` |
| `date` | `date` |
| `digits:value` | `number.length(value)` |
| `different:attribute` | `any.deny(ref().path(attribute))` |
| `email` | - |
| `in:foo,bar,...` | `any.allow([foo,bar])` |
| `integer` | `number.integer()` |
| `max:value` | `number.max(value)` |
| `min:value` | `number.min(value)` |
| `not_in:foo,bar,...` | `any.deny([foo,bar])` |
| `numeric` | `number` |
| `required` | `any.required()` |
| `required_if:anotherfield,value` | `logic.if(any(ref.path(anotherfield)).allow(value)).then(any.required())` |
| `required_unless:anotherfield,value` | `logic.if(any(ref.path(anotherfield)).deny(value)).then(any.required())` |
| `required_with:foo,bar,...` | `logic.if( logic.allow(any(ref.path(foo)).required()).or(any(ref.path(bar)).required()) ).then(any.required())` |
| `required_with_all:foo,bar,...` | `logic.if( logic.allow(any(ref.path(foo)).required()).and(any(ref.path(bar)).required()) ).then(any.required())` |
| `required_without:foo,bar,...` | `logic.if( logic.allow(any(ref.path(foo)).forbidden()).or(any(ref.path(bar)).forbidden()) ).then(any.required())` |
| `required_without_all:foo,bar,...` | `logic.if( logic.allow(any(ref.path(foo)).forbidden()).and(any(ref.path(bar)).forbidden()) ).then(any.required())` |
| `same:attribute` | `any.allow(ref().path(attribute))` |
| `size:value` for number | number.length(value) |
| `size:value` for string | string.length(value) |
| `string` | `string` |
| `url` | - |
| `regex:pattern` | `string.match(pattern)` |
