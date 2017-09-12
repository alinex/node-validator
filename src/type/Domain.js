// @flow
import promisify from 'es6-promisify' // may be removed with node util.promisify later
import util from 'util'

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
    let allow = this._rules.descriptor.pop()
    this._rules.descriptor.push(
      //      this._typeDescriptor,
      allow,
      raw,
    )
    raw = this._rules.validator.pop()
    allow = this._rules.validator.pop()
    this._rules.validator.push(
      //      this._xxxValidator,
      allow,
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
    return Promise.resolve()
  }

  _allowValidator(data: Data): Promise<void> {
    const check = this._check
    this._checkArray('allow')
    this._checkArray('deny')
    // checking
    let denyPriority = 0
    let allowPriority = 0
    const domain = data.value.toLowerCase()
    if (check.deny && check.deny.length) {
      for (const e of check.deny) {
        if (domain === e) {
          denyPriority = 99
          break
        }
        if (domain.endsWith(`.${e}`)) {
          const m = e.match(/\./g)
          const level = m ? m.length + 1 : 1
          if (level > denyPriority) denyPriority = level
        }
      }
    }
    if (check.allow && check.allow.length) {
      for (const e of check.allow) {
        if (domain === e) {
          allowPriority = 99
          break
        }
        if (domain.endsWith(`.${e}`)) {
          const m = e.match(/\./g)
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
}


export default DomainSchema
