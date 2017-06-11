# Object Schema

Create a schema that matches any data object which contains key/value pairs.

The values may be of any other type.

See at [Base Schema](base.md) for the inherited methods you may call like:
- `required`
- `default()`
- `stripEmpty`

## key(name: string, check: Schema)

Specify the schema for a specific value.

```js
const schema = new validator.Object()
.key('one', new validator.Any())
```

## pattern(regexp: RegExp, check: Schema)

Specify the schema for all values which keys match the given pattern. Only the first
match is used and directly specified `key` goes first, too.

```js
const schema = new validator.Object()
.pattern(/number\d/, new validator.Any())
```

## removeUnknown

This will remove all unchecked keys from the object. So only the specified are returned.

```js
const schema = new validator.Object().removeUnknown
.key('one', new validator.Any())
```

It may be inverted using `not.required`.

## min(limit: number) / max(limit: number) / length(limit: number)

Specifies the number of keys the object is allowed to have.

```js
const schema = new validator.Object().min(1).max(3)
```
