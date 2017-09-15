// @flow
import promisify from 'es6-promisify' // may be removed with node util.promisify later
import url from 'url'

// load on demand: request-promise-native, dns, net

import StringSchema from './String'
import DomainSchema from './Domain'
import ValidationError from '../Error'
import type Data from '../Data'
import Reference from '../Reference'


class URLSchema extends StringSchema {
  constructor(base?: any) {
    super(base)
    // add check rules
    let raw = this._rules.descriptor.pop()
    let allow = this._rules.descriptor.pop()
    this._rules.descriptor.push(
      this._resolveDescriptor,
      allow,
      raw,
    )
    raw = this._rules.validator.pop()
    allow = this._rules.validator.pop()
    this._rules.validator.push(
      this._structValidator,
      this._resolveValidator,
      allow,
      this._formatValidator,
      raw,
    )
  }

  stripEmpty(): this { return this._setError('stripEmpty') }
  truncate(): this { return this._setError('truncate') }
  pad(): this { return this._setError('pad') }

  // domain settings
  dns(flag?: bool | Reference): this { return this._setFlag('dns', flag) }

  _typeDescriptor() { // eslint-disable-line class-methods-use-this
    return 'It has to be a valid URI address.\n'
  }

  _structValidator(data: Data): Promise<void> {
    const check = this._check
    // split address
    data.value = url.parse(data.value)
    return Promise.resolve()
  }

  resolve(base?: string | Reference): this { return this._setAny('resolve', base) }

  _resolveDescriptor() {
    const set = this._setting
    let msg = ''
    if (set.resolve) {
      if (this._isReference('resolve')) {
        msg += `A relative address is based on the address defined under \
${set.resolve.description}. `
      } else msg += `A relative address is based on ${set.resolve}. `
    }
    return msg.length ? `${msg.trim()}\n` : msg
  }

  _resolveValidator(data: Data): Promise<void> {
    const check = this._check
    try {
      this._checkString('resolve')
    } catch (err) {
      return Promise.reject(new ValidationError(this, data, err.message))
    }
    // format
    if (check.resolve) data.value = url.resolve(check.resolve, data.value)
    return Promise.resolve()
  }

  _allowValidator(data: Data): Promise<void> {
    const check = this._check
    this._checkArrayString('allow')
    this._checkArrayString('deny')
    // checking
    if (check.deny && check.deny.length) {
      // get lists
      const list = check.deny.map(e => url.parse(e))
      const protocol = list.map(e => e.protocol)
        .filter(e => e.length && data.value.protocol === e)
      const host = list.map(e => e.host)
        .filter(e => e.length && data.value.host === e)
      const hostname = list.map(e => e.hostname)
        .filter(e => e.length && data.value.hostname === e)
      const path = list.map(e => e.path)
        .filter(e => e.length && data.value.path.includes(e))
      if (protocol || hostname || host || path) {
        return Promise.reject(new ValidationError(this, data,
          'URL found in blacklist (denied item).'))
      }
    }
    if (check.allow && check.allow.length) {
      // get lists
      const list = check.allow.map(e => url.parse(e))
      const protocol = list.map(e => e.protocol)
        .filter(e => !e.length || data.value.protocol === e)
      const host = list.map(e => e.host)
        .filter(e => !e.length || data.value.host === e)
      const hostname = list.map(e => e.hostname)
        .filter(e => !e.length || data.value.hostname === e)
      const path = list.map(e => e.path)
        .filter(e => !e.length || data.value.path.includes(e))
      if (!protocol || !hostname || !host || !path) {
        return Promise.reject(new ValidationError(this, data,
          'URL not found in whitelist (allowed item).'))
      }
    }
    return Promise.resolve()
  }

  _formatValidator(data: Data): Promise<void> {
    const check = this._check
    // split address
    data.value = data.value.href
    return Promise.resolve()
  }
}


export default URLSchema
