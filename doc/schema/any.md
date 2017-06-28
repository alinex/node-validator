# Any Schema

Create a schema that matches any data type.

This is an universal type which may be used everywhere there no further knowledge
of the structure is known. It can also be used to make a loose checking schema
first and later replace it through detailed specifications.

See at [Base Schema](base.md) for the inherited methods you may call like:
- `required()`
- `default()`
- `stripEmpty()`

A lot of other types are also based on this one.

## Allowed and/or denied elements

### valid(value)

If you specify at least one value which is allowed only the allowed values are
possible. Therefore a deep check of the values will be done.

```js
const schema = new AnySchema().valid(5)
```

> References are impossible here, use `allow()` therefore.

### invalid(value)

Also you may define which elements you won´t allow. If only invalid elements are
defined all other elements are possible.

```js
const schema = new AnySchema().invalid(5)
```
> References are impossible here, use `disallow()` therefore.

### allow(list)

The same as calling `valid()` multiple times you may replace the current list of allowed elements
by this new list. It will disable this check if you call it with `undefined` or an empty list.

```js
const schema = new AnySchema().allow([5, 10])
schema.allow()
```

### disallow(list)

The same as calling `invalid()` multiple times you may replace the current list of allowed elements
by this new list. It will disable this check if you call it with `undefined` or an empty list.

```js
const schema = new AnySchema().inallow([5, 10])
schema.inallow()
```
