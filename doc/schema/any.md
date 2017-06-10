# Any Schema

Create a schema that matches any data type.

This is an universal type which may be used everywhere there no further knowledge
of the structure is known. It can also be used to make a loose checking schema
first and later replace it through detailed specifications.

See at [Base Schema](base.md) for the inherited methods you may call like:
- `required`
- `default()`
- `stripEmpty`

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

## allowAll(value: Array<any>)

This will add a complete list of values like each is given using `allow()`.

```js
const schema = new validator.Any().allowAll(3, 4, 5)
```

## not.allowAll(value: Array<any>)

This will add a complete list of values like each is given using `not.allow()`.

```js
const schema = new validator.Any().not.allowAll(3, 4, 5)
```
