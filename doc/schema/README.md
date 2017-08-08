# Schema Builder

The schema defines how to validate and sanitize the data structures. It is defined
by using instances of the schema classes and setting their properties.

```js
import { Reference, ObjectSchema, AnySchema } from 'alinex-validator'

const schema = new ObjectSchema('MyTest', 'is an easy schema to show it´s use')
schema.key('one', new Any().optional())
.key('two', new Any().default(new Reference(schema).path('/one')))

const data = { one: 1 }
schema.validate(data)
.then(res => console.log(res))
.catch(err => console.error(err.text))
// res = { one: 1, two: 2 }
```

Everything works like this, in the first line the needed classes are loaded. The
second paragraph defines the schema with two specified keys. And in the last paragraph
the schema is used to validate a data structure.

The core of the Validator is the definition of the schema. This is done step by step and may
also throw some errors for invalid combinations. Like also shown references are possible
anywhere.
See the different reference and schema descriptions for their possible settings and use cases.

To see exactly what your schema allows output it's `description` property and you
will get the resulting configuration explained.

## Overview

All types are based on the `Schema` class directly or indirectly.

![Schema types](schema-types.png)

Each of this classes have different properties and settings which you can use to
specify it.

One exception is the reference which is a special type which didn't validate but will get the
value from the defined resource. Read more about this later.

## References

This is a special value which may be used anywhere in the schema definition and points to a value.
It is a dynamic value which will only be known at validation time. If references are used the checking for correct schema definition can also not be completely done before validation. But it is also checked.
Read more about it at the end of this chapter with all the possibilities.

## Booleans

Where boolean values are required in the schema definition you can also use:
- 'yes', 1, '1', 'true', 't', '+', array or object
- 'no', 0, '0', 'false', 'f', '', '-', undefined, empty array or object

In the next examples only simple references with direct values will be used. But all other work, too.
