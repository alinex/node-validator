// @flow
import util from 'util'

import SchemaData from './SchemaData'
import SchemaError from './SchemaError'

class Schema {

  title: string
  detail: string
  _rules: Set<Array<Function>>

  // validation data

  _negate: bool
  _optional: bool
  _default: any

  constructor(title?: string, detail?: string) {
    this.title = title || this.constructor.name.replace(/(.)Schema/, '$1')
    this.detail = detail || 'should be defined with:'
    this._rules = new Set()
    // init settings
    this._negate = false
    this._optional = true
    // check optional
    this._rules.add([this._optionalDescriptor, this._optionalValidator])
  }

  get not(): Schema {
    this._negate = !this._negate
    return this
  }

  get optional(): Schema {
    this._optional = !this._negate
    this._negate = false
    return this
  }

  default(value: any): Schema {
    this._default = value
    return this
  }

  // using schema

  get description(): string {
    let msg = 'Any data type. '
    this._rules.forEach((rule) => { msg += rule[0]() })
    return msg.trim()
  }

  validate(value: any, source?: string): Promise<any> {
    const data = value instanceof SchemaData ? value : new SchemaData(value, source)
    // run rules seriously
    let p = Promise.resolve()
    this._rules.forEach((rule) => { p = p.then(() => rule[1](data)) })
    // p = p.then(() => this._optionalValidator(data))
    return p.then(() => data.value)
    .catch(err => (err ? Promise.reject(err) : data.value))
  }

  _optionalDescriptor() {
    if (this._default) return `It will default to ${util.inspect(this._default)} if not set. `
    if (this._optional) return 'It is optional and must not be set. '
    return ''
  }

  _optionalValidator(data: SchemaData): Promise<void> {
    if (data.value === undefined && this._default) data.value = this._default
    if (data.value !== undefined) return Promise.resolve()
    if (this._optional) return Promise.reject() // stop processing
    return Promise.reject(new SchemaError(this, data,
      'This element is mandatory!'))
  }

}

export default Schema
