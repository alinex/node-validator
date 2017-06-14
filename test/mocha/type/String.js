// @flow
import chai from 'chai'

import {StringSchema} from '../../../src/index'
import Schema from '../../../src/Schema'
import * as helper from '../helper'

const expect = chai.expect

// to simplify copy and paste in other Schemas
const MySchema = StringSchema

describe('type string', () => {

  it('should work without specification', (done) => {
    const data = 'abc'
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
      const data = 'abc'
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
      const data = 'abc'
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

  describe('makeString', () => {

    it('should convert number', (done) => {
      const data = 12
      const schema = new MySchema().makeString
      helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal('12')
      }, done)
    })

    it('should fail without', (done) => {
      const data = 12
      const schema = new MySchema()
      // use schema
      helper.validateFail(schema, data, undefined, done)
    })

    it('should disable with not', (done) => {
      const data = 12
      const schema = new MySchema().makeString.not.makeString
      // use schema
      helper.validateFail(schema, data, undefined, done)
    })

    it('should describe', () => {
      const schema = new MySchema().makeString
      // use schema
      expect(helper.description(schema)).to.be.a('string')
    })

  })

  describe('length', () => {

    it('should check for minimal length', (done) => {
      const data = 'abc'
      const schema = new MySchema().min(3)
      helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      }, done)
    })

    it('should fail for minimal length', (done) => {
      const data = 'abc'
      const schema = new MySchema().min(5)
      // use schema
      helper.validateFail(schema, data, undefined, done)
    })

    it('should describe minimal length', () => {
      const schema = new MySchema().min(3)
      // use schema
      expect(helper.description(schema)).to.be.a('string')
    })

    it('should check for maximal length', (done) => {
      const data = 'abc'
      const schema = new MySchema().max(3)
      helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      }, done)
    })

    it('should fail for maximal length', (done) => {
      const data = 'abc'
      const schema = new MySchema().max(2)
      // use schema
      helper.validateFail(schema, data, undefined, done)
    })

    it('should describe maximal length', () => {
      const schema = new MySchema().max(5)
      // use schema
      expect(helper.description(schema)).to.be.a('string')
    })

    it('should check for exact length', (done) => {
      const data = 'abc'
      const schema = new MySchema().length(3)
      helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      }, done)
    })

    it('should fail for exact length', (done) => {
      const data = 'abc'
      const schema = new MySchema().length(2)
      // use schema
      helper.validateFail(schema, data, undefined, done)
    })

    it('should describe exact length', () => {
      const schema = new MySchema().length(5)
      // use schema
      expect(helper.description(schema)).to.be.a('string')
    })

    it('should check for range', (done) => {
      const data = 'abc'
      const schema = new MySchema().min(2).max(5)
      helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      }, done)
    })

    it('should fail for range', (done) => {
      const data = 'abc'
      const schema = new MySchema().min(4).max(5)
      // use schema
      helper.validateFail(schema, data, undefined, done)
    })

    it('should describe range', () => {
      const schema = new MySchema().min(3).max(5)
      // use schema
      expect(helper.description(schema)).to.be.a('string')
    })

  })

  describe('pad/truncate', () => {

    it('should not pad', (done) => {
      const data = 'abc'
      const schema = new MySchema().min(3).pad()
      helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      }, done)
    })

    it('should pad', (done) => {
      const data = 'abc'
      const schema = new MySchema().min(5).pad()
      helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal('abc  ')
      }, done)
    })

    it('should pad left', (done) => {
      const data = 'abc'
      const schema = new MySchema().min(5).pad('left')
      helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal('  abc')
      }, done)
    })

    it('should pad both', (done) => {
      const data = 'abc'
      const schema = new MySchema().min(6).pad('both')
      helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(' abc  ')
      }, done)
    })

    it('should pad right char', (done) => {
      const data = 'abc'
      const schema = new MySchema().min(6).pad('right', '12345')
      helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal('abc345')
      }, done)
    })

    it('should pad left char', (done) => {
      const data = 'abc'
      const schema = new MySchema().min(6).pad('left', '12345')
      helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal('123abc')
      }, done)
    })

    it('should pad both char', (done) => {
      const data = 'abc'
      const schema = new MySchema().min(8).pad('both', '-<>-')
      helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal('-<abc>--')
      }, done)
    })

    it('should describe pad', () => {
      const schema = new MySchema().min(5).pad()
      // use schema
      expect(helper.description(schema)).to.be.a('string')
    })

    it('should not truncate', (done) => {
      const data = 'abc'
      const schema = new MySchema().max(3).truncate
      helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      }, done)
    })

    it('should truncate', (done) => {
      const data = 'abcdefg'
      const schema = new MySchema().max(3).truncate
      helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal('abc')
      }, done)
    })

    it('should describe truncate', () => {
      const schema = new MySchema().max(5).truncate
      // use schema
      expect(helper.description(schema)).to.be.a('string')
    })

  })

})
