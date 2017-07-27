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

This validator will parse the given format using different technologies in nearly
all common formats:

- ISO 8601 datetimes

      '2013-02-08'
      '2013-W06-5'
      '2013-039'
      '2013-02-08 09'
      '2013-02-08T09'
      '2013-02-08 09:30'
      '2013-02-08T09:30'
      '2013-02-08 09:30:26'
      '2013-02-08T09:30:26'
      '2013-02-08 09:30:26.123'
      '2013-02-08 24:00:00.00'

- ISO 8601 time only
- ISO 8601 date only

      '2013-02-08 09'
      '2013-W06-5 09'
      '2013-039 09'

- ISO 8601 with timezone

      '2013-02-08 09+07:00'
      '2013-02-08 09-0100'
      '2013-02-08 09Z'
      '2013-02-08 09:30:26.123+07:00'

- natural language: 'today', 'tomorrow', 'yesterday', 'last friday'
- named dates

      '17 August 2013'
      '19 Aug 2013'
      '20 Aug. 2013'
      'Sat Aug 17 2013 18:40:39 GMT+0900 (JST)'

- relative dates

      'This Friday at 13:00'
      '5 days ago'

- specials: 'now'

### type('date'|'time'|'datetime')

Set the type, the part of the date to store,

```js
const schema = new DateSchema().type('date')
schema.type() // to go back to default setting
```

### timezone(string)

If range is set two values are needed in the string or as array containing the start and end.

```js
const schema = new DateSchema().range()
schema.range(false) // to remove setting
```


## Validation

min()
max()
truncate()

## Format

format()
local()
toTimezone()
