# Number Schema

Create a schema that matches a numerical value.

See at [Any Schema](any.md) for the inherited methods you may call like:
- `required`
- `default()`
- `stripEmpty`
- `allow()`
- `allowAll()`
- `allowToClear`

## Sanitize

### unit(unit) / toUnit(unit)

This specifies the unit of the stored numerical value and also allows to give
values in each compatible unit which will automatically recognized and converted.
- `unit()` defines the primary unit, all given number values are of this unit
- `toUnit()` will make (maybe second) conversion and works only together with `unit()`

```js
const Schema = new NumberSchema().unit('m').toUnit('cm')
// allows the value to be: '1.28 m', '0.00128 km' or 1.28 => 128
```

> It can be removed using the `not` flag.

### sanitize

If this flag is set the first numerical value from the given text will be used.
That allows any non numerical characters before or after the value, which will be
stripped away.

```js
const Schema = new NumberSchema().sanitize
```

> Using the `not` flag it can also be removed later.

### round(precision, method)

This allows to round the value to a given precision (number of fraction digits)
and a rounding method ('arithmetic', 'floor', 'ceil'). The default is to use
0 digits arithmetic rounding if called without any parameter.

```js
const Schema = new NumberSchema().round(2)
```

> Using the `not` flag it can also be removed later.

## Value checks

### positive / negative

Allow only positive or negative values.

```js
const Schema = new NumberSchema().positive
```

The corresponding other setting will be removed.

> Using the `not` flag it can also be removed later.

### min(value / max(value) / greater(value) / less(value)

Define a allowed range of `min`, `max` or `greater`, `less` settings. The given value
has to be within the defined range which also is involved with `positive` and `negative`.
While `min` and `max` also allows the given limit as value `greater` and `less`
will not.

```js
const Schema = new NumberSchema().min(5).less(100)
```

> Using the `not` flag it can also be removed later.
