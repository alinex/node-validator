// @flow
import chai from 'chai'

import {BooleanSchema} from '../../../src/index'
import Schema from '../../../src/Schema'
import * as helper from '../helper'

const expect = chai.expect

// to simplify copy and paste in other Schemas
const MySchema = BooleanSchema

describe('type boolean', () => {

  it('should work without specification', (done) => {
    const data = true
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
    expect(helper.description(schema)).to.be.a('string')
  })

  describe('optional/default', () => {

    it('should work with required', (done) => {
      const data = true
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
      const data = false
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

  describe('default parser', () => {

    it('should work for true', (done) => {
      const data = true
      const schema = new MySchema()
      // use schema
      helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      }, done)
    })

    it('should work for false', (done) => {
      const data = true
      const schema = new MySchema()
      // use schema
      helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      }, done)
    })

  })

  describe('truthy/falsy', () => {

    it('should work for true with arguments', (done) => {
      const data = 1
      const schema = new MySchema().truthy(1, 'yes')
      // use schema
      helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(true)
      }, done)
    })

    it('should work for true with list', (done) => {
      const data = 1
      const schema = new MySchema().truthy([1, 'yes'])
      // use schema
      helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(true)
      }, done)
    })

    it('should work for false with list', (done) => {
      const data = 'no'
      const schema = new MySchema().falsy([0, 'no'])
      // use schema
      helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(false)
      }, done)
    })

    it('should work for false with arguments', (done) => {
      const data = 'no'
      const schema = new MySchema().falsy(0, 'no')
      // use schema
      helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(false)
      }, done)
    })

    it('should describe', () => {
      const schema = new MySchema().truthy([1, 'yes']).falsy([0, 'no'])
      // use schema
      expect(helper.description(schema)).to.be.a('string')
    })

  })

  describe('tolerant', () => {

    it('should work', (done) => {
      const data = 'no'
      const schema = new MySchema().tolerant
      // use schema
      helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(false)
      }, done)
    })

    it('should fail after clear', (done) => {
      const schema = new MySchema().truthy(1).not.tolerant
      // use schema
      helper.validateFail(schema, 1, undefined, done)
    })

    it('should describe', () => {
      const schema = new MySchema().tolerant
      // use schema
      expect(helper.description(schema)).to.be.a('string')
    })

  })

  describe('insensitive', () => {

    it('should work', (done) => {
      const data = 'NO'
      const schema = new MySchema().tolerant.insensitive
      // use schema
      helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(false)
      }, done)
    })

    it('should fail if case sensitive', (done) => {
      const schema = new MySchema().tolerant
      // use schema
      helper.validateFail(schema, 'NO', undefined, done)
    })

    it('should describe', () => {
      const schema = new MySchema().tolerant.insensitive
      // use schema
      expect(helper.description(schema)).to.be.a('string')
    })

  })

  describe('format', () => {

    it('should work with defined true output', (done) => {
      const data = true
      const schema = new MySchema().format('JA', 'NEIN')
      // use schema
      helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal('JA')
      }, done)
    })

    it('should work with defined false object', (done) => {
      const data = false
      const schema = new MySchema().format('JA', {no: 1})
      // use schema
      helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal({no: 1})
      }, done)
    })

    it('should describe', () => {
      const schema = new MySchema().format('JA', {no: 1})
      // use schema
      expect(helper.description(schema)).to.be.a('string')
    })

  })

})