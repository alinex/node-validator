// @flow
import Schema from './Schema'
import ValidationError from '../Error'
import type Data from '../Data'
import Reference from '../Reference'

class FunctionSchema extends Schema {
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
    return 'Here a function is needed.\n'
  }

  _typeValidator(data: Data): Promise<void> {
    if (typeof data.value !== 'function') {
      return Promise.reject(new ValidationError(this, data, `Only a function is allowed, a \
${typeof data.value} is given here`))
    }
    return Promise.resolve()
  }

  min(limit?: number | Reference): this {
    const set = this._setting
    if (limit) {
      if (!(limit instanceof Reference)) {
        if (set.max && !this._isReference('max') && limit > set.max) {
          throw new Error('Min length can´t be greater than max length')
        }
        if (limit < 0) throw new Error('Argument length for min() has to be positive')
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
        if (limit < 0) throw new Error('Argument length for max() has to be positive')
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
      msg += `Minimum number of arguments depends on ${set.min.description}. `
    }
    if (set.max instanceof Reference) {
      msg += `Maximum number of arguments depends on ${set.max.description}. `
    }
    if (!this._isReference('min') && !this._isReference('max') && set.min && set.max) {
      msg = set.min === set.max ? `The function has to contain exactly ${set.min} arguments. `
        : `The function can have between ${set.min} and ${set.max} arguments. `
    } else if (!this._isReference('min') && set.min) {
      msg = `The function needs at least ${set.min} arguments. `
    } else if (!this._isReference('max') && set.max) {
      msg = `The function allows up to ${set.min} arguments. `
    }
    return msg.length ? `${msg.trim()}\n` : msg
  }

  _lengthValidator(data: Data): Promise<void> {
    const check = this._check
    try {
      this._checkNumber('min')
      this._checkNumber('max')
      if (check.max && check.min && check.min > check.max) {
        throw new Error('Min arhuments can´t be greater than max arguments')
      }
    } catch (err) {
      return Promise.reject(new ValidationError(this, data, err.message))
    }
    // check value
    const num = data.value.length
    // check length
    if (check.min && num < check.min) {
      return Promise.reject(new ValidationError(this, data,
        `The function has ${num} arguments. \
 This is too less, at least ${check.min} are needed.`))
    }
    if (check.max && num > check.max) {
      return Promise.reject(new ValidationError(this, data,
        `The function has ${num} arguments. \
 This is too much, not more than ${check.max} are allowed.`))
    }
    return Promise.resolve()
  }
}

export default FunctionSchema
