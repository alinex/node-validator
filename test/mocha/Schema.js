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

  it('should describe', () => {
    const schema = new MySchema()
    // use schema
    expect(helper.description(schema)).to.equal('Any data type. It is optional and must not be set.')
  })

  describe('optional/default', () => {

    it('should work with required', (done) => {
      const data = 5
      const schema = new MySchema()
      expect(schema).to.be.an('object')
      schema.required
      // use schema
      helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      }, done)
    })

    it('should fail with required', (done) => {
      const schema = new MySchema()
      schema.required
      // use schema
      helper.validateFail(schema, undefined, undefined, done)
    })

    it('should remove required', (done) => {
      const schema = new MySchema()
      expect(schema).to.be.an('object')
      schema.required.not.required
      // use schema
      helper.validateOk(schema, undefined, undefined, done)
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

    it('should fail with required and undefined default', (done) => {
      const schema = new MySchema()
      schema.required.default(undefined)
      // use schema
      helper.validateFail(schema, undefined, undefined, done)
    })

    it('should remove default using not', (done) => {
      const schema = new MySchema()
      expect(schema).to.be.an('object')
      schema.default(5).not.default()
      // use schema
      helper.validateOk(schema, undefined, undefined, done)
    })

    it('should remove default using no value', (done) => {
      const schema = new MySchema()
      expect(schema).to.be.an('object')
      schema.default(5).default()
      // use schema
      helper.validateOk(schema, undefined, undefined, done)
    })

    it('should describe required', () => {
      const schema = new MySchema()
      schema.required
      // use schema
      expect(helper.description(schema)).to.equal('Any data type.')
    })

    it('should describe default', () => {
      const schema = new MySchema()
      schema.default(5)
      // use schema
      expect(helper.description(schema)).to.be.a('string')
    })

  })

  describe('stripEmpty', () => {

    it('should fail with stripEmpty and null', (done) => {
      const schema = new MySchema()
      schema.required.stripEmpty
      // use schema
      helper.validateFail(schema, null, undefined, done)
    })

    it('should fail with stripEmpty and empty String', (done) => {
      const schema = new MySchema()
      schema.required.stripEmpty
      // use schema
      helper.validateFail(schema, '', undefined, done)
    })

    it('should fail with stripEmpty and empty Array', (done) => {
      const schema = new MySchema()
      schema.required.stripEmpty
      // use schema
      helper.validateFail(schema, [], undefined, done)
    })

    it('should fail with stripEmpty and empty Object', (done) => {
      const schema = new MySchema()
      schema.required.stripEmpty
      // use schema
      helper.validateFail(schema, {}, undefined, done)
    })

    it('should describe required with default', () => {
      const schema = new MySchema()
      schema.default(8)
      // use schema
      expect(helper.description(schema)).to.equal('Any data type. It will default to 8 if not set.')
    })

  })

})
