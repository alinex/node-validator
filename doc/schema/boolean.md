# Boolean Schema

Create a schema that matches any data type.

See at [Base Schema](base.md) for the inherited methods you may call like:
- `required()`
- `default()`
- `stripEmpty()`
- `raw()`

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

References are also possible:

```js
const ref = new Reference([1, 'ja', 'yeah'])
const schema = new BooleanSchema().truhyw(ref)
```

The reference can point to a list of values which are allowed. In case of an object it will take the
object´s keys. If nothing given the list will be cleared and in all other cases the given element will
be set as the only one in a new list.

### tolerant(bool)

This is equal to set the following values:
- `true`:  `1`, `'1'`, `'true'`, `'on'`, `'yes'`, `'+'`
- `false`: `0`, `'0'`, `'false'`, `'off'`, `'no'`, `'-'`

```js
const schema = new BooleanSchema().tolerant()
schema.tolerant(false) // to remove it again
```

With references you can switch the tolerant mode on or off:

```js
const ref = new Reference(true)
const schema = new BooleanSchema().tolerant(ref)
```

The reference can point to any value which may be converted to true/false.

### insensitive(bool)

This makes only sense together with `tolerant` or `truthy`, `falsy` and will match
strings case insensitive.

```js
const schema = new BooleanSchema().tolerant().insensitive()
schema.insensitive(false) // to remove it again
```

This can also be srt using reference:

```js
const ref = new Reference(true)
const schema = new BooleanSchema().tolerant().insensitive(ref)
```

The reference can point to any value which may be converted to true/false.

## Output

By default the output value will be a boolean value but can be set to any object for the two
possible states.

### format(truthy, falsy)

To specify the value returned for `true` and `false` call this method with the
values used for both.

```js
const schema = new BooleanSchema().format('YES', 'NO')
schema.format() // to remove values
```

Here a reference to a list of two elements are possible:

```js
const ref = new Reference(['YES', 'NO'])
const schema = new BooleanSchema().format(ref)
```

The reference can point to a list with the two values. In case of an object it will take the
object´s keys. If nothing given the list will be cleared and in all other cases the given element will
be set as the only one in a new list.
