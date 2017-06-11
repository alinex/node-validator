// @flow
import util from 'util'

import Schema from '../Schema'
import SchemaError from '../SchemaError'
import type SchemaData from '../SchemaData'

class ObjectSchema extends Schema {

  // validation data

  _keys: Map<string, Schema>
  _pattern: Map<RegExp, Schema>
  _removeUnknown: bool
  _min: number
  _max: number

  constructor(title?: string, detail?: string) {
    super(title, detail)
    // init settings
    this._keys = new Map()
    this._pattern = new Map()
    this._removeUnknown = false
    // add check rules
    this._rules.add([this._typeDescriptor, this._typeValidator])
    this._rules.add([this._keysDescriptor, this._keysValidator])
    this._rules.add([this._removeUnknownDescriptor, this._removeUnknownValidator])
    this._rules.add([this._lengthDescriptor, this._lengthValidator])
  }

  // setup schema

  key(name: string, check?: Schema): this {
    if (this._negate) {
      // remove
      this._keys.delete(name)
    } else if (check) {
      this._keys.set(name, check)
    } else {
      throw new Error('Key without schema can´t be defined.')
    }
    this._negate = false
    return this
  }

  pattern(regexp: RegExp, check?: Schema): this {
    if (this._negate) {
      // remove
      this._pattern.delete(regexp)
    } else if (check) {
      this._pattern.set(regexp, check)
    } else {
      throw new Error('Pattern without schema can´t be defined.')
    }
    this._negate = false
    return this
  }

  get removeUnknown(): this {
    this._removeUnknown = !this._negate
    this._negate = false
    return this
  }

  min(limit: number): this {
    const int = parseInt(limit, 10)
    if (int < 0) throw new Error('Length for min() has to be positive')
    if (this._max && int > this._max) {
      throw new Error('Length for min() should be equal or below max')
    }
    this._min = int
    return this
  }

  max(limit: number): this {
    const int = parseInt(limit, 10)
    if (int < 0) throw new Error('Length for max() has to be positive')
    if (this._min && int < this._min) {
      throw new Error('Length for max() should be equal or above min')
    }
    this._max = int
    return this
  }

  length(limit: number): this {
    const int = parseInt(limit, 10)
    if (int < 0) throw new Error('Length for length() has to be positive')
    this._min = int
    this._max = int
    return this
  }

  // using schema

  _typeDescriptor() { // eslint-disable-line class-methods-use-this
    return 'A data object is needed. '
  }

  _typeValidator(data: SchemaData): Promise<void> {
    if (typeof data.value !== 'object') {
      return Promise.reject(new SchemaError(this, data, 'A data object is needed.'))
    }
    return Promise.resolve()
  }

  _keysDescriptor() {
    let msg = ''
    for (const [key, schema] of this._keys) {
      msg += `- \`${key}\`: ${schema.description}\n`
    }
    for (const [re, schema] of this._pattern) {
      msg += `- \`${util.inspect(re)}\`: ${schema.description}\n`
    }
    if (msg.length) msg = `The following keys have a special format:\n${msg}\n`
    return msg
  }

  _keysValidator(data: SchemaData): Promise<void> {
    // check keys
    const checks = []
    const keys = []
    const sum = {}
//      for (let key in data.value) {
    Object.keys(data.value).forEach((key) => {
      const schema = this._keys.get(key)
      if (schema) {
        // against defined keys
        checks.push(schema.validate(data.value[key]))
        keys.push(key)
      } else {
        let found = false
        for (const p of this._pattern.entries()) {
          if (key.match(p[0])) {
            checks.push(p[1].validate(data.value[key]))
            keys.push(key)
            found = true
            break
          }
        }
        // not specified keep it without check
        if (!found) {
          if (!data.temp.unchecked) data.temp.unchecked = []
          data.temp.unchecked[key] = true
          sum[key] = data.value[key]
        }
      }
    })
    return Promise.all(checks)
    .catch(err => Promise.reject(err))
    .then((result) => {
      if (result) {
        result.forEach((e: any, i: number) => { sum[keys[i]] = e })
      }
      data.value = sum
      return Promise.resolve()
    })
  }

  _removeUnknownDescriptor() {
    return this._removeUnknown ? 'Keys not defined with the rules before will be removed. ' : ''
  }

  _removeUnknownValidator(data: SchemaData): Promise<void> {
    if (this._removeUnknown) {
      for (const key in data.temp.unchecked) if (key) delete data.value[key]
    }
    return Promise.resolve()
  }

  _lengthDescriptor() {
    if (this._min && this._max) {
      return this._min === this._max ? `The object has to contain exactly ${this._min} elements. `
      : `The object needs between ${this._min} and ${this._max} elements. `
    }
    if (this._min) return `The object needs at least ${this._min} elements. `
    if (this._max) return `The object allows up to ${this._min} elements. `
    return ''
  }

  _lengthValidator(data: SchemaData): Promise<void> {
    const num = Object.keys(data.value).length
    if (this._min && num < this._min) {
      return Promise.reject(new SchemaError(this, data,
      `The object has a length of ${num} elements. \
This is too less, at least ${this._min} are needed.`))
    }
    if (this._max && num > this._max) {
      return Promise.reject(new SchemaError(this, data,
      `The object has a length of ${num} elements. \
This is too much, not more than ${this._max} are allowed.`))
    }
    return Promise.resolve()
  }

}

export default ObjectSchema
