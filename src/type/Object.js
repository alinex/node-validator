// @flow
import Schema from '../Schema'

class ObjectSchema extends Schema {

  // validation data

  _keys: Map<string, Schema>
  _pattern: Map<RegExp, Schema>

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

  validate(data: Object): Promise<any> {
    return new Promise((resolve, reject) => {
      // optional and default
      const value = this._validateOptional(data)
      if (this._optional && value === undefined) return resolve(value)
      // check all keys
      const checks = []
      this._keys.forEach((e: Schema, k: string) => {
        // load data
        // validate
//        checks.push(e.validate(value[k]))
      })
      Promise.all(checks)
      // with their checks

      // ok
      return resolve(value)
    })
  }

}

export default ObjectSchema
