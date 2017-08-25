// @flow
import util from 'util'

import Schema from './Schema'
import ValidationError from '../Error'
import Data from '../Data'

class LogicSchema extends Schema {
  constructor(base?: any) {
    super(base)
    // add check rules
    let raw = this._rules.descriptor.pop()
    //    this.rules = // remove rule #1 with required
    this._rules.descriptor.push(
      this._logicDescriptor,
      raw,
    )
    raw = this._rules.validator.pop()
    this._rules.validator.push(
      this._logicValidator,
      raw,
    )
  }

  required(): this { return this._setError('required') }
  forbidden(): this { return this._setError('forbidden') }

  inspect(depth: number, options: Object): string {
    const newOptions = Object.assign({}, options, {
      depth: options.depth === null ? null : options.depth - 1,
    })
    const padding = ' '.repeat(5)
    const inner = util.inspect(this._setting.logic, newOptions).replace(/\n/g, `\n${padding}`)
    return `${options.stylize(this.constructor.name, 'class')} ${inner} `
  }

  // setup schema

  if(schema: Schema): this {
    const set = this._setting
    if (set.logic) throw new Error(`Logic is already started using ${set.logic[0][0]}`)
    set.logic = []
    set.logic.push(['if', schema])
    return this
  }

  then(schema: Schema): this {
    const set = this._setting
    if (!set.logic) throw new Error('Logic is not defined use `if()` first')
    if (set.logic[0][0] !== 'if') {
      throw new Error('Logic is not defined as `if()`, only `and` and `or` are allowed here')
    }
    if (set.logic[1]) throw new Error('Then condition in logic is already set')
    set.logic[1] = ['then', schema]
    return this
  }

  else(schema: Schema): this {
    const set = this._setting
    if (!set.logic) throw new Error('Logic is not defined use `if()` first')
    if (set.logic[0][0] !== 'if') {
      throw new Error('Logic is not defined as `if()`, only `and` and `or` are allowed here')
    }
    if (set.logic[2]) throw new Error('Then condition in logic is already set')
    set.logic[2] = ['else', schema]
    return this
  }

  allow(schema: Schema): this {
    const set = this._setting
    if (set.logic) throw new Error(`Logic is already started using ${set.logic[0][0]}`)
    set.logic = []
    set.logic.push(['allow', schema])
    return this
  }

  deny(schema: Schema): this {
    const set = this._setting
    if (set.logic) throw new Error(`Logic is already started using ${set.logic[0][0]}`)
    set.logic = []
    set.logic.push(['deny', schema])
    return this
  }

  and(schema: Schema): this {
    const set = this._setting
    if (!set.logic) throw new Error('Logic is not defined use `allow()` or `deny()` first')
    set.logic.push(['and', schema])
    return this
  }

  or(schema: Schema): this {
    const set = this._setting
    if (!set.logic) throw new Error('Logic is not defined use `allow()` or `deny()` first')
    set.logic.push(['or', schema])
    return this
  }

  _logicDescriptor() {
    const set = this._setting
    if (!set.logic) return ''
    const msg = 'The validation depends on the following logic:\n'
    return msg + set.logic.map(e => `- **${e[0].toUpperCase()}**: ${e[1].description.replace(/\n/g, '\n  ')}\n`)
      .join('')
  }

  _logicValidator(data: Data): Promise<void> {
    const check = this._check
    if (!check.logic) return Promise.resolve()
    let logic = check.logic.slice(0) // clone
    // conditionals
    if (logic[0][0] === 'if') {
      // check if/then/else
      return logic[0][1]._validate(data.clone)
        .then(() => (logic[1] ? logic[1][1]._validate(data) : data))
        .catch(() => (logic[2] ? logic[2][1]._validate(data) : data))
    }
    // replace Schema.validate(data) ? Data : ValidationError
    let p = Promise.resolve()
    logic.forEach((v, i) => {
      const [op, schema] = v
      if (op === 'and') {
        p = p.then((last) => { // last comes from allow, deny...
          // clone last
          if (last instanceof Data) return schema._validate(last.clone)
          return undefined
        })
          .then((last) => {
            logic[i][1] = last
            return last
          })
          .catch((err) => {
            logic[i][1] = err
            return undefined
          })
      } else { // allow, deny, or
        p = p.then(() => schema._validate(data.clone))
          .then((last) => {
            logic[i][1] = last
            return last
          })
          .catch((err) => {
            logic[i][1] = err
            return undefined
          })
      }
    })
    // reverse reduce logic operators
    p = p.then(() => {
      // reverse reduce and
      let last = 0
      logic.forEach((v, i) => {
        const [op, res] = v
        if (op === 'and') {
          if (res instanceof Data) logic[last][1] = res
          else if (logic[last][1] instanceof Data) logic[last][1] = res
          delete logic[i]
        } else last = i
      })
      logic = logic.filter(e => e)
      // reverse reduce or
      for (const v of logic) {
        if (v[1] instanceof Data) {
          logic[0][1] = v[1]
          break
        }
      }
      // interpret allow/deny
      if (logic[0][0] === 'allow') {
        if (logic[0][1] instanceof Data) data.value = logic[0][1].value
        else throw logic[0][1]
      } else if (logic[0][1] instanceof Data) {
        throw new ValidationError(this, data, 'The element is denied by logic')
      }
    })
    // ok
    return p
  }
}

export default LogicSchema
