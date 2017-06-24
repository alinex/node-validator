// @flow
import util from 'util'

import SchemaData from './SchemaData'
import SchemaError from './SchemaError'
import Reference from './Reference'

class Schema {

  title: string
  detail: string
  _rules: Set<Array<Function>>

  // validation data
  _setting: { [string]: any } // definition of object
  _check: { [string]: any } // resolved data

  constructor(title?: string, detail?: string) {
    this.title = title || this.constructor.name.replace(/(.)Schema/, '$1')
    this.detail = detail || 'should be defined with:'
    this._rules = new Set()
    this._setting = {}
    // add check rules
    this._rules.add([this._emptyDescriptor, this._emptyValidator])
    this._rules.add([this._optionalDescriptor, this._optionalValidator])
  }

  // setup schema

  _setFlag(name: string, flag: bool | Reference = true): this {
    if (flag) this._setting[name] = flag
    else delete this._setting[name]
    return this
  }
  _setAny(name: string, value: any): this {
    if (value) this._setting.default = value
    else delete this._setting.default
    return this
  }

  required(flag?: bool | Reference): this { return this._setFlag('required', flag) }
  stripEmpty(flag?: bool | Reference): this { return this._setFlag('stripEmpty', flag) }
  default(value?: any): this { return this._setAny('default', value) }

  // using schema

  get clone(): this {
    if (this._negate) throw new Error('Impossible tu use `not` with clone method')
    return Object.assign((Object.create(this): any), this)
  }

  get description(): string {
    let msg = ''
    this._check = {}
    const set = this._setting
    for (const key of Object.keys(set)) {
      this._check[key] = set[key]
    }
    this._rules.forEach((rule) => { msg += rule[0].call(this) })
    return msg.trim()
  }

  validate(value: any, source?: string, options?: Object): Promise<any> {
    const data = value instanceof SchemaData ? value : new SchemaData(value, source, options)
    // run rules seriously
    let p = Promise.resolve()
    // resolve references in value first
    if (data.value instanceof Reference) {
      p = p.then(() => data.value.raw().data)
      .then((res) => { data.value = res })
    }
    // resolve check settings
    this._check = {}
    const set = this._setting
    for (const key of Object.keys(set)) {
      if (set[key] instanceof Reference) {
        p = p.then(() => set[key].data)
        .then((res) => { this._check[key] = res })
      } else this._check[key] = set[key]
    }
    // run the rules
    this._rules.forEach((rule) => { p = p.then(() => rule[1].call(this, data)) })
    return p.then(() => {
      data.done(data.value)
      return data.value
    })
    .catch(err => (err ? Promise.reject(err) : data.value))
  }

  _emptyDescriptor() {
    return this._check.stripEmpty ? 'Empty values are set to `undefined`.\n' : ''
  }

  _emptyValidator(data: SchemaData): Promise<void> {
    if (this._check.stripEmpty && (
      data.value === '' || data.value === null || (Array.isArray(data.value) && !data.value.length)
      || (Object.keys(data.value).length === 0 && data.value.constructor === Object)
    )) {
      data.value = undefined
    }
    return Promise.resolve()
  }

  _optionalDescriptor() {
    if (this._check.default) {
      return `It will default to ${util.inspect(this._check.default)} if not set.\n`
    }
    if (!this._check.required) return 'It is optional and must not be set.\n'
    return ''
  }

  _optionalValidator(data: SchemaData): Promise<void> {
    const check = this._check
    if (data.value === undefined && check.default) data.value = check.default
    if (data.value !== undefined) return Promise.resolve()
    if (this._check.required) {
      return Promise.reject(new SchemaError(this, data,
      'This element is mandatory!'))
    }
    return Promise.reject() // stop processing, optional is ok
  }
}

export default Schema
