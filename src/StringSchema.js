// @flow
import util from 'util'

import AnySchema from './AnySchema'
import SchemaError from './SchemaError'
import type SchemaData from './SchemaData'

class StringSchema extends AnySchema {

  // validation data

  _makeString: bool

  constructor(title?: string, detail?: string) {
    super(title, detail)
    // init settings
    this._makeString = false
    // add check rules
    this._rules.add([this._makeStringDescriptor, this._makeStringValidator])
  }

  // setup schema

  get makeString(): this {
    this._makeString = !this._negate
    this._negate = false
    return this
  }

  // using schema

  _makeStringDescriptor() {
    return this._makeString ?
    'Other objects will be transformed to Strings as possible.\n' : ''
  }

  _makeStringValidator(data: SchemaData): Promise<void> {
    if (this._makeString && typeof data.value !== 'string') data.value = data.value.toString()
    if (typeof data.value !== 'string') {
      return Promise.reject(new SchemaError(this, data, 'A `string` value is needed here.'))
    }
    return Promise.resolve()
  }

}

export default StringSchema
