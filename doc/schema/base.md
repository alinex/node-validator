# Base Schema

This are the settings which are common for all schema types.


## constructor(base)

In some cases you want to work the validation not on the current data value but with an other
discrete value or referenced value. This is mainly necessary in logical operations described later
in detail.

```js
const schema = new ObjectSchema(5)
  .title('MyTest')
  .detail('is an easy schema to show it´s use')

const schema = new ObjectSchema()
  .key('init', new LogicSchema()
    .allow( new String().stripEmpty() )
    .and( new NumberSchema( new Reference().path('/start') ).min(1) )
    .then( new Schema().required() )
  )
```

A base value is set for NumberSchema based on a referenced value of another structure field. So that
'init' may be set but must be set if 'start' is 1 or more.


## title(string) / detail(string)

With this methods you may give some meta data for this part of the data structure. This may be a
title or some informal details which will be used for error messages before the technical description.

```js
const schema = new ObjectSchema()
  .title('MyTest')
  .detail('is an easy schema to show it´s use')
```

This will bring you an error message like:

```markdown
__Something is wrong.__

> At path: `/any/path`
> Given value was: `5`

But __MyTest__ is an easy schema to show it´s use:
It is optional and must not be set. +3ms
```


## required(bool)

The validation value may be optional (default), meaning if no value is given it will be set
as `undefined`. A value of `null` is considered as a concrete value and won´t trigger
the optional here.

```js
const schema = new AnySchema().required()
schema.required(false) // to remove this setting
```

If this method is called with `false` the schema is set to not optional.

```js
const ref = new Reference(true)
const schema = new AnySchema().required(ref)
```

The reference can point to any value which may be converted to true/false.


## default(any)

The given value is used as a default. The default value will also go through the further rules
and have to succeed all other constraints.

```js
const schema = new AnySchema().default(1)
schema.default(false) // to remove this setting
```

If this is used the `required` setting don't have to be used because it is automatically set.
If nothing is given the default value will be removed.

```js
const ref = new Reference(new Error('Test'))
const schema = new AnySchema().default(ref)
```

The reference can point to any value.


## stripEmpty(bool)

This flag will replace empty values like `null`, `[]`, `{}` or `''` with `undefined`
before going through the optional and default rules. This allows you to also use
the default if an empty element is given.

```js
const schema = new AnySchema().stripEmpty().default(3)
schema.stripEmpty(false) // to remove this setting
```

If this method is called with `false` the schema is set to not replace empty objects.

```js
const ref = new Reference(true)
const schema = new AnySchema().stripEmpty(ref)
```

The reference can point to any value which may be converted to true/false.


## raw(bool)

If this flag is set the value is only changed while validating. After done the original value will
be returned.

```js
const schema = new StringSchema().trim().max(3).raw() // ' 123 ' validates and the spaces are kept
schema.raw(false) // to remove this setting
```

And as always references are possible:

```js
const ref = new Reference(true)
const schema = new AnySchema().raw(ref)
```


## clone

Get a clone of this schema to use it elsewhere with some changes. It is a shallow clone so if you
want to change some sub elements you have to replace them with their clones, too.

```js
const schema = new AnySchema().stripEmpty().default(3)
const clone = schema.clone.stripEmpty(false)
```

This is the part there you may need the remove calls of the methods like shown above to remove some
earlier settings in the clone.
