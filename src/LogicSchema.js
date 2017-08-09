// @flow
import util from 'util'

import Schema from './Schema'
import SchemaError from './SchemaError'
import SchemaData from './SchemaData'

class LogicSchema extends Schema {
  constructor(title?: string, detail?: string) {
    super(title, detail)
    // add check rules
    this._rules.descriptor.push(
      this._logicDescriptor,
    )
    this._rules.validator.push(
      this._logicValidator,
    )
  }

  inspect(depth: number, options: Object): string {
    const newOptions = Object.assign({}, options, {
      depth: options.depth === null ? null : options.depth - 1,
    })
    const padding = ' '.repeat(5)
    const inner = util.inspect(this._setting.logic, newOptions).replace(/\n/g, `\n${padding}`)
    return `${options.stylize(this.constructor.name, 'class')} ${inner} `
  }

  // setup schema

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
    return set.logic.map(e => `${e[0].toUpperCase()} ${e[1].description.replace(/\n/g, '\n  ')}\n`)
      .join('- ')
  }

  _logicValidator(data: SchemaData): Promise<void> {
    const check = this._check
    if (!check.logic) return Promise.resolve()
    // replace Schema.validate(data) ? SchemaData : SchemaError
    let logic = check.logic.slice(0)
    let p = Promise.resolve()
    logic.forEach((v, i) => {
      const [op, schema] = v
      if (op === 'and') {
        p = p.then((last) => {
          // clone last
          if (last instanceof SchemaData) return schema._validate(last.clone)
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
      } else {
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
    p = p.then(() => {
      // reverse reduce and
      let last = 0
      logic.forEach((v, i) => {
        const [op, res] = v
        if (op === 'and') {
          if (res instanceof SchemaData) logic[last][1] = res
          else if (logic[last][1] instanceof SchemaData) logic[last][1] = res
          delete logic[i]
        } else last = i
      })
      logic = logic.filter(e => e)
      // reverse reduce or
      for (const v of logic) {
        if (v[1] instanceof SchemaData) {
          logic[0][1] = v[1]
          break
        }
      }
      // interpret allow/deny
      if (logic[0][0] === 'allow') {
        if (logic[0][1] instanceof SchemaData) data.value = logic[0][1].value
        else throw logic[0][1]
      } else if (logic[0][1] instanceof SchemaData) {
        throw new SchemaError(this, data, 'The element is denied by logic')
      }
    })
    // ok
    return p
  }
}

export default LogicSchema
