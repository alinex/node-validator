// @flow
import Schema from '../Schema'

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
      this._optional = true
    } else if (Array.isArray(value)) {
      value.forEach((v) => {
        if (v === undefined) {
          this._optional = true
        } else {
          this._valid.add(v)
          this._invalid.delete(v)
        }
      })
    } else {
      this._valid.add(value)
      this._invalid.delete(value)
    }
    return this
  }

  disallow(value: any): AnySchema {
    if (value === undefined) {
      this._optional = false
    } else if (Array.isArray(value)) {
      value.forEach((v) => {
        if (v === undefined) {
          this._optional = true
        } else {
          this._invalid.add(v)
          this._valid.delete(v)
        }
      })
    } else {
      this._invalid.add(value)
      this._valid.delete(value)
    }
    return this
  }

  // using schema

  validate(): Promise<any> {
    return new Promise((resolve, reject) => {
      // optional and default
      const value = this.validateOptional(this.data)
      // reject if marked as invalid
      if (this._invalid.size && this._invalid.has(value)) {
        return reject(this.fail('Element found in blacklist (disallowed item)'))
      }
      // reject if valid is set but not included
      if (this._valid.size && !this._valid.has(value)) {
        return reject(this.fail('Element not in whitelist (allowed item)'))
      }
      // ok
      this.result = value
      return resolve()
    })
  }

}

export default AnySchema
