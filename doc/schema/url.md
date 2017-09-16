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

### dns

The dns flag here will trigger a `dns()` check on the domain part of the URL.

### allow(list) / deny(list)

In principal this is identical to the any type and also `valid(item)` and `invalid(item)` may be used
but the matching is a way complexer.

You can give
- protocol - `http:`
- protocol with host - `http://alinex.de`
- path - `/index.html`
- complete url

### resolve(base)

For relative URLs this gives a base to resolve them to a full URL.

```js
const schema = new URLSchema().resolve('https://alinex.github.io')
schema.resolve() // to remove settings
```

### exists

Check if the URL really exists and is accessible.

```js
const schema = new URLSchema().exists()
schema.exists() // to remove settings
```
