// @flow
import promisify from 'es6-promisify' // may be removed with node util.promisify later

import AnySchema from './Any'
import ValidationError from '../Error'
import type Data from '../Data'
import Reference from '../Reference'

// load on demand: dns

class EmailSchema extends AnySchema {
  constructor(base?: any) {
    super(base)
    // add check rules
    let raw = this._rules.descriptor.pop()
    let allow = this._rules.descriptor.pop()
    this._rules.descriptor.push(
      this._typeDescriptor,
      allow,
      this._formatDescriptor,
      raw,
    )
    raw = this._rules.validator.pop()
    allow = this._rules.validator.pop()
    this._rules.validator.push(
      this._typeValidator,
      allow,
      this._formatValidator,
      raw,
    )
  }

  _typeDescriptor() { // eslint-disable-line class-methods-use-this
    return 'It has to be a reasonable email address with optional descriptive part.\n'
  }

  _typeValidator(data: Data): Promise<void> {
    if (typeof data.value !== 'string') {
      return Promise.reject(new ValidationError(this, data, 'A text string is needed.'))
    }
    const match = data.value.match(/^(.*\S)\s+<(.*)>\s*$/)
    const full = (match ? match[2] : data.value).trim()
    if (match) data.value = { name: match[1] }
    else data.value = { name: null }
    const at = full.lastIndexOf('@')
    if (at === -1) data.value.local = full
    else {
      data.value.local = full.substring(0, at)
      data.value.domain = full.substring(at + 1)
    }
    if (!data.value.domain) {
      return Promise.reject(new ValidationError(this, data, 'The email address is missing the server \
part starting with \'@\''))
    }
    if (data.value.local.length > 64) {
      return Promise.reject(new ValidationError(this, data, 'The local mailbox name is too long (64 \
chars max per specification)'))
    }
    return Promise.resolve()
  }

  _allowValidator(data: Data): Promise<void> {
    const check = this._check
    this._checkArray('allow')
    this._checkArray('deny')
    // checking
    let denyPriority = 0
    let allowPriority = 0
    if (check.deny && check.deny.length) {
      const email = `${data.value.local}@${data.value.domain || 'localhost'}`.toLowerCase()
      for (const e of check.deny) {
        const match = e.match(/^(.*\S)\s+<(.*)>\s*$/)
        let full = (match ? match[2] : e).trim().toLowerCase()
        const at = full.lastIndexOf('@')
        let domain = null
        if (at === -1) {
          domain = full
          full = undefined
        } else domain = full.substring(at + 1)
        if (email === full) {
          denyPriority = 99
          break
        }
        if (email.endsWith(`.${domain}`) || email.endsWith(`@${domain}`)) {
          const m = domain.match(/\./g)
          const level = m ? m.length + 1 : 1
          if (level > denyPriority) denyPriority = level
        }
      }
    }
    if (check.allow && check.allow.length) {
      const email = `${data.value.local}@${data.value.domain || 'localhost'}`.toLowerCase()
      for (const e of check.allow) {
        const match = e.match(/^(.*\S)\s+<(.*)>\s*$/)
        let full = (match ? match[2] : e).trim().toLowerCase()
        const at = full.lastIndexOf('@')
        let domain = null
        if (at === -1) {
          domain = full
          full = undefined
        } else domain = full.substring(at + 1)
        if (email === full) {
          allowPriority = 99
          break
        }
        if (email.endsWith(`.${domain}`) || email.endsWith(`@${domain}`)) {
          const m = domain.match(/\./g)
          const level = m ? m.length + 1 : 1
          if (level > allowPriority) allowPriority = level
        }
      }
    }
    if (denyPriority > allowPriority) {
      return Promise.reject(new ValidationError(this, data,
        'Element found in blacklist (denied item).'))
    }
    return Promise.resolve()
  }

  withName(flag?: bool | Reference): this { return this._setFlag('withName', flag) }
  lowercase(flag?: bool | Reference): this { return this._setFlag('lowercase', flag) }

  _formatDescriptor() {
    const set = this._setting
    let msg = ''
    if (set.withName) {
      if (this._isReference('withName')) {
        msg += `The email address may contain a descriptive name if defined under \
${set.withName.description}. `
      } else msg += 'The email address may contain a descriptive name. '
    }
    if (set.lowercase) {
      if (this._isReference('lowercase')) {
        msg += `The email address will be converted to lowercase if defined under \
${set.lowercase.description}. `
      } else msg += 'The email address will be converted to lowercase. '
    }
    return msg.length ? `${msg.trim()}\n` : msg
  }

  _formatValidator(data: Data): Promise<void> {
    const check = this._check
    try {
      this._checkBoolean('withName')
      this._checkBoolean('lowercase')
    } catch (err) {
      return Promise.reject(new ValidationError(this, data, err.message))
    }
    // format
    let email = data.value.local
    if (data.value.domain) email += `@${data.value.domain}`
    if (check.lowercase) email = email.toLowerCase()
    if (check.withName && data.value.name) email = `${data.value.name} <${email}>`
    data.value = email
    return Promise.resolve()
  }
}


export default EmailSchema
