# Number Schema

Create a schema that matches a numerical value.

See at [Any Schema](any.md) for the inherited methods you may call like:
- `required`
- `default()`
- `stripEmpty`
- `allow()`
- `allowAll()`
- `allowToClear`

## Sanitize

### unit(unit)

This specifies the unit of the stored numerical value and also allows to give
values in each compatible unit which will automatically recognized and converted.

```js
const Schema = new NumberSchema().unit('cm')
// allows the value to be: '1.28 m'
```

> It can be removed using the `not` flag.

### sanitize

If this flag is set the first numerical value from the given text will be used.
That allows any non numerical characters before or after the value, which will be
stripped away.

```js
const Schema = new NumberSchema().sanitize
```

> Using the `not` flag it can also be removed later.
