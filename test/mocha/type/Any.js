// @flow
import chai from 'chai'

import { AnySchema, Reference } from '../../../src/index'
import * as helper from '../helper'

const expect = chai.expect

// to simplify copy and paste in other Schemas
const MySchema = AnySchema

describe('any', () => {

  it('should work without specification', (done) => {
    const data = 5
    const schema = new MySchema()
    expect(schema).to.be.an('object')
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

  describe('allow', () => {

    it('should allow single value', (done) => {
      const data = 'a'
      const schema = new MySchema()
      schema.allow(data)
      // use schema
      helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      }, done)
    })

    it('should allow list', (done) => {
      const data = 'a'
      const schema = new MySchema()
      schema.allow(data, 'b')
      // use schema
      helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      }, done)
    })

    it('should allow array', (done) => {
      const data = 'a'
      const schema = new MySchema()
      schema.allow([data, 'b'])
      // use schema
      helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      }, done)
    })

    it('should fail if not in allowed list', (done) => {
      const data = 'b'
      const schema = new MySchema()
      schema.allow('a')
      // use schema
      helper.validateFail(schema, data, undefined, done)
    })

    it('should overwrite old list', (done) => {
      const data = 'b'
      const schema = new MySchema()
      schema.allow('b').allow('a')
      // use schema
      helper.validateFail(schema, data, undefined, done)
    })

    it('should allow remove', (done) => {
      const data = 'a'
      const schema = new MySchema()
      schema.allow('b').allow()
      // use schema
      helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      }, done)
    })

    it('should allow reference as list', (done) => {
      const data = 'a'
      const ref = new Reference(['a'])
      const schema = new MySchema()
      schema.allow(ref)
      // use schema
      helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      }, done)
    })

    it('should allow reference as element', (done) => {
      const data = 'a'
      const ref = new Reference(data)
      const schema = new MySchema()
      schema.allow(ref)
      // use schema
      helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      }, done)
    })

    it('should allow reference in list', (done) => {
      const data = 'a'
      const ref = new Reference(data)
      const schema = new MySchema()
      schema.allow(1, ref)
      // use schema
      helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      }, done)
    })

    it('should describe', () => {
      const schema = new MySchema()
      schema.allow('a')
      // use schema
      expect(helper.description(schema)).to.be.a('string')
    })

    it('should describe with reference', () => {
      const ref = new Reference('a')
      const schema = new MySchema()
      schema.allow(ref)
      // use schema
      expect(helper.description(schema)).to.be.a('string')
    })

  })

  describe('deny', () => {

    it('should allow single value', (done) => {
      const data = 'a'
      const schema = new MySchema()
      schema.deny(data)
      // use schema
      helper.validateFail(schema, data, undefined, done)
    })

    it('should allow list', (done) => {
      const data = 'a'
      const schema = new MySchema()
      schema.deny(data, 'b')
      // use schema
      helper.validateFail(schema, data, undefined, done)
    })

    it('should allow array', (done) => {
      const data = 'a'
      const schema = new MySchema()
      schema.deny([data, 'b'])
      // use schema
      helper.validateFail(schema, data, undefined, done)
    })

    it('should work if not in denied list', (done) => {
      const data = 'b'
      const schema = new MySchema()
      schema.deny('a')
      // use schema
      helper.validateOk(schema, data, undefined, done)
    })

    it('should overwrite old list', (done) => {
      const data = 'b'
      const schema = new MySchema()
      schema.deny('b').deny('a')
      // use schema
      helper.validateOk(schema, data, undefined, done)
    })

    it('should allow remove', (done) => {
      const data = 'a'
      const schema = new MySchema()
      schema.deny('b').deny()
      // use schema
      helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      }, done)
    })

    it('should allow reference as list', (done) => {
      const data = 'a'
      const ref = new Reference(['a'])
      const schema = new MySchema()
      schema.deny(ref)
      // use schema
      helper.validateFail(schema, data, undefined, done)
    })

    it('should allow reference as element', (done) => {
      const data = 'a'
      const ref = new Reference(data)
      const schema = new MySchema()
      schema.deny(ref)
      // use schema
      helper.validateFail(schema, data, undefined, done)
    })

    it('should allow reference in list', (done) => {
      const data = 'a'
      const ref = new Reference(data)
      const schema = new MySchema()
      schema.deny(1, ref)
      // use schema
      helper.validateFail(schema, data, undefined, done)
    })

    it('should describe', () => {
      const schema = new MySchema()
      schema.deny('a')
      // use schema
      expect(helper.description(schema)).to.be.a('string')
    })

    it('should describe with reference', () => {
      const ref = new Reference('a')
      const schema = new MySchema()
      schema.deny(ref)
      // use schema
      expect(helper.description(schema)).to.be.a('string')
    })

  })

  describe('valid', () => {

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

    it('should remove from deny if allowed later', (done) => {
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

    it('should allow reference', (done) => {
      const data = 'a'
      const ref = new Reference('a')
      const schema = new MySchema()
      schema.valid(ref)
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

  })

  describe('invalid', () => {

    it('should fail if in denied list', (done) => {
      const data = 'a'
      const schema = new MySchema()
      schema.invalid(data)
      // use schema
      helper.validateFail(schema, data, undefined, done)
    })

    it('should work if not in denied list', (done) => {
      const data = 'a'
      const schema = new MySchema()
      schema.invalid('b')
      // use schema
      helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      }, done)
    })

    it('should remove from allow if denied later', (done) => {
      const data = 'a'
      const schema = new MySchema()
      schema.valid(data)
      .invalid(data)
      // use schema
      helper.validateFail(schema, data, undefined, done)
    })

    it('should be required if undefined is denied', (done) => {
      const data = undefined
      const schema = new MySchema()
      schema.invalid(undefined)
      // use schema
      helper.validateFail(schema, data, undefined, done)
    })

    it('should allow reference', (done) => {
      const data = 'a'
      const ref = new Reference(data)
      const schema = new MySchema()
      schema.invalid(ref)
      // use schema
      helper.validateFail(schema, data, undefined, done)
    })

    it('should describe invalid', () => {
      const schema = new MySchema()
      schema.invalid('a')
      // use schema
      expect(helper.description(schema)).to.be.a('string')
    })

  })

})
