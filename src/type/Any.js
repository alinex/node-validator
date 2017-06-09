// @flow
import Schema from '../Schema'
import SchemaError from '../SchemaError'
import SchemaData from '../SchemaData'

class AnySchema extends Schema {

  // validation data

  _valid: Set<any>
  _invalid: Set<any>

  constructor() {
    super()
    this._valid = new Set()
    this._invalid = new Set()
  }

  // setup validation

  allow(value: any): AnySchema {
    if (value === undefined) {
      this._optional = !this._negate // true for allow fals for not allow
    } else if (Array.isArray(value)) {
      value.forEach((v) => {
        if (v === undefined) {
          this._optional = !this._negate
        } else if (this._negate) {
          // disallow
          this._invalid.add(v)
          this._valid.delete(v)
        } else {
          // allow
          this._valid.add(v)
          this._invalid.delete(v)
        }
      })
    } else if (this._negate) {
      // disallow
      this._invalid.add(value)
      this._valid.delete(value)
    } else {
      // allow
      this._valid.add(value)
      this._invalid.delete(value)
    }
    this._negate = false
    return this
  }

  // using schema

  validate(value: any, source?: string): Promise<any> {
    const data = value instanceof SchemaData ? value : new SchemaData(value, source)
    return this._optionalValidator(data)
    .then(() => this._validateAllow(data))
    .then(() => data.value)
    .catch(err => (err ? Promise.reject(err) : data.value))
  }

  _validateAllow(value: any): Promise<any> {
    // reject if marked as invalid
    if (this._invalid.size && this._invalid.has(value)) {
      return Promise.reject(new SchemaError(this, value,
        'Element found in blacklist (disallowed item)'))
    }
    // reject if valid is set but not included
    if (this._valid.size && !this._valid.has(value)) {
      return Promise.reject(new SchemaError(this, value,
        'Element not in whitelist (allowed item)'))
    }
    // ok
    return Promise.resolve(value)
  }
}

export default AnySchema
