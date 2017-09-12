# Hostname Schema

The value has to a valid domain name.

This is a specialization of the `StringSchema` the methods used there are used in the same way as in [Any Schema](any.md):
- `title()`
- `detail()`
- `required()`
- `forbidden()`
- `default()`
- `allow()`
- `deny()`
- `valid()`
- `invalid()`
- `raw()`

And the methods from [String Schema](string.md):
- `makeString()`
- `trim`
- `replace()`
- `lowerCase()`
- `upperCase()`
- `alphaNum`
- `hex`
- `allowControls`
- `noHTML`
- `stripDisallowed`
- `min()`
- `max()`
- `length()`
- `match()`
- `notMatch()`


## Checking

### allow(list) / deny(list)

In principal this is identical to the any type and also `valid(item)` and `invalid(item)` may be used
but the matching is a way complexer.

You can give the full domain name, sub domains, domains or TLD in the list. The more precise
element has precedence over the more general ones.

```js
const schema = new DomainSchema()
  .allow('de')
  .deny('spam.de')
```

### min(limit) / max(limit) / length(limit)

The length here works on the number of labels within the domain name. Thats the structural depth of it.


## Formatting

### punycode

The punycode is an ASCII presentation of international domain names. This is the form which is used
internally in the DNS while the browser accepts and displays the unicode representation of it.

```js
const schema = new DomainSchema().punycode() // lügen.de -> xn--lgen-0ra.de
schema.punycode(false) // to remove settings
```
