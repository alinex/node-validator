// @flow
import chai from 'chai'
import chaiAsPromised from 'chai-as-promised'

import debug from './debug'
import type Schema from '../../src/type/Schema'
import type Reference from '../../src/Reference'
import Data from '../../src/Data'

chai.use(chaiAsPromised)
const { expect } = chai

function validateOk(schema: Schema, data: any, cb?: Function): Promise<any> {
  debug(schema, schema.constructor.name)
  debug(new Data(data), schema.constructor.name)
  const res = schema.validate(data)
  debug(res, schema.constructor.name)
  return expect(res).to.be.fulfilled
    .then(() => res.then((e) => {
      debug(schema._check, schema.constructor.name, 'Used checks')
      if (cb) return cb(e)
      return undefined
    }))
}

function validateFail(schema: Schema, data: any, cb?: Function): Promise<any> {
  debug(schema, schema.constructor.name)
  debug(new Data(data), schema.constructor.name)
  const res = schema.validate(data)
  debug(res, schema.constructor.name)
  return expect(res).to.be.rejectedWith(Error)
    .then(() => res.catch((e) => {
      debug(schema._check, schema.constructor.name, 'Used checks')
      if (cb) return cb(e)
      return undefined
    }))
}

function description(schema: Schema) {
  debug(schema, schema.constructor.name)
  const msg = schema.description
  debug(msg, schema.constructor.name)
  expect(msg).to.be.a('string')
  return msg
}

function reference(ref: Reference, pos?: any, cb?: Function): Promise<any> {
  debug(ref, ref.constructor.name)
  const res = ref.resolve(pos)
  debug(res, ref.constructor.name)
  return expect(res).to.be.fulfilled
    .then(() => res.then((e) => {
      if (cb) return cb(e)
      return undefined
    }))
}

export { debug, validateOk, validateFail, description, reference }
