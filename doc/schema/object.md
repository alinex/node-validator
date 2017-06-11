# Object Schema

Create a schema that matches any data object which contains key/value pairs.

The values may be of any other type.

See at [Base Schema](base.md) for the inherited methods you may call like:
- `required`
- `default()`
- `stripEmpty`

## key(name: string|RegExp, check: Schema)

Specify the schema for a specific value or for all values which keys match the given pattern. Only the first
match is used and directly specified `key` goes first, too.

```js
const schema = new validator.Object()
.key('one', new validator.Any())
.key(/number\d/, new validator.Any())
```

> It may be removed using `not.key`.

## removeUnknown

This will remove all unchecked keys from the object. So only the specified are returned.

```js
const schema = new validator.Object().removeUnknown
.key('one', new validator.Any())
```

> It may be inverted using `not.required`.

## min(limit: number) / max(limit: number) / length(limit: number)

Specifies the number of keys the object is allowed to have.

```js
const schema = new validator.Object().min(1).max(3)
```

## requiredKeys(list: string...|Array) / forbiddenKeys(list: string...|Array)

These two methods allow to define the key names which are allowed or disallowed.
It may be called multiple times to specify it.

```js
const schema = new validator.Object().requiredKeys('a', 'b', 'c')
.forbiddenKeys(['d', 'e'])
```

> Use `not` to remove them from one of the lists.

## and(list: string...|Array) / not.and(list: string...|Array)

With this logic check you ensure that all of the given keys or none of them are
present in the data object.

```js
const schema = new validator.Object().and('a', 'b', 'c')
.not.and(['d', 'e', 'f'])
```

## or(list: string...|Array)

With this logic check you ensure that at least one of the given keys are
present in the data object.

```js
const schema = new validator.Object().or('a', 'b', 'c')
```

> If you use the `not` operator it is identical to define them as `forbiddenKeys`.

## xor(list: string...|Array)

With this logic check you ensure that exactly one and not multiple of the given keys are
present in the data object.

```js
const schema = new validator.Object().xor('a', 'b', 'c')
```

> If you use the `not` operator it is identical to define them as `forbiddenKeys`.

## with(key: string, peers: string...|Array)

With this logic check you ensure that if the given 'key' is set all of the other
peers have to be present, too.

```js
const schema = new validator.Object().with('a', ['b', 'c'])
```

## not.with(key: string, peers: string...|Array)

With this logic check you ensure that if the given 'key' is set none of the other
peers are allowed.

```js
const schema = new validator.Object().not.with('a', ['b', 'c'])
```
