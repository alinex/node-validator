// @flow
import Schema from '../Schema'
import SchemaError from '../SchemaError'
import type SchemaData from '../SchemaData'

class AnySchema extends Schema {

  // validation data

  _valid: Set<any>
  _invalid: Set<any>

  constructor(title?: string, detail?: string) {
    super(title, detail)
    // init settings
    this._valid = new Set()
    this._invalid = new Set()
    // add check rules
    this._rules.add([this._allowDescriptor, this._allowValidator])
  }

  // setup schema

  allow(value: any): this {
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

  _allowDescriptor() {
    if (this._invalid.size) {
      return `The keys ${Array.from(this._invalid).join(', ')} are not allowed. `
    }
    if (this._valid.size) {
      return `Only the keys ${Array.from(this._valid).join(', ')} are allowed. `
    }
    return ''
  }

  _allowValidator(data: SchemaData): Promise<void> {
    // reject if marked as invalid
    if (this._invalid.size && this._invalid.has(data.value)) {
      return Promise.reject(new SchemaError(this, data,
        'Element found in blacklist (disallowed item).'))
    }
    // reject if valid is set but not included
    if (this._valid.size && !this._valid.has(data.value)) {
      return Promise.reject(new SchemaError(this, data,
        'Element not in whitelist (allowed item).'))
    }
    // ok
    return Promise.resolve()
  }
}

export default AnySchema
