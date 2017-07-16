# Array Schema

Create a schema that matches any data object which contains key/value pairs.

The values may be of any other type.

See at [Base Schema](base.md) for the inherited methods you may call like:
- `required()`
- `default()`
- `stripEmpty()`


## Sanitize



## Checking Keys


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
