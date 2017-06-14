# String Schema

Create a schema that matches any data type.

This is an universal type which may be used everywhere there no further knowledge
of the structure is known. It can also be used to make a loose checking schema
first and later replace it through detailed specifications.

See at [Any Schema](any.md) for the inherited methods you may call like:
- `required`
- `default()`
- `stripEmpty`
- `allow()`
- `allowAll()`
- `allowToClear`

## Sanitize

### makeString

The flag enables automatic string conversion. so each object which is not already
a string is converted to one. This is done using the `toString()` method which
works on base data types and all objects implementing this common method.

```js
const schema = new StringSchema().makeString
```

> In combination with `not` this will be disabled.

### truncate

In combination with `max()` or `length()` it will crop after max characters.

```js
const schema = new StringSchema().max(10).truncate
```

> In combination with `not` this will be disabled.

### pad(side, chars)

Like `truncate` this method also fixes the string length. It pads strings which are
too short to reach the minimum length.
- `side` one of: `right` (default), `left` and `both`
- `chars` are the characters to pad (defaults to space)

```js
const schema = new StringSchema().min(10).pad() // default will be 'right' with spaces
const schema = new StringSchema().min(10).pad('left', '-') // will pad with dashes
const schema = new StringSchema().min(10).pad('both', '-<>-') // will add ---< and >---
```

If to less characters are given the last (right pad) or first (left pad) will be
repeated. On both side padding with multiple characters the first half will be used
on the left, the second half on the right side with possible repeat.

> Use `not` before to remove padding.

## Checks

### min(limit) / max(limit) / length(limit)

Specifies the number of characters the string is allowed to have.
- `limit` gives the `number` of characters for the string

```js
const schema = new ObjectSchema().min(1).max(3)
```

> Using `not` it will remove the specified setting.
