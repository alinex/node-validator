// @flow
import util from 'util'

import Schema from './type/Schema'
import Data from './Data'

class SchemaError extends Error {
  schema: Schema
  data: Data

  constructor(schema: Schema, data: Data, msg: string) {
    super(msg)
    this.schema = schema
    if (data) this.data = data
  }

  inspect(): string {
    return `Error at ${this.data.source}: ${this.message} `
  }

  get text(): string {
    return `__${this.message}__

> Given value was: \`${util.inspect(this.data.value)}\`
> At path: \`${this.data.source}\`

But __${this.schema._title}__ ${this.schema._detail}:
${this.schema.description}`
  }
}

export default SchemaError
