# Schema Builder

The schema defines how to validate and sanitize the data structures. It is defined
by using instances of the schema classes and setting their properties.

```js
import { ObjectSchema, AnySchema } from 'alinex-validator'

const schema = new ObjectSchema('MyTest', 'is an easy schema to show it´s use')
.key('one', new Any().not.optional)
.key('two', new Any().default(2))

const data = { one: 1 }
schema.validate(data)
.then(res => console.log(res))
.catch(err => console.error(err.text))
// res = { one: 1, two: 2 }
```

Everything works like this, in the first line the needed classes are loaded. The
second paragraph defines the schema with two specified keys. And in the last paragraph
the schema is used to validate a data structure.

See the different schema descriptions for their possible settings and use cases.

To see exactly what your schema allows output it's `description` property and you
will get the resulting configuration explained.
