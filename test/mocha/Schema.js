// @flow
import chai from 'chai'
import Debug from 'debug'

import Schema from '../../src/Schema'
import StringSchema from '../../src/StringSchema'
import Reference from '../../src/Reference'
import SchemaData from '../../src/SchemaData'
import SchemaError from '../../src/SchemaError'
import * as helper from './helper'

const expect = chai.expect
const debug = Debug('test')

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

  describe('meta', () => {

    it('should describe error', () => {
      const schema = new MySchema()
      const value = 5
      const data = new SchemaData(value, '/any/path')
      const err = new SchemaError(schema, data, 'Something is wrong.')
      const msg = err.text
      debug(msg)
      expect(msg).to.equal(`__Something is wrong.__

> Given value was: \`5\`
> At path: \`/any/path\`

But __Schema__ should be defined with:
It is optional and must not be set.`)
    })

    it('should describe error with specific title and detail', () => {
      const schema = new MySchema()
        .title('Test')
        .detail('should be used only for simple testing with')
      const value = 5
      const data = new SchemaData(value, '/any/path')
      const err = new SchemaError(schema, data, 'Something is wrong.')
      const msg = err.text
      debug(msg)
      expect(msg).to.equal(`__Something is wrong.__

> Given value was: \`5\`
> At path: \`/any/path\`

But __Test__ should be used only for simple testing with:
It is optional and must not be set.`)
    })

  })

  describe('base', () => {

    it('should work', () => {
      const data = 5
      const schema = new MySchema(data)
      expect(schema).to.be.an('object')
      // use schema
      return helper.validateOk(schema, 3, (res) => {
        expect(res).deep.equal(data)
      })
    })

    it('should describe', () => {
      const data = 5
      const schema = new MySchema(data)
      // use schema
      expect(helper.description(schema)).to.be.a('string')
    })

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
      expect(helper.description(schema)).to.be.a('string')
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

  describe('raw', () => {

    it('should work', () => {
      const schema = new StringSchema().trim().max(3).raw()
      const data = ' 123 '
      // use schema
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      })
    })

    it('should allow reference', () => {
      const ref = new Reference(true)
      const schema = new StringSchema().trim().max(3).raw(ref)
      const data = ' 123 '
      // use schema
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      })
    })

    it('should describe', () => {
      const schema = new MySchema()
      schema.raw()
      // use schema
      expect(helper.description(schema)).to.be.a('string')
    })

    it('should describe with reference', () => {
      const ref = new Reference(true)
      const schema = new MySchema()
      schema.raw(ref)
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
