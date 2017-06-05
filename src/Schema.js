// @flow
import util from 'util'

import SchemaError from './SchemaError'

class Schema {

  data: any
  result: any
  error: SchemaError

  // validation data

  _negate: bool
  _optional: bool
  _default: any

  constructor() {
    this._negate = false
    this._optional = true
  }

  get not(): Schema {
    this._negate = !this._negate
    return this
  }

  get optional(): Schema {
    this._optional = !this._negate
    this._negate = false
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
    return new Promise((resolve) => {
      // check optional
      const value = this._validateOptional(this.data)
      // ok
      this.result = value
      return resolve(value)
    })
  }

  _validateOptional(data: any): any {
    const value = data === undefined && this._default ? this._default : data
    if (!this._optional && value === undefined) {
      throw this._fail('This element is mandatory!')
    }
    return value
  }

  // after validating

  object(): any {
    return this.result
  }

  // helper methods

  _fail(msg: string) {
    this.error = new SchemaError(this, msg)
    return this.error
  }

}

export default Schema
