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
  it('should work with number', () => {
    const data = 12
    const schema = new MySchema()
    expect(schema).to.be.an('object')
    // use schema
    return helper.validateOk(schema, data, (res) => {
      expect(res).deep.equal(data)
    })
  })

  it('should fail with float', () => {
    const data = 12.8
    const schema = new MySchema()
    expect(schema).to.be.an('object')
    // use schema
    return helper.validateFail(schema, data, undefined)
  })

  it('should fail with negative value', () => {
    const data = -12
    const schema = new MySchema()
    expect(schema).to.be.an('object')
    // use schema
    return helper.validateFail(schema, data, undefined)
  })

  it('should describe', () => {
    const schema = new MySchema()
    // use schema
    expect(helper.description(schema)).to.be.a('string')
  })

  describe('sanitize', () => {
    it('should work with string number', () => {
      const data = '12'
      const schema = new MySchema()
      // use schema
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(12)
      })
    })

    it('should work with string name', () => {
      const data = 'http'
      const schema = new MySchema()
      // use schema
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(80)
      })
    })

  })

  describe('minmax', () => {

    it('should fail with negative', () => {
      const data = -12
      const schema = new MySchema()
      // use schema
      return helper.validateFail(schema, data, undefined)
    })

    it('should support min', () => {
      const data = 12
      const schema = new MySchema().min(5)
      // use schema
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      })
    })

    it('should fail with min', () => {
      const data = -12
      const schema = new MySchema().min(5)
      // use schema
      return helper.validateFail(schema, data, undefined)
    })

    it('should describe min', () => {
      const schema = new MySchema().min(5)
      // use schema
      expect(helper.description(schema)).to.be.a('string')
    })

    it('should support greater', () => {
      const data = 12
      const schema = new MySchema().greater(5)
      // use schema
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      })
    })

    it('should fail with greater', () => {
      const data = 5
      const schema = new MySchema().greater(5)
      // use schema
      return helper.validateFail(schema, data, undefined)
    })

    it('should describe greater', () => {
      const schema = new MySchema().greater(5)
      // use schema
      expect(helper.description(schema)).to.be.a('string')
    })

    it('should support less', () => {
      const data = 4
      const schema = new MySchema().less(5)
      // use schema
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      })
    })

    it('should fail with less', () => {
      const data = 5
      const schema = new MySchema().less(5)
      // use schema
      return helper.validateFail(schema, data, undefined)
    })

    it('should describe less', () => {
      const schema = new MySchema().less(5)
      // use schema
      expect(helper.description(schema)).to.be.a('string')
    })

    it('should support max', () => {
      const data = 4
      const schema = new MySchema().max(5)
      // use schema
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      })
    })

    it('should fail with max', () => {
      const data = 12
      const schema = new MySchema().max(5)
      // use schema
      return helper.validateFail(schema, data, undefined)
    })

    it('should describe max', () => {
      const schema = new MySchema().max(5)
      // use schema
      expect(helper.description(schema)).to.be.a('string')
    })

    it('should allow reference for min', () => {
      const data = 12
      const ref = new Reference(16)
      const schema = new MySchema().min(ref)
      // use schema
      return helper.validateFail(schema, data, undefined)
    })

    it('should allow reference for max', () => {
      const data = 12
      const ref = new Reference(10)
      const schema = new MySchema().max(ref)
      // use schema
      return helper.validateFail(schema, data, undefined)
    })

    it('should allow reference for greater', () => {
      const data = -12
      const ref = new Reference(-12)
      const schema = new MySchema().greater(ref)
      // use schema
      return helper.validateFail(schema, data, undefined)
    })

    it('should allow reference for less', () => {
      const data = -12
      const ref = new Reference(-12)
      const schema = new MySchema().less(ref)
      // use schema
      return helper.validateFail(schema, data, undefined)
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

    it('should fail on deny', () => {
      const data = 8080
      const schema = new MySchema().deny([8080, 'system'])
      // use schema
      return helper.validateFail(schema, data, undefined)
    })

    it('should fail on deny range', () => {
      const data = 80
      const schema = new MySchema().deny([8080, 'system'])
      // use schema
      return helper.validateFail(schema, data, undefined)
    })

    it('should work with deny range', () => {
      const data = 8081
      const schema = new MySchema().deny([8080, 'system'])
      // use schema
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      })
    })

    it('should fail on allow', () => {
      const data = 8081
      const schema = new MySchema().allow([8080, 'system'])
      // use schema
      return helper.validateFail(schema, data, undefined)
    })

    it('should work on allow', () => {
      const data = 8080
      const schema = new MySchema().allow([8080, 'system'])
      // use schema
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      })
    })

    it('should work with allow range', () => {
      const data = 80
      const schema = new MySchema().allow([8080, 'system'])
      // use schema
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      })
    })

    it('should fail on allow with deny', () => {
      const data = 80
      const schema = new MySchema().allow(['system']).deny([80])
      // use schema
      return helper.validateFail(schema, data, undefined)
    })

  })

})
