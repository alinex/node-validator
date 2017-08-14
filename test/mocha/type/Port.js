// @flow
import chai from 'chai'

import Reference from '../../../src/Reference'
import PortSchema from '../../../src/PortSchema'
import Schema from '../../../src/Schema'
import * as helper from '../helper'

const expect = chai.expect

// to simplify copy and paste in other Schemas
const MySchema = PortSchema

describe('number', () => {
  it('should work with number', (done) => {
    const data = 12
    const schema = new MySchema()
    expect(schema).to.be.an('object')
    // use schema
    helper.validateOk(schema, data, (res) => {
      expect(res).deep.equal(data)
    }, done)
  })

  it('should fail with float', (done) => {
    const data = 12.8
    const schema = new MySchema()
    expect(schema).to.be.an('object')
    // use schema
    helper.validateFail(schema, data, undefined, done)
  })

  it('should fail with negative value', (done) => {
    const data = -12
    const schema = new MySchema()
    expect(schema).to.be.an('object')
    // use schema
    helper.validateFail(schema, data, undefined, done)
  })

  it('should describe', () => {
    const schema = new MySchema()
    // use schema
    expect(helper.description(schema)).to.be.a('string')
  })

  describe('sanitize', () => {
    it('should work with string number', (done) => {
      const data = '12'
      const schema = new MySchema()
      // use schema
      helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(12)
      }, done)
    })

    it('should work with string name', (done) => {
      const data = 'http'
      const schema = new MySchema()
      // use schema
      helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(80)
      }, done)
    })

  })

  describe('minmax', () => {

    it('should fail with negative', (done) => {
      const data = -12
      const schema = new MySchema()
      // use schema
      helper.validateFail(schema, data, undefined, done)
    })

    it('should support min', (done) => {
      const data = 12
      const schema = new MySchema().min(5)
      // use schema
      helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      }, done)
    })

    it('should fail with min', (done) => {
      const data = -12
      const schema = new MySchema().min(5)
      // use schema
      helper.validateFail(schema, data, undefined, done)
    })

    it('should describe min', () => {
      const schema = new MySchema().min(5)
      // use schema
      expect(helper.description(schema)).to.be.a('string')
    })

    it('should support greater', (done) => {
      const data = 12
      const schema = new MySchema().greater(5)
      // use schema
      helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      }, done)
    })

    it('should fail with greater', (done) => {
      const data = 5
      const schema = new MySchema().greater(5)
      // use schema
      helper.validateFail(schema, data, undefined, done)
    })

    it('should describe greater', () => {
      const schema = new MySchema().greater(5)
      // use schema
      expect(helper.description(schema)).to.be.a('string')
    })

    it('should support less', (done) => {
      const data = 4
      const schema = new MySchema().less(5)
      // use schema
      helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      }, done)
    })

    it('should fail with less', (done) => {
      const data = 5
      const schema = new MySchema().less(5)
      // use schema
      helper.validateFail(schema, data, undefined, done)
    })

    it('should describe less', () => {
      const schema = new MySchema().less(5)
      // use schema
      expect(helper.description(schema)).to.be.a('string')
    })

    it('should support max', (done) => {
      const data = 4
      const schema = new MySchema().max(5)
      // use schema
      helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      }, done)
    })

    it('should fail with max', (done) => {
      const data = 12
      const schema = new MySchema().max(5)
      // use schema
      helper.validateFail(schema, data, undefined, done)
    })

    it('should describe max', () => {
      const schema = new MySchema().max(5)
      // use schema
      expect(helper.description(schema)).to.be.a('string')
    })

    it('should allow reference for min', (done) => {
      const data = 12
      const ref = new Reference(16)
      const schema = new MySchema().min(ref)
      // use schema
      helper.validateFail(schema, data, undefined, done)
    })

    it('should allow reference for max', (done) => {
      const data = 12
      const ref = new Reference(10)
      const schema = new MySchema().max(ref)
      // use schema
      helper.validateFail(schema, data, undefined, done)
    })

    it('should allow reference for greater', (done) => {
      const data = -12
      const ref = new Reference(-12)
      const schema = new MySchema().greater(ref)
      // use schema
      helper.validateFail(schema, data, undefined, done)
    })

    it('should allow reference for less', (done) => {
      const data = -12
      const ref = new Reference(-12)
      const schema = new MySchema().less(ref)
      // use schema
      helper.validateFail(schema, data, undefined, done)
    })

    it('should describe with reference for min', () => {
      const ref = new Reference(5)
      const schema = new MySchema().min(ref)
      // use schema
      expect(helper.description(schema)).to.be.a('string')
    })

    it('should describe with reference for max', () => {
      const ref = new Reference(5)
      const schema = new MySchema().max(ref)
      // use schema
      expect(helper.description(schema)).to.be.a('string')
    })

    it('should describe with reference for greater', () => {
      const ref = new Reference(5)
      const schema = new MySchema().greater(ref)
      // use schema
      expect(helper.description(schema)).to.be.a('string')
    })

    it('should describe with reference for less', () => {
      const ref = new Reference(5)
      const schema = new MySchema().less(ref)
      // use schema
      expect(helper.description(schema)).to.be.a('string')
    })

  })

  describe('deny', () => {

    it('should fail on deny', (done) => {
      const data = 8080
      const schema = new MySchema().deny([8080, 'system'])
      // use schema
      helper.validateFail(schema, data, undefined, done)
    })

    it('should fail on deny range', (done) => {
      const data = 80
      const schema = new MySchema().deny([8080, 'system'])
      // use schema
      helper.validateFail(schema, data, undefined, done)
    })

    it('should work with deny range', (done) => {
      const data = 8081
      const schema = new MySchema().deny([8080, 'system'])
      // use schema
      helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      }, done)
    })

    it('should fail on allow', (done) => {
      const data = 8081
      const schema = new MySchema().allow([8080, 'system'])
      // use schema
      helper.validateFail(schema, data, undefined, done)
    })

    it('should work on allow', (done) => {
      const data = 8080
      const schema = new MySchema().allow([8080, 'system'])
      // use schema
      helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      }, done)
    })

    it('should work with allow range', (done) => {
      const data = 80
      const schema = new MySchema().allow([8080, 'system'])
      // use schema
      helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      }, done)
    })

    it('should fail on allow with deny', (done) => {
      const data = 80
      const schema = new MySchema().allow(['system']).deny([80])
      // use schema
      helper.validateFail(schema, data, undefined, done)
    })

  })

})
