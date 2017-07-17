import chai from 'chai'

import { AnySchema, ArraySchema, NumberSchema, Reference } from '../../../src/index'
import Schema from '../../../src/Schema'
import * as helper from '../helper'

const expect = chai.expect

// to simplify copy and paste in other Schemas
const MySchema = ArraySchema

describe.only('array', () => {

  it('should work without specification', (done) => {
    const data = [1, 2]
    const schema = new MySchema()
    expect(schema, 'schema').to.be.an('object')
    // use schema
    helper.validateOk(schema, data, (res) => {
      expect(res).deep.equal(data)
      done()
    })
  })

  it('should fail if no array', (done) => {
    const data = 'a'
    const schema = new MySchema()
    // use schema
    helper.validateFail(schema, data, undefined, done)
  })

  it('should describe', () => {
    const schema = new MySchema()
    // use schema
    expect(helper.description(schema)).to.equal(
      'It is optional and must not be set.\nAn array list is needed.')
  })

  describe('split', () => {

    it('should work with string', (done) => {
      const data = 'a,b,c'
      const schema = new MySchema().split(',')
      // use schema
      helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(['a', 'b', 'c'])
      }, done)
    })

    it('should work with pattern', (done) => {
      const data = '1,2-3 -> 4'
      const schema = new MySchema().split(/\D+/)
      // use schema
      helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(['1', '2', '3', '4'])
      }, done)
    })

    it('should remove setting', (done) => {
      const data = 'a,b,c'
      const schema = new MySchema().split(',').split()
      // use schema
      helper.validateFail(schema, data, undefined, done)
    })

    it('should work with reference', (done) => {
      const data = 'a,b,c'
      const ref = new Reference(',')
      const schema = new MySchema().split(ref)
      // use schema
      helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(['a', 'b', 'c'])
      }, done)
    })

    it('should describe', () => {
      const schema = new MySchema().split(',')
      // use schema
      expect(helper.description(schema)).to.be.an('string')
    })

    it('should describe with reference', () => {
      const ref = new Reference(',')
      const schema = new MySchema().split(ref)
      // use schema
      expect(helper.description(schema)).to.be.an('string')
    })

  })

  describe('unique', () => {

    it('should work with error', (done) => {
      const data = [1, 2, 3, 2]
      const schema = new MySchema().unique()
      // use schema
      helper.validateFail(schema, data, undefined, done)
    })

    it('should work with sanitize', (done) => {
      const data = [1, 2, 3, 2]
      const schema = new MySchema().unique().sanitize()
      // use schema
      helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal([1, 2, 3])
      }, done)
    })

    it('should allow remove', (done) => {
      const data = [1, 2, 3, 2]
      const schema = new MySchema().unique().unique(false)
      // use schema
      helper.validateOk(schema, data, undefined, done)
    })

    it('should work with reference', (done) => {
      const data = [1, 2, 3, 2]
      const ref = new Reference(true)
      const schema = new MySchema().unique(ref)
      // use schema
      helper.validateFail(schema, data, undefined, done)
    })

    it('should describe', () => {
      const data = [1, 2, 3, 2]
      const schema = new MySchema().unique().sanitize()
      // use schema
      expect(helper.description(schema)).to.be.an('string')
    })

    it('should describe', () => {
      const data = [1, 2, 3, 2]
      const ref = new Reference(true)
      const schema = new MySchema().unique(ref)
      // use schema
      expect(helper.description(schema)).to.be.an('string')
    })

  })

  describe('items ', () => {

    it('should work with one schema for all', (done) => {
      const data = ['1', '2', 3, 2]
      const schema = new MySchema()
      .item(new NumberSchema())
      // use schema
      helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal([1, 2, 3, 2])
      }, done)
    })

    it('should work with ordered elements', (done) => {
      const data = ['1', '2', 3, 2]
      const schema = new MySchema()
      .item(new AnySchema())
      .item(new NumberSchema())
      // use schema
      helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(['1', 2, 3, 2])
      }, done)
    })

    it('should describe', () => {
      const schema = new MySchema()
      .item(new AnySchema())
      .item(new NumberSchema())
      // use schema
      expect(helper.description(schema)).to.be.an('string')
    })

  })

})
