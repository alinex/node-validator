// @flow
import promisify from 'es6-promisify' // may be removed with node util.promisify later
import fs from 'fs'
import os from 'os'
import path from 'path'
import glob from 'glob'
import util from 'alinex-util'
import Debug from 'debug'

const debug = Debug('validator')

function resolveSearch(data: string|Array<string>, search: Array<string>): Array<string> {
  const dataList = []
  for (const e of (typeof data === 'string' ? [data] : data)) {
    for (const t of search) dataList.push(`${t}${e}`)
  }
  return dataList
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

const write = (data: Object, file: string): Promise<any> => {
  const writer = promisify(fs.writeFile)
  return writer(file, JSON.stringify(data))
}

const schema = (def: string|Object): Promise<Object> => {
  if (typeof def === 'string') return import(def)
  return Promise.resolve(def)
}

class Validator {
  search: Array<string>

  constructor() {
    this.search = ['']
  }

  searchApp(name: string, sub: string = 'config'): Validator {
    const gpath = sub === 'config' ? `/etc/${name}/` : `/var/lib/${name}/${sub}/`
    const upath = `${os.homedir()}/.${name}/${sub}/`
    this.search.push(gpath)
    this.search.push(upath)
    debug(`Search path for ${sub} is set to ${gpath} and ${upath}`)
    return this
  }

  schema(def: string|Object): Promise<Object> { // eslint-disable-line
    return schema(def)
  }

  load(data: string|Array<string>): Promise<any> {
    debug(`search for data files at ${util.inspect(data)}`)
    // extend search for relative paths
    const dataList = resolveSearch(data, this.search)
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

  check(
    data: string|Array<string>|Promise<any>,
    def: string|Object|Promise<Object>,
  ): Promise<any> {
    const list = []
    // support promises
    if (def instanceof Promise) list.push(def)
    else list.push(schema(def))
    if (data instanceof Promise) list.push(data)
    else list.push(this.load(data))
    // validate after load
    return Promise.all(list)
      .then(values => (values[0]: any).validate(values[1], typeof data === 'string' ? data : undefined))
  }

  transform(
    data: string|Array<string>,
    def: string|Object|Promise<Object>,
    file: string, opt?: Object,
  ): Promise<any> {
    // check date
    const stat = promisify(fs.stat)
    let p = Promise.resolve()
    if (!(opt && opt.force)) {
      // extend search for relative paths
      const dataList = resolveSearch(data, this.search)
      // check against others
      const list = [def, file].map(e => stat(e).catch(() => false))
      // get newest file date
      list.unshift(Promise.all(dataList.map(e => stat(e).catch(() => false)))
        .then(res => res.reduce((acc, val) => (!acc || val.mtime > acc ? val : acc), false)))
      p = p
        .then(() => Promise.all(list))
        .then((res) => {
          if (!res[0] || !res[2] || res[0].mtime > res[2].mtime) return Promise.resolve()
          if (def instanceof Promise || !res[1] || res[1].mtime > res[2].mtime) return Promise.resolve()
          return Promise.reject()
        })
    }
    // combine check and write
    return p
      .then(() => this.check(data, def))
      .then(result => write(result, file).then(() => result))
      .catch(() => {
        debug('JSON file found and newer than data and definition')
        return Promise.reject(new Error('No need to create configuration again because it\'s up to date.'))
      })
  }
}

export default Validator
