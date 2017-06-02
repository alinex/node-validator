import chai from 'chai'
import chaiAsPromised from 'chai-as-promised'
import Debug from 'debug'

import Schema from '../../src/Schema'

chai.use(chaiAsPromised)
const expect = chai.expect
const debug = Debug('test')

describe('schema', () => {

  it('should work with data loading', () => {
    const schema = new Schema()
    expect(schema, 'schema').to.be.an('object')
    const data = 5
    schema.load(data)
    expect(schema.validate(), 'validate()').to.eventually.be.fulfilled
    expect(schema.object(), 'object()').to.equal(data)
  })

  it('should work with overloading', () => {
    const schema = new Schema()
    expect(schema, 'schema').to.be.an('object')
    const data = 5
    schema.load(2)
    .load(data)
    expect(schema.validate(), 'validate()').to.eventually.be.fulfilled
    expect(schema.object(), 'object()').to.equal(data)
  })

  it('should work with clear', () => {
    const schema = new Schema()
    expect(schema).to.be.an('object')
    const data = 5
    schema.load(2)
    .clear()
    expect(schema.data, 'data').to.not.exist
    expect(schema.validate(), 'validate()').to.eventually.be.fulfilled
    expect(schema.object(), 'object()').not.exist
  })

  describe('options', () => {

    it('should work with not optional', () => {
      const schema = new Schema()
      expect(schema).to.be.an('object')
      const data = 5
      schema.optional(false)
      .load(data)
      expect(schema.validate(), 'validate()').to.eventually.be.fulfilled
      expect(schema.object(), 'object()').to.equal(data)
    })

    it('should fail with not optional', () => {
      const data = 'a'
      const schema = new Schema()
      schema.optional(false)
      expect(schema.validate(), 'validate()').to.be.rejectedWith(Error)
      expect(schema.error, 'error').to.exist
      .and.has.property('schema')
      debug(schema.error.message)
      expect(schema.object(), 'object()').to.not.exist
    })

    it('should work with default', () => {
      const schema = new Schema()
      expect(schema).to.be.an('object')
      const data = 5
      schema.default(data)
      expect(schema.validate(), 'validate()').to.eventually.be.fulfilled
      expect(schema.object(), 'object()').to.equal(data)
    })

    it('should fail with not optional and undefined default', () => {
      const data = 'a'
      const schema = new Schema()
      schema.optional(false).default(undefined)
      expect(schema.validate(), 'validate()').to.be.rejectedWith(Error)
      expect(schema.error, 'error').to.exist
      .and.has.property('schema')
      debug(schema.error.message)
      expect(schema.object(), 'object()').to.not.exist
    })

  })

  // should work with instance changes

  it('should describe', () => {
    const schema = new Schema()
    const msg = schema.describe()
    debug(msg)
    expect(msg).to.be.a('string')
  })

  it('should describe optional with default', () => {
    const schema = new Schema()
    schema.default(8)
    const msg = schema.describe()
    debug(msg)
    expect(msg).to.be.a('string')
  })

  it('should describe not optional with default', () => {
    const schema = new Schema()
    schema.optional(false).default(8)
    const msg = schema.describe()
    debug(msg)
    expect(msg).to.be.a('string')
  })

})
