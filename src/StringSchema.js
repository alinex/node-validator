// @flow
import util from 'util'

import AnySchema from './AnySchema'
import SchemaError from './SchemaError'
import type SchemaData from './SchemaData'
import Reference from './Reference'

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

  constructor(title?: string, detail?: string) {
    super(title, detail)
    // add check rules
    this._rules.descriptor.push(
      this._makeStringDescriptor,
      this._replaceDescriptor,
      this._caseDescriptor,
      this._checkDescriptor,
//      this._lengthDescriptor,
//      this._matchDescriptor,
    )
    this._rules.validator.push(
      this._makeStringValidator,
      this._replaceValidator,
      this._caseValidator,
      this._checkValidator,
//      this._lengthValidator,
//      this._matchValidator,
    )
  }

  // setup schema

  makeString(flag?: bool | Reference): this { return this._setFlag('makeString', flag) }

  _makeStringDescriptor() {
    const set = this._setting
    let msg = 'A text is needed. '
    if (set.makeString instanceof Reference) {
      msg += `It will be converted to string depending on ${set.makeString.description}. `
    } else if (set.makeString) {
      msg += 'If the value is no string it will be converted to one. '
    }
    return msg.replace(/ $/, '\n')
  }

  _makeStringValidator(data: SchemaData): Promise<void> {
    const check = this._check
    try {
      this._checkBoolean('makeString')
    } catch (err) {
      return Promise.reject(new SchemaError(this, data, err.message))
    }
    // check value
    if (check.makeString && typeof data.value !== 'string') data.value = data.value.toString()
    if (typeof data.value !== 'string') {
      return Promise.reject(new SchemaError(this, data, 'A `string` value is needed here.'))
    }
    return Promise.resolve()
  }

  trim(flag?: bool | Reference): this { return this._setFlag('trim', flag) }

  replace(match?: RegExp|string, replace?: string, name?: string): this {
    const set = this._setting
    if (match === undefined) delete set.replace // clear
    else if (replace === undefined && typeof match === 'string') {
      const len = set.replace.length
      set.replace = set.replace.filter(e => e.name !== match)
      if (len === set.replace.length) {
        throw new Error(`No replacer with the name \`${match}\` is defined`)
      }
    } else if (match && typeof match !== 'string') {
      if (!set.replace) set.replace = []
      set.replace.push(new Replace(match, replace || '', name))
    } else throw new Error('Needs a RegExp as first argument to define `replace()`.')
    return this
  }

  _replaceDescriptor() {
    const set = this._setting
    let msg = ''
    if (set.trim instanceof Reference) {
      msg += `Whitespace character will be trimmed depending on ${set.trim.description}. `
    } else if (set.trim) {
      msg += 'Whitespace characters at the begin and end of the string are removed. '
    }
    if (set.replace && set.replace.length) {
      const list = set.replace
      .map(e => `- \`${util.inspect(e.match)}\` => \`${e.replace}\`${e.name ? ` (${e.name})` : ''}`)
      .join('\n')
      msg += `The following replacements will be done:\n${list}\n`
    }
    return msg.length ? `${msg.replace(/ $/, '')}\n` : msg
  }

  _replaceValidator(data: SchemaData): Promise<void> {
    const check = this._check
    try {
      this._checkBoolean('trim')
    } catch (err) {
      return Promise.reject(new SchemaError(this, data, err.message))
    }
    // check value
    if (check.trim) data.value = data.value.trim()
    if (check.replace && check.replace.length) {
      check.replace.forEach(e => (data.value = data.value.replace(e.match, e.replace)))
    }
    return Promise.resolve()
  }

  uppercase(what: bool | 'all' | 'first' | Reference = 'all') {
    const set = this._setting
    if (what === false) delete set.uppercase
    else {
      if (set.lowercase === what) delete set.lowercase
      if (set.uppercase === true) set.uppercase = 'all'
      else set.uppercase = what
    }
    return this
  }

  lowercase(what: bool | 'all' | 'first' | Reference = 'all') {
    const set = this._setting
    if (what === false) delete set.lowercase
    else {
      if (set.uppercase === what) delete set.uppercase
      if (set.lowercase === true) set.lowercase = 'all'
      else set.lowercase = what
    }
    return this
  }

  _caseDescriptor() {
    const set = this._setting
    let msg = ''
    if (set.lowercase === 'all') msg += 'Convert the whole text to lowercase. '
    else if (set.uppercase === 'all') msg += 'Convert the whole text to uppercase. '
    if (set.lowercase instanceof Reference) {
      msg += `Lower case is used depending on ${set.lowercase.description}. `
    } else if (set.uppercase instanceof Reference) {
      msg += `Upper case is used depending on ${set.uppercase.description}. `
    }
    if (set.lowercase === 'first') msg += 'Convert only the first letter to lowercase. '
    else if (set.uppercase === 'first') msg += 'Convert only the first letter to uppercase. '
    return msg.length ? `${msg.replace(/ $/, '')}\n` : msg
  }

  _caseValidator(data: SchemaData): Promise<void> {
    const check = this._check
    try {
      this._checkBoolean('lowercase')
      this._checkBoolean('uppercase')
    } catch (err) {
      // no problem
    }
    if (check.lowercase === true) check.lowercase = 'all'
    else if (check.lowercase === false) delete check.lowercase
    if (check.uppercase === true) check.uppercase = 'all'
    else if (check.uppercase === false) delete check.uppercase
    try {
      this._checkString('lowercase')
      this._checkString('uppercase')
    } catch (err) {
      return Promise.reject(new SchemaError(this, data, err.message))
    }
    // check value
    if (check.lowercase === 'all') data.value = data.value.toLowerCase()
    else if (check.uppercase === 'all') data.value = data.value.toUpperCase()
    if (check.lowercase === 'first') {
      data.value = `${data.value.substr(0, 1).toLowerCase()}${data.value.substr(1)}`
    } else if (check.uppercase === 'first') {
      data.value = `${data.value.substr(0, 1).toUpperCase()}${data.value.substr(1)}`
    }
    return Promise.resolve()
  }

  alphanum(flag?: bool | Reference): this { return this._setFlag('alphanum', flag) }
  hex(flag?: bool | Reference): this { return this._setFlag('hex', flag) }
  controls(flag?: bool | Reference): this { return this._setFlag('controls', flag) }
  noHTML(flag?: bool | Reference): this { return this._setFlag('noHTML', flag) }
  stripDisallowed(flag?: bool | Reference): this { return this._setFlag('stripDisallowed', flag) }

  _checkDescriptor() {
    const set = this._setting
    let msg = ''
    if (set.alphanum instanceof Reference) {
      msg += `Only alpha numerical characters are allowed depending on \
${set.alphanum.description}. `
    } else if (set.alphanum) {
      msg += 'Only alpha numerical characters are allowed. '
    } else if (set.hex instanceof Reference) {
      msg += `Only hexa decimal characters are allowed depending on \
${set.hex.description}. `
    } else if (set.hex) {
      msg += 'Only hexa decimal characters are allowed. '
    }
    if (set.controls instanceof Reference) {
      msg += `Control characters are allowed depending on ${set.controls.description}. `
    } else if (set.controls) {
      msg += 'Control characters are allowed. '
    }
    if (set.noHTML instanceof Reference) {
      msg += `No HTML tags are allowed depending on ${set.noHTML.description}. `
    } else if (set.noHTML) {
      msg += 'No HTML tags are allowed. '
    }
    if (set.stripDisallowed instanceof Reference) {
      msg += `All not allowed characters will be removed depending on \
${set.stripDisallowed.description}. `
    } else if (set.stripDisallowed) {
      msg += 'All not allowed characters will be removed. '
    }
    return msg.length ? `${msg.replace(/ $/, '')}\n` : msg
  }

  _checkValidator(data: SchemaData): Promise<void> {
    const check = this._check
    try {
      this._checkBoolean('stripDisallowed')
      this._checkBoolean('alphanum')
      this._checkBoolean('hex')
      this._checkBoolean('controls')
      this._checkBoolean('noHTML')
    } catch (err) {
      return Promise.reject(new SchemaError(this, data, err.message))
    }
    // check value
    if (check.stripDisallowed) {
      if (check.alphanum) data.value = data.value.replace(/\W/g, '')
      else if (check.hex) data.value = data.value.replace(/[^a-fA-F0-9]/g, '')
      if (!check.controls) data.value = data.value.replace(/[^\x20-\x7E]/g, '')
      if (check.noHTML) {
        if (!striptags) striptags = require('striptags') // eslint-disable-line global-require
        data.value = striptags(data.value)
      }
    } else {
      if (check.alphanum && data.value.match(/\W/)) {
        return Promise.reject(new SchemaError(this, data,
        'Only alpha numerical characters (a-z, A-Z, 0-9 and _) are allowed.'))
      } else if (check.hex && data.value.match(/[^a-fA-F0-9]/)) {
        return Promise.reject(new SchemaError(this, data,
        'Only hexa decimal characters (a-f, A-F and 0-9) are allowed.'))
      }
      if (!check.controls && data.value.match(/[^\x20-\x7E]/)) {
        return Promise.reject(new SchemaError(this, data,
        'Control characters are not allowed.'))
      }
      if (check.noHTML && data.value.match(/<[\s\S]*>/)) {
        return Promise.reject(new SchemaError(this, data,
        'No tags allowed in this text.'))
      }
    }
    return Promise.resolve()
  }

