// @flow
import Schema from './Schema'
import SchemaError from './SchemaError'
import type SchemaData from './SchemaData'
import Reference from './Reference'

class AnySchema extends Schema {
  constructor(base?: any) {
    super(base)
    // add check rules
    let raw = this._rules.descriptor.pop()
    this._rules.descriptor.push(
      this._allowDescriptor,
      raw,
    )
    raw = this._rules.validator.pop()
    this._rules.validator.push(
      this._allowValidator,
      raw,
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
        if (set.deny) set.deny.delete(e)
      }
    }
    return this
  }
  deny(...values: Array<any>): this {
    const set = this._setting
    const value = values.reduce((acc, val) => acc.concat(val), [])
    if (value.length === 1 && value[0] === undefined) delete set.deny
    else if (value.length === 1 && value[0] instanceof Reference) set.deny = value[0]
    else {
      set.deny = new Set()
      for (const e of value) {
        if (value === undefined) set.required = true
        set.deny.add(e)
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
      if (set.deny && !(set.deny instanceof Reference)) set.deny.delete(value)
    }
    return this
  }
  invalid(value?: any): this {
    const set = this._setting
    if (value === undefined) set.required = true
    else if (set.deny instanceof Reference) {
      throw new Error('No single value if complete deny() list is set as reference.')
    } else {
      if (!set.deny) set.deny = new Set()
      set.deny.add(value)
      if (set.allow && !(set.allow instanceof Reference)) set.allow.delete(value)
    }
    return this
  }

  _allowDescriptor() {
    const set = this._setting
    let msg = ''
    if (set.deny instanceof Reference) {
      msg += `The values within ${set.deny.description} are not allowed. `
    } else if (set.deny && set.deny.size) {
      msg += `The values ${Array.from(set.deny).join(', ').replace(/(.*),/, '$1 and')} \
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
    this._checkArray('deny')
    // reject if marked as invalid
    const datastring = JSON.stringify(data.value)
    if (check.deny && check.deny.length && check.deny
      .filter(e => datastring === JSON.stringify(e)).length) {
      return Promise.reject(new SchemaError(this, data,
        'Element found in blacklist (denyed item).'))
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
