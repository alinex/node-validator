// @flow
import util from 'util'

import SchemaData from './SchemaData'
import SchemaError from './SchemaError'
import Reference from './Reference'

class Schema {

  title: string
  detail: string

  // rules
  _rules: {
    descriptor: Array<Function>,
    check: Array<Function>,
    validator: Array<Function>,
  }
  _setting: { [string]: any } // definition of object
  _check: { [string]: any } // resolved data

  constructor(title?: string, detail?: string) {
    this.title = title || this.constructor.name.replace(/(.)Schema/, '$1')
    this.detail = detail || 'should be defined with:'
    this._rules = {
      descriptor: [],
      check: [],
      validator: [],
    }
    this._setting = {}
    // add check rules
    this._rules.descriptor.push(
      this._emptyDescriptor,
      this._optionalDescriptor)
    this._rules.validator.push(
      this._emptyValidator,
      this._optionalValidator)
  }

  // setup schema

  _setFlag(name: string, flag: bool | Reference = true): this {
    if (flag) this._setting[name] = flag
    else delete this._setting[name]
    return this
  }
  _setAny(name: string, value: any): this {
    if (value) this._setting[name] = value
    else delete this._setting[name]
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
    // copy settings to check
    const set = this._setting
    for (const key of Object.keys(set)) {
      this._check[key] = set[key]
    }
    // create message using the different rules
    this._rules.descriptor.forEach((rule) => {
      if (rule) msg += rule.call(this)
    })
    return msg.trim()
  }

  validate(value: any, source?: string, options?: Object): Promise<any> {
    const data = value instanceof SchemaData ? value : new SchemaData(value, source, options)
    // parallel resolving
    const par = []
    // resolve references in value first
    if (data.value instanceof Reference) {
      par.push(data.value.raw().data
      .then((res) => { data.value = res }))
    }
    // resolve check settings
    this._check = {}
    const set = this._setting
    for (const key of Object.keys(set)) {
      if (set[key] instanceof Reference) {
        par.push(set[key].data
        .then((res) => { this._check[key] = res }))
//      } else if (set[key] instanceof Set) {
//        this._check[key] = new Set()
//        for (const e of set[key]) {
//          if (set[key][e] instanceof Reference) {
//            par.push(set[key][e].data
//            .then((res) => { this._check[key].add(res) }))
//          } else this._check[key].add(set[key][e])
//        }
      } else this._check[key] = set[key]
    }
    let p = Promise.all(par)
    // optimize check values
    this._rules.check.forEach((rule) => { p = p.then(() => rule.call(this, data)) })
    // run the rules seriously
    this._rules.validator.forEach((rule) => { p = p.then(() => rule.call(this, data)) })
    return p.then(() => {
      data.done(data.value)
      return data.value
    })
    .catch(err => (err ? Promise.reject(err) : data.value))
  }

  _emptyDescriptor() {
    const check = this._check
    if (check.stripEmpty instanceof Reference) {
      return `Empty values are set to \`undefined\` depending on ${check.default.description}.\n`
    }
    return check.stripEmpty ? 'Empty values are set to `undefined`.\n' : ''
  }

  _emptyValidator(data: SchemaData): Promise<void> {
    const check = this._check
    if (check.stripEmpty && (
      data.value === '' || data.value === null || (Array.isArray(data.value) && !data.value.length)
      || (Object.keys(data.value).length === 0 && data.value.constructor === Object)
    )) {
      data.value = undefined
    }
    return Promise.resolve()
  }

  _optionalDescriptor() {
    const check = this._check
    if (check.default) {
      const value = check.default instanceof Reference
      ? check.default.description : util.inspect(check.default)
      return `It will default to ${value} if not set.\n`
    }
    if (check.required instanceof Reference) {
      return `It is optional depending on ${check.default.description}.\n`
    }
    if (!check.required) return 'It is optional and must not be set.\n'
    return ''
  }

  _optionalValidator(data: SchemaData): Promise<void> {
    const check = this._check
    if (data.value === undefined && check.default) data.value = check.default
    if (data.value !== undefined) return Promise.resolve()
    if (check.required) {
      return Promise.reject(new SchemaError(this, data,
      'This element is mandatory!'))
    }
    return Promise.reject() // stop processing, optional is ok
  }
}

export default Schema
