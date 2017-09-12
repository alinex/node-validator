# String Schema

Create a schema that matches a string type.

See at [Any Schema](any.md) for the inherited methods you may call like:
- `title()`
- `detail()`
- `required()`
- `forbidden()`
- `default()`
- `stripEmpty()`
- `allow()`
- `deny()`
- `valid()`
- `invalid()`
- `raw()`

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

### lowerCase(what) / upperCase(what)

This will change between upper case and lower case on the whole text (with no parameter)
or only on the first with parameter `first`.

```js
const schema = new StringSchema().lowerCase().upperCase('first')
schema.lowerCase(false).upperCase(false) // remove setting
```

The first line will make everything lower case but the first character upper case.

```js
const ref = new Reference(true)
const schema = new StringSchema().lowerCase(ref)
```

### stripDisallowed

This will remove all disallowed characters defined through the checks:
- `alphaNum` - only alpha numeric characters
- `hex` - only hexadecimal characters
- `controls` - control characters allowed
- `noHTML` - no HTML tags allowed

```js
const schema = new StringSchema().alphaNum().stripDisallowed()
schema.alphaNum(false).stripDisallowed(false) // to remove settings
```

All of the flags allow to use references:

```js
const ref = new Reference(true)
const schema = new StringSchema().alphaNum(ref)
```

### truncate(bool)

In combination with `max()` or `length()` it will crop after max characters.

```js
const schema = new StringSchema().max(10).truncate()
schema.truncate(false) // remove setting
```

Like in the other flags references are possible:

```js
const ref = new Reference(true)
const schema = new StringSchema().max(10).truncate(ref)
```

### pad(side, chars)

Like `truncate` this method also fixes the string length. It pads strings which are
too short to reach the minimum length.
- `side` one of: `right` (default), `left` and `both`
- `chars` are the characters to pad (defaults to space)

```js
const schema = new StringSchema().min(10).pad() // default will be 'right' with spaces
const schema = new StringSchema().min(10).pad('left', '-') // will pad with dashes
const schema = new StringSchema().min(10).pad('both', '-<>-') // will add ---< and >---
schema.pad(false) // to remove the setting
```

If to less characters are given the last (right pad) or first (left pad) will be
repeated. On both side padding with multiple characters the first half will be used
on the left, the second half on the right side with possible repeat.

References are not possible here.

## Checks

### alphaNum(bool)

Only alphaNumeric characters are allowed: a-z, A-Z, 0-9 and _

```js
const schema = new StringSchema().alphaNum()
schema.alphaNum(false) // to remove setting
```

In combination with `stripDisallowed` invalid characters will be removed to make
the text passable.

```js
const ref = new Reference(true)
const schema = new StringSchema().alphaNum(ref)
```

### hex(bool)

Only hexadecimal characters are allowed: a-f, A-F and 0-9

```js
const schema = new StringSchema().hex()
schema.hex(false) // remove setting
```

In combination with `stripDisallowed` invalid characters will be removed to make
the text passable.

```js
const ref = new Reference(true)
const schema = new StringSchema().hex(ref)
```

### controls(bool)

Allow control characters in text.

```js
const schema = new StringSchema().controls()
schema.controls(false) // remove setting
```

In combination with `stripDisallowed` invalid characters will be removed to make
the text passable.

```js
const ref = new Reference(true)
const schema = new StringSchema().controls(ref)
```

### noHTML(bool)

Disallow the use of HTML or XML tags.

```js
const schema = new StringSchema().noHTML()
schema.noHTML(false) // remove setting
```

In combination with `stripDisallowed` invalid tags will be removed to make
the text passable.

```js
const ref = new Reference(true)
const schema = new StringSchema().noHTML(ref)
```

### min(limit) / max(limit) / length(limit)

Specifies the number of characters the string is allowed to have.
- `limit` gives the `number` of characters for the string

```js
const schema = new StringSchema().min(1).max(3)
schema.min().max() // to remove both settings
```

References are also possible:

```js
const ref = new Reference(5)
const schema = new StringSchema().length(ref)
```

### match(re) / notMatch(re)

Set a regular expression which have to match:

```js
const schema = new StringSchema().match(/ab/)
schema.match() // to remove all matches
```

And for negative matches use `notMatch`:

```js
const schema = new StringSchema().notMatch(/ab/)
schema.notMatch() // to remove all matches
```

You may also define multiple matches but an empty call will clear the complete list of positive
or negative matches.

```js
const ref = new Reference('/ab/i')
const schema = new StringSchema().match(ref)
```

Within the references the match can be defined as regular expression object or in string notation.
