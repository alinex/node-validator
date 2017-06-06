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
    // use schema
    const data = 5
    expect(schema.validate(data), 'validate()').to.eventually.deep.equal(data)
  })

  describe('optional/default', () => {

    it('should work with not optional', () => {
      const schema = new MySchema()
      expect(schema).to.be.an('object')
      schema.not.optional
      // use schema
      const data = 5
      expect(schema.validate(data), 'validate()').to.eventually.deep.equal(data)
    })

    it('should fail with not optional', () => {
      const schema = new MySchema()
      schema.not.optional
      // use schema
      let res
      expect(res = schema.validate(), 'validate()').to.be.rejectedWith(Error)
      res.catch(error => debug(error.message))
    })

    it('should work with default', () => {
      const schema = new MySchema()
      expect(schema).to.be.an('object')
      const data = 5
      schema.default(data)
      // use schema
      expect(schema.validate(data), 'validate()').to.eventually.deep.equal(data)
    })

    it('should fail with not optional and undefined default', () => {
      const schema = new MySchema()
      schema.not.optional.default(undefined)
      // use schema
      let res
      expect(res = schema.validate(), 'validate()').to.be.rejectedWith(Error)
      res.catch(error => debug(error.message))
    })

  })

  describe('allow', () => {

    it('should allow specific object', () => {
      const schema = new MySchema()
      const data = 'a'
      schema.allow(data)
      // use schema
      expect(schema.validate(data), 'validate()').to.eventually.deep.equal(data)
    })

    it('should fail if not in allowed list', () => {
      const schema = new MySchema()
      schema.allow('a')
      // use schema
      const data = 'b'
      let res
      expect(res = schema.validate(data), 'validate()').to.be.rejectedWith(Error)
      res.catch(error => debug(error.message))
    })

    it('should fail if in disallowed list', () => {
      const data = 'a'
      const schema = new MySchema()
      schema.not.allow(data)
      // use schema
      let res
      expect(res = schema.validate(data), 'validate()').to.be.rejectedWith(Error)
      res.catch(error => debug(error.message))
    })

    it('should work if not in disallowed list', () => {
      const data = 'a'
      const schema = new MySchema()
      schema.not.allow('b')
      // use schema
      expect(schema.validate(data), 'validate()').to.eventually.deep.equal(data)
    })

    it('should remove from disallow if allowed later', () => {
      const data = 'a'
      const schema = new MySchema()
      schema.not.allow(data)
      .allow(data)
      // use schema
      expect(schema.validate(data), 'validate()').to.eventually.deep.equal(data)
    })

    it('should be optional if undefined is allowed', () => {
      const schema = new MySchema()
      schema.not.optional
      .allow(undefined)
      // use schema
      expect(schema.validate(), 'validate()').to.eventually.be.fulfilled
    })

    it('should allow to define allow as list', () => {
      const data = 'a'
      const schema = new MySchema()
      schema.allow(['a', 'b', 'c'])
      // use schema
      expect(schema.validate(data), 'validate()').to.eventually.deep.equal(data)
    })

    it('should allow to define disallow as list', () => {
      const schema = new MySchema()
      schema.not.allow(['a', 'b', 'c'])
      // use schema
      const data = 'a'
      let res
      expect(res = schema.validate(data), 'validate()').to.be.rejectedWith(Error)
      res.catch(error => debug(error.message))
    })

    it('should be optional if undefined in allowed list', () => {
      const schema = new MySchema()
      schema.not.optional
      .allow(['a', undefined])
      // use schema
      expect(schema.validate(), 'validate()').to.eventually.be.fulfilled
    })

  })

  it('should describe', () => {
    const schema = new MySchema()
    // use schema
    let msg
    expect(msg = schema.description).to.be.a('string')
    debug(msg)
  })

})
