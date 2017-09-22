// @flow
import promisify from 'es6-promisify' // may be removed with node util.promisify later
import url from 'url'
import path from 'path'
import fs from 'fs'
import minimatch from 'minimatch'
// load on demand: request-promise-native, dns, net

import StringSchema from './String'
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
      this._baseDescriptor,
      allow,
      //      this._existsDescriptor,
      this._resolveDescriptor,
      raw,
    )
    raw = this._rules.validator.pop()
    allow = this._rules.validator.pop()
    this._rules.validator.push(
      this._baseValidator,
      allow,
      //      this._existsValidator,
      this._resolveValidator,
      raw,
    )
  }

  stripEmpty(): this { return this._setError('stripEmpty') }
  truncate(): this { return this._setError('truncate') }
  pad(): this { return this._setError('pad') }

  _typeDescriptor() { // eslint-disable-line class-methods-use-this
    return 'It has to be a valid file or directory location.\n'
  }

  baseDir(base?: string | Reference): this { return this._setAny('baseDir', base) }

  _baseDescriptor() {
    const set = this._setting
    let msg = ''
    if (set.base) {
      if (this._isReference('baseDir')) {
        msg += `If a relative path is given it will be resolved from the location defined under \
${set.baseDir.description}. `
      } else msg += `If a relative path is given it will be resolved from ${set.baseDir}. `
    }
    return msg.length ? `${msg.trim()}\n` : msg
  }

  _baseValidator(data: Data): Promise<void> {
    const check = this._check
    try {
      this._checkString('baseDir')
    } catch (err) {
      return Promise.reject(new ValidationError(this, data, err.message))
    }
    // resolve
    if (check.baseDir) data.temp.resolved = path.resolve(check.baseDir, data.value)
    else data.temp.resolved = path.resolve(data.value)
    return Promise.resolve()
  }

  _allowValidator(data: Data): Promise<void> {
    const check = this._check
    this._checkArray('allow')
    this._checkArray('deny')
    // reject if marked as invalid
    if (check.deny && check.deny.length && check.deny
      .filter(e => minimatch(data.value, e)).length) {
      return Promise.reject(new ValidationError(this, data,
        'Element found in blacklist (denyed item).'))
    }
    // reject if valid is set but not included
    if (check.allow && check.allow.length && check.allow
      .filter(e => minimatch(data.value, e)).length === 0) {
      return Promise.reject(new ValidationError(this, data,
        'Element not in whitelist (allowed item).'))
    }
    // ok
    return Promise.resolve()
  }

  exists(flag?: bool | Reference): this { return this._setFlag('exists', flag) }
  readable(flag?: bool | Reference): this { return this._setFlag('readable', flag) }
  writable(flag?: bool | Reference): this { return this._setFlag('writable', flag) }

  _existsDescriptor() {
    const set = this._setting
    let msg = ''
    if (set.writable) {
      if (this._isReference('writable')) {
        msg += `The file has to be writable if defined under ${set.writable.description}. `
      } else msg += 'The file has to be writable. '
    } else if (set.readable) {
      if (this._isReference('readable')) {
        msg += `The file has to be readable if defined under ${set.readable.description}. `
      } else msg += 'The file has to be readable. '
    } else if (set.exists) {
      if (this._isReference('exists')) {
        msg += `The file has to exist if defined under ${set.exists.description}. `
      } else msg += 'The file has to exist. '
    }
    return msg.length ? `${msg.trim()}\n` : msg
  }

  _existsValidator(data: Data): Promise<void> {
    const check = this._check
    try {
      this._checkBoolean('exists')
      this._checkBoolean('readable')
      this._checkBoolean('writable')
    } catch (err) {
      return Promise.reject(new ValidationError(this, data, err.message))
    }
    // format
    let p = Promise.resolve()
    if (check.readable) p = p.then(() => promisify(fs.access)(data.temp.location, fs.R_OK))
    else if (check.writable) p = p.then(() => promisify(fs.access)(data.temp.location, fs.W_OK))
    else if (check.exists) p = p.then(() => promisify(fs.access)(data.temp.location, fs.F_OK))
    return p
  }

  resolve(flag?: bool | Reference): this { return this._setFlag('resolve', flag) }

  _resolveDescriptor() {
    const set = this._setting
    let msg = ''
    if (set.resolve) {
      if (this._isReference('resolve')) {
        msg += `A relative address will be set to it's absolute location if set under \
${set.resolve.description}. `
      } else msg += 'A relative address will be set to it\'s absolute location. '
    }
    return msg.length ? `${msg.trim()}\n` : msg
  }

  _resolveValidator(data: Data): Promise<void> {
    const check = this._check
    try {
      this._checkBoolean('resolve')
    } catch (err) {
      return Promise.reject(new ValidationError(this, data, err.message))
    }
    // format
    if (check.resolve) data.value = data.temp.resolved
    return Promise.resolve()
  }
}


export default FileSchema
