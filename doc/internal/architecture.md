# Architecture

The internal architecture is described only in it´s basics.


## Schema classes

Each schema class should inherit from `Schema` or any of it´s subclasses. It needs a constructor
class like below which calls the parent constructor using `super`.

```js
constructor(title?: string, detail?: string) {
  super(title, detail)
  // init settings
  const set = this._setting
  set.allow = new Set()
  set.disallow = new Set()
  // add check rules
  this._rules.descriptor.push(
    this._allowDescriptor,
  )
  this._rules.check.push(
    this._allowCheck,
  )
  this._rules.validator.push(
    this._allowValidator,
  )
}
```

Within the constructor some settings may be initialized. This is not necessary for flags or simple
settings.

Then you add the functions to describe, optimize the check values and validate to the `_rules`
arrays. Because the parent constructor was called the rules from the parent are already set.
The order may be important.

Next you have to add the methods to set the schema settings:

```js
stripEmpty(flag?: bool | Reference): this { return this._setFlag('stripEmpty', flag) }
default(value?: any): this { return this._setAny('default', value) }
```

The above shows some simple setters which can be completely set using the `_setFlag` and `_setAny`
methods but you may also code it by hand if it is more complex:

```js
valid(value?: any): this {
  const set = this._setting
  if (value instanceof Reference) {
    throw new Error('Reference is only allowed in allow() and disallow() for complete list')
  }
  if (value === undefined) set.required = false
  else if (set.allow instanceof Reference) {
    throw new Error('No single value if complete allow() list is set as reference.')
  } else {
    set.allow.add(value)
    if (!(set.allow instanceof Reference)) set.disallow.delete(value)
  }
  return this
}
```

Here you see the checking for possible reference values everywhere and that if a value is set at
one point it may also change another one. This methods may also throw `Error` if anything impossible is set.

And at last the methods for the rules which are referenced in the constructor have to be set.
The best way is to name the methods after the area and type. Each part may have:
- descriptor - which generates a human description ending with single newline
- check - which may change the schema check (resolved setting) values
- validator - which finally will test and sanitize the value

```js
_emptyDescriptor() {
  const check = this._check
  if (check.stripEmpty instanceof Reference) {
    return `Empty values are set to \`undefined\` depending on ${check.default.description}.\n`
  }
  return check.stripEmpty ? 'Empty values are set to `undefined`.\n' : ''
}

_allowCheck(): void {
  const check = this._check
  // transform arrays from references to set
  if (!check.allow) check.allow = new Set()
  else if (Array.isArray(check.allow)) check.allow = new Set(check.allow)
  else if (!(check.allow instanceof Set)) {
    throw new Error('The `allow` setting have to be a Set.')
  }
}

_emptyValidator(data: SchemaData): Promise<void> {
  const check = this._check
  if (check.stripEmpty && (
    data.value === '' || data.value === null || (Array.isArray(data.value) && !data.value.length)
    || (Object.keys(data.value).length === 0 && data.value.constructor === Object)
  )) {
    data.value = undefined
  }
  return Promise.resolve()
}
```

While the descriptor method has to be synchronous check and validator methods may be synchronous
or return a Promise.


## References

References are a core element of this validator. They should be supported everywhere.






## Control Flow

- set schema
- the schema is checked while defining
- validate
- data references are resolved
- schema references are resolved
- concrete schema definition is checked, maybe error
- validator rules are called
- resulting data structure is returned




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
