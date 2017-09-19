// @flow
import promisify from 'es6-promisify' // may be removed with node util.promisify later
import fs from 'fs'

let format = null // load on demand

const schema = (def: string|Object): Promise<Object> => {
  if (typeof def === 'string') return import(def)
  return Promise.resolve(def)
}

const load = (data: string|Object, def?: string): Promise<any> => {
  if (typeof data === 'string') {
    if (!format) format = require('alinex-format') // eslint-disable-line global-require
    const reader = promisify(fs.readFile)
    const parser = promisify(format.parse)
    return reader(data).then(content => parser(content, def))
  }
  return Promise.resolve(data)
}

const check = (data: string|Object, def: string|Object): Promise<any> => {
  const list = []
  // support promises
  if (def instanceof Promise) list.push(def)
  else list.push(schema(def))
  if (data instanceof Promise) list.push(data)
  else list.push(load(data))
  // validate after load
  return Promise.all(list)
    .then(values => values[0].validate(values[1], typeof data === 'string' ? data : undefined))
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

export default { schema, load, check, transform }
