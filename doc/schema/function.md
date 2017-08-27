# Function Schema

Create a schema that matches a function.

See at [Base Schema](base.md) for the inherited methods you may call like:
- `title()`
- `detail()`
- `required()`
- `forbidden()`
- `default()`
- `raw()`

## Checking arguments

The number of arguments which have to be there may be checked. Splats and parameter with default
values are not counted here.

### min(limit) / max(limit) / length(limit)

Specifies the number of arguments the function needs to have.
- `limit` gives the fix `number`
- `min` and `max` defines a range

```js
const schema = new FunctionSchema().min(1).max(3)
schema.min().max() // to remove both settings
const schema = new FunctionSchema().length(3)
```

References are also possible:

```js
const ref = new Reference(5)
const schema = new FunctionSchema().length(ref)
```
