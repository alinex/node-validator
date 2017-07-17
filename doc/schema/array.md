# Array Schema

Create a schema that contains a list of values of any type.

See at [Base Schema](base.md) for the inherited methods you may call like:
- `required()`
- `default()`
- `stripEmpty()`


## Sanitize

### split(matcher)

This setting allows to automatically split strings or objects which could be converted to strings
into array by splitting them on a defined matcher:

```js
const schema = new ArraySchema().split(',') // split by string
const schema = new ArraySchema().split(/\D+/) // split by regular expression
schema.split() // remove the setting
```

Like seen above the separator may be a `string` or `RegExp`.

```js
const ref = new Reference(',')
const schema = new ArraySchema().split(ref)
```

References are also possible here.

### toArray(bool)

This option allows to give an element directly if only one should be there. The list around it will
be made automatically.

```js
const schema = new ArraySchema().toArray()
schema.toArray(false) // remove the setting
```

So if a single number `3` is given it will be converted to `[3]`. As always a reference can be used
here, too.

```js
const ref = new Reference(true)
const schema = new ArraySchema().toArray(ref)
```

### sanitize(bool)

This option in combination with some checks will automatically fix your value instead of an alert.
You may remove it as all flags by giving `false` to it.

### sanitize().unique(bool)

Remove duplicate elements to get only unique values:

```js
const schema = new ArraySchema().sanitize().unique()
schema.sanitize(false).unique(false) // remove the settings
```

And references are used on both like:

```js
const ref = new Reference(true)
const schema = new ArraySchema().sanizize(ref).unique(ref)
```


## Checking

### unique(bool)

If called without sanitize it will alert if duplicate values are contained.

```js
const schema = new ArraySchema().unique()
schema.unique(false) // remove the setting
```

And references are used on both like:

```js
const ref = new Reference(true)
const schema = new ArraySchema().unique(ref)
```


## Deeper checks

### item(check)

Specify the schema for one or multiple items of the array list. If you call this once you define the
check for element number 0. If you call it multiple times you define the continuing element numbers
1, 2, ... The last given check is used for all further elements automatically.

__Example__

This defines a list containing multiple elements of the same schema:

```js
const schema = new ArraySchema().item(new AnySchema())
schema.item() // to remove all item settings
```

And here we need a string as the first list element with other data for the rest and exactly 3
entries.

```js
const schema = new ArraySchema().length(3)
.item(new StringSchema())
.item(new AnySchema())
```
