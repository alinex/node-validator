// @flow
import chai from 'chai'

import Reference from '../../../src/Reference'
import FunctionSchema from '../../../src/type/Function'
import * as helper from '../helper'

const expect = chai.expect

// to simplify copy and paste in other Schemas
const MySchema = FunctionSchema

describe('function', () => {

  it('should work without specification', () => {
    const data = (e => true)
    const schema = new MySchema()
    expect(schema).to.be.an('object')
    // use schema
    return helper.validateOk(schema, data, (res) => {
      expect(res).deep.equal(data)
    })
  })

  it('should describe', () => {
    const schema = new MySchema()
    // use schema
    expect(helper.description(schema)).to.be.a('string')
  })

  describe('length', () => {

    it('should check for minimal length', () => {
      const data = ((a, b, c) => a + b + c)
      const schema = new MySchema().min(3)
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      })
    })

    it('should fail for minimal length', () => {
      const data = ((a, b, c) => a + b + c)
      const schema = new MySchema().min(5)
      // use schema
      return helper.validateFail(schema, data, undefined)
    })

    it('should remove minimal length setting', () => {
      const data = ((a, b, c) => a + b + c)
      const schema = new MySchema().min(5).min()
      // use schema
      return helper.validateOk(schema, data, undefined)
    })

    it('should allow reference for minimal length', () => {
      const data = ((a, b, c) => a + b + c)
      const ref = new Reference(5)
      const schema = new MySchema().min(ref)
      // use schema
      return helper.validateFail(schema, data, undefined)
    })

    it('should describe minimal length', () => {
      const schema = new MySchema().min(3)
      // use schema
      expect(helper.description(schema)).to.be.a('string')
    })

    it('should describe minimal length with reference', () => {
      const ref = new Reference(5)
      const schema = new MySchema().min(ref)
      // use schema
      expect(helper.description(schema)).to.be.a('string')
    })

    it('should check for maximal length', () => {
      const data = ((a, b, c) => a + b + c)
      const schema = new MySchema().max(3)
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      })
    })

    it('should fail for maximal length', () => {
      const data = ((a, b, c) => a + b + c)
      const schema = new MySchema().max(2)
      // use schema
      return helper.validateFail(schema, data, undefined)
    })
    // +33 78 168 78 96

    it('should remove maximal length setting', () => {
      const data = ((a, b, c) => a + b + c)
      const schema = new MySchema().max(2).max()
      // use schema
      return helper.validateOk(schema, data, undefined)
    })

    it('should allow reference for maximal length', () => {
      const data = ((a, b, c) => a + b + c)
      const ref = new Reference(2)
      const schema = new MySchema().max(ref)
      // use schema
      return helper.validateFail(schema, data, undefined)
    })

    it('should describe maximal length', () => {
      const schema = new MySchema().max(5)
      // use schema
      expect(helper.description(schema)).to.be.a('string')
    })

    it('should describe maximal length with reference', () => {
      const ref = new Reference(5)
      const schema = new MySchema().max(ref)
      // use schema
      expect(helper.description(schema)).to.be.a('string')
    })

    it('should check for exact length', () => {
      const data = ((a, b, c) => a + b + c)
      const schema = new MySchema().length(3)
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      })
    })

    it('should fail for exact length', () => {
      const data = ((a, b, c) => a + b + c)
      const schema = new MySchema().length(2)
      // use schema
      return helper.validateFail(schema, data, undefined)
    })

    it('should allow to remove complete length setting', () => {
      const data = ((a, b, c) => a + b + c)
      const schema = new MySchema().min(12).max(15).length()
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      })
    })

    it('should allow reference for exact length', () => {
      const data = ((a, b, c) => a + b + c)
      const ref = new Reference(5)
      const schema = new MySchema().length(ref)
      // use schema
      return helper.validateFail(schema, data, undefined)
    })

    it('should describe exact length', () => {
      const schema = new MySchema().length(5)
      // use schema
      expect(helper.description(schema)).to.be.a('string')
    })

    it('should describe exact length with reference', () => {
      const ref = new Reference(5)
      const schema = new MySchema().length(ref)
      // use schema
      expect(helper.description(schema)).to.be.a('string')
    })

    it('should check for range', () => {
      const data = ((a, b, c) => a + b + c)
      const schema = new MySchema().min(2).max(5)
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      })
    })

    it('should fail for range', () => {
      const data = ((a, b, c) => a + b + c)
      const schema = new MySchema().min(4).max(5)
      // use schema
      return helper.validateFail(schema, data, undefined)
    })

    it('should describe range', () => {
      const schema = new MySchema().min(3).max(5)
      // use schema
      expect(helper.description(schema)).to.be.a('string')
    })

  })

})
