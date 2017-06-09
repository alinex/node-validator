// @flow
import chai from 'chai'
import chaiAsPromised from 'chai-as-promised'

import debug from './debug'
import type Schema from '../../src/Schema'

chai.use(chaiAsPromised)
const expect = chai.expect

const validateOk = function(schema: Schema, data: any, cb: Function) {
  debug(schema, schema.constructor.name)
  const res = schema.validate(data)
  debug(res, schema.constructor.name)
  expect(res, 'validate()').to.be.fulfilled.notify(() => {
    res.then(e => cb(e))
  })
}

const validateFail = function(schema: Schema, data: any, cb: Function) {
  debug(schema, schema.constructor.name)
  const res = schema.validate(data)
  debug(res, schema.constructor.name)
  expect(res, 'validate()').to.be.rejectedWith(Error).notify(() => {
    res.catch(e => cb(e))
  })
}

const description = function(schema: Schema) {
  debug(schema, schema.constructor.name)
  const msg = schema.description
  debug(msg, schema.constructor.name)
  expect(msg).to.be.a('string')
  return msg
}

export {debug, validateOk, validateFail, description}
