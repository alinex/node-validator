# Number Schema

Create a schema that matches a numerical value.

See at [Any Schema](any.md) for the inherited methods you may call like:
- `title()`
- `detail()`
- `required()`
- `forbidden()`
- `default()`
- `stripEmpty()`
- `allow()`
- `deny()`
- `valid()`
- `invalid()`
- `raw()`

## Sanitize

### unit(unit) / toUnit(unit)

This specifies the unit of the stored numerical value and also allows to give
values in each compatible unit which will automatically recognized and converted.
- `unit()` defines the primary unit, all given number values are of this unit
- `toUnit()` will make (maybe second) conversion and works only together with `unit()`

```js
const schema = new NumberSchema().unit('m').toUnit('cm')
// allows the value to be: '1.28 m', '0.00128 km' or 1.28 => 128
schema.unit().toUnit() // to remove the setting
```

Both may be also given as reference:

```js
const ref = new Reference('cm')
const schema = new NumberSchema().unit(ref)
```

### sanitize(bool)

If this flag is set the first numerical value from the given text will be used.
That allows any non numerical characters before or after the value, which will be
stripped away.

```js
const schema = new NumberSchema().sanitize()
schema.sanitize(false) // to remove the setting
```

You may use a reference here:

```js
const ref = new Reference(true)
const schema = new NumberSchema().sanitize(ref)
```

The reference can point to any value which may be converted to true/false.

### round(precision, method)

This allows to round the value to a given precision (number of fraction digits)
and a rounding method ('arithmetic', 'floor', 'ceil'). The default is to use
0 digits arithmetic rounding if called without any parameter.

```js
const schema = new NumberSchema().round(2)
schema.round(false) // to remove the setting
```

> References are not allowed here but within `integer`.

## integer(bool)

The integer flag will check for an integer value. If the sanitize flag is also used it will
automatically round.

```js
const schema = new NumberSchema().sanitize().integer()
schema.integer(false) // to remove the setting
```

You may use a reference here:

```js
const ref = new Reference(true)
const schema = new NumberSchema().sanitize().integer(ref)
```

The reference can point to any value which may be converted to true/false.

## Value checks

### positive(bool) / negative(bool)

Allow only positive or negative values.

```js
const schema = new NumberSchema().positive()
```

The corresponding other setting will be removed.

Both allow references, too:

```js
const ref = new Reference(true)
const schema = new NumberSchema().negative(ref)
```

The reference can point to any value which may be converted to true/false.

### min(value) / max(value) / greater(value) / less(value)

Define a allowed range of `min`, `max` or `greater`, `less` settings. The given value
has to be within the defined range which also is involved with `positive` and `negative`.
While `min` and `max` also include the given limit as value `greater` and `less`
will not.

```js
const schema = new NumberSchema().min(5).less(100)
```
In all of these settings references are allowed:

```js
const ref = new Reference(15)
const schema = new NumberSchema().min(ref)
```

The reference should point to a numerical value.

### integerType(type)

This allows to specify a integer bit size by giving one of the following names or bit-sizes:

| Name | bit Size | min | max | unsigned max |
| ---- | -------- | --- | --- | ------------ |
| byte | 8 | -128 | 127 | 255 |
| short | 16 | -32768 | 32767 | 65535 |
| long | 32 | -2147483648 | 2147483647 | 4294967295 |
| safe | 53 | -4503599627370496 | 4503599627370495 | 9007199254740991 |
| quad | 64 | -9223372036854776000 | 9223372036854776000 | 18446744073709552000 |

Use `positive` to make it unsigned.

```js
const schema = new NumberSchema().integerType('byte').positive()
```

> References are not possible here.

### multiple(value)

The data has to be a multiple of the value set here.

```js
const schema = new NumberSchema().multiple(8) // 16 => ok, 12 => fail
schema.multiple() // to remove setting
```

And with a reference:

```js
const ref = new Reference(15)
const schema = new NumberSchema().multiple(ref)
```

The reference should point to a numerical value.

### format(string)

By setting one of the following format strings you will get the value back as a formatted string:

| Number | Format | String |
| -------| ------ | ------- |
| 10000 | '0,0.0000' | 10,000.0000 |
| 10000.23 | '0,0' | 10,000 |
| 10000.23 | '+0,0' | +10,000 |
| -10000 | '0,0.0' | -10,000.0 |
| 10000.1234 | '0.000' | 10000.123 |
| 100.1234 | '00000' | 00100 |
| 1000.1234 | '000000,0' | 001,000 |
| 10 | '000.00' | 010.00 |
| 10000.1234 | '0[.]00000' | 10000.12340 |
| -10000 | '(0,0.0000)' | (10,000.0000) |
| -0.23 | '.00' | -.23 |
| -0.23 | '(.00)' | (.23) |
| 0.23 | '0.00000' | 0.23000 |
| 0.23 | '0.0[0000]' | 0.23 |
| 1230974 | '0.0a' | 1.2m |
| 1460 | '0 a' | 1 k |
| -104000 | '0a' | -104k |
| 1 | '0o' | 1st |
| 100 | '0o' | 100th |

You can also add the unit if set earlier by adding `$unit` to the format string.

```js
const schema = new NumberSchema().unit('cm').format('0.00 $unit')
schema.format() // to remove setting
```

And last but not least use `$best` to let the system change the unit to the best selection:

```js
const schema = new NumberSchema().unit('cm').format('0.00 $best')
// value 16000 -> '160.00 m'
```

The format can also be given as reference:

```js
const ref = new Reference('0.00 $unit')
const schema = new NumberSchema().unit('cm').format(ref)
```
