// @flow
import type Schema from './Schema'

class SchemaError extends Error {

  schema: Schema

  constructor(schema: Schema, msg: string) {
    super(msg)
    this.schema = schema
  }
}

export default SchemaError
