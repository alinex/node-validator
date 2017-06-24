# Architecture

The internal architecture is described only in it´s basics.


## Schema classes

Each schema class should inherit from `Schema` or any of it´s subclasses.


REWRITE FROM HERE




### Example

A full schema is described in this example.

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
    if (this.negate) {
      this._invalid.add(value)
      this._valid.delete(value)
    } else {
      this._valid.add(value)
      this._invalid.delete(value)      
    }
    this._negate = false
    return this
  }
```

Like also seen in the code you always have to support the `this._negate` setting
and reset it's value.

Now the previously added methods each as `...Descriptor` and `..Validator` have
to be defined in this pattern:

```js
  // using schema

  _allowDescriptor() {
    if (this._valid.size) {
      return `Only the keys ${Array.from(this._valid).join(', ')} are allowed.\n`
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

The descriptor returns simple markdown and need a newline as last character to format
nicely as text if multiple messages are collected.

And at last close the class and export it. To make it available it has to be
re-exported in `src/index.js`
```js
}

export default MySchema
```

### How it works

The methods which are used from the outside are `description` and `validate` which
are both defined in the base `Schema` class and don´t need to be overwritten.

With the defined rules they will collect all information from the concrete subclass
or run all validations.

### Setter methods

To keep it simple there are no alias method names to set properties. Also there
are no pretty coding methods like 'is', 'be', 'should'...

All boolean settings are set using getters and support the `not` property before.
As possible the default should be a `false` value which is then set. So if the
default is to be optional the method should better be called `require` to
don´t need the not in most cases.
