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
      this._optionalDescriptor,
    )
    this._rules.validator.push(
      this._emptyValidator,
      this._optionalValidator,
    )
  }

  // helper methods

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
  _checkBoolean(name: string) {
    let value
    switch (typeof this._check[name]) {
    case 'undefined':
    case 'boolean':
      break
    case 'string':
      value = this._check[name].toLowerCase()
      if (['yes', 1, '1', 'true', 't', '+'].includes(value)) this._check[name] = true
      else if (['no', 0, '0', 'false', 'f', '', '-'].includes(value)) this._check[name] = false
      break
    default:
      throw new Error(`No boolean value for \`${name}\` setting given in \
${(this._setting[name] && this._setting[name].description) || this._setting[name]}`)
    }
  }
  _checkArray(name: string) {
    const check = this._check
    if (!check[name]) check[name] = []
    else if (check[name] instanceof Set) check[name] = Array.from(check[name])
    else if (!Array.isArray(check[name])) check[name] = [check[name]]
  }
  _checkObject(name: string) {
    const check = this._check
    if (typeof check[name] !== 'object') {
      throw new Error(`No boolean value for \`${name}\` setting given in \
${(this._setting[name] && this._setting[name].description) || this._setting[name]}`)
    }
  }

  // strip empty values

  stripEmpty(flag?: bool | Reference): this { return this._setFlag('stripEmpty', flag) }

  _emptyDescriptor() {
    const set = this._setting
    if (set.stripEmpty instanceof Reference) {
      return `Empty values are set to \`undefined\` depending on ${set.stripEmpty.description}.\n`
    }
    return set.stripEmpty ? 'Empty values are set to `undefined`.\n' : ''
  }

  _emptyValidator(data: SchemaData): Promise<void> {
    const check = this._check
    try {
      this._checkBoolean('stripEmpty')
    } catch (err) {
      return Promise.reject(new SchemaError(this, data, err.message))
    }
    if (check.stripEmpty && (
      data.value === '' || data.value === null || (Array.isArray(data.value) && !data.value.length)
      || (Object.keys(data.value).length === 0 && data.value.constructor === Object)
    )) {
      data.value = undefined
    }
    return Promise.resolve()
  }

  // optional

  required(flag?: bool | Reference): this { return this._setFlag('required', flag) }
  default(value?: any): this { return this._setAny('default', value) }

  _optionalDescriptor() {
    const set = this._setting
    if (set.default) {
      const value = set.default instanceof Reference
      ? set.default.description : util.inspect(set.default)
      return `It will default to ${value} if not set.\n`
    }
    if (set.required instanceof Reference) {
      return `It is optional depending on ${set.required.description}.\n`
    }
    if (!set.required) return 'It is optional and must not be set.\n'
    return ''
  }

  _optionalValidator(data: SchemaData): Promise<void> {
    const check = this._check
    try {
      this._checkBoolean('required')
    } catch (err) {
      return Promise.reject(new SchemaError(this, data, err.message))
    }
    if (data.value === undefined && check.default) data.value = check.default
    if (data.value !== undefined) return Promise.resolve()
    if (check.required) {
      return Promise.reject(new SchemaError(this, data,
      'This element is mandatory!'))
    }
    return Promise.reject() // stop processing, optional is ok
  }

  // using schema

  get clone(): this {
    if (this._negate) throw new Error('Impossible tu use `not` with clone method')
    return Object.assign((Object.create(this): any), this)
  }

  get description(): string {
    let msg = ''
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
      } else if (set[key] instanceof Set) {
        this._check[key] = []
        const raw = Array.from(set[key])
        for (const i of raw.keys()) {
          const e = raw[i]
          if (e instanceof Reference) {
            // preserve position to keep order on async results
            this._check[key][i] = null
            par.push(e.data.then((res) => { this._check[key][i] = res }))
          } else this._check[key].push(e)
        }
      } else if (set[key] instanceof Map) {
        this._check[key] = {}
        for (const k of set[key].keys()) {
          const e = set[key].get(k)
          if (e instanceof Reference) {
            // preserve position to keep order on async results
            this._check[key][k] = null
            par.push(e.data.then((res) => { this._check[key][k] = res }))
          } else this._check[key][k] = e
        }
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
}


export default Schema
