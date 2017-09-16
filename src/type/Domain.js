// @flow
import promisify from 'es6-promisify' // may be removed with node util.promisify later
import punycode from 'punycode'
// load on demand: dns

import StringSchema from './String'
import ValidationError from '../Error'
import type Data from '../Data'
import Reference from '../Reference'

// load on demand: dns

class DomainSchema extends StringSchema {
  constructor(base?: any) {
    super(base)
    // add check rules
    let raw = this._rules.descriptor.pop()
    this._rules.descriptor.push(
      this._dnsDescriptor,
      this._formatDescriptor,
      raw,
    )
    raw = this._rules.validator.pop()
    this._rules.validator.push(
      this._dnsValidator,
      this._formatValidator,
      raw,
    )
    super.stripEmpty()
  }

  stripEmpty(): this { return this._setError('stripEmpty') }
  truncate(): this { return this._setError('truncate') }
  pad(): this { return this._setError('pad') }

  _typeDescriptor() { // eslint-disable-line class-methods-use-this
    return 'It has to be a reasonable hostname.\n'
  }

  _typeValidator(data: Data): Promise<void> {
    if (typeof data.value !== 'string') {
      return Promise.reject(new ValidationError(this, data, 'A text string is needed.'))
    }
    // convert iinternational domains
    data.value = punycode.toASCII(data.value)
    // check domain
    for (const p of data.value.split('.')) {
      if (p.length > 63) {
        return Promise.reject(new ValidationError(this, data, `Each label within the domain name \
should be smaller than 64 characters: '${p}' is to large`))
      }
    }
    if (data.value.length > 253) {
      return Promise.reject(new ValidationError(this, data, 'The full domain name is too large, such \
names are not allowed in DNS'))
    }
    if (!data.value.match(/^[a-zA-Z0-9][a-zA-Z0-9-]{1,61}[a-zA-Z0-9](?:\.[a-zA-Z]{2,})+$/)) {
      return Promise.reject(new ValidationError(this, data, 'Invalid domain name, only a-z, 0-9 and \
`-` is allowed'))
    }
    return Promise.resolve()
  }

  _allowValidator(data: Data): Promise<void> {
    const check = this._check
    this._checkArrayString('allow')
    this._checkArrayString('deny')
    // checking
    let denyPriority = 0
    let allowPriority = 0
    if (check.deny && check.deny.length) {
      for (const e of check.deny) {
        const domain = punycode.toASCII(e)
        if (data.value === domain) {
          denyPriority = 99
          break
        }
        if (data.value.endsWith(`.${domain}`)) {
          const m = domain.match(/\./g)
          const level = m ? m.length + 1 : 1
          if (level > denyPriority) denyPriority = level
        }
      }
    }
    if (check.allow && check.allow.length) {
      for (const e of check.allow) {
        const domain = punycode.toASCII(e)
        if (data.value === domain) {
          allowPriority = 99
          break
        }
        if (data.value.endsWith(`.${domain}`)) {
          const m = domain.match(/\./g)
          const level = m ? m.length + 1 : 1
          if (level > allowPriority) allowPriority = level
        }
      }
    }
    if (denyPriority > allowPriority) {
      return Promise.reject(new ValidationError(this, data,
        'Domain found in blacklist (denied item).'))
    }
    return Promise.resolve()
  }

  _lengthDescriptor() {
    const set = this._setting
    let msg = ''
    if (set.min instanceof Reference) {
      msg += `Minimum number of labels depends on ${set.min.description}. `
    }
    if (set.max instanceof Reference) {
      msg += `Maximum number of labels depends on ${set.max.description}. `
    }
    if (!this._isReference('min') && !this._isReference('max') && set.min && set.max) {
      msg = set.min === set.max ? `The string has to contain exactly ${set.min} labels. `
        : `The string can have between ${set.min} and ${set.max} labels. `
    } else if (!this._isReference('min') && set.min) {
      msg = `The string needs at least ${set.min} labels. `
    } else if (!this._isReference('max') && set.max) {
      msg = `The string allows up to ${set.min} labels. `
    }
    return msg.length ? `${msg.trim()}\n` : msg
  }

