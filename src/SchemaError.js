// @flow
import util from 'util'

import Schema from './Schema'
import SchemaData from './SchemaData'

class SchemaError extends Error {

  schema: Schema
  data: SchemaData

  constructor(schema: Schema, data: SchemaData, msg: string) {
    super(msg)
    this.schema = schema
    if (data) this.data = data
  }

  get text(): string {
    return `__${this.message}__

> Given value was: ${util.inspect(this.data.value)}
> At path: ${this.data.source}

But __${this.schema.title}__ ${this.schema.detail}
${this.schema.description}`
  }
}

export default SchemaError
