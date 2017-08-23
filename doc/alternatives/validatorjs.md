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
| `confirmed` need matching field xxx_confirmation | `xxx_confitrmation = any.allow(new Reference().path('xxx'))` |
| `date` | `date` |
| `digits:value` | `number.length(value)` |
| `different:attribute` | `any.deny(new Reference().path(attribute))` |
| `email` | - |
| `in:foo,bar,...` | `any.allow([foo,bar])` |
| `integer` | `number.integer()` |
| `max:value` | `number.max(value)` |
| `min:value` | `number.min(value)` |
| `not_in:foo,bar,...` | `any.deny([foo,bar])` |
| `numeric` | `number` |
| `required` | `schema.required()` |
| `required_if:anotherfield,value` | - |
| `required_unless:anotherfield,value` | - |
| `required_with:foo,bar,...` | `object.with(a, [foo,bar])` |
| `required_with_all:foo,bar,...` | - |
| `required_without:foo,bar,...` | - |
| `required_without_all:foo,bar,...` | - |
| `same:attribute` | `any.allow(new Reference().path(attribute))` |
| `size:value` for number | number.length(value) |
| `size:value` for string | string.length(value) |
| `string` | `string` |
| `url` | - |
| `regex:pattern` | `string.match(pattern)` |