  _lengthValidator(data: Data): Promise<void> {
    const check = this._check
    try {
      this._checkNumber('min')
      this._checkNumber('max')
      if (check.max && check.min && check.min > check.max) {
        throw new Error('Min label number can´t be greater than max label number')
      }
    } catch (err) {
      return Promise.reject(new ValidationError(this, data, err.message))
    }
    // check length
    const num = data.value.split('.').length
    if (check.min && num < check.min) {
      return Promise.reject(new ValidationError(this, data,
        `The string has ${num} labels. \
 This is too less, at least ${check.min} labesl are needed.`))
    }
    if (check.max && num > check.max) {
      return Promise.reject(new ValidationError(this, data,
        `The string has ${num} labels. \
 This is too much, not more than ${check.max} labels are allowed.`))
    }
    return Promise.resolve()
  }

  dns(type?: string | Array<string> | Reference | Boolean): this {
    const set = this._setting
    if (type === false) delete set.dns
    else if (typeof type === 'string') set.dns = [type]
    else set.dns = type || true
    return this
  }

  _dnsDescriptor() {
    const set = this._setting
    let msg = ''
    if (set.dns) {
      if (this._isReference('dns')) {
        msg += `The domain should has a valid record if set under \
${set.dns.description}. `
      } else if (set.dns === true) msg += 'The domain should has at least one DNS entry. '
      else msg += `The domain should has at least one DNS record of type ${set.dns.join(', ')}. `
    }
    return msg.length ? `${msg.trim()}\n` : msg
  }

  _dnsValidator(data: Data): Promise<void> {
    const check = this._check
    if (check.dns) {
      if (check.dns === true) check.dns = ['ANY']
      else if (typeof check.dns === 'string') check.dns = [check.dns]
      else if (!Array.isArray(check.dns)) {
        return Promise.reject(new ValidationError(this, data, 'The dns setting is no string or string array'))
      }
    }
    // run dns check
    if (check.dns) {
      return import('dns')
        .then((dns) => {
          const resolve = promisify(dns.resolve)
          const p = check.dns.map((e) => {
            const r = e === 'ANY' ? resolve(data.value) : resolve(data.value, e)
            return r.catch(() => undefined)
          })
          return Promise.all(p).then((list) => {
            const success = list.filter(e => Array.isArray(e) && e.length).length
            if (!success) {
              return Promise.reject(new ValidationError(this, data, `No DNS record of type \
${check.dns.join(', ')} found`))
            }
            return Promise.resolve()
          })
        })
    }
    return Promise.resolve()
  }

  punycode(flag?: bool | Reference): this { return this._setFlag('punycode', flag) }
  resolve(flag?: bool | Reference): this { return this._setFlag('resolve', flag) }

  _formatDescriptor() {
    const set = this._setting
    let msg = ''
    if (set.punycode) {
      if (this._isReference('punycode')) {
        msg += `The domain is converted into its ASCII presentation if defined under \
${set.punycode.description}. `
      } else msg += 'The domain is converted to its ASCII presentation. '
    }
    if (set.resolve) {
      if (this._isReference('resolve')) {
        msg += `The domain is resolved into its IP address if defined under \
${set.resolve.description}. `
      } else msg += 'The domain is resolved into its IP address. '
    }
    return msg.length ? `${msg.trim()}\n` : msg
  }

  _formatValidator(data: Data): Promise<void> {
    const check = this._check
    try {
      this._checkBoolean('punycode')
      this._checkBoolean('resolve')
    } catch (err) {
      return Promise.reject(new ValidationError(this, data, err.message))
    }
    // format
    if (!check.punycode) data.value = punycode.toUnicode(data.value)
    if (check.resolve) {
      return import('dns')
        .then(dns => promisify(dns.lookup)(data.value)
          .then((resolved) => {
            data.value = resolved
            return true
          }))
    }
    return Promise.resolve()
  }
}


export default DomainSchema
