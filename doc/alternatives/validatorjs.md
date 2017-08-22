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

This may help to decide what to use and how to transform a schema. Not included is what alinex
can do and validatorjs can't.
