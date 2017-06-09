// @flow
import chai from 'chai'

import Schema from '../../src/Schema'
import * as helper from './helper'

const expect = chai.expect

// to simplify copy and paste in other Schemas
const MySchema = Schema

describe('schema', () => {

  it('should work without specification', (done) => {
    const data = 5
    const schema = new MySchema()
    expect(schema, 'schema').to.be.an('object')
    // use schema
    helper.validateOk(schema, data, (res) => {
      expect(res).deep.equal(data)
      done()
    })
  })

  describe('optional/default', () => {

    it('should work with not optional', (done) => {
      const data = 5
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
      const data = 5
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

  // should work with instance changes

  it('should describe', () => {
    const schema = new MySchema()
    // use schema
    expect(helper.description(schema)).to.equal('Any data type. It is optional and must not be set.')
  })

  it('should describe not optional', () => {
    const schema = new MySchema()
    schema.not.optional
    // use schema
    expect(helper.description(schema)).to.equal('Any data type.')
  })

  it('should describe not optional with default', () => {
    const schema = new MySchema()
    schema.default(8)
    // use schema
    expect(helper.description(schema)).to.equal('Any data type. It will default to 8 if not set.')
  })

})
