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

  validate(): Promise<void> {
    return new Promise((resolve, reject) => {
      if (this._optional && this.data === undefined) return resolve()
      // reject if marked as invalid
      if (this._invalid.size && this._invalid.has(this.data)) {
        return reject(this.fail('Element found in blacklist (disallowed item)'))
      }
      // reject if valid is set but not included
      if (this._valid.size && !this._valid.has(this.data)) {
        return reject(this.fail('Element not in whitelist (allowed item)'))
      }
      // ok
      this.result = this.data
      return resolve()
    })
  }

}

export default AnySchema
