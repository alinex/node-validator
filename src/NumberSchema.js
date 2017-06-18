// @flow
import util from 'util'
import Quantity from 'js-quantities'

import AnySchema from './AnySchema'
import SchemaError from './SchemaError'
import type SchemaData from './SchemaData'

class NumberSchema extends AnySchema {

  // validation data

  _sanitize: bool
  _unit: string

  constructor(title?: string, detail?: string) {
    super(title, detail)
    // init settings
    this._sanitize = false
    // add check rules
    this._rules.add([this._unitDescriptor, this._unitValidator])
    this._rules.add([this._sanitizeDescriptor, this._sanitizeValidator])
  }

  // setup schema

  get sanitize(): this {
    this._sanitize = !this._negate
    this._negate = false
    return this
  }

  unit(unit?: string): this {
    if (this._negate) {
      delete this._unit
      this._negate = false
    } else if (unit) {
      try {
        Quantity(unit)
      } catch (e) { throw new Error(`Unit ${unit} not recognized`) }
      this._unit = unit
    } else {
      throw new Error('To set a unit specify it as parameter to `unit()`')
    }
    return this
  }

  // using schema

  _unitDescriptor() {
    return this._unit ? `Give the values in \`${this._unit}\`.\n` : ''
  }

  _unitValidator(data: SchemaData): Promise<void> {
    if (this._unit && typeof data.value === 'string') {
      if (this._sanitize) data.value = data.value.replace(/^.*?([-+]?\d+\.?\d*\s*\S*).*?$/, '$1')
      let quantity
      try {
        quantity = new Quantity(data.value)
      } catch (e) {
        return Promise.reject(new SchemaError(this, data,
        `Could not parse the unit of ${data.value}: ${e.message}`))
      }
      try {
        data.value = quantity.to(this._unit).scalar
      } catch (e) {
        return Promise.reject(new SchemaError(this, data,
        `Could not convert unit: ${e.message}`))
      }
    }
    return Promise.resolve()
  }

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
