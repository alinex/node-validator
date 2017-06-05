import chai from 'chai'
import chaiAsPromised from 'chai-as-promised'
import Debug from 'debug'

import * as validator from '../../../src/index'

chai.use(chaiAsPromised)
const expect = chai.expect
const debug = Debug('test')

// to simplify copy and paste in other Schemas
const MySchema = validator.Any

describe('type any', () => {

  it('should work without specification', () => {
    const schema = new MySchema()
    expect(schema, 'schema').to.be.an('object')
    const data = 5
    schema.load(data)
    expect(schema.validate(), 'validate()').to.eventually.be.fulfilled
    expect(schema.object(), 'object()').to.equal(data)
  })

  describe('optional/default', () => {

    it('should work with not optional', () => {
      const schema = new MySchema()
      expect(schema).to.be.an('object')
      const data = 5
      schema.not.optional
      .load(data)
      expect(schema.validate(), 'validate()').to.eventually.be.fulfilled
      expect(schema.object(), 'object()').to.equal(data)
    })

    it('should fail with not optional', () => {
      const data = 'a'
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

  describe('allow', () => {

    it('should allow specific object', () => {
      const data = 'a'
      const schema = new MySchema()
      schema.allow(data)
      .load(data)
      expect(schema.validate(), 'validate()').to.eventually.be.fulfilled
      expect(schema.object(), 'object()').to.equal(data)
    })

    it('should fail if not in allowed list', () => {
      const data = 'a'
      const schema = new MySchema()
      schema.allow('a')
      .load('b')
      expect(schema.validate(), 'validate()').to.be.rejectedWith(Error)
      expect(schema.error, 'error').to.exist
      .and.has.property('schema')
      debug(schema.error.message)
      expect(schema.object(), 'object()').to.not.exist
    })

    it('should fail if in disallowed list', () => {
      const data = 'a'
      const schema = new MySchema()
      schema.not.allow(data)
      .load(data)
      expect(schema.validate(), 'validate()').to.be.rejectedWith(Error)
      expect(schema.error, 'error').to.exist
      .and.has.property('schema')
      debug(schema.error.message)
      expect(schema.object(), 'object()').to.not.exist
    })

    it('should work if not in disallowed list', () => {
      const data = 'a'
      const schema = new MySchema()
      schema.not.allow('b')
      .load(data)
      expect(schema.validate(), 'validate()').to.eventually.be.fulfilled
      expect(schema.object(), 'object()').to.equal(data)
    })

    it('should remove from disallow if allowed later', () => {
      const data = 'a'
      const schema = new MySchema()
      schema.not.allow(data)
      .allow(data)
      .load(data)
      expect(schema.validate(), 'validate()').to.eventually.be.fulfilled
      expect(schema.object(), 'object()').to.equal(data)
    })

    it('should be optional if undefined is allowed', () => {
      const schema = new MySchema()
      schema.not.optional
      .allow(undefined)
      expect(schema.validate(), 'validate()').to.eventually.be.fulfilled
    })

    it('should allow to define allow as list', () => {
      const data = 'a'
      const schema = new MySchema()
      schema.allow(['a', 'b', 'c'])
      .load(data)
      expect(schema.validate(), 'validate()').to.eventually.be.fulfilled
      expect(schema.object(), 'object()').to.equal(data)
    })

    it('should allow to define disallow as list', () => {
      const data = 'a'
      const schema = new MySchema()
      schema.not.allow(['a', 'b', 'c'])
      .load(data)
      expect(schema.validate(), 'validate()').to.be.rejectedWith(Error)
      expect(schema.error, 'error').to.exist
      .and.has.property('schema')
      debug(schema.error.message)
      expect(schema.object(), 'object()').to.not.exist
    })

    it('should be optional if undefined in allowed list', () => {
      const schema = new MySchema()
      schema.not.optional
      .allow(['a', undefined])
      expect(schema.validate(), 'validate()').to.eventually.be.fulfilled
    })

  })

  it('should describe', () => {
    const schema = new MySchema()
    expect(schema.describe()).to.be.a('string')
  })

})
