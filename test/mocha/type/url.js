// @flow
import chai from 'chai'

import Reference from '../../../src/Reference'
import URLSchema from '../../../src/type/URL'
import Schema from '../../../src/type/Schema'
import * as helper from '../helper'

const expect = chai.expect

// to simplify copy and paste in other Schemas
const MySchema = URLSchema

describe('url', () => {

  describe('simple', () => {

    it('should work', () => {
      const data = 'http://alinex.github.io'
      const schema = new MySchema()
      expect(schema).to.be.an('object')
      // use schema
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal('http://alinex.github.io/')
      })
    })

    it('should describe', () => {
      const schema = new MySchema()
      // use schema
      expect(helper.description(schema)).to.be.a('string')
    })

  })

  describe('allow', () => {

    it('should work with deny protocol', () => {
      const data = 'https://alinex.github.io'
      const schema = new MySchema().deny('http:')
      expect(schema).to.be.an('object')
      // use schema
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal('https://alinex.github.io/')
      })
    })

    it('should fail with deny protocol', () => {
      const data = 'https://alinex.github.io'
      const schema = new MySchema().deny('https:')
      expect(schema).to.be.an('object')
      // use schema
      return helper.validateFail(schema, data)
    })

  })

  describe('dns', () => {

    it('should work', () => {
      const data = 'http://alinex.github.io'
      const schema = new MySchema().dns()
      expect(schema).to.be.an('object')
      // use schema
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal('http://alinex.github.io/')
      })
    })

    it('should describe', () => {
      const schema = new MySchema().dns()
      // use schema
      expect(helper.description(schema)).to.be.a('string')
    })

  })

  describe('exists', () => {

    it('should work', () => {
      const data = 'http://alinex.github.io'
      const schema = new MySchema().exists()
      expect(schema).to.be.an('object')
      // use schema
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal('http://alinex.github.io/')
      })
    })

    it('should fail', () => {
      const data = 'https://alinex.github.de'
      const schema = new MySchema().exists()
      expect(schema).to.be.an('object')
      // use schema
      return helper.validateFail(schema, data)
    })

    it('should describe', () => {
      const schema = new MySchema().exists()
      // use schema
      expect(helper.description(schema)).to.be.a('string')
    })

  })

})
