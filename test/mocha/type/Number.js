// @flow
import chai from 'chai'

import {NumberSchema} from '../../../src/index'
import Schema from '../../../src/Schema'
import * as helper from '../helper'

const expect = chai.expect

// to simplify copy and paste in other Schemas
const MySchema = NumberSchema

describe('type number', () => {

  it('should work without specification', (done) => {
    const data = 12.8
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
      const data = 12.8
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
      const data = 12.8
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

  describe('sanitize', () => {

    it('should work with string number', (done) => {
      const data = '12.8'
      const schema = new MySchema()
      // use schema
      helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(12.8)
      }, done)
    })

    it('should work with additional text', (done) => {
      const data = 'use 12.8 cm'
      const schema = new MySchema().sanitize
      // use schema
      helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(12.8)
      }, done)
    })

    it('should fail with additional text', (done) => {
      const data = 'use 12.8 cm'
      const schema = new MySchema()
      schema.required
      // use schema
      helper.validateFail(schema, data, undefined, done)
    })

    it('should describe', () => {
      const schema = new MySchema().sanitize
      // use schema
      expect(helper.description(schema)).to.be.a('string')
    })

  })

})
