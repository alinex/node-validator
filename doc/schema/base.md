# Base Schema

This are the settings which are common for all schema types.

## required(bool)

The validation value may be optional (default), meaning if no value is given it will be set
as `undefined`. A value of `null` is considered as a concrete value and won´t trigger
the optional here.

```js
const schema = new AnySchema().required()
schema.required(false) // to remove this setting
```

If this method is called with `false` the schema is set to not optional.

## default(any)

The given value is used as a default. The default value will also go through the further rules
and have to succeed all other constraints.

```js
const schema = new AnySchema().default(1)
schema.default(false) // to remove this setting
```

If this is used the `required` setting don't have to be used because it is automatically set.
If nothing is given the default value will be removed.

## stripEmpty(bool)

This flag will replace empty values like `null`, `[]`, `{}` or `''` with `undefined`
before going through the optional and default rules. This allows you to also use
the default if an empty element is given.

```js
const schema = new AnySchema().stripEmpty().default(3)
schema.stripEmpty(false) // to remove this setting
```

If this method is called with `false` the schema is set to not replace empty objects.

## clone

Get a clone of this schema to use it elsewhere with some changes. It is a shallow clone so if you
want to change some sub elements you have to replace them with their clones, too.

```js
const schema = new AnySchema().stripEmpty().default(3)
const clone = schema.clone.stripEmpty(false)
```

This is the part there you may need the remove calls of the methods like shown above to remove some
earlier settings in the clone.
