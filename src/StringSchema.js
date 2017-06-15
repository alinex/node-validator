// @flow
import util from 'util'

import AnySchema from './AnySchema'
import SchemaError from './SchemaError'
import type SchemaData from './SchemaData'

let striptags // load on demand

type PadType = 'left' | 'right' | 'both'
class Pad {

  char: string
  type: PadType

  constructor(type: PadType = 'right', char: string = ' ') {
    this.type = type
    this.char = char
  }
}

class Replace {

  match: RegExp
  replace: string
  name: string

  constructor(match: RegExp, replace: string, name?: string) {
    this.match = match
    this.replace = replace
    if (name) this.name = name
  }
}

class StringSchema extends AnySchema {

  // validation data

  _makeString: bool
  _trim: bool
  _replace: Array<Replace>
  _uppercase: 'all' | 'first'
  _lowercase: 'all' | 'first'
  _alphanum: bool
  _hex: bool
  _controls: bool
  _noHTML: bool
  _stripDisallowed: bool
  _min: number
  _max: number
  _truncate: bool
  _pad: Pad


  constructor(title?: string, detail?: string) {
    super(title, detail)
    // init settings
    this._makeString = false
    this._truncate = false
    this._trim = false
    this._replace = []
    // add check rules
    this._rules.add([this._makeStringDescriptor, this._makeStringValidator])
    this._rules.add([this._replaceDescriptor, this._replaceValidator])
    this._rules.add([this._caseDescriptor, this._caseValidator])
    this._rules.add([this._checkDescriptor, this._checkValidator])
    this._rules.add([this._lengthDescriptor, this._lengthValidator])
  }

  // setup schema

  get makeString(): this {
    this._makeString = !this._negate
    this._negate = false
    return this
  }

  get trim(): this {
    this._trim = !this._negate
    this._negate = false
    return this
  }

  replace(match?: RegExp|string, replace: string = '', name?: string): this {
    if (typeof match === 'string') name = match
    if (this._negate) {
      if (name) {
        const len = this._replace.length
        this._replace = this._replace.filter(e => e.name !== name)
        if (len === this._replace.length) {
          throw new Error(`No replacer with the name \`${name}\` is defined`)
        }
      } else this._replace = []
      this._negate = false
    } else if (match && typeof match !== 'string') {
      this._replace.push(new Replace(match, replace, name))
    } else throw new Error('Needs a RegExp as first argument to define `replace()`.')
    return this
  }

  uppercase(what: 'all' | 'first' = 'all') {
    if (this._negate) {
      delete this._uppercase
      this._negate = false
    } else if (this._lowercase === what) delete this._lowercase
    else this._uppercase = what
    return this
  }

  lowercase(what: 'all' | 'first' = 'all') {
    if (this._negate) {
      delete this._lowercase
      this._negate = false
    } else if (this._uppercase === what) delete this._uppercase
    else this._lowercase = what
    return this
  }

  get alphanum(): this {
    if (!this._negate && this._hex) throw new Error('The value already has to be hexadecimal.')
    this._alphanum = !this._negate
    this._negate = false
    return this
  }

  get hex(): this {
    if (!this._negate) this._alphanum = false
    this._hex = !this._negate
    this._negate = false
    return this
  }

  get controls(): this {
    this._controls = !this._negate
    this._negate = false
    return this
  }

  get noHTML(): this {
    this._noHTML = !this._negate
    this._negate = false
    return this
  }

  get stripDisallowed(): this {
    this._stripDisallowed = !this._negate
    this._negate = false
    return this
  }

  min(limit?: number): this {
    if (this._negate || limit === undefined) delete this._min
    else {
      const int = parseInt(limit, 10)
      if (int < 0) throw new Error('Length for min() has to be positive')
      if (this._max && int > this._max) {
        throw new Error('Length for min() should be equal or below max')
      }
      this._min = int
    }
    return this
  }

