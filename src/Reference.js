// @flow
// import URL from 'url'
import util from 'alinex-util'
import childProcess from 'child_process'
import promisify from 'es6-promisify' // may be removed with node util.promisify later

import SchemaData from './SchemaData'

const exec = promisify(childProcess.exec)

function sourceFunction(data: any): any {
  return typeof data === 'function' ? data() : data
}

function sourceCommand(data: any): any {
  if (typeof data !== 'string' || !util.string.starts(data, 'exec://')) return data
  return exec(data.substring(7))
}

function sourceSsh(data: any): any {
  if (typeof data !== 'string' || !util.string.starts(data, 'ssh://')) return data
  return 'xxx' // new URL(data)
}

function sourceFile(data: any): any {
  if (typeof data !== 'string' || !util.string.starts(data, 'file://')) return data
  return 'xxx'
}

function sourceWeb(data: any): any {
  if (typeof data !== 'string' || !data.match(/https?:\/\//)) return data
  return 'xxx'
}

const accessor = {
  path: (data: any, def: string): any => {
    // work on SchemaData
    if (data instanceof SchemaData) {
      // back references
      while (def[0] === '/' || def[0] === '.') {
        if (def[0] === '/') {
          def = def.substring(1)
          data = data.root
        } else if (util.string.starts(def, '../')) {
          def = def.substring(3)
          data = data.parent
        }
      }
      data = data.value
    }
    // work on other data structures
    def = def.replace(/^(\.{,2}\/)+/, '') // no initial back references
    return util.object.path(data, def)
  },
}

// range
// search
// split
// match
// parse
// join
// filter
// addRef
// fn
// sort


class Reference {

  base: any
  _raw: bool
  access: Array<Array<any>>

  // direct object
  // file
  // web
  // command
  // fn


  constructor(base?: any) {
    if (base) this.base = base
    this.access = []
    this._raw = false
  }

  inspect(depth: number, options: Object): string {
    const newOptions = Object.assign({}, options, {
      depth: options.depth === null ? null : options.depth - 1,
    })
    const padding = ' '.repeat(5)
    const base = this.base ? util.inspect(this.base, newOptions).replace(/\n/g, `\n${padding}`)
    : 'SchemaData'
    const inner = this.access.map(e => util.inspect(e, newOptions).replace(/\n/g, `\n${padding}`))
    inner.unshift(base)
    return `${options.stylize(this.constructor.name, 'class')} ${inner.join(' ➞ ')} `
  }

  raw(flag: bool = true): this {
    this._raw = flag
    return this
  }

  path(def: string): this {
    def = def.replace(/\/\.\//g, '/').replace(/^\.?\//, '')
    this.access.push(['path', def])
    return this
  }

  get description(): string {
    let msg = `reference at ${util.inspect(this.base)}`
    if (this.access.length) msg += ` -> ${this.access.join(' -> ')}`
    return msg
  }

  resolve(pos: any): Promise<any> {
    // get base data structure
    let p = Promise.resolve(this.base || pos)
    .then(data => sourceFunction(data))
    .then(data => sourceCommand(data))
    .then(data => sourceSsh(data))
    .then(data => sourceFile(data))
    .then(data => sourceWeb(data))
    // run rules seriously
    this.access.forEach(([fn, def]) => { p = p.then(data => accessor[fn](data, def)) })
    return p.then(data => (data instanceof SchemaData ? data.value : data))
    .catch(err => (err instanceof Error ? Promise.reject(err) : err))
  }

}


export default Reference
