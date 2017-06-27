// @flow
import Schema from './Schema'
import SchemaError from './SchemaError'
import type SchemaData from './SchemaData'
import Reference from './Reference'

class AnySchema extends Schema {

  constructor(title?: string, detail?: string) {
    super(title, detail)
    // init settings
    const set = this._setting
    set.allow = new Set()
    set.disallow = new Set()
    // add check rules
    this._rules.descriptor.push(
      this._allowDescriptor,
    )
    this._rules.check.push(
      this._allowCheck,
    )
    this._rules.validator.push(
      this._allowValidator,
    )
  }

  // setup schema

  valid(value?: any): this {
    const set = this._setting
    if (value instanceof Reference) {
      throw new Error('Reference is only allowed in allow() and disallow() for complete list')
    }
    if (value === undefined) set.required = false
    else if (set.allow instanceof Reference) {
      throw new Error('No single value if complete allow() list is set as reference.')
    } else {
      set.allow.add(value)
      if (!(set.allow instanceof Reference)) set.disallow.delete(value)
    }
    return this
  }
  invalid(value?: any): this {
    const set = this._setting
    if (value instanceof Reference) {
      throw new Error('Reference is only allowed in allow() and disallow() for complete list')
    }
    if (value === undefined) set.required = true
    else if (set.disallow instanceof Reference) {
      throw new Error('No single value if complete disallow() list is set as reference.')
    } else {
      set.disallow.add(value)
      if (!(set.disallow instanceof Reference)) set.allow.delete(value)
    }
    return this
  }
  allow(value?: Array<any> | Reference): this {
    const set = this._setting
    if (value === undefined) set.allow.clear()
    else if (value instanceof Reference) set.allow = value
    else {
      set.allow = new Set()
      for (const e of value) {
        set.allow.add(e)
        if (!(set.allow instanceof Reference)) set.disallow.delete(e)
      }
    }
    return this
  }
  disallow(value?: Array<any> | Reference): this {
    const set = this._setting
    if (value === undefined) set.disallow.clear()
    else {
      set.allow = new Set()
      set.allow.delete(value)
      set.disallow.add(value)
    }
    return this
  }

  // using schema

  _allowDescriptor() {
    const check = this._check
    let msg = ''
    if (check.disallow instanceof Reference) {
      msg += `The keys within ${check.disallow.description} are not allowed. `
    } else if (check.disallow.size) {
      msg += `The keys ${Array.from(check.disallow).join(', ').replace(/(.*),/, '$1 and')} \
are not allowed. `
    }
    if (check.allow instanceof Reference) {
      msg += `Only the keys within ${check.allow.description} are allowed. `
    } else if (check.allow.size) {
      msg += `Only the keys ${Array.from(check.allow).join(', ').replace(/(.*),/, '$1 and')} \
are allowed. `
    }
    return msg.length ? `${msg.trim()}\n` : ''
  }
  _allowCheck(): void {
    const check = this._check
    // transform arrays from references to set
    if (!check.allow) check.allow = []
    else if (check.allow instanceof Set) check.allow = Array.from(check.allow)
    else if (!Array.isArray(check.allow)) {
      throw new Error('The `allow` setting have to be a list of values.')
    }
    // transform arrays from references to set
    if (!check.disallow) check.disallow = []
    else if (check.disallow instanceof Set) check.disallow = Array.from(check.disallow)
    else if (!Array.isArray(check.disallow)) {
      throw new Error('The `disallow` setting have to be a list of values.')
    }
  }
  _allowValidator(data: SchemaData): Promise<void> {
    const check = this._check
    const datastring = JSON.stringify(data.value)
    // reject if marked as invalid
    if (check.disallow.size && check.disallow
    .filter(e => datastring === JSON.stringify(e)).length) {
      return Promise.reject(new SchemaError(this, data,
        'Element found in blacklist (disallowed item).'))
    }
    // reject if valid is set but not included
    if (check.allow.size && check.allow
    .filter(e => datastring === JSON.stringify(e)).length) {
      return Promise.reject(new SchemaError(this, data,
        'Element not in whitelist (allowed item).'))
    }
    // ok
    return Promise.resolve()
  }
}

export default AnySchema
