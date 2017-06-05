// @flow
import Schema from '../Schema'

class ObjectSchema extends Schema {

  // validation data

  _keys: Map<string, Schema>

  // setup validation

  keys(name: string, check?: Schema): ObjectSchema {
    if (this._negate) {
      // remove
      this._keys.delete(name)
    } else if (check) {
      this._keys.set(name, check)
    } else {
      throw new Error('Key without value can´t be defined.')
    }
    this._negate = false
    return this
  }

  // using schema

  validate(): Promise<any> {
    return new Promise((resolve, reject) => {
      // optional and default
      const value = this._validateOptional(this.data)
      // check all keys

      // ok
      this.result = value
      return resolve()
    })
  }

}

export default ObjectSchema
