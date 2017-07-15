// @flow
import chai from 'chai'
import chaiAsPromised from 'chai-as-promised'

import debug from './debug'
import type Schema from '../../src/Schema'
import type Reference from '../../src/Reference'
import SchemaData from '../../src/SchemaData'

chai.use(chaiAsPromised)
const expect = chai.expect

function validateOk(schema: Schema, data: any, cb?: Function, done ?: Function) {
  debug(schema, schema.constructor.name)
  debug(new SchemaData(data), schema.constructor.name)
  const res = schema.validate(data)
  debug(res, schema.constructor.name)
  expect(res, 'validate()').to.be.fulfilled.notify(() => {
    res.then((e) => {
      debug(schema._check, schema.constructor.name, 'Used checks')
      try { if (cb) cb(e); if (done) done() } catch (error) { if (done) done(error) }
    })
    .catch((e) => {
      debug(schema._check, schema.constructor.name, 'Used checks')
      if (done) done(new Error('it should not be rejected'))
    })
  })
}

function validateFail(schema: Schema, data: any, cb?: Function, done ?: Function) {
  debug(schema, schema.constructor.name)
  debug(new SchemaData(data), schema.constructor.name)
  const res = schema.validate(data)
  debug(res, schema.constructor.name)
  expect(res, 'validate()').to.be.rejectedWith(Error).notify(() => {
    res.then((e) => {
      debug(schema._check, schema.constructor.name, 'Used checks')
      if (done) done(new Error('it should not be resolved'))
    })
    .catch((e) => {
      debug(schema._check, schema.constructor.name, 'Used checks')
      try { if (cb) cb(e); if (done) done() } catch (error) { if (done) done(error) }
    })
  })
}

function description(schema: Schema) {
  debug(schema, schema.constructor.name)
  const msg = schema.description
  debug(msg, schema.constructor.name)
  expect(msg).to.be.a('string')
  return msg
}

function reference(ref: Reference, pos?: any, cb?: Function, done ?: Function) {
  debug(ref, ref.constructor.name)
  const res = ref.resolve(pos)
  debug(res, ref.constructor.name)
  expect(res, 'reference()').to.be.fulfilled.notify(() => {
    res.then((e) => {
      try { if (cb) cb(e); if (done) done() } catch (error) { if (done) done(error) }
    })
  })
}

export { debug, validateOk, validateFail, description, reference }
