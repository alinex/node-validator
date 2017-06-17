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

### sanitize

If this flag is set the first numerical value from the given text will be used.
That allows any non numerical characters before or after the value, which will be
stripped away.

```js
const Schema = new NumberSchema().sanitize
```

> Using the `not` flag it can also be removed later.
