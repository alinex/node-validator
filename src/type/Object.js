// @flow
import util from 'util'

import Schema from '../Schema'
import SchemaError from '../SchemaError'
import type SchemaData from '../SchemaData'

class ObjectSchema extends Schema {

  // validation data

  _keys: Map<string, Schema>
  _pattern: Map<RegExp, Schema>

  constructor(title?: string, detail?: string) {
    super(title, detail)
    // init settings
    this._keys = new Map()
    this._pattern = new Map()
    // add check rules
    this._rules.add([this._typeDescriptor, this._typeValidator])
    this._rules.add([this._keysDescriptor, this._keysValidator])
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
        if (!found) sum[key] = data.value[key]
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

}

export default ObjectSchema
