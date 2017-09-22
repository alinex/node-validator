# File Schema

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

### baseDir(dir)

If not set or if this directory is relative the  base will be the current working directory.
Which mostly is the directory the application is started from.

```js
const schema = new URLSchema().baseDir('/data') // resolve files from this directory
schema.baseDir() // to remove settings
```

### allow(list) / deny(list)

In principal this is identical to the [any](any.md) type and also `valid(item)` and `invalid(item)` may be used
but the matching allows glob patterns.

### exists / readable / writable

Check if the URL really exists and/or is accessible for reading or writing. Using multiple of them is
the same as using only the highest order (write > read > exists). It is also possible that a location
really exists but is not visible to the current process id, so it is assumed as non-existent.

```js
const schema = new URLSchema().exists()
schema.exists(false) // to remove settings
```

```js
const schema = new URLSchema().readable()
schema.readable(false) // to remove settings
```

```js
const schema = new URLSchema().writable()
schema.writable(false) // to remove settings
```


## Optimizing

### resolve

For relative URLs this will return the absolute path.

```js
const schema = new URLSchema().resolve('https://alinex.github.io')
schema.resolve() // to remove settings
```
