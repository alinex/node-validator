# IP Address Schema

The value has to be an IP address.

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


## Optimizations

### lookup

If this flag is set names can be given too. They will be translated into an IP address using DNS
lookup.

```js
const schema = new IPSchema().lookup() // give 'localhost' or any name to translate
schema.lookup(false) // to go back to default setting
```

### mapping

If a specific type of IP address is needed (see `version(int)`) this setting will convert the
address between the two formats if necessary and possible.

```js
const schema = new IPSchema().mapping() // allow mapping
schema.mapping(false) // to go back to default setting
```

## Check Options

### version(int)

Set a specific type of IP which is necessary.

```js
const schema = new IPSchema().version(4) // IPv4 is needed
const schema = new IPSchema().version(6) // IPv6 is needed
schema.version() // to go back to default setting
```

### allow(list) / deny(list)

In principal this is identical to the any type and also `valid(item)` and `invalid(item)` may be used
but the matching is a way complexer.

You can give concrete addresses to the list but also ip ranges in the form of CIDR (the IP address
and the significant bits behind e.g. ‘127.0.0.1/8’) or by the following named ranges:
- `unspecified`
- `broadcast`
- `multicast`
- `linklocal`
- `loopback`
- `private`
- `reserved`
- `uniquelocal`
- `ipv4mapped`
- `rfc6145`
- `rfc6052`
- `6to4`
- `teredo`
- `special` => all of the named ranges above

```js
// example with only the 192.168.*.* addresses and public ones allowed
const schema = new IPSchema().deny('private').allow('192.168.0.0/16')
```


## Output options

### format(name)

The IP address will be given in a `short` form by default but you may also use:
- `short` - ffff:: (default)
- `long` - ffff:0:0:0:0:0:0:0
- `array` - [65535, 0, 0, 0, 0, 0, 0, 0]
