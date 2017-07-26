// @flow
import util from 'util'

import AnySchema from './AnySchema'
import SchemaError from './SchemaError'
import type SchemaData from './SchemaData'
import Reference from './Reference'

class DatetimeSchema extends AnySchema {

  constructor(title?: string, detail?: string) {
    super(title, detail)
    this._setting.type = 'datetime'
    // add check rules
    let allow = this._rules.descriptor.pop()
    this._rules.descriptor.push(
      this._typeDescriptor,
//      this._makeStringDescriptor,
//      this._replaceDescriptor,
//      this._caseDescriptor,
//      this._checkDescriptor,
//      this._lengthDescriptor,
//      this._matchDescriptor,
      allow,
    )
    allow = this._rules.validator.pop()
    this._rules.validator.push(
//      this._fromStringValidator,
      this._typeValidator,
//      this._replaceValidator,
//      this._caseValidator,
//      this._checkValidator,
//      this._lengthValidator,
//      this._matchValidator,
      allow,
    )
  }

  // setup schema

  type(value: 'date'|'time'|'datetime' = 'datetime'): this { return this._setAny('type', value) }
  range(flag?: bool | Reference): this { return this._setFlag('range', flag) }

  _typeDescriptor() { // eslint-disable-line class-methods-use-this
    const set = this._setting
    if (set.range) return `A range of ${set.type} is needed with start and end ${set.type}.\n`
    return `It has to be a ${set.type}. It may also be given in string format.\n`
  }

  _typeValidator(data: SchemaData): Promise<void> {
    const check = this._check
    if (check.range) {
      if (!Array.isArray(data.value)) {
        return Promise.reject(new SchemaError(this, data,
          `An array containg start and end ${check.type} is needed`))
      }
      if (data.value.length < 2) {
        return Promise.reject(new SchemaError(this, data, `The end ${check.type} is missing`))
      }
      if (data.value.length > 2) {
        return Promise.reject(new SchemaError(this, data,
          `Too much elements in ${check.type} range`))
      }
      if (!(data.value[0] instanceof Date)) {
        return Promise.reject(new SchemaError(this, data, `The start is no ${check.type} element`))
      }
      if (!(data.value[1] instanceof Date)) {
        return Promise.reject(new SchemaError(this, data, `The end is no ${check.type} element`))
      }
    }
    if (!(data.value instanceof Date)) {
      return Promise.reject(new SchemaError(this, data, `A ${check.type} is needed`))
    }
    return Promise.resolve()
  }

//  makeString(flag?: bool | Reference): this { return this._setFlag('makeString', flag) }
//
//  _makeStringDescriptor() {
//    const set = this._setting
//    let msg = 'A text is needed. '
//    if (set.makeString instanceof Reference) {
//      msg += `It will be converted to string depending on ${set.makeString.description}. `
//    } else if (set.makeString) {
//      msg += 'If the value is no string it will be converted to one. '
//    }
//    return msg.replace(/ $/, '\n')
//  }
//
//  _makeStringValidator(data: SchemaData): Promise<void> {
//    const check = this._check
//    try {
//      this._checkBoolean('makeString')
//    } catch (err) {
//      return Promise.reject(new SchemaError(this, data, err.message))
//    }
//    // check value
//    if (check.makeString && typeof data.value !== 'string') data.value = data.value.toString()
//    if (typeof data.value !== 'string') {
//      return Promise.reject(new SchemaError(this, data, 'A `string` value is needed here.'))
//    }
//    return Promise.resolve()
//  }


}

export default DatetimeSchema
