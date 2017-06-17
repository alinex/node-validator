// @flow
import util from 'util'

import AnySchema from './AnySchema'
import SchemaError from './SchemaError'
import type SchemaData from './SchemaData'

class NumberSchema extends AnySchema {

  // validation data

  _sanitize: bool

  constructor(title?: string, detail?: string) {
    super(title, detail)
    // init settings
    this._sanitize = false
    // add check rules
    this._rules.add([this._sanitizeDescriptor, this._sanitizeValidator])
  }

  // setup schema

  get sanitize(): this {
    this._sanitize = !this._negate
    this._negate = false
    return this
  }

  // using schema

  _sanitizeDescriptor() {
    let msg = 'A number is needed. '
    if (this._sanitize) msg += 'Strings are sanitized to get the first numerical value out of it. '
    return msg.replace(/ $/, '\n')
  }

  _sanitizeValidator(data: SchemaData): Promise<void> {
    if (typeof data.value === 'string') {
      if (this._sanitize) data.value = data.value.replace(/^.*?([-+]?\d+\.?\d*).*?$/, '$1')
      data.value = Number(data.value)
    }
    if (typeof data.value !== 'number') {
      return Promise.reject(new SchemaError(this, data,
      `The given value is of type ${typeof data.value} but a number is needed.`))
    } else if (isNaN(data.value)) {
      return Promise.reject(new SchemaError(this, data,
      `The given string \`${data.orig}\` is no valid number.`))
    }
    return Promise.resolve()
  }

}

export default NumberSchema
