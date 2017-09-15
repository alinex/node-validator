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

### connect

In advance to the pure dns checking `dns()` this really connects to the server and checks so if
a real mailserver is running under this domain. It will not validate the local part.

```js
const schema = new EmailSchema().connect()
schema.connect(false) // to remove settings
```

### blackList / greyList

In advance the mail server can be checked to not be on a
- blacklist for abusive use
- greylist for untrusted mail accounts

```js
const schema = new EmailSchema()
.blackList() // check for black listed (Spammer)
.greyList()  // check for grey listed (One time accounts...)
schema.blackList(false).greyList(false) // to remove settings
```


## Formatting

### normalize

Extended formats like additional domains, sub domains and tags which mostly belong to the same mailbox
will be removed.

```js
const schema = new EmailSchema().normalize()
schema.normalize(false) // to remove settings
```

Beispiele:
- `alex@googlemail.com` -> `alex@gmail.com`
- `a.l.e.x@gmail.com` -> `alex@gmail.com`
- `alex+spam@gmail.com` -> `alex@gmail.com`
- `a.l.e.x@facebook.com` -> `alex@facebook.com`

### withName

The email may also be in the form each mail program accepts using a descriptive name and the real
address in `<>` brackets like: 'My Name <mailbox@server.de>'. This is always possible but the
resulting value will only contain the pure address if the `withName()` option is not set.

```js
const schema = new EmailSchema().withName() // keep descriptive name
schema.withName(false) // to remove settings
```
