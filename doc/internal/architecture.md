# Architecture

The internal architecture is described only in it´s basics. Always have a look in the code.


## Schema classes

Each schema class should inherit from `Schema` or any of it´s subclasses and is placed in the `type`
folder.

```js
import AnySchema from './Any'
import ValidationError from '../Error'
import type Data from '../Data'
import Reference from '../Reference'

class IPSchema extends AnySchema {
  // content goes here
}
```

You also see some imports which are basically needed in any schema. All further code goes inside this
class.

A constructor class like below which calls the parent constructor using `super` is needed.

```js
  constructor(base?: any) {
    super(base)
    this._setting.format = 'short'
    // add check rules
    let raw = this._rules.descriptor.pop()
    let allow = this._rules.descriptor.pop()
    this._rules.descriptor.push(
      this._typeDescriptor,
      allow,
      this._versionDescriptor,
      this._formatDescriptor,
      raw,
    )
    raw = this._rules.validator.pop()
    allow = this._rules.validator.pop()
    this._rules.validator.push(
      this._typeValidator,
      allow,
      this._versionValidator,
      this._formatValidator,
      raw,
    )
  }
```

In this you see a lot of things. on line 3 a default will be set for the `format` setting. It is used
if nothing is setup by the implementation.

The rest of the code shows two rule sets which are changed (because order is relevant):
1. the description rules
2. the validation rules

On each of them the last two rules from the parent are popped off to be added later at the correct
position again. Also three new rules are added, the definitions will follow later.

Next you may add some new options:

```js
version(value?: 4 | 6 | Reference): this {
  return this._setAny('version', value)
}
mapping(flag?: bool | Reference): this { return this._setFlag('mapping', flag) }
```

This set up the methods to set the options (really stored in `this._setting.xxx`). The real storing
is done using some set methods but in more complex scenarios you may do this on your own:

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
_versionDescriptor() {
  const set = this._setting
  let msg = ''
  if (set.version) {
    if (this._isReference('version')) {
      msg += `Valid addresses has to be of IP version defined at ${set.version.description}. `
    } else msg += `Only IPv${set.version} addresses are valid. `
  }
  if (set.mapping) {
    if (this._isReference('mapping')) {
      msg += `IPv4 adresses may be automatically converted if set under ${set.mapping.description}. `
    } else msg += 'IPv4 addresses may be automatically converted. '
  }
  return msg.length ? `${msg.trim()}\n` : msg
}

_versionValidator(data: Data): Promise<void> {
  const check = this._check
  try {
    this._checkNumber('version')
    this._checkBoolean('mapping')
    if (check.version && ![4, 6].includes(check.version)) {
      throw new Error(`Only IP version 4 or 6 are valid, ${check.version} is unknown`)
    }
  } catch (err) {
    return Promise.reject(new ValidationError(this, data, err.message))
  }
  // version
  if (check.version) {
    if (check.version === 4) {
      if (data.value.kind() === 'ipv6') {
        if (check.mapping && data.value.isIPv4MappedAddress()) data.value = data.value.toIPv4Address()
        else {
          return Promise.reject(new ValidationError(this, data,
            `The given value is no valid IPv${check.version} address`))
        }
      }
    } else if (data.value.kind() === 'ipv4') {
      if (check.mapping) data.value = data.value.toIPv4MappedAddress()
      else {
        return Promise.reject(new ValidationError(this, data,
          `The given value is no valid IPv${check.version} address`))
      }
    }
  }
  return Promise.resolve()
}
```

While the descriptor method has to be always synchronous, the validator methods may be synchronous
or return a Promise.

You may also overwrite some methods from the parent classes to make them more appropriate to this
type. This is often needed for the allow/deny mechanism to check type sensitive.


## References

References are a core element of the validator. They should be supported nearly everywhere.
But as always there are places in which it makes no sense and only enhances the complexity. But
in all other ones they should be supported by the descriptor and validator methods.


## Control Flow

The workflow will lokk like:
- load the schema
  - set schema (define it)
  - the schema is checked while defining
- validate data structure
  - data references are resolved
  - validate each schema definition level
    - schema references are resolved
    - check for definition errors
    - validator rules are called
    - resulting data structure is returned
  - collect in data class
- return asynchronous with error or resulting data structure

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
