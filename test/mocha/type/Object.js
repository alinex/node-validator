import chai from 'chai'

import * as validator from '../../../src/index'
import Schema from '../../../src/Schema'
import * as helper from '../helper'

const expect = chai.expect

// to simplify copy and paste in other Schemas
const MySchema = validator.Object

describe('type object', () => {

  it('should work without specification', (done) => {
    const data = {a: 1}
    const schema = new MySchema()
    expect(schema, 'schema').to.be.an('object')
    // use schema
    helper.validateOk(schema, data, (res) => {
      expect(res).deep.equal(data)
      done()
    })
  })

  it('should fail if no object', (done) => {
    const data = 'a'
    const schema = new MySchema()
    // use schema
    helper.validateFail(schema, data, undefined, done)
  })

  describe('optional/default', () => {

    it('should work with not optional', (done) => {
      const data = {a: 1}
      const schema = new MySchema()
      expect(schema).to.be.an('object')
      schema.not.optional
      // use schema
      helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      }, done)
    })

    it('should fail with not optional', (done) => {
      const schema = new MySchema()
      schema.not.optional
      // use schema
      helper.validateFail(schema, undefined, undefined, done)
    })

    it('should work with default', (done) => {
      const data = { a: 1 }
      const schema = new MySchema()
      expect(schema).to.be.an('object')
      schema.default(data)
      helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      }, done)
    })

    it('should fail with not optional and undefined default', (done) => {
      const schema = new MySchema()
      schema.not.optional.default(undefined)
      // use schema
      helper.validateFail(schema, undefined, undefined, done)
    })

  })

  describe('key/pattern', () => {

    it('should work with defined keys', (done) => {
      const data = {a: 1}
      const schema = new MySchema()
      expect(schema).to.be.an('object')
      schema.key('a', new validator.Any())
      // use schema
      helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      }, done)
    })

    it('should describe with defined keys', () => {
      const schema = new MySchema()
      schema.key('a', new validator.Any())
      // use schema
      expect(helper.description(schema)).to.equal('Any data type. It is optional and must not be set. A data object is needed. The following keys have a special format:\n- `a`: Any data type. It is optional and must not be set.')
    })

    it('should work with defined pattern', (done) => {
      const data = {name1: 1}
      const schema = new MySchema()
      expect(schema).to.be.an('object')
      schema.pattern(/name\d/, new validator.Any())
      // use schema
      helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      }, done)
    })

    it('should describe with defined pattern', () => {
      const schema = new MySchema()
      schema.pattern(/name\d/, new validator.Any())
      // use schema
      expect(helper.description(schema)).to.equal('Any data type. It is optional and must not be set. A data object is needed. The following keys have a special format:\n- `/name\\d/`: Any data type. It is optional and must not be set.')
    })

  })

  it('should describe', () => {
    const schema = new MySchema()
    // use schema
    expect(helper.description(schema)).to.equal('Any data type. It is optional and must not be set. A data object is needed.')
  })

})
