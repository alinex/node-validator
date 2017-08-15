# How to


## Create schema

It is possible to use the same schema in more than one position but you may also
`clone` a definition and change some parts on the second position.

```js
// config.schema.js

// @flow
import ObjectSchema from '../../src/ObjectSchema'
import StringSchema from '../../src/StringSchema'
import NumberSchema from '../../src/NumberSchema'

const schema = new ObjectSchema()
  .key('title', new StringSchema().allow(['Dr.', 'Prof.']))
  .key('name', new StringSchema().min(3).required())
  .key('street', new StringSchema().min(3).required())
  .key('plz', new NumberSchema().required()
    .positive().max(99999)
    .format('00000'))
  .key('city', new StringSchema().required().min(3))


module.exports = schema
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
to prevent access to the unchecked) and get a detailed description in markdown format using
`err.text()` on failures.


## Load

The following code will load configuration data and validates them:

```js
import validator from 'alinex-validator'

import schema from './config.schema.js'
// alternative:
// const schema = path.resolve(__dirname, 'config.schema.js')

validator.load('config', schema)
  .then((data) => {
    console.log(data)
  })
  .catch((err) => {
    console.error(err.text())
  })
```

If you only want to check them through API you won't need the `.then`-clause.


## Check

The check of config files using the CLI:


```bash
$ validator comfig lib/schema.config.js
```

That's the same as loading without using the value through API.


## Transform

The transform method can also be called through CLI to write a javascript method exporting the
data structure:

```bash
$ validator comfig lib/schema.config.js local/config.js
```

To do the same using API use:

```js
import validator from 'alinex-validator'

import schema from './config.schema.js'
// alternative:
// const schema = path.resolve(__dirname, 'config.schema.js')

validator.transform('config', schema, 'local/config.js')
  .catch((err) => {
    console.error(err.text())
  })
  .then(() => {
    // go on
  })
```
