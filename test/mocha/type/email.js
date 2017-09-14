// @flow
import chai from 'chai'

import Reference from '../../../src/Reference'
import EmailSchema from '../../../src/type/Email'
import Schema from '../../../src/type/Schema'
import * as helper from '../helper'

const expect = chai.expect

// to simplify copy and paste in other Schemas
const MySchema = EmailSchema

describe('email', () => {

  describe('simple', () => {

    it('should remove name part', () => {
      const data = 'Alex <alex@alinex.de>'
      const schema = new MySchema()
      expect(schema).to.be.an('object')
      // use schema
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal('alex@alinex.de')
      })
    })

    it('should keep name part', () => {
      const data = 'Alex <alex@alinex.de>'
      const schema = new MySchema().withName()
      expect(schema).to.be.an('object')
      // use schema
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      })
    })

    it('should fail without server part', () => {
      const data = 'alinex'
      const schema = new MySchema()
      expect(schema).to.be.an('object')
      // use schema
      return helper.validateFail(schema, data)
    })

    it('should describe', () => {
      const schema = new MySchema()
      // use schema
      expect(helper.description(schema)).to.be.a('string')
    })

    it('should describe with name', () => {
      const schema = new MySchema().withName()
      // use schema
      expect(helper.description(schema)).to.be.a('string')
    })

  })

  describe('dns', () => {

    it('should check', () => {
      const data = 'Alex <alex@alinex.de>'
      const schema = new MySchema().dns()
      expect(schema).to.be.an('object')
      // use schema
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal('alex@alinex.de')
      })
    })

    it('should fail', () => {
      const data = 'Alex <alex@www.alinex.de>'
      const schema = new MySchema().dns()
      expect(schema).to.be.an('object')
      // use schema
      return helper.validateFail(schema, data)
    })

    it('should describe', () => {
      const schema = new MySchema().dns()
      // use schema
      expect(helper.description(schema)).to.be.a('string')
    })

  })

  describe('allow', () => {

    it('should work with email', () => {
      const data = 'alex@alinex.de'
      const schema = new MySchema().allow(data)
      expect(schema).to.be.an('object')
      // use schema
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      })
    })

    it('should fail with email', () => {
      const data = 'alex@alinex.de'
      const schema = new MySchema().deny(data)
      expect(schema).to.be.an('object')
      // use schema
      return helper.validateFail(schema, data)
    })

    it('should work with domain', () => {
      const data = 'alex@alinex.de'
      const schema = new MySchema().allow('alinex.de')
      expect(schema).to.be.an('object')
      // use schema
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      })
    })

    it('should fail with domain', () => {
      const data = 'alex@alinex.de'
      const schema = new MySchema().deny('alinex.de')
      expect(schema).to.be.an('object')
      // use schema
      return helper.validateFail(schema, data)
    })

    it('should work with TLD', () => {
      const data = 'alex@alinex.de'
      const schema = new MySchema().allow('de')
      expect(schema).to.be.an('object')
      // use schema
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      })
    })

    it('should fail with TLD', () => {
      const data = 'alex@alinex.de'
      const schema = new MySchema().deny('de')
      expect(schema).to.be.an('object')
      // use schema
      return helper.validateFail(schema, data)
    })

    it('should work with email althought domain is denied', () => {
      const data = 'alex@alinex.de'
      const schema = new MySchema().deny('alinex.de').allow(data)
      expect(schema).to.be.an('object')
      // use schema
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      })
    })

    it('should fail with email althought domain is allowed', () => {
      const data = 'alex@alinex.de'
      const schema = new MySchema().deny(data).allow('alinex.de')
      expect(schema).to.be.an('object')
      // use schema
      return helper.validateFail(schema, data)
    })

  })

  describe.only('connect', () => {

    it('should work', () => {
      const data = 'alex@alinex.de'
      const schema = new MySchema().connect()
      expect(schema).to.be.an('object')
      // use schema
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      })
    })

  })

})
