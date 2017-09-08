// @flow
import chai from 'chai'

import Reference from '../../../src/Reference'
import EmailSchema from '../../../src/type/Email'
import Schema from '../../../src/type/Schema'
import * as helper from '../helper'

const expect = chai.expect

// to simplify copy and paste in other Schemas
const MySchema = EmailSchema

describe.only('email', () => {

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

  describe('lowercase', () => {

    it('should convert email', () => {
      const data = 'Alex <Alex@Alinex.DE>'
      const schema = new MySchema().lowercase()
      expect(schema).to.be.an('object')
      // use schema
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal('alex@alinex.de')
      })
    })

    it('should only work on mail part', () => {
      const data = 'Alex <Alex@Alinex.DE>'
      const schema = new MySchema().withName().lowercase()
      expect(schema).to.be.an('object')
      // use schema
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal('Alex <alex@alinex.de>')
      })
    })

    it('should describe', () => {
      const schema = new MySchema().lowercase()
      // use schema
      expect(helper.description(schema)).to.be.a('string')
    })
  })

  describe.skip('local', () => {

    it('should work with local ipv4', () => {
      const data = '127.0.0.1'
      const schema = new MySchema()
      expect(schema).to.be.an('object')
      // use schema
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      })
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

})
