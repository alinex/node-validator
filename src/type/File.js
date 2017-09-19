// @flow
import url from 'url'

// load on demand: request-promise-native, dns, net

import StringSchema from './String'
import DomainSchema from './Domain'
import ValidationError from '../Error'
import type Data from '../Data'
import Reference from '../Reference'


class FileSchema extends StringSchema {
  constructor(base?: any) {
    super(base)
    // add check rules
    let raw = this._rules.descriptor.pop()
    let allow = this._rules.descriptor.pop()
    this._rules.descriptor.push(
      //      this._searchDescriptor,
      //      this._resolveDescriptor,
      allow,
      //      this._existsDescriptor,
      raw,
    )
    raw = this._rules.validator.pop()
    allow = this._rules.validator.pop()
    this._rules.validator.push(
      //      this._searchValidator,
      //      this._resolveValidator,
      allow,
      //      this._existsValidator,
      raw,
    )
  }

  stripEmpty(): this { return this._setError('stripEmpty') }
  truncate(): this { return this._setError('truncate') }
  pad(): this { return this._setError('pad') }

  _typeDescriptor() { // eslint-disable-line class-methods-use-this
    return 'It has to be a valid file or directory location.\n'
  }

  _searchDescriptor() {
    const set = this._setting
    const schema = new DomainSchema()
    if (set.dns) schema.dns()
    return `- domain part: ${schema.description}\n\n`
  }

  _searchValidator(data: Data): Promise<void> {
    const check = this._check
    // split address
    data.value = url.parse(data.value)
    // check domain
    const schema = new DomainSchema().raw()
    if (check.dns) schema.dns()
    return schema._validate(data.sub('host'))
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
        .filter(e => e && e.length && data.value.protocol === e)
      const host = list.map(e => e.host)
        .filter(e => e && e.length && data.value.host === e)
      const hostname = list.map(e => e.hostname)
        .filter(e => e && e.length && data.value.hostname === e)
      const path = list.map(e => e.path)
        .filter(e => e && e.length && data.value.path.includes(e))
      if (protocol.length || hostname.length || host.length || path.length) {
        return Promise.reject(new ValidationError(this, data,
          'URL found in blacklist (denied item).'))
      }
    }
    if (check.allow && check.allow.length) {
      // get lists
      const list = check.allow.map(e => url.parse(e))
      const protocol = list.map(e => e.protocol)
        .filter(e => !e || !e.length || data.value.protocol === e)
      const host = list.map(e => e.host)
        .filter(e => !e || !e.length || data.value.host === e)
      const hostname = list.map(e => e.hostname)
        .filter(e => !e || !e.length || data.value.hostname === e)
      const path = list.map(e => e.path)
        .filter(e => !e || !e.length || data.value.path.includes(e))
      if (!protocol.length || !hostname.length || !host.length || !path.length) {
        return Promise.reject(new ValidationError(this, data,
          'URL not found in whitelist (allowed item).'))
      }
    }
    return Promise.resolve()
  }

  exists(flag?: bool | Reference): this { return this._setFlag('exists', flag) }

  _existsDescriptor() {
    const set = this._setting
    let msg = ''
    if (set.exists) {
      if (this._isReference('exists')) {
        msg += `The URL have to exist and be accessible if defined under \
${set.exists.description}. `
      } else msg += 'The URL have to exist and be accessible. '
    }
    return msg.length ? `${msg.trim()}\n` : msg
  }

  _existsValidator(data: Data): Promise<void> {
    const check = this._check
    try {
      this._checkBoolean('exists')
    } catch (err) {
      return Promise.reject(new ValidationError(this, data, err.message))
    }
    // format
    if (check.exists) {
      return import('request-promise-native')
        .then((request: any) => request(data.value.href))
    }
    return Promise.resolve()
  }
}


export default FileSchema
