# Port Schema

Create a schema that matches a TCP/UDP port number.

This is a specialization of the `NumberSchema` so some of the methods used there are predefined,
while you may use others in the same way as in [Number Schema](number.md):
- `title()`
- `detail()`
- `required()`
- `default()`
- `stripEmpty()`
- `min()`
- `max()`
- `less()`
- `greater()`
- `allow()`
- `deny()`
- `valid()`
- `invalid()`
- `raw()`

Beside the numerical input you may also give port names as known in the /etc/services
list like: 'ftp', 'http', 'ssh', ... If you do so it will be replaced by their default port numbers.

For validation in `allow()`, `deny()`, `valid()` or `invalid()`
you can also use the predefined ranges:
- 'system'
- 'registered'
- 'dynamic'

The order is allow is used before deny, direct number or name is used before range.
