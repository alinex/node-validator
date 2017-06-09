# Architecture

The Validator is based on classes which helps you to easily define a specific data
schema. Therefore the appropriate class is used to create an instance and set it up
using it´s methods. This newly created schema may also be a structure and combination
of different schema class instances.

This schema can describe itself human readable and can be given a data structure
to validate. It will run asynchronously over the data structure to check and optimize
it. As a result it will return an promise with the resulting data structure.

If the data isn´t valid it will reject with an Error object which can show the
real problem in detail.


### Schema classes

Each schema class should inherit from `Schema` or any of it´s subclasses:

```js
// @flow
import Schema from '../Schema'
import SchemaError from '../SchemaError'
import type SchemaData from '../SchemaData'

class MySchema extends Schema {
```

Now you define the special fields (only for flow type checking) which are used.
As they are private they start with an underscore to define them as such.

```js
  // validation data

  _valid: Set<any>
  _invalid: Set<any>
```

The constructor have to call it's parent constructor and initialize the above
defined properties. It should also add all rules for this type, which will be
defined below.

```js
  constructor(title?: string, detail?: string) {
    super(title, detail)
    // init settings
    this._valid = new Set()
    this._invalid = new Set()
    // add check rules
    this._rules.add([this._allowDescriptor, this._allowValidator])
  }
```

As next part some public methods are used to set the properties.

```js
  // setup schema

  allow(value: any): this {
    this._valid.add(value)
    this._invalid.delete(value)
  }
```

Now the previously added methods each as `...Descriptor` and `..Validator` have
to be defined in this pattern:

```js
  // using schema

  _allowDescriptor() {
    if (this._valid.size) {
      return `Only the keys ${Array.from(this._valid).join(', ')} are allowed. `
    }
    return ''
  }

  _allowValidator(data: SchemaData): Promise<void> {
    // reject if valid is set but not included
    if (this._valid.size && !this._valid.has(data.value)) {
      return Promise.reject(new SchemaError(this, data,
        'Element not in whitelist (allowed item).'))
    }
    // ok
    return Promise.resolve()
  }
```

And at last close the class and export it. To make it available it has to be
re-exported in `src/index.js`
```js
}

export default AnySchema
```



## Type definition

- new class
- extends `Schema` or other schema
- may have some validation properties
- with rules to set them
- and an overwritten `validate` method

## Schema setup

- import schema
- instantiate it
- set validation settings

## Validation

- `load` data
- `validate`
- `describe`

## Accessing values

- `object`
- `get` direct value (on object)
- `toJS` export javascript

## CLI

- convert yaml

## Special

- `clear` data
- multiple loading
- json schema import

## Ideas

- defaults in schema
- default as extra data structure
- source info
- error list
- structure
