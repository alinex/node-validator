import chai from 'chai'

import Reference from '../../../src/Reference'
import ObjectSchema from '../../../src/type/Object'
import AnySchema from '../../../src/type/Any'
import Schema from '../../../src/type/Schema'
import * as helper from '../helper'

const expect = chai.expect

// to simplify copy and paste in other Schemas
const MySchema = ObjectSchema

describe('object', () => {

  it('should work without specification', () => {
    const data = { a: 1 }
    const schema = new MySchema()
    expect(schema, 'schema').to.be.an('object')
    // use schema
    return helper.validateOk(schema, data, (res) => {
      expect(res).deep.equal(data)
    })
  })

  it('should fail if no object', () => {
    const data = 'a'
    const schema = new MySchema()
    // use schema
    return helper.validateFail(schema, data, undefined)
  })

  it('should describe', () => {
    const schema = new MySchema()
    // use schema
    expect(helper.description(schema)).to.equal(
      'A data object is needed.')
  })

  describe('deepen/flatten', () => {

    it('should work with deepen as string', () => {
      const data = { 'a.a': 1, 'a.b': 2, c: 3 }
      const schema = new MySchema().deepen('.')
      // use schema
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal({ a: { a: 1, b: 2 }, c: 3 })
      })
    })

    it('should work with deepen as pattern', () => {
      const data = { 'a.a': 1, 'a.b': 2, c: 3 }
      const schema = new MySchema().deepen(/\./)
      // use schema
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal({ a: { a: 1, b: 2 }, c: 3 })
      })
    })

    it('should work with flatten as string', () => {
      const data = { a: { a: 1, b: 2 }, c: 3 }
      const schema = new MySchema().flatten('.')
      // use schema
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal({ 'a.a': 1, 'a.b': 2, c: 3 })
      })
    })

    it('should remove deepen', () => {
      const data = { 'a.a': 1, 'a.b': 2, c: 3 }
      const schema = new MySchema().deepen('.').deepen()
      // use schema
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      })
    })

    it('should remove flatten', () => {
      const data = { a: { a: 1, b: 2 }, c: 3 }
      const schema = new MySchema().flatten('.').flatten()
      // use schema
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      })
    })

    it('should work with deepen as reference', () => {
      const data = { 'a.a': 1, 'a.b': 2, c: 3 }
      const ref = new Reference('.')
      const schema = new MySchema().deepen(ref)
      // use schema
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal({ a: { a: 1, b: 2 }, c: 3 })
      })
    })

    it('should work with flatten as reference', () => {
      const data = { a: { a: 1, b: 2 }, c: 3 }
      const ref = new Reference('.')
      const schema = new MySchema().flatten(ref)
      // use schema
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal({ 'a.a': 1, 'a.b': 2, c: 3 })
      })
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

  describe('copy/move', () => {

    it('should copy one key', () => {
      const data = { a: 1 }
      const schema = new MySchema().copy('a', 'b')
      // use schema
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal({ a: 1, b: 1 })
      })
    })

    it('should copy multiple key', () => {
      const data = { a: 1, b: 2 }
      const schema = new MySchema().copy('a', 'b')
      // use schema
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal({ a: 1, b: 2 })
      })
    })

    it('should copy multiple key with force', () => {
      const data = { a: 1, b: 2 }
      const schema = new MySchema().copy('a', 'b', true)
      // use schema
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal({ a: 1, b: 1 })
      })
    })

    it('should remove copy setting', () => {
      const data = { a: 1 }
      const schema = new MySchema().copy('a', 'b').copy()
      // use schema
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal({ a: 1 })
      })
    })

    it('should use reference to copy to', () => {
      const data = { a: 1, b: 2 }
      const ref = new Reference('c')
      const schema = new MySchema().copy('a', ref)
      // use schema
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal({ a: 1, b: 2, c: 1 })
      })
    })

    it('should use reference as copy from', () => {
      const data = { a: 1, b: 2 }
      const ref = new Reference('b')
      const schema = new MySchema().copy(ref, 'c')
      // use schema
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal({ a: 1, b: 2, c: 2 })
      })
    })

    it('should move key', () => {
      const data = { a: 1, b: 2 }
      const schema = new MySchema().move('a', 'c')
      // use schema
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal({ b: 2, c: 1 })
      })
    })

    it('should move key by force', () => {
      const data = { a: 1, b: 2 }
      const schema = new MySchema().move('a', 'b', true)
      // use schema
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal({ b: 1 })
      })
    })

    it('should move multiple in order', () => {
      const data = { a: 1, b: 2 }
      const schema = new MySchema().move('a', 'c').move('b', 'a').move('c', 'b')
      // use schema
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal({ a: 2, b: 1 })
      })
    })

    it('should describe copy', () => {
      const schema = new MySchema().copy('a', 'b')
      // use schema
      expect(helper.description(schema)).to.be.a('string')
    })

    it('should describe move', () => {
      const schema = new MySchema().move('a', 'b')
      // use schema
      expect(helper.description(schema)).to.be.a('string')
    })

    it('should describe copy with reference', () => {
      const ref = new Reference('b')
      const schema = new MySchema().copy('a', ref)
      // use schema
      expect(helper.description(schema)).to.be.a('string')
    })

  })

  describe('key', () => {

    it('should work with defined keys', () => {
      const data = { a: 1 }
      const schema = new MySchema()
      expect(schema).to.be.an('object')
      schema.key('a', new AnySchema())
      // use schema
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      })
    })

    it('should describe with defined keys', () => {
      const schema = new MySchema()
      schema.key('a', new AnySchema())
      // use schema
      expect(helper.description(schema)).to.be.a('string')
    })

    it('should work with defined pattern', () => {
      const data = { name1: 1 }
      const schema = new MySchema()
      expect(schema).to.be.an('object')
      schema.key(/name\d/, new AnySchema())
      // use schema
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      })
    })

    it('should describe with defined pattern', () => {
      const schema = new MySchema()
      schema.key(/name\d/, new AnySchema())
      // use schema
      expect(helper.description(schema)).to.be.a('string')
    })

    it('should remove defined keys', () => {
      const data = { a: 1 }
      const schema = new MySchema()
      expect(schema).to.be.an('object')
      schema.key('a', new AnySchema()).key('a')
      // use schema
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
        expect(schema._setting.keys.size).to.equal(0)
      })
    })

  })

  describe('removeUnknown', () => {

    it('should work with defined keys', () => {
      const data = { a: 1, b: 2, c: 3 }
      const schema = new MySchema().removeUnknown()
        .key('a', new AnySchema())
      // use schema
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal({ a: 1 })
      })
    })

    it('should work with pattern', () => {
      const data = { a: 1, b: 2, c: 3 }
      const schema = new MySchema().removeUnknown()
        .key(/[ab]/, new AnySchema())
      // use schema
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal({ a: 1, b: 2 })
      })
    })

    it('should work with negate', () => {
      const data = { a: 1, b: 2, c: 3 }
      const schema = new MySchema().removeUnknown()
        .key('a', new AnySchema()).removeUnknown(false)
      // use schema
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal({ a: 1, b: 2, c: 3 })
      })
    })

    it('should describe', () => {
      const schema = new MySchema().removeUnknown()
        .key('a', new AnySchema())
      // use schema
      expect(helper.description(schema)).to.be.a('string')
    })

  })

  describe('denyUnknown', () => {

    it('should work with defined keys', () => {
      const data = { a: 1, b: 2, c: 3 }
      const schema = new MySchema().denyUnknown()
        .key('a', new AnySchema())
        .key('b', new AnySchema())
        .key('c', new AnySchema())
      // use schema
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      })
    })

    it('should for undefined key', () => {
      const data = { a: 1, b: 2, c: 3 }
      const schema = new MySchema().denyUnknown()
        .key(/[ab]/, new AnySchema())
      // use schema
      return helper.validateFail(schema, data)
    })

    it('should describe', () => {
      const schema = new MySchema().denyUnknown()
        .key('a', new AnySchema())
      // use schema
      expect(helper.description(schema)).to.be.a('string')
    })

  })

  describe('length', () => {

    it('should work with min', () => {
      const data = { a: 1, b: 2, c: 3 }
      const schema = new MySchema().min(2)
      // use schema
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      })
    })

    it('should fail with min', () => {
      const data = { a: 1, b: 2, c: 3 }
      const schema = new MySchema().min(5)
      // use schema
      return helper.validateFail(schema, data, undefined)
    })

    it('should allow min with reference', () => {
      const ref = new Reference(5)
      const data = { a: 1, b: 2, c: 3 }
      const schema = new MySchema().min(ref)
      // use schema
      return helper.validateFail(schema, data, undefined)
    })

    it('should work with max', () => {
      const data = { a: 1, b: 2, c: 3 }
      const schema = new MySchema().max(5)
      // use schema
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      })
    })

    it('should fail with max', () => {
      const data = { a: 1, b: 2, c: 3 }
      const schema = new MySchema().max(2)
      // use schema
      return helper.validateFail(schema, data, undefined)
    })

    it('should allow max with reference', () => {
      const ref = new Reference(2)
      const data = { a: 1, b: 2, c: 3 }
      const schema = new MySchema().max(ref)
      // use schema
      return helper.validateFail(schema, data, undefined)
    })

    it('should work with length', () => {
      const data = { a: 1, b: 2, c: 3 }
      const schema = new MySchema().length(3)
      // use schema
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      })
    })

    it('should fail with length', () => {
      const data = { a: 1, b: 2, c: 3 }
      const schema = new MySchema().length(2)
      // use schema
      return helper.validateFail(schema, data, undefined)
    })

    it('should work with min and max', () => {
      const data = { a: 1, b: 2, c: 3 }
      const schema = new MySchema().min(2).max(5)
      // use schema
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      })
    })

    it('should remove min', () => {
      const data = { a: 1, b: 2, c: 3 }
      const schema = new MySchema().min(5).min()
      // use schema
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      })
    })

    it('should remove max', () => {
      const data = { a: 1, b: 2, c: 3 }
      const schema = new MySchema().max(2).max()
      // use schema
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      })
    })

    it('should remove length', () => {
      const data = { a: 1, b: 2, c: 3 }
      const schema = new MySchema().length(5).length()
      // use schema
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      })
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

    it('should work with required key', () => {
      const data = { a: 1, b: 2, c: 3 }
      const schema = new MySchema().requiredKeys('a')
      // use schema
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      })
    })

    it('should work with required key list', () => {
      const data = { a: 1, b: 2, c: 3 }
      const schema = new MySchema().requiredKeys('a', 'b', 'c')
      // use schema
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      })
    })

    it('should work with required key array', () => {
      const data = { a: 1, b: 2, c: 3 }
      const schema = new MySchema().requiredKeys(['a', 'b', 'c'])
      // use schema
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      })
    })

    it('should fail with required keys', () => {
      const data = { a: 1, b: 2, c: 3 }
      const schema = new MySchema().requiredKeys('d')
      // use schema
      return helper.validateFail(schema, data, undefined)
    })

    it('should allow to remove with forbiddenKeys', () => {
      const data = { a: 1, b: 2, c: 3 }
      const schema = new MySchema().requiredKeys('a', 'b', 'c', 'd')
        .forbiddenKeys('d')
      // use schema
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      })
    })

    it('should allow required keys with reference', () => {
      const data = { a: 1, b: 2, c: 3 }
      const ref = new Reference('d')
      const schema = new MySchema().requiredKeys(ref)
      // use schema
      return helper.validateFail(schema, data, undefined)
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

    it('should work with forbidden key', () => {
      const data = { a: 1, b: 2, c: 3 }
      const schema = new MySchema().forbiddenKeys('d')
      // use schema
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      })
    })

    it('should work with forbidden key list', () => {
      const data = { a: 1, b: 2, c: 3 }
      const schema = new MySchema().forbiddenKeys('d', 'e', 'f')
      // use schema
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      })
    })

    it('should work with forbidden key array', () => {
      const data = { a: 1, b: 2, c: 3 }
      const schema = new MySchema().forbiddenKeys(['d', 'e', 'f'])
      // use schema
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      })
    })

    it('should fail with forbidden keys', () => {
      const data = { a: 1, b: 2, c: 3 }
      const schema = new MySchema().forbiddenKeys('a')
      // use schema
      return helper.validateFail(schema, data, undefined)
    })

    it('should allow to remove with requiredKerys', () => {
      const data = { a: 1, b: 2, c: 3 }
      const schema = new MySchema().forbiddenKeys('c', 'd', 'e', 'f')
        .requiredKeys('c')
      // use schema
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      })
    })

    it('should allow forbidden keys with reference', () => {
      const data = { a: 1, b: 2, c: 3 }
      const ref = new Reference('a')
      const schema = new MySchema().forbiddenKeys(ref)
      // use schema
      return helper.validateFail(schema, data, undefined)
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

    it('should work with and', () => {
      const data = { a: 1, b: 2, c: 3 }
      const schema = new MySchema().and('a', 'b', 'c')
      // use schema
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      })
    })

    it('should fail with and', () => {
      const data = { a: 1, b: 2 }
      const schema = new MySchema().and('a', 'b', 'c')
      // use schema
      return helper.validateFail(schema, data, undefined)
    })

    it('should describe and', () => {
      const schema = new MySchema().and('a', 'b', 'c')
      // use schema
      expect(helper.description(schema)).to.be.a('string')
    })

    it('should work with nand', () => {
      const data = { a: 1, b: 2 }
      const schema = new MySchema().nand('a', 'b', 'c')
      // use schema
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      })
    })

    it('should fail with nand', () => {
      const data = { a: 1, b: 2, c: 3 }
      const schema = new MySchema().nand('a', 'b', 'c')
      // use schema
      return helper.validateFail(schema, data, undefined)
    })

    it('should describe nand', () => {
      const schema = new MySchema().nand('a', 'b', 'c')
      // use schema
      expect(helper.description(schema)).to.be.a('string')
    })

    it('should work with or', () => {
      const data = { a: 1, b: 2 }
      const schema = new MySchema().or('a', 'b', 'c')
      // use schema
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      })
    })

    it('should fail with or', () => {
      const data = { d: 1, e: 2 }
      const schema = new MySchema().or('a', 'b', 'c')
      // use schema
      return helper.validateFail(schema, data, undefined)
    })

    it('should describe or', () => {
      const schema = new MySchema().or('a', 'b', 'c')
      // use schema
      expect(helper.description(schema)).to.be.a('string')
    })

    it('should work with xor', () => {
      const data = { a: 1 }
      const schema = new MySchema().xor('a', 'b', 'c')
      // use schema
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      })
    })

    it('should fail with xor', () => {
      const data = { a: 1, b: 2 }
      const schema = new MySchema().xor('a', 'b', 'c')
      // use schema
      return helper.validateFail(schema, data, undefined)
    })

    it('should describe xor', () => {
      const schema = new MySchema().xor('a', 'b', 'c')
      // use schema
      expect(helper.description(schema)).to.be.a('string')
    })

    it('should work with with', () => {
      const data = { a: 1, b: 2, c: 3 }
      const schema = new MySchema().with('a', 'b', 'c')
      // use schema
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      })
    })

    it('should fail with with', () => {
      const data = { a: 1, b: 2 }
      const schema = new MySchema().with('a', 'b', 'c')
      // use schema
      return helper.validateFail(schema, data, undefined)
    })

    it('should describe with', () => {
      const schema = new MySchema().with('a', 'b', 'c')
      // use schema
      expect(helper.description(schema)).to.be.a('string')
    })

    it('should work with without', () => {
      const data = { a: 1, d: 2, e: 3 }
      const schema = new MySchema().without('a', 'b', 'c')
      // use schema
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      })
    })

    it('should fail with without', () => {
      const data = { a: 1, b: 2 }
      const schema = new MySchema().without('a', 'b', 'c')
      // use schema
      return helper.validateFail(schema, data, undefined)
    })

    it('should describe without', () => {
      const schema = new MySchema().without('a', 'b', 'c')
      // use schema
      expect(helper.description(schema)).to.be.a('string')
    })

    it('should allow to clearLogic', () => {
      const data = { a: 1, b: 2 }
      const schema = new MySchema().and('a', 'b', 'c').clearLogic()
      // use schema
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      })
    })

  })

})
