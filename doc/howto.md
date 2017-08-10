# How to


## Create schema

It is possible to use the same schema in more than one position but you may also
`clone` a definition and change some parts on the second position.

```js
// config.schema.js
import ObjectSchema from 'alinex-validator/lib/ObjectSchema'
import StringSchema from 'alinex-validator/lib/StringSchema'
import NumberSchema from 'alinex-validator/lib/NumberSchema'

const schema = new ObjectSchema()
.key('title', new StringSchema().uppercase().min(3).max(30))
.key('number', new NumberSchema().positive().integer())

module.exports(schema)
```

It is also a good idea to pack the schema into it´s own file and make the `schema` the default
export like int his example.


## Describe structure

Read the `description` property and you will get the documentation as markdown text. You may
convert this to HTML or other format using any markdown tool. This gives you an online help.

```js
import schema from './config.schema.js'

const msg = schema.description
console.log(msg)
```


## Validate

To really check the data structure call the `validate` method.

```js
import schema from './config.schema.js'

let data = { ... } // any data structure to check

schema.validate(data)
  .then((data) => {
    console.log(data)
  })
  .catch((err) => {
    console.error(err.text())
  })
```

Like seen in this example you can further work with the validated data (it is overloaded here
to prevent access to the unchecked) and get a detailed description in markdown format using `err.text()` on failures.


## Load

```js
import validator from 'alinex-validator'
import schema from './config.schema.js'

let data = { ... } // any data structure to check

schema.validate(data)
  .then((data) => {
    console.log(data)
  })
  .catch((err) => {
    console.error(err.text())
  })
```

## Check


## Transform
