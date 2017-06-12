# Object Schema

Create a schema that matches any data object which contains key/value pairs.

The values may be of any other type.

See at [Base Schema](base.md) for the inherited methods you may call like:
- `required`
- `default()`
- `stripEmpty`


## Sanitize

### deepen(separator)

A elements containing a special separator are split up on each occurrence and be
converted into a deep structure. The separator may be given as `string` or `RegExp`.

```js
// data = {'a.a': 1, 'a.b': 2, c: 3}
const schema = new MySchema().deepen('.')
// result = {a: {a: 1, b: 2}, c: 3}
```

### flatten(separator)

That's the opposite of deepen and will flatten deep structures using the given
separator which has to be a `string`.

```js
// data = {a: {a: 1, b: 2}, c: 3}
const schema = new MySchema().flatten('.')
// result = {'a.a': 1, 'a.b': 2, c: 3}
```

### removeUnknown

This will remove all unchecked keys from the object. So only the specified are returned.
All elements which has specific checks set via `key` are checked.

```js
const schema = new validator.Object().removeUnknown
.key('one', new validator.Any())
```

> It may be inverted using `not.required`.


## Checking Keys

### min(limit) / max(limit) / length(limit)

Specifies the number of keys the object is allowed to have.
- `limit` gives the `number` of elements to be within the data object

```js
const schema = new validator.Object().min(1).max(3)
```

### requiredKeys(list) / forbiddenKeys(list)

These two methods allow to define the key names which are allowed or disallowed.
It may be called multiple times to specify it.

```js
const schema = new validator.Object().requiredKeys('a', 'b', 'c')
.forbiddenKeys(['d', 'e'])
```

The list of keys can be given as:
- one or multiple `string`
- Array of `string`

> Use `not` to remove them from one of the lists.

## and(list)

With this logic check you ensure that all of the given keys or none of them are
present in the data object.

```js
const schema = new validator.Object().and('a', 'b', 'c')
```

The list of keys can be given as:
- one or multiple `string`
- Array of `string`

## not.and(list)

With this logic check you ensure that some of the given keys may be set but neither
all of them.

```js
const schema = new validator.Object().not.and('a', 'b', 'c')
```

The list of keys can be given as:
- one or multiple `string`
- Array of `string`

## or(list)

With this logic check you ensure that at least one of the given keys are
present in the data object.

```js
const schema = new validator.Object().or('a', 'b', 'c')
```

The list of keys can be given as:
- one or multiple `string`
- Array of `string`

> If you use the `not` operator it is identical to define them as `forbiddenKeys`.

## xor(list)

With this logic check you ensure that exactly one and not multiple of the given keys are
present in the data object.

```js
const schema = new validator.Object().xor('a', 'b', 'c')
```

The list of keys can be given as:
- one or multiple `string`
- Array of `string`

> If you use the `not` operator it is identical to define them as `forbiddenKeys`.

## with(key, peers)

With this logic check you ensure that if the given 'key' is set all of the other
peers have to be present, too.

```js
const schema = new validator.Object().with('a', ['b', 'c'])
```

The parameters may be:
- first `string` as the key to check and one or multiple `string` as peers
- first `string` as the key to check and Array of `string` peers (more clear in
  reading code)

## not.with(key, peers)

With this logic check you ensure that if the given 'key' is set none of the other
peers are allowed.

```js
const schema = new validator.Object().not.with('a', ['b', 'c'])
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
const schema = new validator.Object()
.key('one', new validator.Any())
.key(/number\d/, new validator.Any())
```

> It may be removed using `not.key`.
