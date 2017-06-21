# How to


## Create schema

It is possible to use the same schema in more than one position but you may also
`clone` a definition and change some parts on the second position.

```js
const schema = new ObjectSchema()
.key('title', new StringSchema().uppercase().min(3).max(30))
.key('number', new NumberSchema().positive.integer)
```

It is also a good idea to pack the schema into it´s own file and make the `schema` the default
export.

## Describe structure

Read the `description` property and you will get the documentation as markdown text. You may
convert this to HTML or other format using any markdown tool.

```js
const msg = schema.description
```

## Validate

To really check the data structure call the `validate` method.

```js
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

## Options for validate
