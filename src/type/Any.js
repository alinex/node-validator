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
    // reject if marked as invalid
    if (this._invalid.size && this._invalid.has(this.data)) return Promise.reject()
    // reject if valid is set but not included
    if (this._valid.size && !this._valid.has(this.data)) return Promise.reject()
    // ok
    this.result = this.data
    return Promise.resolve()
  }

}

export default AnySchema