  max(limit?: number): this {
    if (this._negate || limit === undefined) delete this._max
    else {
      const int = parseInt(limit, 10)
      if (int < 0) throw new Error('Length for max() has to be positive')
      if (this._min && int < this._min) {
        throw new Error('Length for max() should be equal or above min')
      }
      this._max = int
    }
    return this
  }

  length(limit?: number): this {
    if (this._negate || limit === undefined) {
      delete this._min
      delete this._max
    } else {
      const int = parseInt(limit, 10)
      if (int < 0) throw new Error('Length has to be positive')
      this._min = int
      this._max = int
    }
    return this
  }

  get truncate(): this {
    this._truncate = !this._negate
    this._negate = false
    return this
  }

  pad(side: PadType = 'right', char: string = ' '): this {
    if (this._negate) {
      delete this._pad
      this._negate = false
    } else {
      this._pad = new Pad(side, char)
    }
    return this
  }

  // using schema

  _makeStringDescriptor() {
    return this._makeString ?
    'Other objects will be transformed to Strings as possible.\n' : ''
  }

  _makeStringValidator(data: SchemaData): Promise<void> {
    if (this._makeString && typeof data.value !== 'string') data.value = data.value.toString()
    if (typeof data.value !== 'string') {
      return Promise.reject(new SchemaError(this, data, 'A `string` value is needed here.'))
    }
    return Promise.resolve()
  }

  _replaceDescriptor() {
    let msg = ''
    if (this._trim) msg += 'Whitespace characters at the begin and end of the string are removed. '
    if (this._replace.length) {
      const list = this._replace
      .map(e => `- \`${util.inspect(e.match)}\` => \`${e.replace}\`${e.name ? ` (${e.name})` : ''}`)
      .join('\n')
      msg += `The following replacements will be done:\n${list}\n`
    }
    return msg.length ? `${msg.replace(/ $/, '')}\n` : msg
  }

  _replaceValidator(data: SchemaData): Promise<void> {
    if (this._trim) data.value = data.value.trim()
    if (this._replace.length) {
      this._replace.forEach(e => (data.value = data.value.replace(e.match, e.replace)))
    }
    return Promise.resolve()
  }

  _caseDescriptor() {
    let msg = ''
    if (this._lowercase === 'all') msg += 'Convert the whole text to lowercase. '
    else if (this._uppercase === 'all') msg += 'Convert the whole text to uppercase. '
    if (this._lowercase === 'first') msg += 'Convert only the first letter to lowercase. '
    else if (this._uppercase === 'first') msg += 'Convert only the first letter to uppercase. '
    return msg.length ? `${msg.replace(/ $/, '')}\n` : msg
  }

  _caseValidator(data: SchemaData): Promise<void> {
    if (this._lowercase === 'all') data.value = data.value.toLowerCase()
    else if (this._uppercase === 'all') data.value = data.value.toUpperCase()
    if (this._lowercase === 'first') {
      data.value = `${data.value.substr(0, 1).toLowerCase()}${data.value.substr(1)}`
    } else if (this._uppercase === 'first') {
      data.value = `${data.value.substr(0, 1).toUpperCase()}${data.value.substr(1)}`
    }
    return Promise.resolve()
  }

  _checkDescriptor() {
//    _stripDisallowed: bool
    let msg = ''
    if (this._alphanum) msg += 'Only alpha numerical characters are allowed. '
    if (this._hex) msg += 'Only hexa decimal characters are allowed. '
    if (this._controls) msg += 'Control characters are also allowed. '
    if (this._noHTML) msg += 'No HTML tags allowed. '
    if (this._stripDisallowed) msg += 'All not allowed characters will be removed. '
    return msg.length ? `${msg.replace(/ $/, '')}\n` : msg
  }

