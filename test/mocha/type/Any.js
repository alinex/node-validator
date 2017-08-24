// @flow
import chai from 'chai'

import Reference from '../../../src/Reference'
import AnySchema from '../../../src/type/Any'
import * as helper from '../helper'

const expect = chai.expect

// to simplify copy and paste in other Schemas
const MySchema = AnySchema

describe('any', () => {

  it('should work without specification', () => {
    const data = 5
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
    expect(helper.description(schema)).to.equal('It is optional and must not be set.')
  })

  describe('allow', () => {

    it('should allow single value', () => {
      const data = 'a'
      const schema = new MySchema()
      schema.allow(data)
      // use schema
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      })
    })

    it('should allow list', () => {
      const data = 'a'
      const schema = new MySchema()
      schema.allow(data, 'b')
      // use schema
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      })
    })

    it('should allow array', () => {
      const data = 'a'
      const schema = new MySchema()
      schema.allow([data, 'b'])
      // use schema
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      })
    })

    it('should fail if not in allowed list', () => {
      const data = 'b'
      const schema = new MySchema()
      schema.allow('a')
      // use schema
      return helper.validateFail(schema, data, undefined)
    })

    it('should overwrite old list', () => {
      const data = 'b'
      const schema = new MySchema()
      schema.allow('b').allow('a')
      // use schema
      return helper.validateFail(schema, data, undefined)
    })

    it('should allow remove', () => {
      const data = 'a'
      const schema = new MySchema()
      schema.allow('b').allow()
      // use schema
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      })
    })

    it('should allow reference as list', () => {
      const data = 'a'
      const ref = new Reference(['a'])
      const schema = new MySchema()
      schema.allow(ref)
      // use schema
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      })
    })

    it('should allow reference as element', () => {
      const data = 'a'
      const ref = new Reference(data)
      const schema = new MySchema()
      schema.allow(ref)
      // use schema
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      })
    })

    it('should allow reference in list', () => {
      const data = 'a'
      const ref = new Reference(data)
      const schema = new MySchema()
      schema.allow(1, ref)
      // use schema
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      })
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

    it('should allow single value', () => {
      const data = 'a'
      const schema = new MySchema()
      schema.deny(data)
      // use schema
      return helper.validateFail(schema, data, undefined)
    })

    it('should allow list', () => {
      const data = 'a'
      const schema = new MySchema()
      schema.deny(data, 'b')
      // use schema
      return helper.validateFail(schema, data, undefined)
    })

    it('should allow array', () => {
      const data = 'a'
      const schema = new MySchema()
      schema.deny([data, 'b'])
      // use schema
      return helper.validateFail(schema, data, undefined)
    })

    it('should work if not in denied list', () => {
      const data = 'b'
      const schema = new MySchema()
      schema.deny('a')
      // use schema
      return helper.validateOk(schema, data, undefined)
    })

    it('should overwrite old list', () => {
      const data = 'b'
      const schema = new MySchema()
      schema.deny('b').deny('a')
      // use schema
      return helper.validateOk(schema, data, undefined)
    })

    it('should allow remove', () => {
      const data = 'a'
      const schema = new MySchema()
      schema.deny('b').deny()
      // use schema
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      })
    })

    it('should allow reference as list', () => {
      const data = 'a'
      const ref = new Reference(['a'])
      const schema = new MySchema()
      schema.deny(ref)
      // use schema
      return helper.validateFail(schema, data, undefined)
    })

    it('should allow reference as element', () => {
      const data = 'a'
      const ref = new Reference(data)
      const schema = new MySchema()
      schema.deny(ref)
      // use schema
      return helper.validateFail(schema, data, undefined)
    })

    it('should allow reference in list', () => {
      const data = 'a'
      const ref = new Reference(data)
      const schema = new MySchema()
      schema.deny(1, ref)
      // use schema
      return helper.validateFail(schema, data, undefined)
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

    it('should allow specific object', () => {
      const data = 'a'
      const schema = new MySchema()
      schema.valid(data)
      // use schema
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      })
    })

    it('should fail if not in allowed list', () => {
      const data = 'b'
      const schema = new MySchema()
      schema.valid('a')
      // use schema
      return helper.validateFail(schema, data, undefined)
    })

    it('should remove from deny if allowed later', () => {
      const data = 'a'
      const schema = new MySchema()
      schema.invalid(data)
        .valid(data)
      // use schema
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      })
    })

    it('should be optional if undefined is allowed', () => {
      const data = undefined
      const schema = new MySchema()
      schema.required()
        .valid(undefined)
      // use schema
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      })
    })

    it('should allow reference', () => {
      const data = 'a'
      const ref = new Reference('a')
      const schema = new MySchema()
      schema.valid(ref)
      // use schema
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      })
    })

    it('should describe valid', () => {
      const schema = new MySchema()
      schema.valid('a')
      // use schema
      expect(helper.description(schema)).to.be.a('string')
    })

  })

  describe('invalid', () => {

    it('should fail if in denied list', () => {
      const data = 'a'
      const schema = new MySchema()
      schema.invalid(data)
      // use schema
      return helper.validateFail(schema, data, undefined)
    })

    it('should work if not in denied list', () => {
      const data = 'a'
      const schema = new MySchema()
      schema.invalid('b')
      // use schema
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      })
    })

    it('should remove from allow if denied later', () => {
      const data = 'a'
      const schema = new MySchema()
      schema.valid(data)
        .invalid(data)
      // use schema
      return helper.validateFail(schema, data, undefined)
    })

    it('should be required if undefined is denied', () => {
      const data = undefined
      const schema = new MySchema()
      schema.invalid(undefined)
      // use schema
      return helper.validateFail(schema, data, undefined)
    })

    it('should allow reference', () => {
      const data = 'a'
      const ref = new Reference(data)
      const schema = new MySchema()
      schema.invalid(ref)
      // use schema
      return helper.validateFail(schema, data, undefined)
    })

    it('should describe invalid', () => {
      const schema = new MySchema()
      schema.invalid('a')
      // use schema
      expect(helper.description(schema)).to.be.a('string')
    })

  })

})
