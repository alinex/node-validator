// @flow
import chai from 'chai'

import Reference from '../../../src/Reference'
import DomainSchema from '../../../src/type/Domain'
import Schema from '../../../src/type/Schema'
import * as helper from '../helper'

const expect = chai.expect

// to simplify copy and paste in other Schemas
const MySchema = DomainSchema

describe('domain', () => {

  describe('simple', () => {

    it('should work', () => {
      const data = 'alinex.de'
      const schema = new MySchema()
      expect(schema).to.be.an('object')
      // use schema
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      })
    })

    it('should fail if too long', () => {
      const data = 'alinex is the name of my development projects and also available as a domain name \
registered to me personally so it may be accessed using alinex.de - this whole text is way too long to \
be a valid domain name and so should be rejected because it can not be a domain with this length'
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

  })

  describe('allow', () => {

    it('should work with fqdn', () => {
      const data = 'alinex.de'
      const schema = new MySchema().allow(data)
      expect(schema).to.be.an('object')
      // use schema
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      })
    })

    it('should fail with fqdn', () => {
      const data = 'alinex.de'
      const schema = new MySchema().deny(data)
      expect(schema).to.be.an('object')
      // use schema
      return helper.validateFail(schema, data)
    })

    it('should work with domain', () => {
      const data = 'alex.alinex.de'
      const schema = new MySchema().allow('alinex.de')
      expect(schema).to.be.an('object')
      // use schema
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      })
    })

    it('should fail with domain', () => {
      const data = 'alex.alinex.de'
      const schema = new MySchema().deny('alinex.de')
      expect(schema).to.be.an('object')
      // use schema
      return helper.validateFail(schema, data)
    })

    it('should work with TLD', () => {
      const data = 'alex.alinex.de'
      const schema = new MySchema().allow('de')
      expect(schema).to.be.an('object')
      // use schema
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      })
    })

    it('should fail with TLD', () => {
      const data = 'alex.alinex.de'
      const schema = new MySchema().deny('de')
      expect(schema).to.be.an('object')
      // use schema
      return helper.validateFail(schema, data)
    })

    it('should work with email althought domain is denied', () => {
      const data = 'alex.alinex.de'
      const schema = new MySchema().deny('alinex.de').allow(data)
      expect(schema).to.be.an('object')
      // use schema
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      })
    })

    it('should fail with email althought domain is allowed', () => {
      const data = 'alex.alinex.de'
      const schema = new MySchema().deny(data).allow('alinex.de')
      expect(schema).to.be.an('object')
      // use schema
      return helper.validateFail(schema, data)
    })

  })

  describe('dns', function dnstest() {
    this.timeout(5000)

    it('should work with domain', () => {
      const data = 'alinex.de'
      const schema = new MySchema().dns()
      expect(schema).to.be.an('object')
      // use schema
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      })
    })

    it('should fail with domain', () => {
      const data = 'alex.alinex'
      const schema = new MySchema().dns()
      expect(schema).to.be.an('object')
      // use schema
      return helper.validateFail(schema, data)
    })

    it('should work with MX check', () => {
      const data = 'alinex.de'
      const schema = new MySchema().dns('MX')
      expect(schema).to.be.an('object')
      // use schema
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      })
    })

    it('should fail with MX check', () => {
      const data = 'www.alinex.de'
      const schema = new MySchema().dns('MX')
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

  describe('punycode', () => {

    it('should keep unicode if not set', () => {
      const data = 'lügen.de'
      const schema = new MySchema()
      expect(schema).to.be.an('object')
      // use schema
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      })
    })

    it('should transform to ascii', () => {
      const data = 'lügen.de'
      const schema = new MySchema().punycode()
      expect(schema).to.be.an('object')
      // use schema
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal('xn--lgen-0ra.de')
      })
    })

    it('should describe', () => {
      const schema = new MySchema().punycode()
      // use schema
      expect(helper.description(schema)).to.be.a('string')
    })

  })

  describe('resolve', () => {

    it('should work', () => {
      const data = 'alinex.de'
      const schema = new MySchema().resolve()
      expect(schema).to.be.an('object')
      // use schema
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal('95.173.102.23')
      })
    })

    it('should describe', () => {
      const schema = new MySchema().resolve()
      // use schema
      expect(helper.description(schema)).to.be.a('string')
    })

  })

})