  _checkValidator(data: SchemaData): Promise<void> {
    if (this._stripDisallowed) {
      if (this._alphanum) data.value = data.value.replace(/\W/g, '')
      if (this._hex) data.value = data.value.replace(/[^a-fA-F0-9]/g, '')
      if (!this._controls) data.value = data.value.replace(/[^\x20-\x7E]/g, '')
      if (this._noHTML) {
        if (!striptags) striptags = require('striptags') // eslint-disable-line global-require
        data.value = striptags(data.value)
      }
    } else {
      if (this._alphanum && data.value.match(/\W/)) {
        return Promise.reject(new SchemaError(this, data,
        'Only alpha numerical characters (a-z, A-Z, 0-9 and _) are allowed.'))
      }
      if (this._hex && data.value.match(/[^a-fA-F0-9]/)) {
        return Promise.reject(new SchemaError(this, data,
        'Only hexa decimal characters (a-f, A-F and 0-9) are allowed.'))
      }
      if (!this._controls && data.value.match(/[^\x20-\x7E]/)) {
        return Promise.reject(new SchemaError(this, data,
        'Control characters are not allowed.'))
      }
      if (this._noHTML && data.value.match(/<[\s\S]*>/)) {
        return Promise.reject(new SchemaError(this, data,
        'No tags allowed in this text.'))
      }
    }
    return Promise.resolve()
  }

  _lengthDescriptor() {
    let msg = ''
    if (this._min && this._max) {
      msg = this._min === this._max ? `The string has to contain exactly ${this._min} characters. `
      : `The string can have between ${this._min} and ${this._max} characters. `
    } else if (this._min) {
      msg = `The string needs at least ${this._min} characters. `
    } else if (this._max) {
      msg = `The string allows up to ${this._min} characters. `
    }
    if (this._mmin && this._truncate) {
      msg += `If it´s too short the string will be padded on \
${this._pad.type === 'both' ? '' : 'the '}${this._pad.type} \
${this._pad.type === 'both' ? 'sides' : 'side'} using \`${util.inspect(this._pad.char)}\`. `
    }
    if (this._max && this._truncate) msg += 'If it´s too long the string will be truncated. '
    return msg.length ? `${msg.trim()}\n` : msg
  }

  _lengthValidator(data: SchemaData): Promise<void> {
    let num = data.value.length
    // pad
    if (this._pad && num < this._min) {
      const add = this._min - num
      let pad = this._pad.char
      let a
      switch (this._pad.type) {
      case 'right':
        if (pad.length < add) pad += pad.slice(-1).repeat(add - pad.length)
        data.value += pad.slice(-add)
        break
      case 'left':
        if (pad.length < add) pad = `${pad.slice(0, 1).repeat(add - pad.length)}${pad}`
        data.value = `${pad.slice(0, add)}${data.value}`
        break
      default:
        a = Math.ceil(add / 2)
        pad = this._pad.char.length > 1
        ? this._pad.char.slice(-Math.ceil(this._pad.char.length / 2)) : this._pad.char
        if (pad.length < a) pad += pad.slice(-1).repeat(a - pad.length)
        data.value += pad.slice(-a)
        pad = this._pad.char.length > 1
        ? this._pad.char.slice(0, Math.ceil(this._pad.char.length / 2)) : this._pad.char
        a = Math.floor(add / 2)
        if (pad.length < a) pad = `${pad.slice(0, 1).repeat(a - pad.length)}${pad}`
        data.value = `${pad.slice(0, a)}${data.value}`
      }
      num = data.value.length
    }
    // truncate
    if (this._truncate && num > this._max) {
      data.value = data.value.substr(0, this._max)
      num = data.value.length
    }
    // check length
    if (this._min && num < this._min) {
      return Promise.reject(new SchemaError(this, data,
      `The string has a length of ${num} characters. \
This is too less, at least ${this._min} are needed.`))
    }
    if (this._max && num > this._max) {
      return Promise.reject(new SchemaError(this, data,
      `The string has a length of ${num} characters. \
This is too much, not more than ${this._max} are allowed.`))
    }
    return Promise.resolve()
  }

}

export default StringSchema
