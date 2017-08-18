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

const write = (file: string): Promise<any> => {
}

const transform = (data: string|Object, def: string|Object, file: string): Promise<any> => {
}

export default { schema, load, check, transform }
