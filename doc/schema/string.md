# String Schema

Create a schema that matches any data type.

This is an universal type which may be used everywhere there no further knowledge
of the structure is known. It can also be used to make a loose checking schema
first and later replace it through detailed specifications.

See at [Any Schema](any.md) for the inherited methods you may call like:
- `required()`
- `default()`
- `stripEmpty()`
- `allow()`
- `disallow()`
- `valid()`
- `invalid()`

## Sanitize

### makeString(bool)

The flag enables automatic string conversion. so each object which is not already
a string is converted to one. This is done using the `toString()` method which
works on base data types and all objects implementing this common method.

```js
const schema = new StringSchema().makeString()
schema.makeString(false) // to remove the setting
```

It can also be set as reference:

```js
const ref = new Reference(true)
const schema = new StringSchema().makeString(ref)
```

### trim(bool)

If this flag is set all whitespace characters will be removed from the begin and
end of the string.

```js
const schema = new StringSchema().trim()
schema.trim(false) // to remove the setting
```

And also with reference:

```js
const ref = new Reference(true)
const schema = new StringSchema().makeString(ref)
```

### replace(match, replace, name)

Strings maybe changed using regular expression replacements. Therefore call this
method using:
- `match` - a `RegExp` which defines what to replace
- `replace` - the `string` which is used as replacements (may include $1... for captured
  groups), if not given the match will be removed
- `name` - a short identification to possibly remove only this rule later and to
  explain the rule a bit

```js
const schema = new StringSchema().replace(/(\w),\s?/g, '$1 and ', ', to and')
schema.replace(', to and') // remove one setting
schema.replace() // remove all setting
```

> References are not possible here.

### lowercase(what) / uppercase(what)

This will change between uppercase and lowercase on the whole text (with no parameter)
or only on the first with parameter `first`.

```js
const schema = new StringSchema().lowercase().uppercase('first')
schema.lowercase(false).uppercase(false) // remove setting
```

The first line will make everything lowercase but the first character uppercase.

```js
const ref = new Reference(true)
const schema = new StringSchema().lowercase(ref)
```

### stripDisallowed

This will remove all disallowed characters defined through the checks:
- `alphanum`
- `hex`
- `controls`
- `noHTML`

```js
const schema = new StringSchema().alphanum().stripDisallowed()
```

See the description of the check rules below.

> With `not` the flag can be removed again.

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

### alphanum

Only alphanumeric characters are allowed: a-z, A-Z, 0-9 and _

```js
const schema = new StringSchema().alphanum
```

In combination with `stripDisallowed` invalid characters will be removed to make
the text passable.

> With `not` the flag can be removed again.

### hex

Only hexadecimal characters are allowed: a-f, A-F and 0-9

```js
const schema = new StringSchema().hex
```

In combination with `stripDisallowed` invalid characters will be removed to make
the text passable.

> With `not` the flag can be removed again.

### controls

Allow control characters in text.

```js
const schema = new StringSchema().controls
```

In combination with `stripDisallowed` invalid characters will be removed to make
the text passable.

> With `not` the flag can be removed again.

### noHTML

Disallow the use of HTML or XML tags.

```js
const schema = new StringSchema().noHTML
```

In combination with `stripDisallowed` invalid tags will be removed to make
the text passable.

> With `not` the flag can be removed again.

### min(limit) / max(limit) / length(limit)

Specifies the number of characters the string is allowed to have.
- `limit` gives the `number` of characters for the string

```js
const schema = new StringSchema().min(1).max(3)
```

> Using `not` it will remove the specified setting.

### match(re) / not.match(re) / clearMatch

Set a regular expression which have to match or should not match:

```js
const schema = new StringSchema().match(/ab/)
```

> To remove positive and negative matches use `clearMatch` instead of not.
