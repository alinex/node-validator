# RegExp Schema

Create a schema that matches a regular expression.

See at [Base Schema](base.md) for the inherited methods you may call like:
- `title()`
- `detail()`
- `required()`
- `forbidden()`
- `default()`
- `raw()`

Instead of giving a regular expression directly it may also be given as a string.


## Checking matched groups

You may define the number of matched groups within the regular expression.

### min(limit) / max(limit) / length(limit)

Specifies the number of matched groups the regular expression contains.
- `limit` gives the fix `number`
- `min` and `max` defines a range

```js
const schema = new RegExpSchema().min(1).max(3)
schema.min().max() // to remove both settings
const schema = new RegExpSchema().length(3)
```

References are also possible:

```js
const ref = new Reference(5)
const schema = new RegExpSchema().length(ref)
```
