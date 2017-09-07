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
      raw,
    )
    raw = this._rules.validator.pop()
    allow = this._rules.validator.pop()
    this._rules.validator.push(
      this._typeValidator,
      allow,
      raw,
    )
  }

  lookup(flag?: bool | Reference): this { return this._setFlag('lookup', flag) }

  _typeDescriptor() { // eslint-disable-line class-methods-use-this
    return 'It has to be a text string.\n'
  }

  _typeValidator(data: Data): Promise<void> {
    if (typeof data.value !== 'string') {
      return Promise.reject(new ValidationError(this, data, 'A text string is needed.'))
    }
    return Promise.resolve()
  }
}


export default EmailSchema
