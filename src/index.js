// @flow
import promisify from 'es6-promisify' // may be removed with node util.promisify later
import fs from 'fs'
import os from 'os'
import path from 'path'
import glob from 'glob'
import util from 'alinex-util'
import Debug from 'debug'

const debug = Debug('validator')

const schema = (def: string|Object): Promise<Object> => {
  if (typeof def === 'string') return import(def)
  return Promise.resolve(def)
}

function sharedStart(array) {
  const A = array.concat().sort()
  const a1 = A[0]
  const a2 = A[A.length - 1]
  const L = a1.length
  let i = 0
  while (i < L && a1.charAt(i) === a2.charAt(i)) i += 1
  return a1.substring(0, i)
}

const search = ['']
const searchApp = (name: string): void => {
  search.push(`/etc/${name}/`)
  search.push(`${os.homedir()}/.${name}/`)
}

const load = (data: string|Array<string>): Promise<any> => {
  debug(`search for data files at ${util.inspect(data)}`)
  // extend search for relative paths
  // const dataList = typeof data === 'string' ? [data] : data
  const dataList = []
  for (const e of (typeof data === 'string' ? [data] : data)) {
    for (const t of search) dataList.push(`${t}${e}`)
  }
  // search and load
  return import('alinex-format')
    .then((format) => {
      const reader = promisify(fs.readFile)
      const parser = promisify(format.parse)
      const searchGlob = promisify(glob)
      return Promise.all(dataList.map(e => searchGlob(e)))
        .then(res => res.reduce((acc, val) => acc.concat(val), []))
      //      return search(data)
        .then((files) => {
          for (const f of files) debug(`found data file at ${f}`)
          return files
        })
        .then((files) => {
          const base = sharedStart(files.map(e => path.dirname(e)))
          return Promise.all(files.map(file => reader(file)
            .then(content => parser(content))
            .then((content) => {
              const dir = path.dirname(file).substr(base.length + 1)
              if (dir) {
                for (const e of dir.split('/')) {
                  const obj = {}
                  obj[e] = content
                  content = obj
                }
              }
              return content
            })))
        })
        .then(list => list.reduce((acc, val) => util.extend(acc, val), {}))
    })
}

const check = (data: string|Object, def: string|Object): Promise<any> => {
  const list = []
  // support promises
  if (def instanceof Promise) list.push(def)
  else list.push(schema(def))
  if (data instanceof Promise) list.push(data)
  else list.push(data)
  // validate after load
  return Promise.all(list)
    .then(values => (values[0]: any).validate(values[1], typeof data === 'string' ? data : undefined))
}

const write = (data: Object, file: string): Promise<any> => {
  const writer = promisify(fs.writeFile)
  return writer(file, JSON.stringify(data))
}

const transform = (data: string|Object, def: string|Object, file: string, opt?: Object): Promise<any> => {
  // check date
  const stat = promisify(fs.stat)
  let p = Promise.resolve()
  if (typeof data === 'string' && typeof def === 'string' && !(opt && opt.force)) {
    const list = [data, def, file].map(e => stat(e).catch(() => false))
    p = p
      .then(() => Promise.all(list))
      .then(res => ((res[0] && res[1] && res[2] && res[0].mtime < res[2].mtime && res[1].mtime < res[2].mtime)
        ? Promise.reject() : Promise.resolve()))
  }
  // combine check and write
  return p
    .then(() => check(data, def))
    .then(result => write(result, file))
    .catch(() => Promise.reject(new Error('No need to create configuration again because it\'s up to date.')))
}

export default { schema, search, searchApp, load, check, transform }
