# Presets

Presets are some more specific types which are build using the real schema types with some already
defined options. You can create them using the functions and if you like justify it with some more
options.


## Usage

Here is an example to get a character (based on StringSchema):

```js
import * as val from 'alinex-validator/dist/builder'
// create schema
const schema = val.preset.character()
.upperCase() // specify to be upper case
```


## Possible Presets

### word

A combination of non whitespace charcters with a length of at least 1.
It is based on [StringSchema](string.md).

### character

A single, non whitespace charcter.
It is based on [StringSchema](string.md).

### hostOrIP

Either a domain name or an IP address.
It is based on [LogicSchema](logic.md) using:
- [DomainSchema](domain.md)
- [IPSchema](ip.md)

### plz

The postalcode for german cities consisting of a number with 5 digits.
It is based on [NumberSchema](number.md).
