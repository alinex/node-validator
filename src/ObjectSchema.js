// @flow
import util from 'util'

import Schema from './Schema'
import SchemaError from './SchemaError'
import type SchemaData from './SchemaData'
import Reference from './Reference'

class Logic {
  type: string
  key: string
  peers: Array<string>

  constructor(type: string, key?: string, peers: Array<string>) {
    this.type = type
    if (key) this.key = key
    this.peers = peers
  }
}

class ObjectSchema extends Schema {

  constructor(title?: string, detail?: string) {
    super(title, detail)
    //    // init settings
    //    this._keys = new Map()
    //    this._removeUnknown = false
    //    this._keysRequired = new Set()
    //    this._keysForbidden = new Set()
    //    this._logic = []
    // add check rules
    this._rules.descriptor.push(
      this._typeDescriptor,
      this._structureDescriptor,
      this._keysDescriptor,
      this._removeDescriptor,
//      this._keysRequireDescriptor,
//      this._logicDescriptor,
      this._lengthDescriptor,
    )
    this._rules.validator.push(
      this._typeValidator,
      this._structureValidator,
      this._keysValidator,
      this._removeValidator,
//      this._keysRequireValidator,
//      this._logicValidator,
      this._lengthValidator,
    )
  }

  // setup schema

  _typeDescriptor() { // eslint-disable-line class-methods-use-this
    return 'A data object is needed.\n'
  }

  _typeValidator(data: SchemaData): Promise<void> {
    if (typeof data.value !== 'object') {
      return Promise.reject(new SchemaError(this, data, 'A data object is needed.'))
    }
    return Promise.resolve()
  }

  deepen(value?: string | RegExp | Reference): this { return this._setAny('deepen', value) }
  flatten(value?: string | Reference): this { return this._setAny('flatten', value) }

  _structureDescriptor() {
    const set = this._setting
    let msg = ''
    if (set.deepen instanceof Reference) {
      msg += `Key names will be split on ${set.deepen.description}. `
    } else if (set.deepen) {
      msg += `Key names will be split on \
 \`${typeof set.deepen === 'string' ? set.deepen : util.inspect(set.deepen)}\` \
 into deeper structures. `
    }
    if (set.flatten) {
      msg += `Deep structures will be flattened by combining key names using \
 \`${set.flatten}\` as separator. `
    }
    return msg.length ? `${msg.trim()}\n` : msg
  }

  _structureValidator(data: SchemaData): Promise<void> {
    const check = this._check
    try {
      this._checkMatch('deepen')
      this._checkString('flatten')
    } catch (err) {
      return Promise.reject(new SchemaError(this, data, err.message))
    }
    // check value
    if (check.deepen) {
      Object.keys(data.value).forEach((key) => {
        const value = data.value[key]
        const parts = key.split(check.deepen)
        if (parts.length > 1) {
          let obj = data.value
          const last = parts.pop()
          parts.forEach((e) => {
            if (!obj[e]) obj[e] = {}
            obj = obj[e]
          })
          obj[last] = value
          delete data.value[key]
        }
      })
    }
    if (check.flatten) {
      const result = {}
      const separator = check.flatten
      function recurse(cur, prop) { // eslint-disable-line no-inner-declarations
        if (Object(cur) !== cur) {
          result[prop] = cur
        } else if (Array.isArray(cur) && cur.length) {
          for (let i = 0, l = cur.length; i < l; i += 1) recurse(cur[i], `${prop}${separator}${i}`)
        } else if (Object.keys(cur).length) {
          for (const p in cur) {
            if (Object.prototype.hasOwnProperty.call(cur, p)) {
              recurse(cur[p], prop ? `${prop}${separator}${p}` : p)
            }
          }
        } else { // empty
          result[prop] = cur
        }
      }
      recurse(data.value, '')
      data.value = result
    }
    return Promise.resolve()
  }

  key(name?: string | RegExp, check?: Schema): this {
    const set = this._setting
    if (name === undefined) delete set.keys
    else {
      if (!set.keys) set.keys = new Map()
      if (check === undefined) set.keys.delete(name)
      else set.keys.set(name, check)
    }
    return this
  }

  _keysDescriptor() {
    const set = this._setting
    let msg = ''
    if (set.keys) {
      for (const [key, schema] of set.keys) {
        msg += `- \`${typeof key === 'string' ? key : util.inspect(key)}\`: ${schema.description}\n`
      }
      if (msg.length) msg = `The following keys have a special format:\n${msg}\n`
    }
    return msg
  }

