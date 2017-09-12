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
- `lowercase()`
- `uppercase()`
- `alphanum`
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

### lowercase

This flag will turn the address part completely into lowercase. This is possible because the case
is irrelevant for email addresses.

```js
const schema = new DomainSchema().lowercase()
schema.lowercase(false) // to remove settings
```
