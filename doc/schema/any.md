# Any Schema

Create a schema that matches any data type.

This is an universal type which may be used everywhere there no further knowledge
of the structure is known. It can also be used to make a loose checking schema
first and later replace it through detailed specifications.

See at [Base Schema](base.md) for the inherited methods you may call like:
- `required`
- `default()`
- `stripEmpty`

## allow(value) / not.allow(value)

If you specify at least one value which is allowed only the allowed values are
possible. Therefore a deep check will be done.

```js
const schema = new AnySchema().allow(5)
```

Also you may define which elements you won´t allow. If only invalid elements are
defined all other elements are possible.

```js
const schema = new AnySchema().not.allow(5)
```

## allowAll(list) / not.allowAll(list)

This will add a complete list of values like each is given using `allow()`.

```js
const schema = new AnySchema().allowAll(3, 4, 5)
```

This will add a complete list of values like each is given using `not.allow()`.

```js
const schema = new AnySchema().not.allowAll(3, 4, 5)
```

## allowToClear / not.allowToClear

This method allows you to clear the list of valid or invalid entries completely.
It's the only way to get a value out of both lists because the normal `allow` and
`not.allow` always removes from one and inserts in the other list.
