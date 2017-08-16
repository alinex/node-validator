// @flow

const schema = (data: string|Object): Promise<Object> => {
  if (typeof data === 'string') return import(data)
  return Promise.resolve(data)
}

const load = () => {
}

const validate = () => {
}

const write = () => {
}

const check = () => {
}

const transform = () => {
}

export default { schema, check, transform }
