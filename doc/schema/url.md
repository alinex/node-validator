# URL Schema

The value has to a valid URL address.

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


## Checking


In advance to the pure dns checking `dns()` this really connects to the server and checks so if
a real mailserver is running under this domain. It will not validate the local part.

```js
const schema = new EmailSchema().connect()
schema.connect(false) // to remove settings
```
