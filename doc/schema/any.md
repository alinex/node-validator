# Any Schema

Create a schema that matches any data type.

This is an universal type which may be used everywhere there no further knowledge
of the structure is known. It can also be used to make a loose checking schema
first and later replace it through detailed specifications.

## required / not.required

The value may be optional (default), meaning if no value is given it will be set
as `undefined`. A value of `null` is considered as a concrete value and won´t trigger
the optional here. The `not` negates this and makes the schema not optional.

```js
const schema = new validator.Any().required
```

## default(value: any)

The given value is used as an default if nothing is given meaning the value is set
to `undefined`. The default value will also go through the further rules and have
to succeed all other constraints.
If this is used the `required` setting don't have to be used.

```js
const schema = new validator.Any().default(1)
```

## allow(value: any)

If you specify at least one value which is allowed only the allowed values are
possible. Therefore a deep check will be done.

```js
const schema = new validator.Any().allow(5)
```

## not.allow(value: any)

Also you may define which elements you won´t allow. If only invalid elements are
defined all other elements are possible.

```js
const schema = new validator.Any().not.allow(5)
```
