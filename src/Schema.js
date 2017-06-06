// @flow
import util from 'util'

import SchemaError from './SchemaError'

// TODO maybe data class
// structure of data Object
// references to schema to use
// checker = new validator.check(data, schema)
// checker.load(date2)
// checker.validate()
//
//

class Schema {

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

  get description(): string {
    if (this._default) return `It will default to ${util.inspect(this._default)} if not set.`
    return this._optional ? 'It is optional and must not be set.' : ''
  }

  validate(data: any): Promise<void> {
    return new Promise((resolve) => {
      // check optional
      const value = this._validateOptional(data)
      return resolve(value)
    })
  }

  _validateOptional(data: any): any {
    const value = data === undefined && this._default ? this._default : data
    if (!this._optional && value === undefined) {
      throw new SchemaError(this, 'This element is mandatory!')
    }
    return value
  }

}

export default Schema
