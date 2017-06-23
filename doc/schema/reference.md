# References

This is a special type which is used in another form.

## Within schema

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

## Within data structure

A reference may also be used within the data structure:

```js
const data = {
  // as value
  a: new Reference(...)
}
```

Within the data structure the references will be resolved also before using them. Here the `raw`
value will always be used ignoring the setting in the reference itself. So no problems with circular
references will be there.

## Possibilities

The references allows to point to
- other parts of the validating structure
- any other data structure
- an function returning data directly or by promise
- a web resource
- a local file content
- a command output
