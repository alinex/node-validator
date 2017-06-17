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
  _required: bool
  _stripEmpty: bool
  _default: any

  constructor(title?: string, detail?: string) {
    this.title = title || this.constructor.name.replace(/(.)Schema/, '$1')
    this.detail = detail || 'should be defined with:'
    this._rules = new Set()
    // init settings
    this._negate = false
    this._required = false
    this._stripEmpty = false
    // add check rules
    this._rules.add([this._emptyDescriptor, this._emptyValidator])
    this._rules.add([this._optionalDescriptor, this._optionalValidator])
  }

  // setup schema

  get not(): this {
    this._negate = !this._negate
    return this
  }

  get required(): this {
    this._required = !this._negate
    this._negate = false
    return this
  }

  get stripEmpty(): this {
    this._stripEmpty = !this._negate
    this._negate = false
    return this
  }

  default(value?: any): this {
    if (this._negate || value === undefined) delete this._default
    else this._default = value
    this._negate = false
    return this
  }

  // using schema

  get clone(): this {
    if (this._negate) throw new Error('Impossible tu use `not` with clone method')
    return Object.assign((Object.create(this): any), this)
  }

  get description(): string {
    let msg = 'Any data type. '
    this._rules.forEach((rule) => { msg += rule[0].call(this) })
    return msg.trim()
  }

  validate(value: any, source?: string, options?: Object): Promise<any> {
    const data = value instanceof SchemaData ? value : new SchemaData(value, source, options)
    // run rules seriously
    let p = Promise.resolve()
    this._rules.forEach((rule) => { p = p.then(() => rule[1].call(this, data)) })
    return p.then(() => data.value)
    .catch(err => (err ? Promise.reject(err) : data.value))
  }

  _emptyDescriptor() {
    return this._stripEmpty ? 'Empty values are set to `undefined`.\n' : ''
  }

  _emptyValidator(data: SchemaData): Promise<void> {
    if (this._stripEmpty && (
      data.value === '' || data.value === null || (Array.isArray(data.value) && !data.value.length)
      || (Object.keys(data.value).length === 0 && data.value.constructor === Object)
    )) {
      data.value = undefined
    }
    return Promise.resolve()
  }

  _optionalDescriptor() {
    if (this._default) return `It will default to ${util.inspect(this._default)} if not set.\n`
    if (!this._required) return 'It is optional and must not be set.\n'
    return ''
  }

  _optionalValidator(data: SchemaData): Promise<void> {
    if (data.value === undefined && this._default) data.value = this._default
    if (data.value !== undefined) return Promise.resolve()
    if (this._required) {
      return Promise.reject(new SchemaError(this, data,
      'This element is mandatory!'))
    }
    return Promise.reject() // stop processing, optional is ok
  }
}

export default Schema
