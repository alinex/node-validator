// @flow
import Schema from '../Schema'
import SchemaError from '../SchemaError'

class ObjectSchema extends Schema {

  // validation data

  _keys: Map<string, Schema>
  _pattern: Map<RegExp, Schema>

  constructor() {
    super()
    this._keys = new Map()
    this._pattern = new Map()
  }

  // setup validation

  keys(name: string, check?: Schema): ObjectSchema {
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

  pattern(regexp: RegExp, check?: Schema): ObjectSchema {
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

  validate(data: any): Promise<any> {
    return this._optionalValidator(data)
    .then(value => this._validateKeys(value))
    .catch((err) => { // check for early returned value through reject
      if (err instanceof SchemaError) return Promise.reject(err)
      return Promise.resolve(err)
    })
  }

  _validateKeys(data: any): Promise<any> {
    return Promise.resolve(this)
  }

//  validate2(data: Object): Promise<any> {
//    return new Promise((resolve, reject) => {
//      // optional and default
//      let value = this._validateOptional(data)
//      if (this._optional && value === undefined) return resolve(value)
//      // check for object
//      if (typeof data !== 'object') {
//        return reject(new SchemaError(this, 'An object is needed.', data))
//      }
//      // check keys
//      const checks = []
//      const keys = []
//      const sum = {}
////      for (let key in value) {
//      Object.keys(value).forEach((key) => {
//        const schema = this._keys.get(key)
//        if (schema) {
//          // against defined keys
//          checks.push(schema.validate(data[key]))
//          keys.push(key)
//        } else {
//          let found = false
//          for (const p of this._pattern.entries()) {
//            if (key.match(p[0])) {
//              checks.push(p[1].validate(data[key]))
//              keys.push(key)
//              found = true
//              break
//            }
//          }
//          // not specified
//          if (!found) sum[key] = data[key]
//        }
//      })
//      Promise.all(checks)
//      .catch(err => reject(err))
//      .then((result) => {
//        if (result) {
//          result.forEach((e: any, i: number) => { sum[keys[i]] = e })
//        }
//        value = sum
//        return resolve(value)
//      })
//      return undefined
//    })
//  }

}

export default ObjectSchema
