// @flow
import chai from 'chai'

import Schema from '../../src/Schema'
import Reference from '../../src/Reference'
import * as helper from './helper'

const expect = chai.expect

// to simplify copy and paste in other Schemas
const MySchema = Schema

describe('schema', () => {

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

  describe('required', () => {

    it('should work', () => {
      const data = 5
      const schema = new MySchema().required()
      expect(schema).to.be.an('object')
      // use schema
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      })
    })

    it('should fail', () => {
      const schema = new MySchema().required()
      // use schema
      return helper.validateFail(schema)
    })

    it('should rallow emove', () => {
      const schema = new MySchema().required().required(false)
      expect(schema).to.be.an('object')
      // use schema
      return helper.validateOk(schema)
    })

    it('should allow references', () => {
      const ref = new Reference(true)
      const schema = new MySchema().required(ref)
      // use schema
      return helper.validateFail(schema)
    })

    it('should describe', () => {
      const schema = new MySchema().required()
      // use schema
      expect(helper.description(schema)).to.equal('')
    })

    it('should describe', () => {
      const ref = new Reference(true)
      const schema = new MySchema().required(ref)
      // use schema
      expect(helper.description(schema)).to.be.a('string')
    })

  })

  describe('default', () => {

    it('should work', () => {
      const data = 5
      const schema = new MySchema()
      expect(schema).to.be.an('object')
      schema.default(data)
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      })
    })

    it('should fail with required and undefined default', () => {
      const schema = new MySchema()
      schema.required().default(undefined)
      // use schema
      return helper.validateFail(schema)
    })

    it('should allow remove', () => {
      const schema = new MySchema()
      expect(schema).to.be.an('object')
      schema.default(5).default()
      // use schema
      return helper.validateOk(schema)
    })

    it('should allow references', () => {
      const data = 5
      const ref = new Reference(true)
      const schema = new MySchema()
      schema.default(ref)
      expect(schema).to.be.an('object')
      // use schema
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      })
    })

    it('should describe', () => {
      const schema = new MySchema()
      schema.default(5)
      // use schema
      expect(helper.description(schema)).to.be.a('string')
    })

    it('should describe with reference', () => {
      const ref = new Reference(5)
      const schema = new MySchema()
      schema.default(ref)
      // use schema
      expect(helper.description(schema)).to.be.a('string')
    })

  })

  describe('stripEmpty', () => {

    it('should fail with null', () => {
      const schema = new MySchema().required().stripEmpty()
      // use schema
      return helper.validateFail(schema, null)
    })

    it('should fail with empty String', () => {
      const schema = new MySchema().required().stripEmpty()
      // use schema
      return helper.validateFail(schema, '')
    })

    it('should fail with empty Array', () => {
      const schema = new MySchema().required().stripEmpty()
      // use schema
      return helper.validateFail(schema, [])
    })

    it('should fail with empty Object', () => {
      const schema = new MySchema().required().stripEmpty()
      // use schema
      return helper.validateFail(schema, {})
    })

    it('should allow remove', () => {
      const schema = new MySchema().required().stripEmpty(false)
      // use schema
      return helper.validateOk(schema, '')
    })

    it('should allow reference', () => {
      const ref = new Reference(true)
      const schema = new MySchema().required().stripEmpty(ref)
      // use schema
      return helper.validateFail(schema, null)
    })

    it('should describe', () => {
      const schema = new MySchema()
      schema.stripEmpty()
      // use schema
      expect(helper.description(schema)).to.be.a('string')
    })

    it('should describe with reference', () => {
      const ref = new Reference(true)
      const schema = new MySchema()
      schema.stripEmpty(ref)
      // use schema
      expect(helper.description(schema)).to.be.a('string')
    })

  })

  describe('clone', () => {

    it('should clone schema', () => {
      const schema = new MySchema()
      const clone = schema.clone
      // use schema
      expect(clone).to.be.an.instanceof(Schema).and.not.equal(schema)
    })

  })

})
