// @flow
import util from 'alinex-util'

import Schema from './Schema'
import SchemaError from './SchemaError'
import type SchemaData from './SchemaData'
import Reference from './Reference'

class ArraySchema extends Schema {

  constructor(title?: string, detail?: string) {
    super(title, detail)
    // add check rules
    this._rules.descriptor.push(
      this._typeDescriptor,
      this._splitDescriptor,
      this._toArrayDescriptor,
      this._uniqueDescriptor,
//      this._keysDescriptor,
//      this._logicDescriptor,
//      this._lengthDescriptor,
    )
    this._rules.validator.push(
      this._splitValidator,
      this._toArrayValidator,
      this._typeValidator,
      this._uniqueValidator,
//      this._keysValidator,
//      this._logicValidator,
//      this._lengthValidator,
    )
  }

  // setup schema

  _typeDescriptor() { // eslint-disable-line class-methods-use-this
    return 'An array list is needed.\n'
  }

  _typeValidator(data: SchemaData): Promise<void> {
    if (!Array.isArray(data.value)) {
      return Promise.reject(new SchemaError(this, data, 'An array list is needed.'))
    }
    return Promise.resolve()
  }

  split(value?: string | RegExp | Reference): this { return this._setAny('split', value) }

  _splitDescriptor() {
    const set = this._setting
    if (set.split instanceof Reference) {
      return `A single string may be split up dependeing on ${set.split.description} \
as separator.\n`
    }
    if (set.split) {
      return `If a single string is given it is split up by \
\`${util.inspect(set.split)}\`.\n`
    }
    return ''
  }

  _splitValidator(data: SchemaData): Promise<void> {
    const check = this._check
    try {
      this._checkMatch('split')
    } catch (err) {
      return Promise.reject(new SchemaError(this, data, err.message))
    }
    // check value
    if (check.split && typeof data.value === 'string') {
      data.value = data.value.split(check.split)
    }
    return Promise.resolve()
  }

  toArray(flag?: bool | Reference): this { return this._setFlag('toArray', flag) }

  _toArrayDescriptor() {
    const set = this._setting
    if (set.toArray instanceof Reference) {
      return `A single element is auto wrapped as array depending on ${set.toArray.description}.\n`
    }
    if (set.toArray) {
      return 'A single element is auto wrapped as array with only this element.\n'
    }
    return ''
  }

  _toArrayValidator(data: SchemaData): Promise<void> {
    const check = this._check
    try {
      this._checkBoolean('toArray')
    } catch (err) {
      return Promise.reject(new SchemaError(this, data, err.message))
    }
    // check value
    if (!Array.isArray(data.value) && check.toArray) data.value = [data.value]
    return Promise.resolve()
  }

  sanitize(flag?: bool | Reference): this { return this._setFlag('sanitize', flag) }
  unique(flag?: bool | Reference): this { return this._setFlag('unique', flag) }

  _uniqueDescriptor() {
    const set = this._setting
    let msg = ''
    if (set.sanitize instanceof Reference) {
      msg += `As possible the list will be sanitized depending on ${set.sanitize.description}. `
    }
    if (set.sanitize) {
      msg += 'As possible the list will be sanitized. '
    }
    if (set.unique instanceof Reference) {
      msg += `All elements have to be unique depending on ${set.unique.description}. `
    }
    if (set.unique) {
      msg += 'All elements have to be unique. '
    }
    return msg.length ? msg.replace(/ $/, '\n') : ''
  }

  _uniqueValidator(data: SchemaData): Promise<void> {
    const check = this._check
    try {
      this._checkBoolean('sanitize')
      this._checkBoolean('unique')
    } catch (err) {
      return Promise.reject(new SchemaError(this, data, err.message))
    }
    // check value
    if (check.sanitize) data.value = util.array.unique(data.value)
    else {
      const c = new Set()
      for (const e of data.value) {
        if (c.has(e)) {
          return Promise.reject(new SchemaError(this, data,
            `'No duplicate elements in list allowed: ${util.inspect(e)}'`))
        }
        c.add(e)
      }
    }
    return Promise.resolve()
  }

  // shuffle
  // sort
  // items() check each item against this if required they have to be there
  //   it may contain them
  //   if required it must contain them
  // ordered() like items but check in order given
  // min() number of items
  // max()
  // length()

  // format()

}

export default ArraySchema
