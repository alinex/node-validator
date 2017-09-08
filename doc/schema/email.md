# Email Address Schema

The value has to an email address.

This is a specialization of the `AnySchema` the methods used there are used in the same way as in [Any Schema](any.md):
- `title()`
- `detail()`
- `required()`
- `forbidden()`
- `default()`
- `stripEmpty()`
- `allow()`
- `deny()`
- `valid()`
- `invalid()`
- `raw()`


### lowercase

This flag will turn the address part completely into lowercase. This is possible because the case
is irrelevant for email addresses.

```js
const schema = new EmailSchema().lowercase()
schema.lowercase(false) // to remove settings
```

### withName

The email may also be in the form each mail program accepts using a descriptive name and the real
address in `<>` brackets like: 'My Name <mailbox@server.de>'. This is always possible but the
resulting value will only contain the pure address if the `withName()` option is not set.

```js
const schema = new EmailSchema().withName() // keep descriptive name
schema.withName(false) // to remove settings
```
