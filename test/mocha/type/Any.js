// @flow
import chai from 'chai'

import { AnySchema } from '../../../src/index'
import Schema from '../../../src/Schema'
import * as helper from '../helper'

const expect = chai.expect

// to simplify copy and paste in other Schemas
const MySchema = AnySchema

describe('any', () => {

  it('should work without specification', (done) => {
    const data = 5
    const schema = new MySchema()
    expect(schema, 'schema').to.be.an('object')
    // use schema
    helper.validateOk(schema, data, (res) => {
      expect(res).deep.equal(data)
    }, done)
  })

  it('should describe', () => {
    const schema = new MySchema()
    // use schema
    expect(helper.description(schema)).to.equal('It is optional and must not be set.')
  })

  describe('optional/default', () => {

    it('should work with required', (done) => {
      const data = 5
      const schema = new MySchema().required()
      expect(schema).to.be.an('object')
      // use schema
      helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      }, done)
    })

    it('should fail with required', (done) => {
      const schema = new MySchema().required()
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

    it('should fail with required and undefined default', (done) => {
      const schema = new MySchema()
      schema.required().default(undefined)
      // use schema
      helper.validateFail(schema, undefined, undefined, done)
    })

  })

  describe('valid/invalid', () => {

    it('should allow specific object', (done) => {
      const data = 'a'
      const schema = new MySchema()
      schema.valid(data)
      // use schema
      helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      }, done)
    })

    it('should fail if not in allowed list', (done) => {
      const data = 'b'
      const schema = new MySchema()
      schema.valid('a')
      // use schema
      helper.validateFail(schema, data, undefined, done)
    })

    it('should fail if in disallowed list', (done) => {
      const data = 'a'
      const schema = new MySchema()
      schema.invalid(data)
      // use schema
      helper.validateFail(schema, data, undefined, done)
    })

    it('should work if not in disallowed list', (done) => {
      const data = 'a'
      const schema = new MySchema()
      schema.invalid('b')
      // use schema
      helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      }, done)
    })

    it('should remove from disallow if allowed later', (done) => {
      const data = 'a'
      const schema = new MySchema()
      schema.invalid(data)
      .valid(data)
      // use schema
      helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      }, done)
    })

    it('should be optional if undefined is allowed', (done) => {
      const data = undefined
      const schema = new MySchema()
      schema.required()
      .valid(undefined)
      // use schema
      helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      }, done)
    })

    it('should describe valid', () => {
      const schema = new MySchema()
      schema.valid('a')
      // use schema
      expect(helper.description(schema)).to.be.a('string')
    })

    it('should describe invalid', () => {
      const schema = new MySchema()
      schema.invalid('a')
      // use schema
      expect(helper.description(schema)).to.be.a('string')
    })

  })

})
