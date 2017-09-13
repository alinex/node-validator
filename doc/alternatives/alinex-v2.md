# Alinex V2 (older version)

As this is the prior and older version nearly everything is possible again but in another way. See
also the few changes below:

> The code examples are only pseudo code to make it shorter

| Alinex V2 | Alinex V3 |
| --------- | --------- |
| `all.optional=true` | default |
| `all.default=val` | `any.default(val)` |
| `and` |  `logic.allow(schema1).and(schema2)` |
| `any` | `any` |
| `array` | `array` |
| `array.notEmpty=true` | `array.filter()` |
| `array.minLength=length` | `array.min(length)` |
| `array.maxLength=length` | `array.max(length)` |
| `array.toArray=true` | `array.toArray()` |
| `boolean` | `boolean` |
| `boolean.format=[t,f]` | `boolean.format(t,f)` |
| `byte` | `number` |
| `byte.unit=unit` | `number.unit(unit)` |
| `byte.round=true` | `number.round()` |
| `byte.decimal=num` | `number.round(num)` |
| `byte.min=val` | `number.min(val)` |
| `byte.max=val` | `number.max(val)` |
| `datetime` | `date` |
| `datetime.range=true` | `date` |
| `datetime.timezone=tz` | `date` |
| `datetime.min=val` | `date.min(val)` |
| `datetime.max=val` | `date.max(val)` |
| `datetime.part='date'` | `date.type('date')` |
| `datetime.part='time'` | `date.type('time')` |
| `datetime.part='datetime'` | `date.type('datetime')` |
| `datetime.format=fmt` | `date.format(fmt)` |
| `datetime.locale=ll` | `date.toLocale(ll)` |
| `datetime.toTimezine=tz` | `date.timezone(tz)` |
| `email` | `email` |
| `email.lowerCase=true` | `email.lowerCase()` |
| `email.normalize=true` | - |
| `email.checkServer=true` | `email.dns()` |
| `email.checkBlacklisted=true` | - |
| `email.checkGraylisted=true` | - |
| `file` | - |
| `file.basedir=dir` | - |
| `file.resolve=true` | - |
| `file.exists=true` | - |
| `file.find=fn` | - |
| `file.filetype=type` | - |
| `float` | `number` |
| `float.sanitize=true` | `number.sanitize()` |
| `float.unit=unit` | `number.unit(unit)` |
| `float.round=true` | `number.round()` |
| `float.round='floor'` | `number.round(0, 'floor')` |
| `float.round='ceil'` | `number.round(0, 'ceil')` |
| `float.decimals=num` | `number.round(num)` |
| `float.min=val` | `number.min(val)` |
| `float.max=val` | `number.max(val)` |
| `float.toUnit=unit` | `number.toUnit(unit)` |
| `float.format=fmt` | `number.format(fmt)` |
| `float.locale=ll` | - |
| `function` | `function` |
| `handlebars` | - |
| `hostname` | `domain` |
| `integer` | `number.integer()` |
| `integer.sanitize=true` | `number.sanitize()` |
| `integer.unit=unit` | `number.unit(unit)` |
| `integer.round=true` | `number.round()` |
| `integer.round='floor'` | `number.round(0, 'floor')` |
| `integer.round='ceil'` | `number.round(0, 'ceil')` |
| `integer.min=val` | `number.min(val)` |
| `integer.max=val` | `number.max(val)` |
| `integer.inttype=type` | `number.integerType(type)` |
| `integer.unsigned=true` | `number.positive()` |
| `integer.toUnit=unit` | `number.toUnit(unit)` |
| `integer.format=fmt` | `number.format(fmt)` |
| `integer.locale=ll` | - |
| `interval` | - |
| `interval.unit=unit` | - |
| `interval.round=true` | - |
| `interval.decimals=num` | - |
| `interval.min=val` | - |
| `interval.max=val` | - |
| `ipaddr` | `ip` |
| `ipaddr.version='ipv4'` | `ip.version(4)` |
| `ipaddr.allow=list` | `ip.allow(list)` |
| `ipaddr.deny=list` | `ip.deny(list)` |
| `ipaddr.format='short'` | `ip.format('short')` |
| `ipaddr.format='long'` | `ip.format('long')` |
| `object` | `object` |
| `object.flatten=true` | `object.flatten()` |
| `object.instanceOf=class` | - |
| `object.mandatoryKeys=true` | set each one as required |
| `object.mandatoryKeys=list` | `object.requiredKeys(list)` |
| `object.allowedKeys=true` | `object.denyUnknown()` |
| `object.allowedKeys=list` | define them and use `object.denyUnknown()` |
| `object.entries=schema` | `object.key(/./, schema)` |
| `object.keys=map` | `object.key(name, schema)` |
| `or=foo,bar` | `logic.allow(foo).or(bar)` |
| `percent` | `number` |
| `port` | `port` |
| `port.allow=list` | `port.allow(list)` |
| `port.deny=list` | `port.deny(list)` |
| `regexp` | - |
| `string` | `string` |
| `string.makeString=true` | `string.makeString()` |
| `string.allowControls=true` | `string.controls()` |
| `string.stripTags=true` | `string.noHTML()` |
| `string.lowerCase=true` | `string.lowercase()` |
| `string.lowerCase='first'` | `string.lowercase('first')` |
| `string.upperCase=true` | `string.uppercase()` |
| `string.upperCase='first'` | `string.uppercase('first')` |
| `string.replace=list[match,replace]` | `string.replace(match,replace)` |
| `string.trim=true` | `string.trim()` |
| `string.crop=num` | `string.max(num).truncate()` |
| `string.minLength=num` | `string.min(num)` |
| `string.maxLength=num` | `string.max(num)` |
| `string.values=list` | `string.allow(list)` |
| `string.startsWith=text` | `string.match(/^text/)` |
| `string.endsWith=text` | `string.match(/text$/)` |
| `string.match=match` | `string.match(match)` |
| `string.matchNot=match` | `string.notMatch(match)` |
