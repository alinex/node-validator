# Logic Schema

This is not a new data type but a logical wrapper around other types.

It allows you to combine different schema settings using different logical operators. This gives
you the possibility to define alternatives or put different schema in queue together like String
sanitization with number conversion.

See at [Base Schema](base.md) for the inherited methods you may call like:
- `required()`
- `default()`
- `stripEmpty()`


## Start the logic queue

The logic queue can be started in two ways. As a positive queue using `allow()` to only select the
ones which succeeds the logic. Or as a negative queue using `deny()` to only allow the settings
which will not succeed in logic.

### allow(schema)

```js
const schema = new LogicSchema()
.allow(new StringSchema().replace(/_/g, '', 'remove _'))
.and(new NumberSchema())
```

### deny(schema)

```js
const schema = new LogicSchema()
.deny(new StringSchema().match(/6[01]6/)) // deny '606' + '616' (string)
.or(new NumberSchema().positive.max(99)) // deny 0..99 (number)
```

## Logic operators

The logical queue is processed in the following precedence: `AND`, `OR`.
This is the same as in most programming languages. If you need braces use a sub logic schema which
does exactly this.

### and(schema)

### or(schema)


# CODE

set.logic: Set[string, Schema]

replace Schema.validate(data) ? SchemaData : SchemaError

last = null
for [op, schema], i of set.logic
  if op is 'and'    
    set.logic[i][1] = last = schema.validate(last)
  else
    set.logic[i][1] = last = schema.validate(data)

reverse reduce and
reverse reduce or
interpret allow/deny
