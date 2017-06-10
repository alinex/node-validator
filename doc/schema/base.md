# Base Schema

This are the settings which are common for all schema types.

## required

The value may be optional (default), meaning if no value is given it will be set
as `undefined`. A value of `null` is considered as a concrete value and won´t trigger
the optional here. The `not` negates this and makes the schema not optional.

```js
const schema = new validator.Any().required
```

It may be inverted using `not.required`.

## default(value: any)

The given value is used as an default if nothing is given meaning the value is set
to `undefined`. The default value will also go through the further rules and have
to succeed all other constraints.
If this is used the `required` setting don't have to be used.

```js
const schema = new validator.Any().default(1)
```

## stripEmpty

This will replace empty values like `null`, `[]`, `{}` or `''` with `undefined`
before going through the optional and default rules. This allows you to also use
the default if an empty element is given.

```js
const schema = new validator.Any().stripEmpty.default(3)
```

It may be inverted using `not.stripEmpty`.