  _keysValidator(data: SchemaData): Promise<void> {
    const check = this._check
    try {
      this._checkObject('keys')
    } catch (err) {
      return Promise.reject(new SchemaError(this, data, err.message))
    }
    // check value
    const checks = []
    const keys = []
    const sum = {}
    Object.keys(data.value).forEach((key) => {
      let found = false
      let schema = check.keys[key]
      if (schema) {
        // against defined keys
        checks.push(schema.validate(data.sub(key)))
        keys.push(key)
        found = true
      } else if (Object.keys(check.keys).length > 0) {
        // agains pattern
        for (const k of Object.keys(check.keys)) {
          if (k.match(/^\/([^\\/]|\\.)+\/[gi]*$/)) {
            const parts : Array<string> = k.match(/([^\\/]|\\.)+/g)
            const re = new RegExp(parts[0], (parts[1]: any))
            schema = check.keys[k]
            if (key.match(re)) {
              checks.push(schema.validate(data.sub(key)))
              keys.push(key)
              found = true
              break
            }
          }
        }
      }
      // not specified keep it without check
      if (!found) {
        if (!data.temp.unchecked) data.temp.unchecked = []
        data.temp.unchecked[key] = true
        sum[key] = data.value[key]
      }
    })
    // catch up sub checks
    return Promise.all(checks)
    .catch(err => Promise.reject(err))
    .then((result) => {
      if (result) {
        result.forEach((e: any, i: number) => { sum[keys[i]] = e })
      }
      data.value = sum
      return Promise.resolve()
    })
  }

  removeUnknown(flag?: bool | Reference): this { return this._setFlag('removeUnknown', flag) }

  _removeDescriptor() {
    const set = this._setting
    if (set.removeUnknown instanceof Reference) {
      return `Keys not defined with the rules before will be removed depending on \
${set.removeUnknown.description}.\n`
    }
    if (set.removeUnknown) return 'Keys not defined with the rules before will be removed.\n'
    return ''
  }

  _removeValidator(data: SchemaData): Promise<void> {
    const check = this._check
    try {
      this._checkBoolean('removeUnknown')
    } catch (err) {
      return Promise.reject(new SchemaError(this, data, err.message))
    }
    // check value
    if (check.removeUnknown) {
      for (const key in data.temp.unchecked) if (key) delete data.value[key]
    }
    return Promise.resolve()
  }

  min(value?: number | Reference): this {
    const set = this._setting
    if (value) {
      if (!(value instanceof Reference)) {
        const int = parseInt(value, 10)
        if (int < 0) throw new Error('Length for min() has to be positive')
        if (set.max && !this._isReference('max') && value > set.max) {
          throw new Error('Length for min() should be equal or below max')
        }
      }
      set.min = value
    } else delete set.min
    return this
  }

  max(value?: number | Reference): this {
    const set = this._setting
    if (value) {
      if (!(value instanceof Reference)) {
        const int = parseInt(value, 10)
        if (int <= 0) throw new Error('Length for max() has to be positive')
        if (set.min && !this._isReference('min') && value < set.min) {
          throw new Error('Length for max() should be equal or above min')
        }
      }
      set.max = value
    } else delete set.max
    return this
  }

  length(value?: number | Reference): this {
    const set = this._setting
    if (value) {
      if (!(value instanceof Reference)) {
        const int = parseInt(value, 10)
        if (int <= 0) throw new Error('Length has to be positive')
      }
      set.min = value
      set.max = value
    } else {
      delete set.min
      delete set.max
    }
    return this
  }

  _lengthDescriptor() {
    const set = this._setting
    let msg = ''
    if (set.min && set.max) {
      if (this._isReference('min')) {
        msg += `The object needs at have at least the specified in ${set.min.description} \
number of elements. `
      } else {
        msg += `The object needs at least ${set.min} elements. `
      }
      if (this._isReference('max')) {
        msg += `The object can't have more than specified in ${set.max.description} \
elements. `
      } else {
        msg += `The object allows up to ${set.min} elements. `
      }
      return set.min === set.max ? `The object has to contain exactly ${set.min} elements.\n`
      : `The object needs between ${set.min} and ${set.max} elements.\n`
    }
    return msg.length ? msg.replace(/ $/, '\n') : msg
  }

