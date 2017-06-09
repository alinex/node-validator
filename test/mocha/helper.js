// @flow
import chai from 'chai'
import chaiAsPromised from 'chai-as-promised'

import debug from './debug'
import type Schema from '../../src/Schema'
import SchemaData from '../../src/SchemaData'

chai.use(chaiAsPromised)
const expect = chai.expect

const validateOk = function(schema: Schema, data: any, cb?: Function, done ?: Function) {
  debug(schema, schema.constructor.name)
  debug(new SchemaData(data), schema.constructor.name)
  const res = schema.validate(data)
  debug(res, schema.constructor.name)
  expect(res, 'validate()').to.be.fulfilled.notify(() => {
    res.then(e => {
      try { if (cb) cb(e); if (done) done() }
      catch(error) { if (done) done(error) }
    })
  })
}

const validateFail = function(schema: Schema, data: any, cb?: Function, done ?: Function) {
  debug(schema, schema.constructor.name)
  debug(new SchemaData(data), schema.constructor.name)
  const res = schema.validate(data)
  debug(res, schema.constructor.name)
  expect(res, 'validate()').to.be.rejectedWith(Error).notify(() => {
    res.catch(e => {
      try { if (cb) cb(e); if (done) done() }
      catch(error) { if (done) done(error) }
    })
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
