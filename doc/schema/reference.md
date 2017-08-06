# References

This is a special type which is used in another form.

## Usage

### Within schema

It can be set in schema settings on the
normal types to read the setting from the reference instead of using a fixed setting value.

```js
const schema = new ObjectSchema()
// as value
.key('a', new Reference(...))
// as setting value
.key('b', new BooleanSchema().default(new Reference(...)))
// as flag setting
.key('c', new BooleanSchema().optional(new Reference(...)))
```

If references are used within a schema it will resolve before using the value. If not specifically
defined as raw the reference will check for values within the validating structure only after the
value pointed to is checked itself.

> This may lead to circular references which will freeze the check. If so change the reference or
> use the raw value in one place at least.

### Within data structure

A reference may also be used within the data structure:

```js
const data = {
  // as value
  a: new Reference(...)
}
```

Within the data structure the references will be resolved also before using them. Here the `raw()`
value will always be used ignoring the setting in the reference itself. So no problems with circular
references will be there.

> It is only replaced in parts which are specified with any type of Schema. Parts which are deeper
and are not specified in Schema will not be replaced.

## Sources

The references allows to point to
- other parts of the validating structure
- any other data structure
- a function returning data directly or by promise
- an environment value
- a command output
- a local file content
- a web resource

And each source may return results pointing to other sources, too. But this is only possible in the
above list top-down. So the given function may return a command to call, which returns a file URI
which contains a we URI there the real data is loaded.

### Schema Data

This allows you to reference other values within the same schema. This will get the validated value
of the referenced element:

```js
const ref = new Reference() // will use the current schema data element as start
```

### Object Structure

Also a value can be retrieved from any other data structure:

```js
const ref = new Reference(data)
```

### Function

For every not as simple things you can also give a function which returns a promise or the base
value:

```js
function source() { ... }
const ref = new Reference(source)
```

### Environment Setting

Use a value from the environment.

```js
const ref = new Reference('env://TEST')
```

### Command

An local command may be also called by giving a command line:

```js
const ref = new Reference('exec://date')
const ref = new Reference('exec:///bin/date +%Y') // with full path and options
```

This can also be used on remote commands (not implemented yet!):

```js
const ref = new Reference('ssh://server#date') // server defined for alinex-exec
const ref = new Reference('ssh://root:password@server#date')
const ref = new Reference('ssh://root@server/home/alex/.ssh/id#date')
```

### Local file

The local file is read in as complete text.

```js
const ref = new Reference('file:///etc/myconf')
```

### Web resource

The page code or file contents is used as one text element.

```js
const ref = new Reference('http://example.com/data')
const ref = new Reference('https://example.com/data')
```

## Accessors

The different accessor methods are used to work on the reference value and get the final value out.
They are added to a queue and are done in the order they are defined.

### path()

Allows to access specific parts of an object structure:

```js
const data = {
  a: { b: '11' },
  c: '2',
}
const ref1 = new Reference(data).path('/c') // '2'
const ref2 = new Reference(data).path('/a/b') // '11'
```

Backreferences are only possible in schema data:

```js
const ref = new Reference().path('../a') // neighbor element
```

You can search by using asterisk as directory placeholder or a double asterisk to go multiple level deep:

```js
const ref = new Reference().path('/name/*/min')   // within any subelement
const ref = new Reference().path('/name/*/*/min') // two level deep
const ref = new Reference().path('/name/**/min')  // in any depth
```

You may also use regexp notation to find the correct element:

```js
const ref = new Reference().path('/name/test[AB]/min') // one missing character
const ref = new Reference().path('/name/test\d+/min')  // multiple missing characters
```

See the [Mozilla Developer Network](https://developer.mozilla.org/de/docs/Web/ JavaScript/Reference/Global_Objects/RegExp) for the possible syntax but without modifier.

### keys()

Get only the list of keys from an object.

```js
const data = { one: 1, two: 2 }
const ref = new Reference(data).keys()
// value will be ['one', 'two']
```

### values()

Get only the list of values from an object.

```js
const data = { one: 1, two: 2 }
const ref = new Reference(data).values()
// value will be [1, 2]
```

### trim()

Starting and ending whitespace which may come from file read or command input will be removed.

```js
const data = 'Test\n'
const ref = new Reference(data).trim()
// value will be 'Test'
```

This method may also called on arrays or objects which will trim all of their string values.

### split(separator, separator, separator)

This allows to split the string element or the array/objects string values by the defined
separators. Up to three splits may be defined here.

```js
const data = 'One;Eins\nTwo;Zwei\nThree;Drei'
const ref = new Reference(data).trim('\n', ';')
// value will be [['One', 'Eins'], ['Two', 'Zwei'], ['Three', 'Drei']]
```

If nothing given the newline character is assumed as only separator.
You may also use regular expressions to separate the string.

### join(separator, separator, separator)

This is the opposite of `split` and will join array maybe with sub arrays together into a single
string. The first separator is used for the outermost join.

```js
const data = [['One', 'Eins'], ['Two', 'Zwei'], ['Three', 'Drei']]
const ref = new Reference(data).join('\n', ';')
// value will be 'One;Eins\nTwo;Zwei\nThree;Drei'
```

If no separator given it will join one level deep with newline as separator.

### match(regexp)

Run a regular expression on the string and get the found matches back or the match and it's groups
for single matches.

```js
const data = 'The house number one is just beside house number three.'
const ref = new Reference(data).match(/number (\w+)/g)
// value will be ['number one', 'number three']
const ref = new Reference(data).match(/number (\w+)/)
// value will be ['number one', 'one']
```

For single matches element 0 will be the full match, the groups will follow. If used on object or
list each element of them will be replaced with the match result.

### range(list...)

The range allows to filter specific elements of an array or object. All other elements will be
removed.

```js
const data = [10, 11, 12, 13, 14, 15]
const ref = new Reference(data).range([1], [3, 5])
// value will be [11, 13, 14]
const ref = new Reference(data).range([0, 2], [3, -1])
// value will be [10, 11, 13, 14]
```

The lists contain one or two integers defining the element to extract or the range of elements
to extract. The number `0` defines the start or end of the list. Also negative numbers can be used
to define the element from the end. If an end number is given all elements till the defined but
excluding the end number are included.

### filter(list|RegExp)

The filter allows to select only some elements of an array or object. Therefor you give a list of
allowed elements or an expression which must be matched.

```js
const data = ['number one', 'number two', 'number three', 'number four']
const ref = new Reference(data).filter('number three', 'number four', 'number five')
// value will be ['number three', 'number four']
const ref = new Reference(data).filter(/ t/)
// value will be ['number two', 'number three']
```

Use `exclude()` for negated selection.

### exclude(list|RegExp)

The exclude allows to select all elements without the defined ones from an array or object. Therefor
you give a list of disallowed elements or an expression which should not be matched.

```js
const data = ['number one', 'number two', 'number three', 'number four']
const ref = new Reference(data).exclude('number three', 'number four', 'number five')
// value will be ['number one', 'number two']
const ref = new Reference(data).exclude(/ t/)
// value will be ['number one', 'number four']
```

Use `filter()` for positive selection.





### flatten(separator)

    array
    object

### deepen(separator)

    string

### parse(format)

The parse method allows to convert a string from a defined format into a data structure. The
following formats are supported:
- yaml
- json
- xml
- csv

### fn(options)

    call method like internal accessors

### or(Reference)

    go on if first returns undefined

### concat(Reference)

    strings
    arrays
    objects