  _lengthValidator(data: SchemaData): Promise<void> {
    const check = this._check
    try {
      this._checkNumber('min')
      this._checkNumber('max')
    } catch (err) {
      return Promise.reject(new SchemaError(this, data, err.message))
    }
    // check value
    const num = Object.keys(data.value).length
    if (check.min && num < check.min) {
      return Promise.reject(new SchemaError(this, data,
      `The object has a length of ${num} elements. \
 This is too less, at least ${check.min} are needed.`))
    }
    if (check.max && num > check.max) {
      return Promise.reject(new SchemaError(this, data,
      `The object has a length of ${num} elements. \
 This is too much, not more than ${check.max} are allowed.`))
    }
    return Promise.resolve()
  }


//  requiredKeys(...keys: Array<string|Array<string>>): this {
//    // flatten list
//    const list = keys.reduce((acc, val) => acc.concat(val), [])
//    for (const e of list) {
//      if (this._negate) this._keysRequired.delete(e)
//      else if (!this._keysRequired.has(e)) this._keysRequired.add(e)
//    }
//    this._negate = false
//    return this
//  }
//
//  forbiddenKeys(...keys: Array<string|Array<string>>): this {
//    // flatten list
//    const list = keys.reduce((acc, val) => acc.concat(val), [])
//    for (const e of list) {
//      if (this._negate) this._keysForbidden.delete(e)
//      else if (!this._keysForbidden.has(e)) this._keysForbidden.add(e)
//    }
//    this._negate = false
//    return this
//  }
//
//  and(...keys: Array<string|Array<string>>): this {
//    // flatten list
//    const list = keys.reduce((acc, val) => acc.concat(val), [])
//    this._logic.push(new Logic(this._negate ? 'nand' : 'and', undefined, list))
//    this._negate = false
//    return this
//  }
//
//  or(...keys: Array<string|Array<string>>): this {
//    // flatten list
//    const list = keys.reduce((acc, val) => acc.concat(val), [])
//    if (this._negate) {
//      this._negate = false
//      return this.forbiddenKeys(list)
//    }
//    this._logic.push(new Logic('or', undefined, list))
//    return this
//  }
//
//  xor(...keys: Array<string|Array<string>>): this {
//    // flatten list
//    const list = keys.reduce((acc, val) => acc.concat(val), [])
//    if (this._negate) {
//      this._negate = false
//      return this.forbiddenKeys(list)
//    }
//    this._logic.push(new Logic('xor', undefined, list))
//    return this
//  }
//
//  with(key: string, ...peers: Array<string|Array<string>>): this {
//    // flatten list
//    const list = peers.reduce((acc, val) => acc.concat(val), [])
//    this._logic.push(new Logic(this._negate ? 'without' : 'with', key, list))
//    this._negate = false
//    return this
//  }
//
//  get clearLogic(): this {
//    // flatten list
//    this._logic = []
//    this._negate = false // not supported
//    return this
//  }
//
//  // using schema
//
//
//
//
//  _keysRequiredDescriptor() {
//    let msg = ''
//    if (this._keysRequired.size) {
//      const list = Array.from(this._keysRequired)
//      .map(e => `\`${e}\``).join(', ')
//      .replace(/(.*),/, '$1 and')
//      msg += `The keys ${list} are required. `
//    }
//    if (this._keysForbidden.size) {
//      const list = Array.from(this._keysForbidden)
//      .map(e => `\`${e}\``).join(', ')
//      .replace(/(.*),/, '$1 and')
//      msg += `None of the keys ${list} are allowed.\n`
//    }
//    return msg
//  }
//
//  _keysRequiredValidator(data: SchemaData): Promise<void> {
//    const keys = Object.keys(data.value)
//    if (this._keysRequired.size) {
//      for (const check of this._keysRequired) {
//        if (!keys.includes(check)) {
//          return Promise.reject(new SchemaError(this, data,
//            `The key ${check} is missing. `))
//        }
//      }
//    }
//    if (this._keysForbidden.size) {
//      for (const check of this._keysForbidden) {
//        if (keys.includes(check)) {
//          return Promise.reject(new SchemaError(this, data,
//            `The key ${check} is not allowed here. `))
//        }
//      }
//    }
//    return Promise.resolve()
//  }
//
//  _logicDescriptor() {
//    let msg = ''
//    if (this._logic.length) {
//      for (const rule of this._logic) {
//        if (rule.type === 'and') {
//          const list = rule.peers.map(e => `\`${e}\``)
//          .join(', ').replace(/(.*),/, '$1 and')
//          msg += `All or none of the keys ${list} have to be present. `
//        } else if (rule.type === 'nand') {
//          const list = rule.peers.map(e => `\`${e}\``)
//          .join(', ').replace(/(.*),/, '$1 and')
//          msg += `Some but not all of the keys ${list} can be present. `
//        } else if (rule.type === 'or') {
//          const list = rule.peers.map(e => `\`${e}\``)
//          .join(', ').replace(/(.*),/, '$1 and')
//          msg += `At least one of the keys ${list} have to be present. `
//        } else if (rule.type === 'xor') {
//          const list = rule.peers.map(e => `\`${e}\``)
//          .join(', ').replace(/(.*),/, '$1 and')
//          msg += `Exactly one of the keys ${list} have to be present. `
//        } else if (rule.type === 'with') {
//          const list = rule.peers.map(e => `\`${e}\``)
//          .join(', ').replace(/(.*),/, '$1 and')
//          msg += `If \`${rule.key}\` is set the keys ${list} have to be present, too. `
//        } else if (rule.type === 'without') {
//          const list = rule.peers.map(e => `\`${e}\``)
//          .join(', ').replace(/(.*),/, '$1 and')
//          msg += `If \`${rule.key}\` is set the keys ${list} are forbidden. `
//        }
//      }
//    }
//    return msg.length ? `${msg.trim()}\n` : msg
//  }
//
//  _logicValidator(data: SchemaData): Promise<void> {
//    if (this._logic.length) {
//      const keys = Object.keys(data.value)
//      for (const rule of this._logic) {
//        if (rule.type === 'and') {
//          const contained = rule.peers.filter(e => keys.includes(e))
//          // fail if one but not all
//          if (contained.length > 0 && contained.length !== rule.peers.length) {
//            const list = rule.peers.map(e => `\`${e}\``)
//            .join(', ').replace(/(.*),/, '$1 and')
//            return Promise.reject(new SchemaError(this, data,
//              `All or none of the keys ${list} have to be present \
// but there are only ${contained.length} of the ${rule.peers.length} keys present.`))
//          }
//        } else if (rule.type === 'nand') {
//          const contained = rule.peers.filter(e => keys.includes(e))
//          // fail if all
//          if (contained.length === rule.peers.length) {
//            const list = rule.peers.map(e => `\`${e}\``)
//            .join(', ').replace(/(.*),/, '$1 and')
//            return Promise.reject(new SchemaError(this, data,
//              `Some but not all of the keys ${list} can be present but all are set.`))
//          }
//        } else if (rule.type === 'or') {
//          const contained = rule.peers.filter(e => keys.includes(e))
//          // fail if not at least one
//          if (!contained.length) {
//            const list = rule.peers.map(e => `\`${e}\``)
//            .join(', ').replace(/(.*),/, '$1 and')
//            return Promise.reject(new SchemaError(this, data,
//              `At least one of the keys ${list} have to be present but none are set.`))
//          }
//        } else if (rule.type === 'xor') {
//          const contained = rule.peers.filter(e => keys.includes(e))
//          // fail if not exactly one
//          if (contained.length !== 1) {
//            const list = rule.peers.map(e => `\`${e}\``)
//            .join(', ').replace(/(.*),/, '$1 and')
//            return Promise.reject(new SchemaError(this, data,
//              `Exactly one of the keys ${list} have to be present \
// but ${contained.length} are set.`))
//          }
//        } else if (rule.type === 'with') {
//          const contained = rule.peers.filter(e => keys.includes(e))
//          // fail if key is present but not all peers
//          if (keys.includes(rule.key) && contained.length !== rule.peers.length) {
//            const list = rule.peers.map(e => `\`${e}\``)
//            .join(', ').replace(/(.*),/, '$1 and')
//            return Promise.reject(new SchemaError(this, data,
//              `If \`${rule.key}\` is set the keys ${list} have to be present \
// but there are only ${contained.length} of the ${rule.peers.length} keys present.`))
//          }
//        } else if (rule.type === 'without') {
//          const contained = rule.peers.filter(e => keys.includes(e))
//          // fail if key is present and at least one peer
//          if (keys.includes(rule.key) && contained.length) {
//            const list = rule.peers.map(e => `\`${e}\``)
//            .join(', ').replace(/(.*),/, '$1 and')
//            return Promise.reject(new SchemaError(this, data,
//              `If \`${rule.key}\` is set the keys ${list} are forbidden \
// but ${contained.length} keys are set.`))
//          }
//        }
//      }
//    }
//    return Promise.resolve()
//  }

}

export default ObjectSchema