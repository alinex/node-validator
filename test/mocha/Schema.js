import chai from 'chai'
import chaiAsPromised from 'chai-as-promised'
import Debug from 'debug'

import Schema from '../../src/Schema'

chai.use(chaiAsPromised)
const expect = chai.expect
const debug = Debug('test')

// to simplify copy and paste in other Schemas
const MySchema = Schema

describe('schema', () => {

  it('should work without specification', () => {
    const schema = new MySchema()
    expect(schema, 'schema').to.be.an('object')
    const data = 5
    schema.load(data)
    expect(schema.validate(), 'validate()').to.eventually.be.fulfilled
    expect(schema.object(), 'object()').to.equal(data)
  })

  it('should work with overloading', () => {
    const schema = new MySchema()
    expect(schema, 'schema').to.be.an('object')
    const data = 5
    schema.load(2)
    .load(data)
    expect(schema.validate(), 'validate()').to.eventually.be.fulfilled
    expect(schema.object(), 'object()').to.equal(data)
  })

  it('should work with clear', () => {
    const schema = new MySchema()
    expect(schema).to.be.an('object')
    const data = 5
    schema.load(2)
    .clear()
    expect(schema.data, 'data').to.not.exist
    expect(schema.validate(), 'validate()').to.eventually.be.fulfilled
    expect(schema.object(), 'object()').not.exist
  })

  describe('optional/default', () => {

    it('should work with not optional', () => {
      const data = 5
      const schema = new MySchema()
      expect(schema).to.be.an('object')
      schema.not.optional
      .load(data)
      expect(schema.validate(), 'validate()').to.eventually.be.fulfilled
      expect(schema.object(), 'object()').to.equal(data)
    })

    it('should fail with not optional', () => {
      const schema = new MySchema()
      schema.not.optional
      expect(schema.validate(), 'validate()').to.be.rejectedWith(Error)
      expect(schema.error, 'error').to.exist
      .and.has.property('schema')
      debug(schema.error.message)
      expect(schema.object(), 'object()').to.not.exist
    })

    it('should work with default', () => {
      const schema = new MySchema()
      expect(schema).to.be.an('object')
      const data = 5
      schema.default(data)
      expect(schema.validate(), 'validate()').to.eventually.be.fulfilled
      expect(schema.object(), 'object()').to.equal(data)
    })

    it('should fail with not optional and undefined default', () => {
      const data = 'a'
      const schema = new MySchema()
      schema.not.optional.default(undefined)
      expect(schema.validate(), 'validate()').to.be.rejectedWith(Error)
      expect(schema.error, 'error').to.exist
      .and.has.property('schema')
      debug(schema.error.message)
      expect(schema.object(), 'object()').to.not.exist
    })

  })

  // should work with instance changes

  it('should describe', () => {
    const schema = new MySchema()
    const msg = schema.describe()
    debug(msg)
    expect(msg).to.be.a('string')
  })

  it('should describe not optional', () => {
    const schema = new MySchema()
    schema.not.optional
    const msg = schema.describe()
    debug(msg)
    expect(msg).to.be.a('string')
  })

  it('should describe not optional with default', () => {
    const schema = new MySchema()
    schema.default(8)
    const msg = schema.describe()
    debug(msg)
    expect(msg).to.be.a('string')
  })

})
