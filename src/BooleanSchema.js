// @flow
import util from 'util'

import Schema from './Schema'
import SchemaError from './SchemaError'
import type SchemaData from './SchemaData'
import Reference from './Reference'

class BooleanSchema extends Schema {
  constructor(title?: string, detail?: string) {
    super(title, detail)
    // init settings
    const set = this._setting
    set.truthy = new Set()
    set.falsy = new Set()
    set.format = new Map()
    // add check rules
    let raw = this._rules.descriptor.pop()
    this._rules.descriptor.push(
      this._parserDescriptor,
      this._formatDescriptor,
      raw,
    )
    raw = this._rules.validator.pop()
    this._rules.validator.push(
      this._parserValidator,
      this._formatValidator,
      raw,
    )
  }

  // parse schema

  truthy(...values: Array<any>): this {
    const set = this._setting
    const value = values.reduce((acc, val) => acc.concat(val), [])
    if (value.length === 1 && value[0] === undefined) set.truthy.clear()
    else if (value.length === 1 && value[0] instanceof Reference) set.truthy = value[0]
    else {
      set.truthy = new Set()
      for (const e of value) {
        if (value === undefined) set.required = false
        set.truthy.add(e)
        set.falsy.delete(e)
      }
    }
    return this
  }
  falsy(...values: Array<any>): this {
    const set = this._setting
    const value = values.reduce((acc, val) => acc.concat(val), [])
    if (value.length === 1 && value[0] === undefined) set.falsy.clear()
    else if (value.length === 1 && value[0] instanceof Reference) set.falsy = value[0]
    else {
      set.falsy = new Set()
      for (const e of value) {
        if (value === undefined) set.required = false
        set.falsy.add(e)
        set.truthy.delete(e)
      }
    }
    return this
  }

  tolerant(flag: bool | Reference = true): this {
    const set = this._setting
    if (flag) {
      this.truthy(1, '1', 'true', 'on', 'yes', '+')
      this.falsy(0, '0', 'false', 'off', 'no', '-')
    } else {
      set.truthy.clear()
      set.falsy.clear()
    }
    return this
  }

  insensitive(flag?: bool | Reference): this { return this._setFlag('insensitive', flag) }

  _parserDescriptor() {
    const set = this._setting
    let msg = ''
    let truthy = Array.from(set.truthy)
    truthy.unshift(true)
    truthy = truthy.map(e => `\`${util.inspect(e)}\``).join(', ').replace(/(.*),/, '$1 and')
    let falsy = Array.from(set.falsy)
    falsy.unshift(false)
    falsy = falsy.map(e => `\`${util.inspect(e)}\``).join(', ').replace(/(.*),/, '$1 and')
    msg = `A boolean which is \`true\` for ${truthy} and \`false\` for ${falsy}. `
    if (set.insensitive instanceof Reference) {
      msg += `Strings are matched case insensitive depending on ${set.insensitive.description}. `
    } else if (set.insensitive) {
      msg = 'Strings are matched insensitive for possible `true`/`false` values. '
    }
    return msg.replace(/ $/, '\n')
  }

  _parserValidator(data: SchemaData): Promise<void> {
    const check = this._check
    try {
      this._checkArray('truthy')
      this._checkArray('falsy')
      this._checkBoolean('insensitive')
    } catch (err) {
      return Promise.reject(new SchemaError(this, data, err.message))
    }
    if (check.insensitive) {
      check.truthy = Array.from(check.truthy)
        .map(e => (typeof e === 'string' ? e.toLowerCase() : e))
      check.falsy = Array.from(check.falsy)
        .map(e => (typeof e === 'string' ? e.toLowerCase() : e))
    }
    check.truthy.unshift(true)
    check.falsy.unshift(false)
    // check value
    if (check.insensitive) data.value = data.value.toLowerCase()
    if (check.truthy.includes(data.value)) data.value = true
    else if (check.falsy.includes(data.value)) data.value = false
    else {
      return Promise.reject(new SchemaError(this, data,
        'A boolean value is needed but neither `true` nor `false` was given.'))
    }
    // ok
    return Promise.resolve()
  }

  // format

  format(truthy: any, falsy: any): this {
    const set = this._setting
    if (truthy) set.format.set(true, truthy)
    else if (truthy === undefined) set.format.delete(true)
    if (falsy) set.format.set(false, falsy)
    else if (falsy === undefined) set.format.delete(false)
    return this
  }

  _formatDescriptor() {
    const set = this._setting
    return set.format.size ?
      `Strings are formatted using \`${util.inspect(set.format.get(true))}\` for \
\`true\` and \`${util.inspect(set.format.get(false))}\` for \`false\`.\n` : ''
  }

  _formatValidator(data: SchemaData): Promise<void> {
    const check = this._check
    try {
      this._checkObject('format')
      if (Object.keys(check.format).filter(e => e !== 'true' && e !== 'false').length) {
        throw new Error('Only `true` and `false` settings are allowed in format()`')
      }
    } catch (err) {
      return Promise.reject(new SchemaError(this, data, err.message))
    }
    // check value
    if (Object.keys(check.format).length) data.value = check.format[data.value] || data.value
    return Promise.resolve()
  }
}

export default BooleanSchema
