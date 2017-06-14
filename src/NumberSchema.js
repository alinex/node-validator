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
    return this._sanitize ?
    'Strings are matched sanitize for possible `true`/`false` values.\n' : ''
  }

  _sanitizeValidator(data: SchemaData): Promise<void> {
    if (this._sanitize && typeof data.value === 'string') data.value = data.value.toLowerCase()
    return Promise.resolve()
  }

}

export default NumberSchema
