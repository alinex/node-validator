# Datetime Schema

Create a schema that matches date or time values.

It can be used for dates, time, date with time and also ranges of them which consists of a start
and end date or time.

See at [Any Schema](any.md) for the inherited methods you may call like:
- `required()`
- `default()`
- `stripEmpty()`
- `allow()`
- `deny()`
- `valid()`
- `invalid()`


## Type

This schema may contain different form of dates. At first you may set the type to only contain the
date, only the time or both (default: datetime). Also this type may collect a time range which
consists of a start and end value as an array.

### type('date'|'time'|'datetime')

Set the type, the part of the date to store,

```js
const schema = new DateSchema().type('date')
schema.type() // to go back to default setting
```

### range(bool)

If range is set two values are needed in the string or as array containing the start and end.

```js
const schema = new DateSchema().range()
schema.range(false) // to remove setting
```


## Sanitize

timezone()

## Validation

min()
max()
truncate()

## Format

format()
local()
toTimezone()
