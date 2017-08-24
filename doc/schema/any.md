# Any Schema

Create a schema that matches any data type.

This is an universal type which may be used everywhere there no further knowledge
of the structure is known. It can also be used to make a loose checking schema
first and later replace it through detailed specifications.

See at [Base Schema](base.md) for the inherited methods you may call like:
- `title()`
- `detail()`
- `required()`
- `default()`
- `stripEmpty()`
- `raw()`

A lot of other types are also based on this one.

## Allow / deny elements

With the following settings specific values may be defined which are allowed or denied. If used
for some subtypes the values also have to fit into the subtype schema.

### allow(list)

The complete list will be changed by giving a new list as single element, list of elements or
an array of elements. If this is called multiple times it will always replace the previous list.
To add some values `valid()` may be used multiple times.

The data element has to deeply equal to at least one of the elements in the allowed list. That works
like a whitelist.

```js
const schema = new AnySchema().allow([5, 10])
schema.allow() // remove the complete list
```

If called without a value or an empty array it will remove the list.

```js
const ref = new Reference([1, 2, 3])
const schema = new AnySchema().allow(ref)
```

The reference can point to a list of values which are allowed. In case of an object it will take the
object´s keys. If nothing given the list will be cleared and in all other cases the given element will
be set as the only one in a new list.

### deny(list)

Opposite to `allow()` this allows to specify elements which are not allowed like a blacklist.
The complete list will be changed by giving a new list as single element, list of elements or
an array of elements. If this is called multiple times it will always replace the previous list.
To add some values `invalid()` may be used multiple times.

```js
const schema = new AnySchema().deny([5, 10])
schema.deny()
```

References may be used like for `allow()`.

```js
const ref = new Reference([1, 2, 3])
const schema = new AnySchema().deny(ref)
```

The reference can point to a list of values which are allowed. In case of an object it will take the
object´s keys. If nothing given the list will be cleared and in all other cases the given element will
be set as the only one in a new list.

### valid(value)

Instead of `allow()` this will not replace the allowed list but add to it. You may give a single
value which is added to the list of allowed values. This is impossible if the complete list is
set as reference.

```js
const schema = new AnySchema().allow([1, 2, 3])
.valid(5) // now 1, 2, 3 and 5 are valid
```

To remove a single value set it as `invalid` which also removes it from the allowed list.,

```js
const ref = new Reference(5)
const schema = new AnySchema().valid(ref)
```

Here the reference presents a single value and it is put into the allowed list as it is.

### invalid(value)

Instead of `deny()` this will not replace the denied list but add to it. You may give a single
value which is added to the list of denied values. This is impossible if the complete list is
set as reference.

```js
const schema = new AnySchema().deny([1, 2, 3])
.invalid(5) // now 1, 2, 3 and 5 are invalid
```

To remove a single value set it as `valid` which also removes it from the allowed list.,

```js
const ref = new Reference(5)
const schema = new AnySchema().invalid(ref)
```

Here the reference presents a single value and it is put into the denied list as it is.
