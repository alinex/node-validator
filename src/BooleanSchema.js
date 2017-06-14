// @flow
import util from 'util'

import Schema from './Schema'
import SchemaError from './SchemaError'
import type SchemaData from './SchemaData'

class BooleanSchema extends Schema {

  // validation data

  _truthy: Set<any>
  _falsy: Set<any>
  _insensitive: bool
  _format: Map<bool, any>

  constructor(title?: string, detail?: string) {
    super(title, detail)
    // init settings
    this._truthy = new Set()
    this._falsy = new Set()
    this._insensitive = false
    this._format = new Map()
    // add check rules
    this._rules.add([this._insensitiveDescriptor, this._insensitiveValidator])
    this._rules.add([this._parserDescriptor, this._parserValidator])
    this._rules.add([this._formatDescriptor, this._formatValidator])
  }

  // setup schema

  truthy(...values: any|Array<any>): this {
    values.reduce((acc, val) => acc.concat(val), [])
    .forEach((value) => {
      if (value !== true && value !== false) {
        if (value === undefined) {
          this._required = false
          this._default = !this._negate
        } else if (this._negate) {
          // falsy
          this._falsy.add(value)
          this._truthy.delete(value)
        } else {
          // allow
          this._truthy.add(value)
          this._falsy.delete(value)
        }
      }
    })
    this._negate = false // been used
    return this
  }

  falsy(...values: any|Array<any>): this {
    this._negate = !this._negate
    return this.truthy(...values)
  }

  get tolerant(): this {
    if (this._negate) {
      this._truthy.clear()
      this._falsy.clear()
      this._negate = false
    } else {
      this.truthy(1, '1', 'true', 'on', 'yes', '+')
      this.falsy(0, '0', 'false', 'off', 'no', '-')
    }
    return this
  }

  get insensitive(): this {
    this._insensitive = !this._negate
    this._negate = false
    return this
  }

  format(truthy: any, falsy: any): this {
    if (this._negate) this._format.clear()
    else this._format.set(true, truthy).set(false, falsy)
    this._negate = false
    return this
  }

  // using schema

  _insensitiveDescriptor() {
    return this._insensitive ?
    'Strings are matched insensitive for possible `true`/`false` values.\n' : ''
  }

  _insensitiveValidator(data: SchemaData): Promise<void> {
    if (this._insensitive && typeof data.value === 'string') data.value = data.value.toLowerCase()
    return Promise.resolve()
  }

  _parserDescriptor() {
    let truthy = Array.from(this._truthy)
    truthy.unshift(true)
    truthy = truthy.map(e => `\`${util.inspect(e)}\``).join(', ').replace(/(.*),/, '$1 and')
    let falsy = Array.from(this._falsy)
    falsy.unshift(false)
    falsy = falsy.map(e => `\`${util.inspect(e)}\``).join(', ').replace(/(.*),/, '$1 and')
    return `A boolean which is \`true\` for ${truthy} and \`false\` for ${falsy}.\n`
  }

  _parserValidator(data: SchemaData): Promise<void> {
    const truthy = Array.from(this._truthy)
    .map(e => (this._insensitive && typeof e === 'string' ? e.toLowerCase() : e))
    truthy.unshift(true)
    const falsy = Array.from(this._falsy)
    .map(e => (this._insensitive && typeof e === 'string' ? e.toLowerCase() : e))
    falsy.unshift(false)
    if (truthy.includes(data.value)) data.value = true
    else if (falsy.includes(data.value)) data.value = false
    else {
      return Promise.reject(new SchemaError(this, data,
      'A boolean value is needed but it no allowed `true` nor `false` was given.'))
    }
    // ok
    return Promise.resolve()
  }

  _formatDescriptor() {
    return this._format.size ?
    `Strings are formatted using \`${util.inspect(this._format.get(true))}\` for \
\`true\` and \`${util.inspect(this._format.get(false))}\` for \`false\`.\n` : ''
  }

  _formatValidator(data: SchemaData): Promise<void> {
    if (this._format.size) data.value = this._format.get(data.value) || data.value
    return Promise.resolve()
  }
}

export default BooleanSchema
