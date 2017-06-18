// @flow
import chai from 'chai'

import {AnySchema} from '../../../src/index'
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

  })

  describe('allow', () => {

    it('should allow specific object', (done) => {
      const data = 'a'
      const schema = new MySchema()
      schema.allow(data)
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

    it('should fail if in disallowed list', (done) => {
      const data = 'a'
      const schema = new MySchema()
      schema.not.allow(data)
      // use schema
      helper.validateFail(schema, data, undefined, done)
    })

    it('should work if not in disallowed list', (done) => {
      const data = 'a'
      const schema = new MySchema()
      schema.not.allow('b')
      // use schema
      helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      }, done)
    })

    it('should remove from disallow if allowed later', (done) => {
      const data = 'a'
      const schema = new MySchema()
      schema.not.allow(data)
      .allow(data)
      // use schema
      helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      }, done)
    })

    it('should be optional if undefined is allowed', (done) => {
      const data = undefined
      const schema = new MySchema()
      schema.required
      .allow(undefined)
      // use schema
      helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      }, done)
    })

    it('should allow with array', (done) => {
      const data = [1, 2, 3]
      const schema = new MySchema()
      schema.allow([1, 2, 3])
      // use schema
      helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      }, done)
    })

    it('should describe allow', () => {
      const schema = new MySchema()
      schema.allow('a')
      // use schema
      expect(helper.description(schema)).to.be.a('string')
    })

    it('should describe not allow', () => {
      const schema = new MySchema()
      schema.not.allow('a')
      // use schema
      expect(helper.description(schema)).to.be.a('string')
    })

  })

  describe('allowAll', () => {

    it('should allow to define allow as list', (done) => {
      const data = 'a'
      const schema = new MySchema()
      schema.allowAll(['a', 'b', 'c'])
      // use schema
      helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      }, done)
    })

    it('should allow to define disallow as list', (done) => {
      const data = 'a'
      const schema = new MySchema()
      schema.not.allowAll(['a', 'b', 'c'])
      // use schema
      helper.validateFail(schema, data, (err) => {
        expect(err.message).to.equal('Element found in blacklist (disallowed item).')
      }, done)
    })

    it('should be optional if undefined in allowed list', (done) => {
      const data = undefined
      const schema = new MySchema()
      schema.required
      .allowAll(['a', undefined])
      // use schema
      helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      }, done)
    })

  })

  describe('allowToClear', () => {

    it('should allow in invalid list', (done) => {
      const data = 'a'
      const schema = new MySchema()
      schema.not.allow(data).not.allowToClear
      // use schema
      helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      }, done)
    })

    it('should allow in valid list', (done) => {
      const data = 'a'
      const schema = new MySchema()
      schema.allow(data).allowToClear.allow('b')
      // use schema
      helper.validateFail(schema, data, undefined, done)
    })

  })

})
