// @flow
import chai from 'chai'

import Reference from '../../../src/Reference'
import IPSchema from '../../../src/type/IP'
import Schema from '../../../src/type/Schema'
import * as helper from '../helper'

const expect = chai.expect

// to simplify copy and paste in other Schemas
const MySchema = IPSchema

describe('ip', () => {

  describe('simple', () => {

    it('should work with local ipv4', () => {
      const data = '127.0.0.1'
      const schema = new MySchema()
      expect(schema).to.be.an('object')
      // use schema
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      })
    })

    it('should work with ipv4', () => {
      const data = '192.12.1.1'
      const schema = new MySchema()
      expect(schema).to.be.an('object')
      // use schema
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      })
    })

    it('should work with ipv6', () => {
      const data = 'ffff::'
      const schema = new MySchema()
      expect(schema).to.be.an('object')
      // use schema
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      })
    })

    it('should work with byte array', () => {
      const data = ['192', '12', '1', '1']
      const schema = new MySchema()
      expect(schema).to.be.an('object')
      // use schema
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal('192.12.1.1')
      })
    })

    it('should fail for object', () => {
      const data = { a: 1 }
      const schema = new MySchema()
      expect(schema).to.be.an('object')
      // use schema
      return helper.validateFail(schema, data)
    })

    it('should fail for number', () => {
      const data = 1
      const schema = new MySchema()
      expect(schema).to.be.an('object')
      // use schema
      return helper.validateFail(schema, data)
    })

    it('should fail for empty array', () => {
      const data = []
      const schema = new MySchema()
      expect(schema).to.be.an('object')
      // use schema
      return helper.validateFail(schema, data)
    })

    it('should fail for other string', () => {
      const data = 'localhost'
      const schema = new MySchema()
      expect(schema).to.be.an('object')
      // use schema
      return helper.validateFail(schema, data)
    })

    it('should fail for invalid ip', () => {
      const data = '300.92.16.2'
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

  describe('lookup', () => {

    it('should work with localhost', () => {
      const data = 'localhost'
      const schema = new MySchema().lookup()
      expect(schema).to.be.an('object')
      // use schema
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal('127.0.0.1')
      })
    })

    it('should fail for invalid name', () => {
      const data = 'not.existing.domain'
      const schema = new MySchema()
      expect(schema).to.be.an('object')
      // use schema
      return helper.validateFail(schema, data)
    })

    it('should fail for invalid ip', () => {
      const data = '300.92.16.2'
      const schema = new MySchema()
      expect(schema).to.be.an('object')
      // use schema
      return helper.validateFail(schema, data)
    })

    it('should describe', () => {
      const schema = new MySchema().lookup()
      // use schema
      expect(helper.description(schema)).to.be.a('string')
    })

  })

  describe('allow', () => {

    it('should work with allow specific address', () => {
      const data = '218.92.16.2'
      const schema = new MySchema().allow(data)
      expect(schema).to.be.an('object')
      // use schema
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      })
    })

    it('should fail with allow specific address', () => {
      const data = '218.92.16.2'
      const schema = new MySchema().allow('218.92.16.1')
      expect(schema).to.be.an('object')
      // use schema
      return helper.validateFail(schema, data)
    })

    it('should work with deny specific address', () => {
      const data = '218.92.16.2'
      const schema = new MySchema().deny('218.92.16.1')
      expect(schema).to.be.an('object')
      // use schema
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      })
    })

    it('should fail with deny specific address', () => {
      const data = '218.92.16.2'
      const schema = new MySchema().deny(data)
      expect(schema).to.be.an('object')
      // use schema
      return helper.validateFail(schema, data)
    })

    it('should work with allow range', () => {
      const data = '192.168.100.1'
      const schema = new MySchema().allow('private')
      expect(schema).to.be.an('object')
      // use schema
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      })
    })

    it('should fail with allow range', () => {
      const data = '218.92.16.2'
      const schema = new MySchema().allow('private')
      expect(schema).to.be.an('object')
      // use schema
      return helper.validateFail(schema, data)
    })

    it('should work with deny range', () => {
      const data = '218.92.16.2'
      const schema = new MySchema().deny('private')
      expect(schema).to.be.an('object')
      // use schema
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      })
    })

    it('should fail with deny range', () => {
      const data = '192.168.100.1'
      const schema = new MySchema().deny('private')
      expect(schema).to.be.an('object')
      // use schema
      return helper.validateFail(schema, data)
    })

    it('should work with deny range but allowed sub range', () => {
      const data = '192.168.100.1'
      const schema = new MySchema().deny('private').allow('192.168.0.0/16')
      expect(schema).to.be.an('object')
      // use schema
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      })
    })

    it('should fail with allow range and denied sub range', () => {
      const data = '192.168.100.1'
      const schema = new MySchema().allow('private').deny('192.168.0.0/16')
      expect(schema).to.be.an('object')
      // use schema
      return helper.validateFail(schema, data)
    })

  })

  describe('version', () => {

    it('should work with ipv4', () => {
      const data = '127.0.0.1'
      const schema = new MySchema().version(4)
      expect(schema).to.be.an('object')
      // use schema
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      })
    })

    it('should fail for invalid ipV6', () => {
      const data = 'ffff::'
      const schema = new MySchema().version(4)
      expect(schema).to.be.an('object')
      // use schema
      return helper.validateFail(schema, data)
    })

    it('should work with ipv6', () => {
      const data = 'ffff::'
      const schema = new MySchema().version(6)
      expect(schema).to.be.an('object')
      // use schema
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      })
    })

    it('should fail for invalid ipV4', () => {
      const data = '127.0.0.1'
      const schema = new MySchema().version(6)
      expect(schema).to.be.an('object')
      // use schema
      return helper.validateFail(schema, data)
    })

    it('should describe', () => {
      const schema = new MySchema().version(4)
      // use schema
      expect(helper.description(schema)).to.be.a('string')
    })

  })

  describe('format', () => {

    it('should allow long format', () => {
      const data = 'ffff::'
      const schema = new MySchema().format('long')
      expect(schema).to.be.an('object')
      // use schema
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal('ffff:0:0:0:0:0:0:0')
      })
    })

    it('should allow array format', () => {
      const data = 'ffff::'
      const schema = new MySchema().format('array')
      expect(schema).to.be.an('object')
      // use schema
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal([65535, 0, 0, 0, 0, 0, 0, 0])
      })
    })

    it('should describe with long', () => {
      const schema = new MySchema().format('long')
      // use schema
      expect(helper.description(schema)).to.be.a('string')
    })

    it('should support mapping to ipv6', () => {
      const data = '127.0.0.1'
      const schema = new MySchema().mapping().version(6)
      expect(schema).to.be.an('object')
      // use schema
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal('::ffff:7f00:1')
      })
    })

    it('should support mapping to ipv4', () => {
      const data = '::ffff:7f00:1'
      const schema = new MySchema().mapping().version(4)
      expect(schema).to.be.an('object')
      // use schema
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal('127.0.0.1')
      })
    })

    it('should describe with mapping', () => {
      const schema = new MySchema().mapping()
      // use schema
      expect(helper.description(schema)).to.be.a('string')
    })

  })

})
