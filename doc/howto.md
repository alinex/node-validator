# How to


## Create schema

It is possible to use the same schema in more than one position but you may also
`clone` a definition and change some parts on the second position.

```js
// config.schema.js

// @flow
import ObjectSchema from 'alinex-validator/dist/type/Object'
import StringSchema from 'alinex-validator/dist/type/String'
import NumberSchema from 'alinex-validator/dist/type/Number'

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

Everything works like this, in the first lines the needed classes are loaded. The
second paragraph defines the schema with two specified keys. And in the last paragraph
the schema is used to validate a data structure.

The core of the Validator is the definition of the schema. This is done step by step and may
also throw some errors for invalid combinations. Like also shown references are possible
anywhere.
See the different reference and schema descriptions for their possible settings and use cases.

To see exactly what your schema allows output it's `description` property and you
will get the resulting configuration explained.

__Complete Schema Loading__

It is also possible to load all schema types instead of each one individually. Therefor use the
builder collection:

```js
import * as val from 'alinex-validator/dist/builder'

const schema = new val.Object()
  .title('MyTest')
  .detail('is an easy schema to show it´s use')
  .key('one', new val.Any().optional())
  .key('two', new val.Any().default(new val.Reference(schema).path('/one')))

const data = { one: 1 }
schema.validate(data)
  .then(res => console.log(res))
  .catch(err => console.error(err.text))
// res = { one: 1, two: 2 }
```

In both examples the schema is applied on the value at the current position in the data structure
but you may also use an other value given as constructor parameter.

It is also a good idea to pack the schema into it´s own file and make the `schema` the default
export like int his example.


## Load Schema

The schema may be loaded in different ways:

```js
// load schema
import schema from './config.schema.js'
schema.validate(data)

// or dynamic load using require
const schema = require(__dirname + '/../data/address.schema')
schema.validate(data)

// or using dynamic es6 imports
import(`${__dirname}/../data/address.schema`)
  .then(schema => schema.validate(data))

// or use the validator internal loader
import validator from 'alinex-validator'
validator.schema(`${__dirname}/../data/address.schema`)
  .then(schema => schema.validate(data))
```


## Describe structure

Read the `description` property and you will get the documentation as markdown text. You may
convert this to HTML or other format using any markdown tool. This gives you an online help.

```js
import schema from './config.schema.js'

const msg = schema.description
console.log(msg)
```


## Load Data

The validator may also load configuration files from filesystem:

```js
import validator from 'alinex-validator'

const data = validator.load('config/**/*.yml') // alternatively may load an array
```

You can also define there to search for relative paths:

```js
import validator from 'alinex-validator'

validator.searchApp('myApp') // search under /etc/myApp an home-dir/.myApp
const data = validator.load('config/**/*.yml')
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

The `data` reference can also be a filename which will be loaded and parsed automatically.
Also glob patterns like in the shell are possible to select multiple files which will be merged together
before validating.


## Check

The check of config files using the CLI:


```bash
$ validator comfig lib/schema.config.js
```

That's the same as loading without using the value through API:

```js
import validator from 'alinex-validator'

import schema from './config.schema.js'

validator.check('config', schema)
  .then((data) => {
    console.log(data)
  })
  .catch((err) => {
    console.error(err.text())
  })

// or alternative with loading specific type
validator.check(validator.load('config', 'yaml'), schema)
  .then((data) => {
    console.log(data)
  })
  .catch((err) => {
    console.error(err.text())
  })
```

If you only want to check them through API you won't need the `.then`-clause.


## Transform

The transform method can also be called through CLI to write the data structure using JSON:

```bash
$ validator comfig lib/schema.config.js local/config.js
```

To do the same using API use:

```js
import validator from 'alinex-validator'

import schema from './config.schema.js'
// alternative:
// const schema = path.resolve(__dirname, 'config.schema.js')

validator.transform('config', schema, 'local/config.json')
  .catch((err) => {
    console.error(err.text())
  })
  .then(() => {
    // go on
  })
```


## CLI Usage

As also possible in the API you may give a relative path which is resolved from the current directory
(mostly the application base directory). And you may use glob patterns in the shell.

__Only check data structure:__

    validator --input <file-or-dir> --schema <file>

This will validate the data structure and show you possible errors. This may be used every time
after something is changed.

__Preparse and transform data structure:__

    validator --input <file-or-dir> --schema <file> --output <json-file>

After validation and optimization the resulting data structure will be written as JSON file to
be easily and fast imported in the program.
