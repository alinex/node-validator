// @flow
import chai from 'chai'
import path from 'path'

import Reference from '../../../src/Reference'
import FileSchema from '../../../src/type/File'
import Schema from '../../../src/type/Schema'
import * as helper from '../helper'

const expect = chai.expect

// to simplify copy and paste in other Schemas
const MySchema = FileSchema

describe('file', () => {

  describe('simple', () => {

    it('should work', () => {
      const data = 'http://alinex.github.io'
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

  })

  describe('resolve', () => {

    it('should work with relative path', () => {
      const data = 'test.txt'
      const schema = new MySchema().resolve()
      // use schema
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(path.resolve(data))
      })
    })

    it('should work with baseDir', () => {
      const data = 'test.txt'
      const schema = new MySchema().baseDir('/data').resolve()
      // use schema
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(path.join('/data', data))
      })
    })

    it('should work with relative baseDir', () => {
      const data = 'test.txt'
      const schema = new MySchema().baseDir('data').resolve()
      // use schema
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(path.resolve('data', data))
      })
    })

    it('should describe', () => {
      const schema = new MySchema().baseDir('/data').resolve()
      // use schema
      expect(helper.description(schema)).to.be.a('string')
    })

  })

  describe('allow', () => {

    it('should work with complete file', () => {
      const data = 'package.json'
      const schema = new MySchema().allow(data)
      // use schema
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      })
    })

    it('should fail with complete file', () => {
      const data = 'package.json'
      const schema = new MySchema().deny(data)
      // use schema
      return helper.validateFail(schema, data)
    })

    it('should work with glob', () => {
      const data = 'package.json'
      const schema = new MySchema().allow('*.json')
      // use schema
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      })
    })

    it('should fail with glob', () => {
      const data = 'package.json'
      const schema = new MySchema().deny('*.json')
      // use schema
      return helper.validateFail(schema, data)
    })

  })

  describe('access', () => {

    it('should work with exists', () => {
      const data = 'package.json'
      const schema = new MySchema().exists()
      // use schema
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      })
    })

    it('should describe exists', () => {
      const schema = new MySchema().exists()
      // use schema
      expect(helper.description(schema)).to.be.a('string')
    })

    it('should work with readable', () => {
      const data = 'package.json'
      const schema = new MySchema().readable()
      // use schema
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      })
    })

    it('should describe readable', () => {
      const schema = new MySchema().readable()
      // use schema
      expect(helper.description(schema)).to.be.a('string')
    })

    it('should work with writable', () => {
      const data = 'package.json'
      const schema = new MySchema().writable()
      // use schema
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      })
    })

    it('should describe writable', () => {
      const schema = new MySchema().writable()
      // use schema
      expect(helper.description(schema)).to.be.a('string')
    })

  })
})
