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
      this._itemsDescriptor,
      this._lengthDescriptor,
    )
    this._rules.validator.push(
      this._splitValidator,
      this._toArrayValidator,
      this._typeValidator,
      this._uniqueValidator,
      this._itemsValidator,
      this._lengthValidator,
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
    if (check.unique === undefined) return Promise.resolve()
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
            `No duplicate elements in list allowed: '${util.inspect(e)}' found more than once`))
        }
        c.add(e)
      }
    }
    return Promise.resolve()
  }

  // shuffle
  // sort

  item(check?: Schema): this {
    const set = this._setting
    if (check === undefined) delete set.items
    else {
      if (!set.items) set.items = []
      set.items.push(check)
    }
    return this
  }

  _itemsDescriptor() {
    const set = this._setting
    let msg = ''
    if (set.items) {
      set.items.forEach((schema, i) => (msg += `- ${i}: ${schema.description}\n`))
      if (msg.length) msg = `The following items have a special format:\n${msg}\n`
    }
    return msg
  }

  _itemsValidator(data: SchemaData): Promise<void> {
    const check = this._check
    // check value
    if (!check.items) return Promise.resolve()
    const checks = []
    data.value.forEach((e, i) => {
      const schema = check.items[i] || check.items[check.items.length - 1]
      checks.push(schema.validate(data.sub(i)))
    })
    // catch up sub checks
    return Promise.all(checks)
    .catch(err => Promise.reject(err))
    .then((result) => {
      data.value = result
      return Promise.resolve()
    })
  }

  min(value?: number | Reference): this {
    const set = this._setting
    if (value) {
      if (!(value instanceof Reference)) {
        const int = parseInt(value, 10)
        if (int < 0) throw new Error('Length for min() has to be positive')
        if (set.max && !this._isReference('max') && value > set.max) {
          throw new Error('Length for min() should be equal or below max')
        }
      }
      set.min = value
    } else delete set.min
    return this
  }

  max(value?: number | Reference): this {
    const set = this._setting
    if (value) {
      if (!(value instanceof Reference)) {
        const int = parseInt(value, 10)
        if (int <= 0) throw new Error('Length for max() has to be positive')
        if (set.min && !this._isReference('min') && value < set.min) {
          throw new Error('Length for max() should be equal or above min')
        }
      }
      set.max = value
    } else delete set.max
    return this
  }

  length(value?: number | Reference): this {
    const set = this._setting
    if (value) {
      if (!(value instanceof Reference)) {
        const int = parseInt(value, 10)
        if (int <= 0) throw new Error('Length has to be positive')
      }
      set.min = value
      set.max = value
    } else {
      delete set.min
      delete set.max
    }
    return this
  }

  _lengthDescriptor() {
    const set = this._setting
    let msg = ''
    if (set.min || set.max) {
      if (set.min === set.max) {
        if (this._isReference('min')) {
          return `The object has to contain the number of items specified in \
${set.min.description}.\n`
        }
        return `The object has to contain exactly ${set.min} items.\n`
      }
      if (this._isReference('min')) {
        msg += `The object needs at have at least the specified in ${set.min.description} \
number of items. `
      } else {
        msg += `The object needs at least ${set.min} items. `
      }
      if (this._isReference('max')) {
        msg += `The object can't have more than specified in ${set.max.description} \
items. `
      } else {
        msg += `The object allows up to ${set.min} items. `
      }
      if (set.min && set.max && !this._isReference('min') && !this._isReference('max')) {
        return `The object needs between ${set.min} and ${set.max} items.\n`
      }
    }
    return msg.length ? msg.replace(/ $/, '\n') : msg
  }

  _lengthValidator(data: SchemaData): Promise<void> {
    const check = this._check
    try {
      this._checkNumber('min')
      this._checkNumber('max')
    } catch (err) {
      return Promise.reject(new SchemaError(this, data, err.message))
    }
    // check value
    const num = data.value.length
    if (check.min && num < check.min) {
      return Promise.reject(new SchemaError(this, data,
      `The object should has a length of ${num} elements. \
This is too less, at least ${check.min} are needed.`))
    }
    if (check.max && num > check.max) {
      return Promise.reject(new SchemaError(this, data,
      `The object should has a length of ${num} elements. \
This is too much, not more than ${check.max} are allowed.`))
    }
    return Promise.resolve()
  }


  // format()

}

export default ArraySchema
