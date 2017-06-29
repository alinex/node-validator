# Any Schema

Create a schema that matches any data type.

This is an universal type which may be used everywhere there no further knowledge
of the structure is known. It can also be used to make a loose checking schema
first and later replace it through detailed specifications.

See at [Base Schema](base.md) for the inherited methods you may call like:
- `required()`
- `default()`
- `stripEmpty()`

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
schema.allow()
```

> If called without a value or an empty array it will remove the list.

### disallow(list)

Opposite to `allow()` this allows to specify elements which are not allowed like a blacklist.
The complete list will be changed by giving a new list as single element, list of elements or
an array of elements. If this is called multiple times it will always replace the previous list.
To add some values `invalid()` may be used multiple times.

```js
const schema = new AnySchema().inallow([5, 10])
schema.inallow()
```




### valid(value)

If you specify at least one value which is allowed only the allowed values are
possible. Therefore a deep check of the values will be done.

```js
const schema = new AnySchema().valid(5)
```

> References are impossible here, use `allow()` therefore.

### invalid(value)

Also you may define which elements you won´t allow. If only invalid elements are
defined all other elements are possible.

```js
const schema = new AnySchema().invalid(5)
```
> References are impossible here, use `disallow()` therefore.
