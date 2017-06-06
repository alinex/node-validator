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
      // use schema
      const data = 5
      schema.default(data)
      expect(schema.validate(), 'validate()').to.eventually.deep.equal(data)
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

  // should work with instance changes

  it('should describe', () => {
    const schema = new MySchema()
    // use schema
    let msg
    expect(msg = schema.description).to.be.a('string')
    debug(msg)
  })

  it('should describe not optional', () => {
    const schema = new MySchema()
    schema.not.optional
    // use schema
    const msg = schema.description
    debug(msg)
    expect(msg).to.be.a('string')
  })

  it('should describe not optional with default', () => {
    const schema = new MySchema()
    schema.default(8)
    // use schema
    const msg = schema.description
    debug(msg)
    expect(msg).to.be.a('string')
  })

})
