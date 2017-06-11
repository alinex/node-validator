# Base Schema

This are the settings which are common for all schema types.

## not

Some methods allow to negate their function. If this makes sense it is added
in the examples. Therefore the not is added before the method call.

```js
const schema = new validator.Any().not.allow(1)
```

This operator is only valid for the next method. If you need it again it has to
be given again.

Also on a lot of methods you may need the `not` operator to go back to the initial
setting. This is especially useful if you cloned a schema from somewhere else and
want to change something here. Such possibilities are mostly added as a short note
in each method description.

## required

The value may be optional (default), meaning if no value is given it will be set
as `undefined`. A value of `null` is considered as a concrete value and won´t trigger
the optional here. The `not` negates this and makes the schema not optional.

```js
const schema = new validator.Any().required
```

> It may be inverted using `not.required`.

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

> It may be inverted using `not.stripEmpty`.
