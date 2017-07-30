# References

This is a special type which is used in another form.

## Usage

### Within schema

It can be set in schema settings on the
normal types to read the setting from the reference instead of using a fixed setting value.

```js
const schema = new ObjectSchema()
// as value
.key('a', new Reference(...))
// as setting value
.key('b', new BooleanSchema().default(new Reference(...)))
// as flag setting
.key('c', new BooleanSchema().optional(new Reference(...)))
```

If references are used within a schema it will resolve before using the value. If not specifically
defined as raw the reference will check for values within the validating structure only after the
value pointed to is checked itself.

> This may lead to circular references which will freeze the check. If so change the reference or
> use the raw value in one place at least.

### Within data structure

A reference may also be used within the data structure:

```js
const data = {
  // as value
  a: new Reference(...)
}
```

Within the data structure the references will be resolved also before using them. Here the `raw()`
value will always be used ignoring the setting in the reference itself. So no problems with circular
references will be there.

> It is only replaced in parts which are specified with any type of Schema. Parts which are deeper
and are not specified in Schema will not be replaced.

## Sources

The references allows to point to
- other parts of the validating structure
- any other data structure
- an function returning data directly or by promise
- a command output
- a local file content
- a web resource

And each source may return results pointing to other sources, too. But this is only possible in the
above list top-down. So the given function may return a command to call, which returns a file URI
which contains a we URI there the real data is loaded.

### Schema Data

```js
const ref = new Reference() // will use the current schema data element as start
```

### Object Structure

```js
const ref = new Reference(data)
```

### Function

```js
function source() { ... }
const ref = new Reference(source)
```

### Command

```js
const ref = new Reference('exec://date')
```

This can also be used on remote commands:

```js
const ref = new Reference('ssh://server/date') // server defined for alinex-exec
const ref = new Reference('ssh://root:password@server/date')
```

### Local file

```js
const ref = new Reference('file:///etc/myconf')
```

### Web resource

```js
const ref = new Reference('http://example.com/data')
const ref = new Reference('http://example.com/data')
```

## Accessors

### path()

```js
const data = {
  a: { b: '11' },
  c: '2',
}
const ref1 = new Reference(data).path('/c') // '2'
const ref2 = new Reference(data).path('/a/b') // '11'
```

Backreferences are only possible in schema data:

```js
const ref = new Reference().path('../a') // neighbor element
```

### range()

### search()

### split()

### match()

### parse()

### join()

### filter()

### addRef()

### fn()
