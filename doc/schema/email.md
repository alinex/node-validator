# Email Address Schema

The value has to an email address.

This is a specialization of the `AnySchema` the methods used there are used in the same way as in [Any Schema](any.md):
- `title()`
- `detail()`
- `required()`
- `forbidden()`
- `default()`
- `stripEmpty()`
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

And the methods from [Domain Schema](domain.md):
- `punycode()`
- `resolve()`


## Checking

### dns

The dns flag here will trigger a `dns('MX')` check on the domain part of the email address.

### allow(list) / deny(list)

In principal this is identical to the any type and also `valid(item)` and `invalid(item)` may be used
but the matching is a way complexer.

You can give complete email addresses, sub domains, domains or TLD in the list. The more precise
element has precedence over the more general ones.


## Formatting

### withName

The email may also be in the form each mail program accepts using a descriptive name and the real
address in `<>` brackets like: 'My Name <mailbox@server.de>'. This is always possible but the
resulting value will only contain the pure address if the `withName()` option is not set.

```js
const schema = new EmailSchema().withName() // keep descriptive name
schema.withName(false) // to remove settings
```
