# Logic Schema

This is not a new data type but a logical wrapper around other types.

It allows you to combine different schema settings using different logical operators. This gives
you the possibility to define alternatives or put different schema in queue together like String
sanitization with number conversion.

See at [Base Schema](base.md) for the inherited methods you may call like:
- `title()`
- `detail()`
- `default()`
- `stripEmpty()`
- `raw()`


## Schema combination

It is possible to put multiple schemas together with logical AND and OR.

### allow(schema) / deny(schema)

Such logic queues can be started in two ways. As a positive queue using `allow()` to only select the
ones which succeeds the logic. Or as a negative queue using `deny()` to only allow the settings
which will not succeed in logic.

```js
const schema = new LogicSchema()
.allow(new StringSchema().replace(/_/g, '', 'remove _'))
.and(new NumberSchema())
```


```js
const schema = new LogicSchema()
.deny(new StringSchema().match(/6[01]6/)) // deny '606' + '616' (string)
.or(new NumberSchema().positive.max(99)) // deny 0..99 (number)
```

### and(schema) / or(schema)

The logical queue is processed in the following precedence: `AND`, `OR` and top down.
This is the same as in most programming languages. If you need braces use a sub logic schema which
does exactly this.

You can use both operators multiple times:
- **AND** here both schema definitions have to validate. They will run serial so that the later ones get the
changed values from the earlier.
- **OR** at least one of the schema definitions has to validate.


## Conditionals

It is also possible to use a schema as a conditional operator and decide how to validate depending
on it's result, if it succeeds or fails. This is in the same way normal if..then..else conditions work.

### if(schema)

This starts the conditional...
