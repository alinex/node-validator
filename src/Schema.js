// @flow
import SchemaError from './SchemaError'

class Schema {

  data: any
  result: any
  error: Error

  // validation data

  _optional: bool

  constructor() {
    this._optional = true
  }

  optional(value: bool) {
    this._optional = value
    return this
  }

  // using schema

  load(data: any) {
    this.data = data
  }

  describe(): string {
    return this.toString()
  }

  validate(): Promise<void> {
    this.result = this.data
    return Promise.resolve()
  }

  fail(msg: string) {
    this.error = new SchemaError(this, msg)
    return this.error
  }

  // after validating

  object(): any {
    return this.result
  }
}

export default Schema
