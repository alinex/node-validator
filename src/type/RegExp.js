// @flow
import Schema from './Schema'
import ValidationError from '../Error'
import Reference from '../Reference'
import type Data from '../Data'

class RegExpSchema extends Schema {
  constructor(base?: any) {
    super(base)
    // add check rules
    let raw = this._rules.descriptor.pop()
    this._rules.descriptor.push(
      this._typeDescriptor,
      this._lengthDescriptor,
      raw,
    )
    raw = this._rules.validator.pop()
    this._rules.validator.push(
      this._typeValidator,
      this._lengthValidator,
      raw,
    )
  }

  // parse schema

  _typeDescriptor() { // eslint-disable-line class-methods-use-this
    return 'Here a regular expression as RegExp object or in string format is needed.\n'
  }

  _typeValidator(data: Data): Promise<void> {
    if (typeof data.value === 'string' && data.value.match(/^\/.*?\/[gim]*$/)) {
      const parts = data.value.match(/^\/(.*?)\/([gim]*)$/)
      data.value = new RegExp(parts[1], parts[2])
      return Promise.resolve()
    }
    if (typeof data.value === 'object' && data.value instanceof RegExp) {
      return Promise.resolve()
    }
    return Promise.reject(new ValidationError(this, data, `Only a RegExp object or string representation \
is allowed, a ${typeof data.value} is given here`))
  }

  min(limit?: number | Reference): this {
    const set = this._setting
    if (limit) {
      if (!(limit instanceof Reference)) {
        if (set.max && !this._isReference('max') && limit > set.max) {
          throw new Error('Min length can´t be greater than max length')
        }
        if (limit < 0) throw new Error('Matched groups length for min() has to be positive')
      }
      set.min = limit
    } else delete set.min
    return this
  }

  max(limit?: number | Reference): this {
    const set = this._setting
    if (limit) {
      if (!(limit instanceof Reference)) {
        if (set.min && !this._isReference('min') && limit < set.min) {
          throw new Error('Max length can´t be less than min length')
        }
        if (limit < 0) throw new Error('Matched groups length for max() has to be positive')
      }
      set.max = limit
    } else delete set.max
    return this
  }

  length(limit?: number | Reference): this {
    const set = this._setting
    if (limit) {
      if (!(limit instanceof Reference)) {
        if (limit < 0) throw new Error('Length has to be positive')
      }
      set.min = limit
      set.max = limit
    } else {
      delete set.min
      delete set.max
    }
    return this
  }

  _lengthDescriptor() {
    const set = this._setting
    let msg = ''
    if (set.min instanceof Reference) {
      msg += `Minimum number of matched groups depends on ${set.min.description}. `
    }
    if (set.max instanceof Reference) {
      msg += `Maximum number of matched groups depends on ${set.max.description}. `
    }
    if (!this._isReference('min') && !this._isReference('max') && set.min && set.max) {
      msg = set.min === set.max ? `The function has to contain exactly ${set.min} matched groups. `
        : `The function can have between ${set.min} and ${set.max} matched groups. `
    } else if (!this._isReference('min') && set.min) {
      msg = `The function needs at least ${set.min} matched groups. `
    } else if (!this._isReference('max') && set.max) {
      msg = `The function allows up to ${set.min} matched groups. `
    }
    return msg.length ? `${msg.trim()}\n` : msg
  }

  _lengthValidator(data: Data): Promise<void> {
    const check = this._check
    try {
      this._checkNumber('min')
      this._checkNumber('max')
      if (check.max && check.min && check.min > check.max) {
        throw new Error('Min arhuments can´t be greater than max matched groups')
      }
    } catch (err) {
      return Promise.reject(new ValidationError(this, data, err.message))
    }
    // check value
    const num = (new RegExp(`${data.value.toString()}|`)).exec('').length - 1
    // check length
    if (check.min && num < check.min) {
      return Promise.reject(new ValidationError(this, data,
        `The function has ${num} matched groups. \
   This is too less, at least ${check.min} are needed.`))
    }
    if (check.max && num > check.max) {
      return Promise.reject(new ValidationError(this, data,
        `The function has ${num} matched groups. \
   This is too much, not more than ${check.max} are allowed.`))
    }
    return Promise.resolve()
  }
}

export default RegExpSchema
