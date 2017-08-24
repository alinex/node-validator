# Object Schema

Create a schema that matches any data object which contains key/value pairs.

The values may be of any other type.

See at [Base Schema](base.md) for the inherited methods you may call like:
- `title()`
- `detail()`
- `required()`
- `default()`
- `stripEmpty()`
- `raw()`


## Sanitize

### deepen(separator)

A elements containing a special separator are split up on each occurrence and be
converted into a deep structure. The separator may be given as `string` or `RegExp`.

```js
// data = {'a.a': 1, 'a.b': 2, c: 3}
const schema = new ObjectSchema().deepen('.')
// result = {a: {a: 1, b: 2}, c: 3}
schema.deepen() // to remove setting
```

References to regular expression or string:

```js
const ref = new Reference('.')
const schema = new ObjectSchema().deepen(ref)
```

### flatten(separator)

That's the opposite of deepen and will flatten deep structures using the given
separator which has to be a `string`.

```js
// data = {a: {a: 1, b: 2}, c: 3}
const schema = new ObjectSchema().flatten('.')
// result = {'a.a': 1, 'a.b': 2, c: 3}
schema.flatten() // to remove setting
```

References to regular expression or string:

```js
const ref = new Reference('.')
const schema = new ObjectSchema().flatten(ref)
```

### removeUnknown

This will remove all unchecked keys from the object. So only the specified are returned.
All elements which has specific checks set via `key` are checked.

```js
const schema = new ObjectSchema().removeUnknown()
.key('one', new AnySchema())
schema.removeUnknown(false) // to remove setting
```

This can also be used with nreference:

```js
const ref = new Reference(true)
const schema = new ObjectSchema().removeUnknown(ref)
.key('one', new AnySchema())
```


## Checking Keys

### min(limit) / max(limit) / length(limit)

Specifies the number of keys the object is allowed to have.
- `limit` gives the `number` of elements to be within the data object

```js
const schema = new ObjectSchema().min(1).max(3)
schema.min() // to remove setting, same for max
schema.length() // to remove min and max setting
```

References are possible:

```js
const ref = new Reference(5)
const schema = new ObjectSchema().length(ref)
```

### requiredKeys(list) / forbiddenKeys(list)

These two methods allow to define the key names which are allowed or disallowed.
It may be called multiple times to specify it.

```js
const schema = new ObjectSchema().requiredKeys('a', 'b', 'c')
.forbiddenKeys(['d', 'e'])
```

The list of keys can be given as:
- one or multiple `string`
- Array of `string`

### and(list)

With this logic check you ensure that all of the given keys or none of them are
present in the data object.

```js
const schema = new ObjectSchema().and('a', 'b', 'c')
```

The list of keys can be given as:
- one or multiple `string`
- Array of `string`

### nand(list)

With this logic check you ensure that some of the given keys may be set but neither
all of them.

```js
const schema = new ObjectSchema().nand('a', 'b', 'c')
```

The list of keys can be given as:
- one or multiple `string`
- Array of `string`

### or(list)

With this logic check you ensure that at least one of the given keys are
present in the data object.

```js
const schema = new ObjectSchema().or('a', 'b', 'c')
```

The list of keys can be given as:
- one or multiple `string`
- Array of `string`

### xor(list)

With this logic check you ensure that exactly one and not multiple of the given keys are
present in the data object.

```js
const schema = new ObjectSchema().xor('a', 'b', 'c')
```

The list of keys can be given as:
- one or multiple `string`
- Array of `string`

### with(key, peers)

With this logic check you ensure that if the given 'key' is set all of the other
peers have to be present, too.

```js
const schema = new ObjectSchema().with('a', ['b', 'c'])
```

The parameters may be:
- first `string` as the key to check and one or multiple `string` as peers
- first `string` as the key to check and Array of `string` peers (more clear in
  reading code)

### without(key, peers)

With this logic check you ensure that if the given 'key' is set none of the other
peers are allowed.

```js
const schema = new ObjectSchema().without('a', ['b', 'c'])
```

The parameters may be:
- first `string` as the key to check and one or multiple `string` as peers
- first `string` as the key to check and Array of `string` peers (more clear in
  reading code)


## Deeper checks

### key(name, check)

Specify the schema for a specific value or for all values which keys match the given pattern. Only the first
match is used and directly specified `key` goes first, too.
- `name`: have to be a `string` or `RegExp` matching one or multiple keys
- `check`: is a new `Schema` type instance which defines the value of this element

__Example__

```js
const schema = new ObjectSchema()
.key('one', new AnySchema())
.key(/number\d/, new AnySchema())
schema.key() // to remove all keys
schema.key('one') // to only remove this key
```

> References are not possible here.
