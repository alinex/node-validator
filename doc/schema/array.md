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
schema.sanitize(true).unique(false) // remove the settings
```

And references are used on both like:

```js
const ref = new Reference(true)
const schema = new ArraySchema().sanizize(ref).unique(ref)
```

### shuffle(bool)

All list items will be shuffled to get a random order:

```js
const schema = new ArraySchema().shuffle()
schema.shuffle(false) // remove the setting
```

A reference may be used as flag:

```js
const ref = new Reference(true)
const schema = new ArraySchema().shuffle(ref)
```

### sort(bool)

Sort a list alphabetically by it's contents:

```js
const schema = new ArraySchema().sort()
schema.sort(false) // remove the setting
```

A reference may be used as flag:

```js
const ref = new Reference(true)
const schema = new ArraySchema().sort(ref)
```

### reverse(bool)

Additionally to `sort()` or separately the order of the list items will be reversed:

```js
const schema = new ArraySchema().reverse()
schema.reverse(false) // remove the settings
```

A reference may be used as flag:

```js
const ref = new Reference(true)
const schema = new ArraySchema().reverse(ref)
```

### format(string)

Convert the list into a text string in one of the following formats:
- `json` - use standard json format
- `pretty` - use more readable, human style
- `simple` - make a comma separated list

```js
const schema = new ArraySchema().format('simple')
schema.format() // remove the setting
```

A reference may be used as flag:

```js
const ref = new Reference('human')
const schema = new ArraySchema().format(ref)
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

### min(limit) / max(limit) / length(limit)

Specifies the number of items in the array which are allowed.
- `limit` gives the `number` of items

```js
const schema = new ArraySchema().min(1).max(3)
schema.min().max() // to remove both settings
```

References are also possible:

```js
const ref = new Reference(5)
const schema = new ArraySchema().length(ref)
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
