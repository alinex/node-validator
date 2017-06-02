// @flow
import util from 'util'

import SchemaError from './SchemaError'

class Schema {

  data: any
  result: any
  error: SchemaError

  // validation data

  _optional: bool
  _default: any

  constructor() {
    this._optional = true
  }

  optional(value: bool): Schema {
    this._optional = value
    return this
  }

  default(value: any): Schema {
    this._default = value
    return this
  }

  // using schema

  load(data: any): Schema {
    this.data = data
    return this
  }

  clear(): Schema {
    delete this.data
    delete this.result
    delete this.error
    return this
  }

  describe(): string {
    if (this._default) return `It will default to ${util.inspect(this._default)} if not set.`
    return this._optional ? 'It is optional and must not be set.' : ''
  }

  validate(): Promise<void> {
    return new Promise((resolve, reject) => {
      const value = this.data === undefined && this._default ? this._default : this.data
      if (!this._optional && value === undefined) {
        return reject(this.fail('This element is mandatory!'))
      }
      this.result = value
      return resolve()
    })
  }

  // after validating

  object(): any {
    return this.result
  }

  // helper methods

  fail(msg: string) {
    this.error = new SchemaError(this, msg)
    return this.error
  }

}

export default Schema
