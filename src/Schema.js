// @flow
import util from 'util'

import SchemaData from './SchemaData'
import SchemaError from './SchemaError'
import Reference from './Reference'

class Schema {
  _title: string
  _detail: string
  base: any

  // rules
  _rules: {
    descriptor: Array<Function>,
    check: Array<Function>,
    validator: Array<Function>,
  }
  _setting: { [string]: any } // definition of object
  _check: { [string]: any } // resolved data

  constructor(base?: any) {
    if (base) this.base = base
    this._title = this.constructor.name.replace(/(.)Schema/, '$1')
    this._detail = 'should be defined with'
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
      this._rawDescriptor,
    )
    this._rules.validator.push(
      this._emptyValidator,
      this._optionalValidator,
      this._rawValidator,
    )
  }

  inspect(depth: number, options: Object): string {
    const newOptions = Object.assign({}, options, {
      depth: options.depth === null ? null : options.depth - 1,
    })
    const base = this.base ? `base=${util.inspect(this.base)}` : ''
    const padding = ' '.repeat(5)
    const inner = util.inspect(this._setting, newOptions).replace(/\n/g, `\n${padding}`)
    return `${options.stylize(this.constructor.name, 'class')} ${base} ${inner} `
  }

  title(title: string): this {
    this._title = title
    return this
  }
  detail(detail: string): this {
    this._detail = detail
    return this
  }

  // helper methods

  _setError(name: string, msg?: string): this {
    throw (new Error(msg || `In ${this.constructor.name} you are not allowed to set
      ${name} manually`))
  }
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
  _isReference(name: string) {
    return this._setting[name] instanceof Reference
  }
  _checkBoolean(name: string) {
    let value
    switch (typeof this._check[name]) {
    case 'undefined':
    case 'boolean':
      break
    case 'string':
      value = this._check[name].toLowerCase()
      if (value === undefined) this._check[name] = false
      else if (Array.isArray(value)) this._check[name] = value.length > 0
      else if (typeof value === 'object') this._check[name] = Object.keys(value).length > 0
      else if (['yes', 1, '1', 'true', 't', '+'].includes(value)) this._check[name] = true
      else if (['no', 0, '0', 'false', 'f', '', '-'].includes(value)) this._check[name] = false
      break
    default:
      throw new Error(`No boolean value for \`${name}\` setting given in \
${(this._setting[name] && this._setting[name].description) || this._setting[name]}`)
    }
  }
  _checkString(name: string) {
    const check = this._check
    if (check[name] && typeof check[name] !== 'string') {
      throw new Error(`No string value for \`${name}\` setting given in \
${(this._setting[name] && this._setting[name].description) || this._setting[name]}`)
    }
  }
  _checkArrayString(name: string) {
    this._checkArray(name)
    const check = this._check
    if (check[name]) {
      check[name].forEach((e) => {
        if (typeof e !== 'string') {
          throw new Error(`No string value for \`${name}\` setting given in \
    ${(this._setting[name] && this._setting[name].description) || this._setting[name]}`)
        }
      })
    }
  }
  _checkNumber(name: string) {
    const check = this._check
    if (check[name] && typeof check[name] !== 'number') {
      throw new Error(`No numerical value for \`${name}\` setting given in \
${(this._setting[name] && this._setting[name].description) || this._setting[name]}`)
    }
  }
  _checkArray(name: string) {
    const check = this._check
    if (check[name]) {
      if (check[name] instanceof Set) check[name] = Array.from(check[name])
      else if (!Array.isArray(check[name])) {
        if (typeof check[name] === 'object') check[name] = Object.keys(check[name])
        else check[name] = [check[name]]
      }
    }
  }
  _checkObject(name: string) {
    const check = this._check
    if (!check[name]) check[name] = {}
    else if (typeof check[name] !== 'object') {
      throw new Error(`No object for \`${name}\` setting given in \
${(this._setting[name] && this._setting[name].description) || this._setting[name]}`)
    }
  }
  _checkMatch(name: string) {
    const check = this._check
    if (check[name] === undefined) return
    if (check[name] instanceof RegExp) return
    const e = check[name].toString()
    if (e.match(/^\/([^\\/]|\\.)+\/[gi]*$/)) {
      const parts : Array<string> = e.match(/([^\\/]|\\.)+/g)
      if (parts.length < 1 || parts.length > 2) {
        throw new Error(`Could not convert ${util.inspect(check[name])} to regular expression`)
      }
      check[name] = new RegExp(parts[0], (parts[1]: any))
    }
    check[name] = check[name].toString()
  }
  _checkArrayMatch(name: string) {
    this._checkArray(name)
    const check = this._check
    if (check[name] === undefined) return
    check[name] = check[name].map((e) => {
      if (e instanceof RegExp) return e
      const el = e.toString()
      if (el.match(/^\/([^\\/]|\\.)+\/[gi]*$/)) {
        const parts : Array<string> = el.match(/([^\\/]|\\.)+/g)
        if (parts.length < 1 || parts.length > 2) {
          throw new Error(`Could not convert ${util.inspect(e)} to regular expression`)
        }
        return new RegExp(parts[0], (parts[1]: any))
      }
      return el
    })
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

  raw(flag?: bool | Reference): this { return this._setFlag('raw', flag) }

  _rawDescriptor() {
    const set = this._setting
    if (set.raw instanceof Reference) {
      return `The original value is used depending on ${set.raw.description}.\n`
    }
    return set.raw ? 'After validation the original value is used.\n' : ''
  }

  _rawValidator(data: SchemaData): Promise<void> {
    const check = this._check
    try {
      this._checkBoolean('raw')
    } catch (err) {
      return Promise.reject(new SchemaError(this, data, err.message))
    }
    if (check.raw) data.value = data.orig
    return Promise.resolve()
  }

  // using schema

  get clone(): this {
    return Object.assign((Object.create(this): any), this)
  }

  get description(): string {
    let msg = ''
    // support base setting
    if (this.base) {
      msg += `Use ${this.base instanceof SchemaData ? this.base.value : this.base} as base for this check. `
    }
    // create message using the different rules
    this._rules.descriptor.forEach((rule) => {
      if (rule) msg += rule.call(this)
    })
    return msg.trim()
  }

  _validate(value: any, source?: string, options?: Object): Promise<any> {
    const data = value instanceof SchemaData ? value : new SchemaData(value, source, options)
    if (this.base) { // use base setting if defined
      data.value = this.base instanceof SchemaData ? this.base.value : this.base
    }
    let p = Promise.resolve()
    // resolve references in value first
    if (data.value instanceof Reference) {
      p = p.then(() => data.value.raw().resolve(data))
        .then((res) => {
          data.value = res
        })
    }
    // resolve check settings
    const par = []
    this._check = {}
    const set = this._setting
    for (const key of Object.keys(set)) {
      let raw = set[key]
      if (raw instanceof Set) raw = Array.from(raw)
      if (raw instanceof Reference) {
        par.push(raw.resolve(data)
          .then((res) => { this._check[key] = res }))
      } else if (Array.isArray(raw)) {
        this._check[key] = []
        for (const i of raw.keys()) {
          const e = raw[i]
          if (e instanceof Reference) {
            // preserve position to keep order on async results
            this._check[key][i] = null
            par.push(e.resolve(data).then((res) => { this._check[key][i] = res }))
          } else this._check[key].push(e)
        }
      } else if (raw instanceof Map) {
        this._check[key] = {}
        for (const k of raw.keys()) {
          const e = raw.get(k)
          if (e instanceof Reference) {
            // preserve position to keep order on async results
            this._check[key][k] = null
            par.push(e.resolve(data).then((res) => { this._check[key][k] = res }))
          } else this._check[key][k] = e
        }
      } else this._check[key] = raw
    }
    // optimize check values
    p = p.then(() => Promise.all(par))
    // run the rules seriously
    this._rules.validator.forEach((rule) => { p = p.then(() => rule.call(this, data)) })
    return p.then(() => {
      data.done(data.value)
      return data
    })
      .catch(err => (err ? Promise.reject(err) : data))
  }

  validate(value: any, source?: string, options?: Object): Promise<any> {
    return this._validate(value, source, options)
      .then(data => data.value)
  }
}


export default Schema
