// @flow
import Schema from './Schema'
import SchemaError from './SchemaError'
import type SchemaData from './SchemaData'
import Reference from './Reference'

class AnySchema extends Schema {

//  _setting: {
//    stripEmpty?: bool | Reference,
//    default?: any,
//    required?: bool | Reference,
//    allow: Set<any>,
//    disallow: Set<any>,
//  }

  constructor(title?: string, detail?: string) {
    super(title, detail)
    // add check rules
    this._rules.descriptor.push(
      this._allowDescriptor,
    )
    this._rules.validator.push(
      this._allowValidator,
    )
  }

  // setup schema

  allow(...values: Array<any>): this {
    const set = this._setting
    const value = values.reduce((acc, val) => acc.concat(val), [])
    if (value.length === 1 && value[0] === undefined) delete set.allow
    else if (value.length === 1 && value[0] instanceof Reference) set.allow = value[0]
    else {
      set.allow = new Set()
      for (const e of value) {
        if (value === undefined) set.required = false
        set.allow.add(e)
        if (set.disallow) set.disallow.delete(e)
      }
    }
    return this
  }
  disallow(...values: Array<any>): this {
    const set = this._setting
    const value = values.reduce((acc, val) => acc.concat(val), [])
    if (value.length === 1 && value[0] === undefined) delete set.disallow
    else if (value.length === 1 && value[0] instanceof Reference) set.disallow = value[0]
    else {
      set.disallow = new Set()
      for (const e of value) {
        if (value === undefined) set.required = true
        set.disallow.add(e)
        if (set.allow) set.allow.delete(e)
      }
    }
    return this
  }

  valid(value?: any): this {
    const set = this._setting
    if (value === undefined) set.required = false
    else if (set.allow instanceof Reference) {
      throw new Error('No single value if complete allow() list is set as reference.')
    } else {
      if (!set.allow) set.allow = new Set()
      set.allow.add(value)
      if (set.disallow && !(set.disallow instanceof Reference)) set.disallow.delete(value)
    }
    return this
  }
  invalid(value?: any): this {
    const set = this._setting
    if (value === undefined) set.required = true
    else if (set.disallow instanceof Reference) {
      throw new Error('No single value if complete disallow() list is set as reference.')
    } else {
      if (!set.disallow) set.disallow = new Set()
      set.disallow.add(value)
      if (set.allow && !(set.allow instanceof Reference)) set.allow.delete(value)
    }
    return this
  }

  _allowDescriptor() {
    const set = this._setting
    let msg = ''
    if (set.disallow instanceof Reference) {
      msg += `The values within ${set.disallow.description} are not allowed. `
    } else if (set.disallow && set.disallow.size) {
      msg += `The values ${Array.from(set.disallow).join(', ').replace(/(.*),/, '$1 and')} \
are not allowed. `
    }
    if (set.allow instanceof Reference) {
      msg += `Only the values within ${set.allow.description} are allowed. `
    } else if (set.allow && set.allow.size) {
      msg += `Only the values ${Array.from(set.allow).join(', ').replace(/(.*),/, '$1 and')} \
are allowed. `
    }
    return msg.length ? `${msg.trim()}\n` : ''
  }

  _allowValidator(data: SchemaData): Promise<void> {
    const check = this._check
    this._checkArray('allow')
    this._checkArray('disallow')
    // reject if marked as invalid
    const datastring = JSON.stringify(data.value)
    if (check.disallow && check.disallow.length && check.disallow
    .filter(e => datastring === JSON.stringify(e)).length) {
      return Promise.reject(new SchemaError(this, data,
        'Element found in blacklist (disallowed item).'))
    }
    // reject if valid is set but not included
    if (check.allow && check.allow.length && check.allow
    .filter(e => datastring === JSON.stringify(e)).length === 0) {
      return Promise.reject(new SchemaError(this, data,
        'Element not in whitelist (allowed item).'))
    }
    // ok
    return Promise.resolve()
  }
}

export default AnySchema
