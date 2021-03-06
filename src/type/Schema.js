// @flow
import util from 'util'
import debug from 'debug'

import Data from '../Data'
import ValidationError from '../Error'
import Reference from '../Reference'

class Schema {
  _title: string
  _detail: string
  base: any
  debug: debug

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
    this.debug = debug(`validator:${this.constructor.name.replace(/Schema/, '').toLowerCase()}`)
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
    const base = this.base ? `base=${util.inspect(this.base)} ` : ''
    const padding = ' '.repeat(5)
    const inner = util.inspect(this._setting, newOptions).replace(/\n/g, `\n${padding}`)
    return `${options.stylize(this.constructor.name, 'class')} ${base}${inner} `
  }

  title(title: string): this {
    this._title = title
    return this
  }
  detail(detail: string): this {
    this._detail = detail
    return this
  }
  schema(path: string): Schema {
    let obj = this
    for (const key of path.split(/\//)) {
      if (obj instanceof Schema) obj = obj._setting[key]
      else if (obj instanceof Map) obj = obj.get(key)
      else obj = (obj: Object)[key]
    }
    if (!(obj instanceof Schema)) throw new Error(`No schema element under ${path} found`)
    return obj
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

  _emptyValidator(data: Data): Promise<void> {
    const check = this._check
    try {
      this._checkBoolean('stripEmpty')
    } catch (err) {
      return Promise.reject(new ValidationError(this, data, err.message))
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

  required(flag?: bool | Reference): this {
    const set = this._setting
    if (set.forbidden && !this._isReference('forbidden')) {
      throw new Error('This is already `forbidden` and can´t be also be `required`')
    }
    return this._setFlag('required', flag)
  }
  forbidden(flag?: bool | Reference): this {
    const set = this._setting
    if (set.required && !this._isReference('required')) {
      throw new Error('This is already `required` and can´t be also be `forbidden`')
    }
    return this._setFlag('forbidden', flag)
  }
  default(value?: any): this { return this._setAny('default', value) }

  _optionalDescriptor() {
    const set = this._setting
    let msg = ''
    if (set.default) {
      const value = set.default instanceof Reference
        ? set.default.description : util.inspect(set.default)
      msg += `It will default to ${value} if not set. `
    }
    if (set.required) {
      if (set.required instanceof Reference) {
        msg += `It is required depending on ${set.required.description}. `
      } else msg += 'It is required and has to be set with a value. '
    }
    if (set.forbidden) {
      if (set.forbidden instanceof Reference) {
        msg += `It is forbidden depending on ${set.forbidden.description}. `
      } else msg += 'It is forbidden and could not contain a value. '
    }
    return msg.replace(/ $/, '\n')
  }

  _optionalValidator(data: Data): Promise<void> {
    const check = this._check
    try {
      this._checkBoolean('required')
      this._checkBoolean('forbidden')
    } catch (err) {
      return Promise.reject(new ValidationError(this, data, err.message))
    }
    // use default
    if (data.value === undefined && check.default) data.value = check.default
    // check for required
    if (check.required && data.value === undefined) {
      return Promise.reject(new ValidationError(this, data, 'This element is mandatory!'))
    }
    if (check.forbidden && data.value !== undefined) {
      return Promise.reject(new ValidationError(this, data, 'This element is forbidden!'))
    }
    if (data.value === undefined) return Promise.reject() // stop processing, optional is ok
    return Promise.resolve()
  }

  raw(flag?: bool | Reference): this { return this._setFlag('raw', flag) }

  _rawDescriptor() {
    const set = this._setting
    if (set.raw instanceof Reference) {
      return `The original value is used depending on ${set.raw.description}.\n`
    }
    return set.raw ? 'After validation the original value is used.\n' : ''
  }

  _rawValidator(data: Data): Promise<void> {
    const check = this._check
    try {
      this._checkBoolean('raw')
    } catch (err) {
      return Promise.reject(new ValidationError(this, data, err.message))
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
      msg += `Use as base: ${util.inspect(this.base instanceof Data ? this.base.value : this.base).trim()}. `
    }
    // create message using the different rules
    this._rules.descriptor.forEach((rule) => {
      if (rule) msg += rule.call(this)
    })
    return msg.trim()
  }

  _validate(value: any, source?: string, options?: Object): Promise<any> {
    if (this.debug.enabled) {
      this.debug(util.inspect(value))
      this.debug(`   ${util.inspect(this)}`)
    }
    const data = value instanceof Data ? value : new Data(value, source, options)
    if (this.base) { // use base setting if defined
      data.value = this.base instanceof Data ? this.base.value : this.base
    }
    let p = Promise.resolve()
    // resolve references in value first
    if (data.value instanceof Reference) {
      p = p.then(() => data.value.raw().resolve(data))
        .then((res) => {
          data.value = res
          if (this.debug.enabled) this.debug(`   Use base: ${util.inspect(data)}`)
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
          } else if (Array.isArray(e)) {
            this._check[key][i] = []
            for (const j of e.keys()) {
              const sub = e[j]
              if (sub instanceof Reference) {
                // preserve position to keep order on async results
                this._check[key][i][j] = null
                par.push(sub.resolve(data).then((res) => { this._check[key][i][j] = res }))
              } else this._check[key][i][j] = sub
            }
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
    //    this._rules.validator.forEach((rule) => {
    //      p = p.then(() => {
    //        console.log(rule)
    //        return rule.call(this, data)
    //      })
    //    })
    return p.then(() => {
      if (this.debug.enabled) this.debug(`=> ${util.inspect(data)}`)
      data.done(data.value)
      return data
    })
      .catch((err) => {
        if (this.debug.enabled) {
          if (err) this.debug(`=> ${util.inspect(err)}`)
          else this.debug(`=> ${util.inspect(data)}`)
        }
        return (err ? Promise.reject(err) : data)
      })
  }

  validate(value: any, source?: string, options?: Object): Promise<any> {
    return this._validate(value, source, options)
      .then(data => data.value)
  }
}


export default Schema
