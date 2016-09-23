Schema Definition
==============================================================

The schema is the definition of the allowed element. It specifies the type and range
of the value, the sanitize methods and checks to use and will be used to check and
precalculate complex object structures.

The Schema is defined as object with the concrete specification as
attributes. The common attributes are:

- title - gives a short title for the element
- description - has a more descriptive information
- type - check type
- key - used in object's entries to give a regexp matchhing the keys for which
  the rule is specified.

In it's easiest way the schema definition includes only a type:

``` coffee
schema =
  type: 'integer'
```

Or with the above descriptive fields:

``` coffee
schema =
  title: "Max runs"
  description: 'the number of runs which may occur'
  type: 'integer'
```

Further each type has it's own additional attributes which may be set to
specify how it works.

``` coffee
address =
  type: 'object'
  allowedKeys: true
  entries:
    name:
      type: 'string'
    street:
      type: 'string'
    city:
      type: 'string'
    country:
      type: 'string'
    email:
      type: 'string'
```

See the documentation of each type for further information on their attributes.

This attributes can be differentiated into the groups:

- sanitize options - try to make the value parseable
- validate options - check if the value is valid
- format options - change the value to a specific output format

You will find them in the type description.


Compositing
----------------------------------------------------

As your structure gets more and more complex it may help you keep the overview
if you divide by setting some parts to variables first before compositing all
together:

``` coffee
address =
  type: 'object'
  allowedKeys: true
  entries:
    name:
      type: 'string'
    street:
      type: 'string'
    city:
      type: 'string'
    country:
      type: 'string'
    email:
      type: 'string'

console.log validator.checkSync
  name: 'audiocd'
  value: value
  schema:
    type: 'object'
    allowedKeys: true
    entries:
      title:
        type: 'string'
      publisher: address
      artists:
        type: 'array'
        notEmpty: true
        entries: address
      composer: address
```

The above example shows how to composite a complex structure out of parts and
how to reuse the same elements.


Optional values
-----------------------------------------------------------

All types (excluding boolean) support the `optional` parameter, which makes an
entry in the data structure optional.
If not given it will be set to null or the value given by `default`.

- `optional` - the value must not be present (will return null)
- `default` - value used if optional and no value given

The `default` option automatically makes the setting optional.
