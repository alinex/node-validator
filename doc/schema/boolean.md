# Boolean Schema

Create a schema that matches any data type.

This is an universal type which may be used everywhere there no further knowledge
of the structure is known. It can also be used to make a loose checking schema
first and later replace it through detailed specifications.

See at [Base Schema](base.md) for the inherited methods you may call like:
- `required()`
- `default()`
- `stripEmpty()`

## Parsing

### truthy(list) / falsy(list)

With these two methods multiple values can be set which are interpreted as `true`
or `false`. Using not before is the same as using the other method.
A real boolean value is always used.

Multiple values can be given as multiple arguments or array. Any type is possible
as attributes but if you want to use an array as the value it have to be nested inside
an array itself.

```js
const schema = new BooleanSchema().truthy(1, 'yes').falsy(0, 'no')
schema.truthy() // to remove the list
```

### tolerant

This is equal to set the following values:
- `true`:  `1`, `'1'`, `'true'`, `'on'`, `'yes'`, `'+'`
- `false`: `0`, `'0'`, `'false'`, `'off'`, `'no'`, `'-'`

```js
const schema = new BooleanSchema().tolerant()
schema.tolerant(false) // to remove it again
```

### insensitive

This makes only sense together with `tolerant` or `truthy`, `falsy` and will match
strings case insensitive.

```js
const schema = new BooleanSchema().tolerant.insensitive
```

## Output

### format(truthy, falsy)

To specify the value returned for `true` and `false` call this method with the
values used for both.

```js
const schema = new BooleanSchema().format('YES', 'NO')
```
