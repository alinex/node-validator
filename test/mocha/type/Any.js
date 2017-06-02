import chai from 'chai'
import chaiAsPromised from 'chai-as-promised'
import Debug from 'debug'

import * as validator from '../../../src/index'

chai.use(chaiAsPromised)
const expect = chai.expect
const debug = Debug('test')

describe('type any', () => {

  it('should load validator', () => {
    expect(validator, 'module').to.be.an('object')
    expect(validator.Any, 'AnySchema').to.be.a('function')
  })

  it('should work with data loading', () => {
    const schema = new validator.Any()
    expect(schema, 'schema').to.be.an('object')
    const data = 5
    schema.load(data)
    expect(schema.validate(), 'validate()').to.eventually.be.fulfilled
    expect(schema.object(), 'object()').to.equal(data)
  })

  it('should allow validation options', () => {
    const data = 'a'
    const schema = new validator.Any()
    schema.allow(data)
    .load(data)
    expect(schema.validate(), 'validate()').to.eventually.be.fulfilled
    expect(schema.object(), 'object()').to.equal(data)
  })

  it('should fail', () => {
    const data = 'a'
    const schema = new validator.Any()
    schema.allow('a')
    .load('b')
    expect(schema.validate(), 'validate()').to.be.rejectedWith(Error)
    expect(schema.error, 'error').to.exist
    .and.has.property('schema')
    debug(schema.error.message)
    expect(schema.object(), 'object()').to.not.exist
  })

  it('should work with overloading', () => {
    const schema = new validator.Any()
    expect(schema, 'schema').to.be.an('object')
    const data = 5
    schema.allow(data)
    .load(2)
    .load(data)
    expect(schema.validate(), 'validate()').to.eventually.be.fulfilled
    expect(schema.object(), 'object()').to.equal(data)
  })

  it('should work with clear', () => {
    const schema = new validator.Any()
    expect(schema).to.be.an('object')
    const data = 5
    schema.allow(data)
    .load(2)
    .clear()
    expect(schema.data, 'data').to.not.exist
    expect(schema.validate(), 'validate()').to.eventually.be.fulfilled
    expect(schema.object(), 'object()').not.exist
  })

  // should work with instance changes

  it('should describe', () => {
    const schema = new validator.Any()
    expect(schema.describe()).to.be.a('string')
  })

})
