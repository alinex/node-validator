// @flow
import promisify from 'es6-promisify' // may be removed with node util.promisify later


let format = null // load on demand

const schema = (def: string|Object): Promise<Object> => {
  if (typeof def === 'string') return import(def)
  return Promise.resolve(def)
}

const load = (data: string|Object, def?: string): Promise<any> => {
  if (typeof data === 'string') {
    if (!format) format = require('alinex-format') // eslint-disable-line global-require
    const parser = promisify(format.parse)
    return parser(data, def)
  }
  return Promise.resolve(data)
}

const check = (data: string|Object, def: string|Object): Promise<any> => {
  const list = [schema(def)]
  // support promises
  if (def instanceof Promise) list.push(def)
  else list.push(schema(def))
  if (data instanceof Promise) list.push(data)
  else list.push(load(data))
  // validate after load
  return Promise.all(list)
    .then((values) => {
      values[0].validate(values[1], typeof data === 'string' ? data : undefined)
    })
}

const write = () => {
}

const transform = () => {
}

export default { schema, load, check, transform }
