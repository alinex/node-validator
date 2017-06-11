// @flow
import util from 'util'

import Schema from '../Schema'
import SchemaError from '../SchemaError'
import type SchemaData from '../SchemaData'

class ObjectSchema extends Schema {

  // validation data

  _keys: Map<string|RegExp, Schema>
  _removeUnknown: bool
  _min: number
  _max: number
  _keysRequired: Set<string>
  _keysForbidden: Set<string>
  _logic: Array<string>

  constructor(title?: string, detail?: string) {
    super(title, detail)
    // init settings
    this._keys = new Map()
    this._removeUnknown = false
    this._keysRequired = new Set()
    this._keysForbidden = new Set()
    this._logic = []
    // add check rules
    this._rules.add([this._typeDescriptor, this._typeValidator])
    this._rules.add([this._keysDescriptor, this._keysValidator])
    this._rules.add([this._removeUnknownDescriptor, this._removeUnknownValidator])
    this._rules.add([this._keysRequiredDescriptor, this._keysRequiredValidator])
    this._rules.add([this._lengthDescriptor, this._lengthValidator])
  }

  // setup schema

  key(name: string|RegExp, check?: Schema): this {
    if (this._negate) {
      // remove
      this._keys.delete(name)
    } else if (check) {
      this._keys.set(name, check)
    } else {
      throw new Error(`${typeof name === 'string' ? 'Key' : 'Pattern'} \
without schema can´t be defined.`)
    }
    this._negate = false
    return this
  }

  get removeUnknown(): this {
    this._removeUnknown = !this._negate
    this._negate = false
    return this
  }

  min(limit?: number): this {
    if (this._negate || limit === undefined) delete this._min
    else {
      const int = parseInt(limit, 10)
      if (int < 0) throw new Error('Length for min() has to be positive')
      if (this._max && int > this._max) {
        throw new Error('Length for min() should be equal or below max')
      }
      this._min = int
    }
    return this
  }

  max(limit?: number): this {
    if (this._negate || limit === undefined) delete this._max
    else {
      const int = parseInt(limit, 10)
      if (int < 0) throw new Error('Length for max() has to be positive')
      if (this._min && int < this._min) {
        throw new Error('Length for max() should be equal or above min')
      }
      this._max = int
    }
    return this
  }

  length(limit?: number): this {
    if (this._negate || limit === undefined) {
      delete this._min
      delete this._max
    } else {
      const int = parseInt(limit, 10)
      if (int < 0) throw new Error('Length for length() has to be positive')
      this._min = int
      this._max = int
    }
    return this
  }

  requiredKeys(...keys: Array<string|Array<string>>): this {
    for (const e of keys) {
      if (typeof e === 'string') {
        if (this._negate) this._keysRequired.delete(e)
        else if (!this._keysRequired.has(e)) this._keysRequired.add(e)
      } else { // array
        for (const l of e) {
          if (this._negate) this._keysRequired.delete(l)
          else if (!this._keysRequired.has(l)) this._keysRequired.add(l)
        }
      }
    }
    this._negate = false
    return this
  }

  forbiddenKeys(...keys: Array<string|Array<string>>): this {
    for (const e of keys) {
      if (typeof e === 'string') {
        if (this._negate) this._keysForbidden.delete(e)
        else if (!this._keysForbidden.has(e)) this._keysForbidden.add(e)
      } else { // array
        for (const l of e) {
          if (this._negate) this._keysForbidden.delete(l)
          else if (!this._keysForbidden.has(l)) this._keysForbidden.add(l)
        }
      }
    }
    this._negate = false
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
      msg += `- \`${typeof key === 'string' ? key : util.inspect(key)}\`: ${schema.description}\n`
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
        for (const p of this._keys.entries()) {
          if (typeof p !== 'string' && key.match(p[0])) {
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

  _keysRequiredDescriptor() {
    let msg = ''
    if (this._keysRequired.size) {
      let list = Array.from(this._keysRequired)
      .map(e => `\`${e}\``).join(', ')
      list = list.replace(/(.*),/, '$1 and')
      msg += `The keys ${list} are required. `
    }
    if (this._keysForbidden.size) {
      let list = Array.from(this._keysForbidden)
      .map(e => `\`${e}\``).join(', ')
      list = list.replace(/(.*),/, '$1 and')
      msg += `None of the keys ${list} are allowed.\n`
    }
    return msg
  }

  _keysRequiredValidator(data: SchemaData): Promise<void> {
    const keys = Object.keys(data.value)
    if (this._keysRequired.size) {
      for (const check of this._keysRequired) {
        if (!keys.includes(check)) {
          return Promise.reject(new SchemaError(this, data,
            `The key ${check} is missing. `))
        }
      }
    }
    if (this._keysForbidden.size) {
      for (const check of this._keysForbidden) {
        if (keys.includes(check)) {
          return Promise.reject(new SchemaError(this, data,
            `The key ${check} is not allowed here. `))
        }
      }
    }
    return Promise.resolve()
  }

}

export default ObjectSchema
