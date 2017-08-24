// @flow
import util from 'util'

import AnySchema from './Any'
import ValidationError from '../Error'
import type Data from '../Data'
import Reference from '../Reference'

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
  constructor(base?: any) {
    super(base)
    // add check rules
    let allow = this._rules.descriptor.pop()
    let raw = this._rules.descriptor.pop()
    this._rules.descriptor.push(
      this._typeDescriptor,
      this._makeStringDescriptor,
      this._replaceDescriptor,
      this._caseDescriptor,
      this._checkDescriptor,
      this._lengthDescriptor,
      this._matchDescriptor,
      allow,
      raw,
    )
    allow = this._rules.validator.pop()
    raw = this._rules.validator.pop()
    this._rules.validator.push(
      this._makeStringValidator,
      this._typeValidator,
      this._replaceValidator,
      this._caseValidator,
      this._checkValidator,
      this._lengthValidator,
      this._matchValidator,
      allow,
      raw,
    )
  }

  // setup schema

  _typeDescriptor() { // eslint-disable-line class-methods-use-this
    return 'It has to be a text string.\n'
  }

  _typeValidator(data: Data): Promise<void> {
    if (typeof data.value !== 'string') {
      return Promise.reject(new ValidationError(this, data, 'A text string is needed.'))
    }
    return Promise.resolve()
  }

  makeString(flag?: bool | Reference): this { return this._setFlag('makeString', flag) }

  _makeStringDescriptor() {
    const set = this._setting
    let msg = ''
    if (set.makeString instanceof Reference) {
      msg += `It will be converted to string depending on ${set.makeString.description}. `
    } else if (set.makeString) {
      msg += 'If the value is no string it will be converted to one. '
    }
    return msg.replace(/ $/, '\n')
  }

  _makeStringValidator(data: Data): Promise<void> {
    const check = this._check
    try {
      this._checkBoolean('makeString')
    } catch (err) {
      return Promise.reject(new ValidationError(this, data, err.message))
    }
    // check value
    if (check.makeString && typeof data.value !== 'string') data.value = data.value.toString()
    if (typeof data.value !== 'string') {
      return Promise.reject(new ValidationError(this, data, 'A `string` value is needed here.'))
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
        .map(e => `- \`${util.inspect(e.match)}\` =>
        \`${e.replace}\`${e.name ? ` (${e.name})` : ''}`)
        .join('\n')
      msg += `The following replacements will be done:\n${list}\n`
    }
    return msg.length ? `${msg.replace(/ $/, '')}\n` : msg
  }

  _replaceValidator(data: Data): Promise<void> {
    const check = this._check
    try {
      this._checkBoolean('trim')
    } catch (err) {
      return Promise.reject(new ValidationError(this, data, err.message))
    }
    // check value
    if (check.trim) data.value = data.value.trim()
    if (check.replace && check.replace.length) {
      check.replace.forEach((e) => {
        data.value = data.value.replace(e.match, e.replace)
      })
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

  _caseValidator(data: Data): Promise<void> {
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
      return Promise.reject(new ValidationError(this, data, err.message))
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

  _checkValidator(data: Data): Promise<void> {
    const check = this._check
    try {
      this._checkBoolean('stripDisallowed')
      this._checkBoolean('alphanum')
      this._checkBoolean('hex')
      this._checkBoolean('controls')
      this._checkBoolean('noHTML')
    } catch (err) {
      return Promise.reject(new ValidationError(this, data, err.message))
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
        return Promise.reject(new ValidationError(this, data,
          'Only alpha numerical characters (a-z, A-Z, 0-9 and _) are allowed.'))
      } else if (check.hex && data.value.match(/[^a-fA-F0-9]/)) {
        return Promise.reject(new ValidationError(this, data,
          'Only hexa decimal characters (a-f, A-F and 0-9) are allowed.'))
      }
      if (!check.controls && data.value.match(/[^\x20-\x7E]/)) {
        return Promise.reject(new ValidationError(this, data,
          'Control characters are not allowed.'))
      }
      if (check.noHTML && data.value.match(/<[\s\S]*>/)) {
        return Promise.reject(new ValidationError(this, data,
          'No tags allowed in this text.'))
      }
    }
    return Promise.resolve()
  }

  min(limit?: number | Reference): this {
    const set = this._setting
    if (limit) {
      if (!(limit instanceof Reference)) {
        if (set.max && !this._isReference('max') && limit > set.max) {
          throw new Error('Min length can´t be greater than max length')
        }
        if (limit < 0) throw new Error('Length for min() has to be positive')
      }
      set.min = limit
    } else delete set.min
    return this
  }

  max(limit?: number | Reference): this {
    const set = this._setting
    if (limit) {
      if (!(limit instanceof Reference)) {
        if (set.min && !this._isReference('min') && limit < set.min) {
          throw new Error('Max length can´t be less than min length')
        }
        if (limit < 0) throw new Error('Length for max() has to be positive')
      }
      set.max = limit
    } else delete set.max
    return this
  }

  length(limit?: number | Reference): this {
    const set = this._setting
    if (limit) {
      if (!(limit instanceof Reference)) {
        if (limit < 0) throw new Error('Length has to be positive')
      }
      set.min = limit
      set.max = limit
    } else {
      delete set.min
      delete set.max
    }
    return this
  }

  truncate(flag?: bool | Reference): this { return this._setFlag('truncate', flag) }

  pad(side: false | PadType = 'right', char: string = ' '): this {
    const set = this._setting
    if (side === false) delete set.pad
    else set.pad = new Pad(side, char)
    return this
  }

  _lengthDescriptor() {
    const set = this._setting
    let msg = ''
    if (set.min instanceof Reference) {
      msg += `Minimum character length depends on ${set.min.description}. `
    }
    if (set.max instanceof Reference) {
      msg += `Maximum character length depends on ${set.max.description}. `
    }
    if (!this._isReference('min') && !this._isReference('max') && set.min && set.max) {
      msg = set.min === set.max ? `The string has to contain exactly ${set.min} characters. `
        : `The string can have between ${set.min} and ${set.max} characters. `
    } else if (!this._isReference('min') && set.min) {
      msg = `The string needs at least ${set.min} characters. `
    } else if (!this._isReference('max') && set.max) {
      msg = `The string allows up to ${set.min} characters. `
    }
    if (set.truncate instanceof Reference) {
      msg += `Too long string will be truncated depending on ${set.truncate.description}. `
    } else if (!this._isReference('truncate') && set.truncate) {
      msg += 'If it´s too long the string will be truncated. '
    }
    if (set.pad) {
      msg += `If it´s too short the string will be padded on \
 ${set.pad.type === 'both' ? '' : 'the '}${set.pad.type} \
 ${set.pad.type === 'both' ? 'sides' : 'side'} using \`${util.inspect(set.pad.char)}\`. `
    }
    return msg.length ? `${msg.trim()}\n` : msg
  }

  _lengthValidator(data: Data): Promise<void> {
    const check = this._check
    try {
      this._checkNumber('min')
      this._checkNumber('Max')
      this._checkBoolean('truncate')
      if (check.max && check.min && check.min > check.max) {
        throw new Error('Min length can´t be greater than max length')
      }
    } catch (err) {
      return Promise.reject(new ValidationError(this, data, err.message))
    }
    // check value
    let num = data.value.length
    // pad
    if (check.pad && num < check.min) {
      const add = check.min - num
      let pad = check.pad.char
      let a
      switch (check.pad.type) {
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
        pad = check.pad.char.length > 1
          ? check.pad.char.slice(-Math.ceil(check.pad.char.length / 2)) : check.pad.char
        if (pad.length < a) pad += pad.slice(-1).repeat(a - pad.length)
        data.value += pad.slice(-a)
        pad = check.pad.char.length > 1
          ? check.pad.char.slice(0, Math.ceil(check.pad.char.length / 2)) : check.pad.char
        a = Math.floor(add / 2)
        if (pad.length < a) pad = `${pad.slice(0, 1).repeat(a - pad.length)}${pad}`
        data.value = `${pad.slice(0, a)}${data.value}`
      }
      num = data.value.length
    }
    // truncate
    if (check.truncate && num > check.max) {
      data.value = data.value.substr(0, check.max)
      num = data.value.length
    }
    // check length
    if (check.min && num < check.min) {
      return Promise.reject(new ValidationError(this, data,
        `The string has a length of ${num} characters. \
 This is too less, at least ${check.min} are needed.`))
    }
    if (check.max && num > check.max) {
      return Promise.reject(new ValidationError(this, data,
        `The string has a length of ${num} characters. \
 This is too much, not more than ${check.max} are allowed.`))
    }
    return Promise.resolve()
  }

  match(re?: RegExp | Reference): this {
    const set = this._setting
    if (re === undefined) delete set.match
    else {
      if (!set.match) set.match = []
      set.match.push(re)
    }
    return this
  }

  notMatch(re?: RegExp | Reference): this {
    const set = this._setting
    if (re === undefined) delete set.notMatch
    else {
      if (!set.notMatch) set.notMatch = []
      set.notMatch.push(re)
    }
    return this
  }

  _matchDescriptor() {
    const set = this._setting
    let msg = ''
    if ((set.match && set.match.length) || (set.notMatch && set.notMatch.length)) {
      msg += 'The text should:'
      if (set.match && set.match.length) {
        msg += set.match.map((e) => {
          if (e instanceof Reference) return `\n- match ${e.description}`
          return `\n- match \`${util.inspect(e)}\``
        }).join('')
      }
      if (set.notMatch && set.notMatch.length) {
        msg += set.notMatch.map((e) => {
          if (e instanceof Reference) return `\n- not match ${e.description}`
          return `\n- not match \`${util.inspect(e)}\``
        }).join('')
      }
      msg += '\n\n'
    }
    return msg
  }

  _matchValidator(data: Data): Promise<void> {
    const check = this._check
    try {
      this._checkArrayMatch('match')
      this._checkArrayMatch('notMatch')
    } catch (err) {
      return Promise.reject(new ValidationError(this, data, err.message))
    }
    // check value
    if (check.match && check.match.length) {
      const fail = check.match.filter((e) => {
        if (typeof e === 'string') return !data.value.includes(e)
        return !data.value.match(e)
      })
        .map(e => `\`${util.inspect(e)}\``)
        .join(', ').replace(/(.*), /, '$1 and ')
      if (fail) {
        return Promise.reject(new ValidationError(this, data,
          `The text should match: ${fail}`))
      }
    }
    if (check.notMatch && check.notMatch.length) {
      const fail = check.notMatch.filter((e) => {
        if (typeof e === 'string') return data.value.includes(e)
        return data.value.match(e)
      })
        .map(e => `\`${util.inspect(e)}\``)
        .join(', ').replace(/(.*), /, '$1 and ')
      if (fail) {
        return Promise.reject(new ValidationError(this, data,
          `The text should not match: ${fail}`))
      }
    }
    return Promise.resolve()
  }
}

export default StringSchema
