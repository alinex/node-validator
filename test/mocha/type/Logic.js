// @flow
import chai from 'chai'

import { NumberSchema, LogicSchema, StringSchema } from '../../../src/index'
import * as helper from '../helper'

const expect = chai.expect

// to simplify copy and paste in other Schemas
const MySchema = LogicSchema

describe.only('logic', () => {

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

  describe('and', () => {

    it('should work', (done) => {
      const data = '5_5'
      const schema = new MySchema()
      .allow(new StringSchema().replace(/_/g, '', 'remove _'))
      .and(new NumberSchema())
      // use schema
      helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(55)
      }, done)
    })

    it('should fail', (done) => {
      const data = '5-5'
      const schema = new MySchema()
      .allow(new StringSchema().replace(/_/g, '', 'remove _'))
      .and(new NumberSchema())
      // use schema
      helper.validateFail(schema, data, undefined, done)
    })

    it('should deny', (done) => {
      const data = '5_5'
      const schema = new MySchema()
      .deny(new StringSchema().replace(/_/g, '', 'remove _'))
      .and(new NumberSchema())
      // use schema
      helper.validateFail(schema, data, undefined, done)
    })

    it('should work with deny', (done) => {
      const data = '5-5'
      const schema = new MySchema()
      .deny(new StringSchema().replace(/_/g, '', 'remove _'))
      .and(new NumberSchema())
      // use schema
      helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal('5-5')
      }, done)
    })

    it('should describe', () => {
      const schema = new MySchema()
      .allow(new StringSchema().replace(/_/g, '', 'remove _'))
      .and(new NumberSchema())
      // use schema
      expect(helper.description(schema)).to.be.a('string')
    })

  })

  describe('OR', () => {

    it('should work', (done) => {
      const data = 'one'
      const schema = new MySchema()
      .allow(new StringSchema().replace(/^one$/i, '1').allow('1'))
      .or(new NumberSchema().positive())
      // use schema
      helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal('1')
      }, done)
    })

    it('should work with alternative', (done) => {
      const data = 14
      const schema = new MySchema()
      .allow(new StringSchema().replace(/^one$/i, '1').allow('1'))
      .or(new NumberSchema().positive())
      // use schema
      helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(14)
      }, done)
    })

    it('should fail', (done) => {
      const data = 'eins'
      const schema = new MySchema()
      .allow(new StringSchema().replace(/^one$/i, '1').allow('1'))
      .or(new NumberSchema().positive())
      // use schema
      helper.validateFail(schema, data, undefined, done)
    })

    it('should describe', () => {
      const schema = new MySchema()
      .allow(new StringSchema().replace(/^one$/i, '1').allow('1'))
      .or(new NumberSchema().positive())
      // use schema
      expect(helper.description(schema)).to.be.a('string')
    })

  })

})