//  min(limit?: number): this {
//    if (this._negate || limit === undefined) delete this._min
//    else {
//      const int = parseInt(limit, 10)
//      if (int < 0) throw new Error('Length for min() has to be positive')
//      if (this._max && int > this._max) {
//        throw new Error('Length for min() should be equal or below max')
//      }
//      this._min = int
//    }
//    return this
//  }
//
//  max(limit?: number): this {
//    if (this._negate || limit === undefined) delete this._max
//    else {
//      const int = parseInt(limit, 10)
//      if (int < 0) throw new Error('Length for max() has to be positive')
//      if (this._min && int < this._min) {
//        throw new Error('Length for max() should be equal or above min')
//      }
//      this._max = int
//    }
//    return this
//  }
//
//  length(limit?: number): this {
//    if (this._negate || limit === undefined) {
//      delete this._min
//      delete this._max
//    } else {
//      const int = parseInt(limit, 10)
//      if (int < 0) throw new Error('Length has to be positive')
//      this._min = int
//      this._max = int
//    }
//    return this
//  }
//
//  get truncate(): this {
//    this._truncate = !this._negate
//    this._negate = false
//    return this
//  }
//
//  pad(side: PadType = 'right', char: string = ' '): this {
//    if (this._negate) {
//      delete this._pad
//      this._negate = false
//    } else {
//      this._pad = new Pad(side, char)
//    }
//    return this
//  }
//
//  match(re: RegExp): this {
//    if (this._negate) {
//      this._negate = false
//      this._notMatch.push(re)
//    } else this._match.push(re)
//    return this
//  }
//
//  get clearMatch(): this {
//    if (this._negate) throw new Error('Negation of clearMatch is not possible')
//    this._match = []
//    this._notMatch = []
//    return this
//  }
//
//  // using schema
//
//
//
//
//
//  _lengthDescriptor() {
//    let msg = ''
//    if (this._min && this._max) {
//      msg = this._min === this._max ? `The string has to contain exactly ${this._min} characters. `
//      : `The string can have between ${this._min} and ${this._max} characters. `
//    } else if (this._min) {
//      msg = `The string needs at least ${this._min} characters. `
//    } else if (this._max) {
//      msg = `The string allows up to ${this._min} characters. `
//    }
//    if (this._mmin && this._truncate) {
//      msg += `If it´s too short the string will be padded on \
// ${this._pad.type === 'both' ? '' : 'the '}${this._pad.type} \
// ${this._pad.type === 'both' ? 'sides' : 'side'} using \`${util.inspect(this._pad.char)}\`. `
//    }
//    if (this._max && this._truncate) msg += 'If it´s too long the string will be truncated. '
//    return msg.length ? `${msg.trim()}\n` : msg
//  }
//
//  _lengthValidator(data: SchemaData): Promise<void> {
//    let num = data.value.length
//    // pad
//    if (this._pad && num < this._min) {
//      const add = this._min - num
//      let pad = this._pad.char
//      let a
//      switch (this._pad.type) {
//      case 'right':
//        if (pad.length < add) pad += pad.slice(-1).repeat(add - pad.length)
//        data.value += pad.slice(-add)
//        break
//      case 'left':
//        if (pad.length < add) pad = `${pad.slice(0, 1).repeat(add - pad.length)}${pad}`
//        data.value = `${pad.slice(0, add)}${data.value}`
//        break
//      default:
//        a = Math.ceil(add / 2)
//        pad = this._pad.char.length > 1
//        ? this._pad.char.slice(-Math.ceil(this._pad.char.length / 2)) : this._pad.char
//        if (pad.length < a) pad += pad.slice(-1).repeat(a - pad.length)
//        data.value += pad.slice(-a)
//        pad = this._pad.char.length > 1
//        ? this._pad.char.slice(0, Math.ceil(this._pad.char.length / 2)) : this._pad.char
//        a = Math.floor(add / 2)
//        if (pad.length < a) pad = `${pad.slice(0, 1).repeat(a - pad.length)}${pad}`
//        data.value = `${pad.slice(0, a)}${data.value}`
//      }
//      num = data.value.length
//    }
//    // truncate
//    if (this._truncate && num > this._max) {
//      data.value = data.value.substr(0, this._max)
//      num = data.value.length
//    }
//    // check length
//    if (this._min && num < this._min) {
//      return Promise.reject(new SchemaError(this, data,
//      `The string has a length of ${num} characters. \
// This is too less, at least ${this._min} are needed.`))
//    }
//    if (this._max && num > this._max) {
//      return Promise.reject(new SchemaError(this, data,
//      `The string has a length of ${num} characters. \
// This is too much, not more than ${this._max} are allowed.`))
//    }
//    return Promise.resolve()
//  }
//
//  _matchDescriptor() {
//    let msg = ''
//    if (this._match.length || this._notMatch.length) {
//      msg += 'The text should:'
//      if (this._match.length) {
//        msg += this._match.map(e => `\n- match \`${util.inspect(e)}\``).join('')
//      }
//      if (this._notMatch.length) {
//        msg += this._notMatch.map(e => `\n- match \`${util.inspect(e)}\``).join('')
//      }
//      msg += '\n\n'
//    }
//    return msg
//  }
//
//  _matchValidator(data: SchemaData): Promise<void> {
//    if (this._match.length) {
//      const fail = this._match.filter(e => !data.value.match(e))
//      .map(e => `\`${util.inspect(e)}\``)
//      .join(', ').replace(/(.*), /, '$1 and ')
//      if (fail) {
//        return Promise.reject(new SchemaError(this, data,
//          `The text should match: ${fail}`))
//      }
//    }
//    if (this._notMatch.length) {
//      const fail = this._notMatch.filter(e => data.value.match(e))
//      .map(e => `\`${util.inspect(e)}\``)
//      .join(', ').replace(/(.*), /, '$1 and ')
//      if (fail) {
//        return Promise.reject(new SchemaError(this, data,
//          `The text should not match: ${fail}`))
//      }
//    }
//    return Promise.resolve()
//  }
//
}

export default StringSchema
