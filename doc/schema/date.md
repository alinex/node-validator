# Datetime Schema

Create a schema that matches date or time values.

It can be used for dates, time, date with time and also ranges of them which consists of a start
and end date or time.

See at [Any Schema](any.md) for the inherited methods you may call like:
- `title()`
- `detail()`
- `required()`
- `default()`
- `stripEmpty()`
- `allow()`
- `deny()`
- `valid()`
- `invalid()`
- `raw()`


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

Set the timezone which is assumed as default if none is given. You may give the short names or the
complete written names.

```js
const schema = new DateSchema().timezone('EST')
schema.timezone('Eastern Standard Time') // alternative with complete name
schema.timezone() // to remove setting
```

References are also possible:

```js
const ref = new Reference('EST')
const schema = new DateSchema().timezone(ref)
```


## Validation

You may give a time frame in which the date may be. The time frame may also be given in the same way
as the date value. So you can also use the 'now' date.

### min(value) / max(value) / greater(value) / less(value)

Define a allowed range of `min`, `max` or `greater`, `less` settings. The given time/date
has to be within the defined range.
While `min` and `max` also includes the given limit as time/date `greater` and `less`
will not.

```js
const schema = new DateSchema().min('now') // date in the future
schema.min() // to remove setting

const schema = new DateSchema().less('now') // date in the past
schema.less() // to remove setting
```

This method names are used in favoir of before and after to be equivalent to the number type and
others.


## Format

### format()

Define the format for the output. This may be `milliseconds` or `seconds` (alias `unix`) to convert
to a unix timestamp (since 1st January 1970) or with a format defined under:
https://momentjs.com/docs/#/displaying/format/

You may also use some of the predefined formats:
- ISO8601: `YYYY-MM-DDTHH:mm:ssZ`
- RFC1123: `ddd, DD MMM YYYY HH:mm:ss z`
- RFC2822: `ddd, DD MMM YYYY HH:mm:ss ZZ`
- RFC822: `ddd, DD MMM YY HH:mm:ss ZZ`
- RFC1036: `ddd, D MMM YY HH:mm:ss ZZ`

```js
const schema = new DateSchema().format('YYYY-MM-DD HH:mm:ss')
schema.format() // to remove setting
```

If no format is given a `Date` object is returned.

```js
const ref = new Reference('YYYY-MM-DD HH:mm:ss')
const schema = new DateSchema().format(ref)
```

### toLocale()

The format can also be converted to other locales (non english). You may also use some special
localized formats with this.

```js
const schema = new DateSchema().toLocale('de').format('LLLL')
schema.toLocale() // to remove locale setting
```

```js
const ref = new Reference('de')
const schema = new DateSchema().toLocale(ref).format('LLLL')
```

### toTimezone()

This allows to change the timezone of the outcoming time in format:

```js
const schema = new DateSchema().toTimezone('CET').format('LLLL')
schema.toTimezone() // to remove setting
```

```js
const ref = new Reference('CET')
const schema = new DateSchema().toTimezone(ref).format('LLLL')
```
