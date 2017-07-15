import chai from 'chai'

import { AnySchema, ObjectSchema, Reference } from '../../../src/index'
import Schema from '../../../src/Schema'
import * as helper from '../helper'

const expect = chai.expect

// to simplify copy and paste in other Schemas
const MySchema = ObjectSchema

describe.only('object', () => {

  it('should work without specification', (done) => {
    const data = { a: 1 }
    const schema = new MySchema()
    expect(schema, 'schema').to.be.an('object')
    // use schema
    helper.validateOk(schema, data, (res) => {
      expect(res).deep.equal(data)
      done()
    })
  })

  it('should fail if no object', (done) => {
    const data = 'a'
    const schema = new MySchema()
    // use schema
    helper.validateFail(schema, data, undefined, done)
  })

  it('should describe', () => {
    const schema = new MySchema()
    // use schema
    expect(helper.description(schema)).to.equal(
      'It is optional and must not be set.\nA data object is needed.')
  })

  describe('deepen/flatten', () => {

    it('should work with deepen as string', (done) => {
      const data = { 'a.a': 1, 'a.b': 2, c: 3 }
      const schema = new MySchema().deepen('.')
      // use schema
      helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal({ a: { a: 1, b: 2 }, c: 3 })
      }, done)
    })

    it('should work with deepen as pattern', (done) => {
      const data = { 'a.a': 1, 'a.b': 2, c: 3 }
      const schema = new MySchema().deepen(/\./)
      // use schema
      helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal({ a: { a: 1, b: 2 }, c: 3 })
      }, done)
    })

    it('should work with flatten as string', (done) => {
      const data = { a: { a: 1, b: 2 }, c: 3 }
      const schema = new MySchema().flatten('.')
      // use schema
      helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal({ 'a.a': 1, 'a.b': 2, c: 3 })
      }, done)
    })

    it('should remove deepen', (done) => {
      const data = { 'a.a': 1, 'a.b': 2, c: 3 }
      const schema = new MySchema().deepen('.').deepen()
      // use schema
      helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      }, done)
    })

    it('should remove flatten', (done) => {
      const data = { a: { a: 1, b: 2 }, c: 3 }
      const schema = new MySchema().flatten('.').flatten()
      // use schema
      helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      }, done)
    })

    it('should work with deepen as reference', (done) => {
      const data = { 'a.a': 1, 'a.b': 2, c: 3 }
      const ref = new Reference('.')
      const schema = new MySchema().deepen(ref)
      // use schema
      helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal({ a: { a: 1, b: 2 }, c: 3 })
      }, done)
    })

    it('should work with flatten as reference', (done) => {
      const data = { a: { a: 1, b: 2 }, c: 3 }
      const ref = new Reference('.')
      const schema = new MySchema().flatten(ref)
      // use schema
      helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal({ 'a.a': 1, 'a.b': 2, c: 3 })
      }, done)
    })

    it('should describe deepen', () => {
      const schema = new MySchema().deepen('.')
      // use schema
      expect(helper.description(schema)).to.be.a('string')
    })

    it('should describe deepen with reference', () => {
      const ref = new Reference('.')
      const schema = new MySchema().deepen(ref)
      // use schema
      expect(helper.description(schema)).to.be.a('string')
    })

    it('should describe flatten', () => {
      const schema = new MySchema().flatten('.')
      // use schema
      expect(helper.description(schema)).to.be.a('string')
    })

    it('should describe flatten with reference', () => {
      const ref = new Reference('.')
      const schema = new MySchema().flatten(ref)
      // use schema
      expect(helper.description(schema)).to.be.a('string')
    })

  })

  describe('key', () => {

    it('should work with defined keys', (done) => {
      const data = { a: 1 }
      const schema = new MySchema()
      expect(schema).to.be.an('object')
      schema.key('a', new AnySchema())
      // use schema
      helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      }, done)
    })

    it('should describe with defined keys', () => {
      const schema = new MySchema()
      schema.key('a', new AnySchema())
      // use schema
      expect(helper.description(schema)).to.be.a('string')
    })

    it('should work with defined pattern', (done) => {
      const data = { name1: 1 }
      const schema = new MySchema()
      expect(schema).to.be.an('object')
      schema.key(/name\d/, new AnySchema())
      // use schema
      helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      }, done)
    })

    it('should describe with defined pattern', () => {
      const schema = new MySchema()
      schema.key(/name\d/, new AnySchema())
      // use schema
      expect(helper.description(schema)).to.be.a('string')
    })

    it('should remove defined keys', (done) => {
      const data = { a: 1 }
      const schema = new MySchema()
      expect(schema).to.be.an('object')
      schema.key('a', new AnySchema()).key('a')
      // use schema
      helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
        expect(schema._setting.keys.size).to.equal(0)
      }, done)
    })

  })

  describe('removeUnknown', () => {

    it('should work with defined keys', (done) => {
      const data = { a: 1, b: 2, c: 3 }
      const schema = new MySchema().removeUnknown()
      .key('a', new AnySchema())
      // use schema
      helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal({ a: 1 })
      }, done)
    })

    it('should work with pattern', (done) => {
      const data = { a: 1, b: 2, c: 3 }
      const schema = new MySchema().removeUnknown()
      .key(/[ab]/, new AnySchema())
      // use schema
      helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal({ a: 1, b: 2 })
      }, done)
    })

    it('should work with negate', (done) => {
      const data = { a: 1, b: 2, c: 3 }
      const schema = new MySchema().removeUnknown()
      .key('a', new AnySchema()).removeUnknown(false)
      // use schema
      helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal({ a: 1, b: 2, c: 3 })
      }, done)
    })

    it('should describe', () => {
      const schema = new MySchema().removeUnknown()
      .key('a', new AnySchema())
      // use schema
      expect(helper.description(schema)).to.be.a('string')
    })

  })

  describe('length', () => {

    it('should work with min', (done) => {
      const data = { a: 1, b: 2, c: 3 }
      const schema = new MySchema().min(2)
      // use schema
      helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      }, done)
    })

    it('should fail with min', (done) => {
      const data = { a: 1, b: 2, c: 3 }
      const schema = new MySchema().min(5)
      // use schema
      helper.validateFail(schema, data, undefined, done)
    })

    it('should allow min with reference', (done) => {
      const ref = new Reference(5)
      const data = { a: 1, b: 2, c: 3 }
      const schema = new MySchema().min(ref)
      // use schema
      helper.validateFail(schema, data, undefined, done)
    })

    it('should work with max', (done) => {
      const data = { a: 1, b: 2, c: 3 }
      const schema = new MySchema().max(5)
      // use schema
      helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      }, done)
    })

    it('should fail with max', (done) => {
      const data = { a: 1, b: 2, c: 3 }
      const schema = new MySchema().max(2)
      // use schema
      helper.validateFail(schema, data, undefined, done)
    })

    it('should allow max with reference', (done) => {
      const ref = new Reference(2)
      const data = { a: 1, b: 2, c: 3 }
      const schema = new MySchema().max(ref)
      // use schema
      helper.validateFail(schema, data, undefined, done)
    })

    it('should work with length', (done) => {
      const data = { a: 1, b: 2, c: 3 }
      const schema = new MySchema().length(3)
      // use schema
      helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      }, done)
    })

    it('should fail with length', (done) => {
      const data = { a: 1, b: 2, c: 3 }
      const schema = new MySchema().length(2)
      // use schema
      helper.validateFail(schema, data, undefined, done)
    })

    it('should work with min and max', (done) => {
      const data = { a: 1, b: 2, c: 3 }
      const schema = new MySchema().min(2).max(5)
      // use schema
      helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      }, done)
    })

    it('should remove min', (done) => {
      const data = { a: 1, b: 2, c: 3 }
      const schema = new MySchema().min(5).min()
      // use schema
      helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      }, done)
    })

    it('should remove max', (done) => {
      const data = { a: 1, b: 2, c: 3 }
      const schema = new MySchema().max(2).max()
      // use schema
      helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      }, done)
    })

    it('should remove length', (done) => {
      const data = { a: 1, b: 2, c: 3 }
      const schema = new MySchema().length(5).length()
      // use schema
      helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      }, done)
    })

    it('should describe length', () => {
      const schema = new MySchema().length(4)
      // use schema
      expect(helper.description(schema)).to.be.a('string')
    })

    it('should describe min and max', () => {
      const schema = new MySchema().min(2).max(5)
      // use schema
      expect(helper.description(schema)).to.be.a('string')
    })

    it('should describe min with reference', () => {
      const ref = new Reference(4)
      const schema = new MySchema().min(ref)
      // use schema
      expect(helper.description(schema)).to.be.a('string')
    })

    it('should describe max with reference', () => {
      const ref = new Reference(4)
      const schema = new MySchema().max(ref)
      // use schema
      expect(helper.description(schema)).to.be.a('string')
    })

  })

  describe('requiredKeys', () => {

    it('should work with required key', (done) => {
      const data = { a: 1, b: 2, c: 3 }
      const schema = new MySchema().requiredKeys('a')
      // use schema
      helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      }, done)
    })

    it('should work with required key list', (done) => {
      const data = { a: 1, b: 2, c: 3 }
      const schema = new MySchema().requiredKeys('a', 'b', 'c')
      // use schema
      helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      }, done)
    })

    it('should work with required key array', (done) => {
      const data = { a: 1, b: 2, c: 3 }
      const schema = new MySchema().requiredKeys(['a', 'b', 'c'])
      // use schema
      helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      }, done)
    })

    it('should fail with required keys', (done) => {
      const data = { a: 1, b: 2, c: 3 }
      const schema = new MySchema().requiredKeys('d')
      // use schema
      helper.validateFail(schema, data, undefined, done)
    })

    it('should allow to remove with forbiddenKeys', (done) => {
      const data = { a: 1, b: 2, c: 3 }
      const schema = new MySchema().requiredKeys('a', 'b', 'c', 'd')
      .forbiddenKeys('d')
      // use schema
      helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      }, done)
    })

    it('should allow required keys with reference', (done) => {
      const data = { a: 1, b: 2, c: 3 }
      const ref = new Reference('d')
      const schema = new MySchema().requiredKeys(ref)
      // use schema
      helper.validateFail(schema, data, undefined, done)
    })

    it('should describe', () => {
      const schema = new MySchema().requiredKeys('a', 'b', 'c')
      // use schema
      expect(helper.description(schema)).to.be.a('string')
    })

    it('should describe with reference', () => {
      const ref = new Reference('d')
      const schema = new MySchema().requiredKeys(ref)
      // use schema
      expect(helper.description(schema)).to.be.a('string')
    })

  })

  describe('forbiddenKeys', () => {

    it('should work with forbidden key', (done) => {
      const data = { a: 1, b: 2, c: 3 }
      const schema = new MySchema().forbiddenKeys('d')
      // use schema
      helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      }, done)
    })

    it('should work with forbidden key list', (done) => {
      const data = { a: 1, b: 2, c: 3 }
      const schema = new MySchema().forbiddenKeys('d', 'e', 'f')
      // use schema
      helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      }, done)
    })

    it('should work with forbidden key array', (done) => {
      const data = { a: 1, b: 2, c: 3 }
      const schema = new MySchema().forbiddenKeys(['d', 'e', 'f'])
      // use schema
      helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      }, done)
    })

    it('should fail with forbidden keys', (done) => {
      const data = { a: 1, b: 2, c: 3 }
      const schema = new MySchema().forbiddenKeys('a')
      // use schema
      helper.validateFail(schema, data, undefined, done)
    })

    it('should allow to remove with requiredKerys', (done) => {
      const data = { a: 1, b: 2, c: 3 }
      const schema = new MySchema().forbiddenKeys('c', 'd', 'e', 'f')
      .requiredKeys('c')
      // use schema
      helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      }, done)
    })

    it('should allow forbidden keys with reference', (done) => {
      const data = { a: 1, b: 2, c: 3 }
      const ref = new Reference('a')
      const schema = new MySchema().forbiddenKeys(ref)
      // use schema
      helper.validateFail(schema, data, undefined, done)
    })

    it('should describe', () => {
      const schema = new MySchema().forbiddenKeys('a', 'b', 'c')
      // use schema
      expect(helper.description(schema)).to.be.a('string')
    })

    it('should describe with reference', () => {
      const ref = new Reference('a')
      const schema = new MySchema().forbiddenKeys(ref)
      // use schema
      expect(helper.description(schema)).to.be.a('string')
    })

  })

  describe('logic', () => {

    it('should work with and', (done) => {
      const data = { a: 1, b: 2, c: 3 }
      const schema = new MySchema().and('a', 'b', 'c')
      // use schema
      helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      }, done)
    })

    it('should fail with and', (done) => {
      const data = { a: 1, b: 2 }
      const schema = new MySchema().and('a', 'b', 'c')
      // use schema
      helper.validateFail(schema, data, undefined, done)
    })

    it('should describe and', () => {
      const schema = new MySchema().and('a', 'b', 'c')
      // use schema
      expect(helper.description(schema)).to.be.a('string')
    })

    it('should work with nand', (done) => {
      const data = { a: 1, b: 2 }
      const schema = new MySchema().nand('a', 'b', 'c')
      // use schema
      helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      }, done)
    })

    it('should fail with nand', (done) => {
      const data = { a: 1, b: 2, c: 3 }
      const schema = new MySchema().nand('a', 'b', 'c')
      // use schema
      helper.validateFail(schema, data, undefined, done)
    })

    it('should describe nand', () => {
      const schema = new MySchema().nand('a', 'b', 'c')
      // use schema
      expect(helper.description(schema)).to.be.a('string')
    })

    it('should work with or', (done) => {
      const data = { a: 1, b: 2 }
      const schema = new MySchema().or('a', 'b', 'c')
      // use schema
      helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      }, done)
    })

    it('should fail with or', (done) => {
      const data = { d: 1, e: 2 }
      const schema = new MySchema().or('a', 'b', 'c')
      // use schema
      helper.validateFail(schema, data, undefined, done)
    })

    it('should describe or', () => {
      const schema = new MySchema().or('a', 'b', 'c')
      // use schema
      expect(helper.description(schema)).to.be.a('string')
    })

    it('should work with xor', (done) => {
      const data = { a: 1 }
      const schema = new MySchema().xor('a', 'b', 'c')
      // use schema
      helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      }, done)
    })

    it('should fail with xor', (done) => {
      const data = { a: 1, b: 2 }
      const schema = new MySchema().xor('a', 'b', 'c')
      // use schema
      helper.validateFail(schema, data, undefined, done)
    })

    it('should describe xor', () => {
      const schema = new MySchema().xor('a', 'b', 'c')
      // use schema
      expect(helper.description(schema)).to.be.a('string')
    })

    it('should work with with', (done) => {
      const data = { a: 1, b: 2, c: 3 }
      const schema = new MySchema().with('a', 'b', 'c')
      // use schema
      helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      }, done)
    })

    it('should fail with with', (done) => {
      const data = { a: 1, b: 2 }
      const schema = new MySchema().with('a', 'b', 'c')
      // use schema
      helper.validateFail(schema, data, undefined, done)
    })

    it('should describe with', () => {
      const schema = new MySchema().with('a', 'b', 'c')
      // use schema
      expect(helper.description(schema)).to.be.a('string')
    })

    it('should work with without', (done) => {
      const data = { a: 1, d: 2, e: 3 }
      const schema = new MySchema().without('a', 'b', 'c')
      // use schema
      helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      }, done)
    })

    it('should fail with without', (done) => {
      const data = { a: 1, b: 2 }
      const schema = new MySchema().without('a', 'b', 'c')
      // use schema
      helper.validateFail(schema, data, undefined, done)
    })

    it('should describe without', () => {
      const schema = new MySchema().without('a', 'b', 'c')
      // use schema
      expect(helper.description(schema)).to.be.a('string')
    })

    it('should allow to clearLogic', (done) => {
      const data = { a: 1, b: 2 }
      const schema = new MySchema().and('a', 'b', 'c').clearLogic()
      // use schema
      helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      }, done)
    })

  })

})
