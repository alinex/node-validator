// @flow
// import URL from 'url'
import util from 'alinex-util'
import childProcess from 'child_process'
import promisify from 'es6-promisify' // may be removed with node util.promisify later
import fs from 'fs'
import request from 'request-promise-native'

import SchemaData from './SchemaData'

const exec = promisify(childProcess.exec)
const readFile = promisify(fs.readFile)

function sourceFunction(data: any): any {
  return typeof data === 'function' ? data() : data
}

function sourceEnvironment(data: any): any {
  if (typeof data !== 'string' || !util.string.starts(data, 'env://')) return data
  return process.env[data.substring(6)]
}

function sourceCommand(data: any): any {
  if (typeof data !== 'string' || !util.string.starts(data, 'exec://')) return data
  return exec(data.substring(7))
}

function sourceSsh(data: any): any {
  if (typeof data !== 'string' || !util.string.starts(data, 'ssh://')) return data
  return 'xxx' // new URL(data)
//   var Client = require('ssh2').Client;
//
// var conn = new Client();
// conn.on('ready', function() {
//   console.log('Client :: ready');
//   conn.exec('uptime', function(err, stream) {
//     if (err) throw err;
//     stream.on('close', function(code, signal) {
//       console.log('Stream :: close :: code: ' + code + ', signal: ' + signal);
//       conn.end();
//     }).on('data', function(data) {
//       console.log('STDOUT: ' + data);
//     }).stderr.on('data', function(data) {
//       console.log('STDERR: ' + data);
//     });
//   });
// }).connect({
//   host: '192.168.100.100',
//   port: 22,
//   username: 'frylock',
//   privateKey: require('fs').readFileSync('/here/is/my/key')
// });
}

function sourceFile(data: any): any {
  if (typeof data !== 'string' || !util.string.starts(data, 'file://')) return data
  return readFile(data.substring(7), 'utf8')
}

function sourceWeb(data: any): any {
  if (typeof data !== 'string' || !data.match(/https?:\/\//)) return data
  return request(data)
}

const accessor = {

  path: (data: any, def: string): any => {
    if (typeof data !== 'object') return data
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
    def = def.replace(/[^/]+\/\.\.\//g, '').replace(/^(\.{,2}\/)+/, '')
    return util.object.pathSearch(data, def)
  },

  keys: (data: any): any => {
    if (typeof data !== 'object') return data
    return Object.keys(data)
  },

  values: (data: any): any => {
    if (typeof data !== 'object') return data
    return Object.values(data)
  },

  trim: (data: any): any => {
    if (typeof data === 'string') return data.trim()
    if (Array.isArray(data)) return data.map(e => accessor.trim(e))
    if (typeof data === 'object') {
      const obj = {}
      for (const key of Object.keys(data)) obj[key] = accessor.trim(data[key])
      return obj
    }
    return data
  },

  split: (data: any, def: Array<string|RegExp>): any => {
    if (typeof data === 'string') {
      data = data.split(def[0])
      if (def[1]) data = data.map(e => e.split(def[1]))
      if (def[2]) data = data.map(e => e.map(f => f.split(def[2])))
      return data
    }
    if (Array.isArray(data)) return data.map(e => accessor.split(e, def))
    if (typeof data === 'object') {
      const obj = {}
      for (const key of Object.keys(data)) obj[key] = accessor.split(data[key], def)
      return obj
    }
    return data
  },

  join: (data: any, def: Array<string|RegExp>): any => {
    if (typeof data === 'string') return data
    if (Array.isArray(data)) {
      if (def[2]) {
        data = data.map(e => (Array.isArray(e)
        ? e.map(f => (Array.isArray(f) ? f.join(def[2]) : f)) : e))
      }
      if (def[1]) data = data.map(e => (Array.isArray(e) ? e.join(def[1]) : e))
      return data.join(def[0])
    }
    if (typeof data === 'object') {
      const obj = {}
      for (const key of Object.keys(data)) obj[key] = accessor.join(data[key], def)
      return obj
    }
    return data
  },

  match: (data: any, def: RegExp): any => {
    if (typeof data === 'string') return data.match(def)
    if (Array.isArray(data)) return data.map(e => accessor.match(e, def))
    if (typeof data === 'object') {
      const obj = {}
      for (const key of Object.keys(data)) obj[key] = accessor.match(data[key], def)
      return obj
    }
    return data
  },

}

// range
// search
// match
// parse
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

  keys(): this {
    this.access.push(['keys', true])
    return this
  }

  values(): this {
    this.access.push(['values', true])
    return this
  }

  trim(): this {
    this.access.push(['trim', true])
    return this
  }

  split(...def: Array<string|RegExp>): this {
    if (!def.length) def = ['\n']
    this.access.push(['split', def])
    return this
  }

  join(...def: Array<string>): this {
    if (!def.length) def = ['\n']
    this.access.push(['join', def])
    return this
  }

  match(def: RegExp): this {
    this.access.push(['match', def])
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
    .then(data => sourceEnvironment(data))
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
