import chai from 'chai'

import * as validator from '../../../src/index'
import Schema from '../../../src/Schema'
import * as helper from '../helper'

const expect = chai.expect

// to simplify copy and paste in other Schemas
const MySchema = validator.Object

describe('type object', () => {

  it('should work without specification', (done) => {
    const data = {a: 1}
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
    expect(helper.description(schema)).to.equal('Any data type. It is optional and must not be set.\nA data object is needed.')
  })

  describe('optional/default', () => {

    it('should work with required', (done) => {
      const data = {a: 1}
      const schema = new MySchema()
      expect(schema).to.be.an('object')
      schema.required
      // use schema
      helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      }, done)
    })

    it('should fail with required', (done) => {
      const schema = new MySchema()
      schema.required
      // use schema
      helper.validateFail(schema, undefined, undefined, done)
    })

    it('should work with default', (done) => {
      const data = { a: 1 }
      const schema = new MySchema()
      expect(schema).to.be.an('object')
      schema.default(data)
      helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      }, done)
    })

    it('should fail with required and undefined default', (done) => {
      const schema = new MySchema()
      schema.required.default(undefined)
      // use schema
      helper.validateFail(schema, undefined, undefined, done)
    })

  })

  describe('key', () => {

    it('should work with defined keys', (done) => {
      const data = {a: 1}
      const schema = new MySchema()
      expect(schema).to.be.an('object')
      schema.key('a', new validator.Any())
      // use schema
      helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      }, done)
    })

    it('should describe with defined keys', () => {
      const schema = new MySchema()
      schema.key('a', new validator.Any())
      // use schema
      expect(helper.description(schema)).to.equal('Any data type. It is optional and must not be set.\n\
A data object is needed.\n\
The following keys have a special format:\n\
- `a`: Any data type. It is optional and must not be set.')
    })

    it('should work with defined pattern', (done) => {
      const data = {name1: 1}
      const schema = new MySchema()
      expect(schema).to.be.an('object')
      schema.key(/name\d/, new validator.Any())
      // use schema
      helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      }, done)
    })

    it('should describe with defined pattern', () => {
      const schema = new MySchema()
      schema.key(/name\d/, new validator.Any())
      // use schema
      expect(helper.description(schema)).to.equal('Any data type. It is optional and must not be set.\n\
A data object is needed.\n\
The following keys have a special format:\n\
- `/name\\d/`: Any data type. It is optional and must not be set.')
    })

    it('should remove defined keys', (done) => {
      const data = {a: 1}
      const schema = new MySchema()
      expect(schema).to.be.an('object')
      schema.key('a', new validator.Any()).not.key('a')
      // use schema
      helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
        expect(schema._keys.size).to.equal(0)
      }, done)
    })

  })

  describe('removeUnknown', () => {

    it('should work with defined keys', (done) => {
      const data = {a: 1, b: 2, c: 3}
      const schema = new MySchema().removeUnknown
      .key('a', new validator.Any())
      // use schema
      helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal({a: 1})
      }, done)
    })

    it('should work with pattern', (done) => {
      const data = {a: 1, b: 2, c: 3}
      const schema = new MySchema().removeUnknown
      .key(/[ab]/, new validator.Any())
      // use schema
      helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal({a: 1, b: 2})
      }, done)
    })

    it('should work with negate', (done) => {
      const data = {a: 1, b: 2, c: 3}
      const schema = new MySchema().removeUnknown
      .key('a', new validator.Any()).not.removeUnknown
      // use schema
      helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal({a: 1, b: 2, c: 3})
      }, done)
    })

    it('should describe', () => {
      const schema = new MySchema().removeUnknown
      .key('a', new validator.Any())
      // use schema
      expect(helper.description(schema)).to.be.a('string')
    })

  })

  describe('length', () => {

    it('should work with min', (done) => {
      const data = {a: 1, b: 2, c: 3}
      const schema = new MySchema().min(2)
      // use schema
      helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      }, done)
    })

    it('should fail with min', (done) => {
      const data = {a: 1, b: 2, c: 3}
      const schema = new MySchema().min(5)
      // use schema
      helper.validateFail(schema, data, undefined, done)
    })

    it('should work with max', (done) => {
      const data = {a: 1, b: 2, c: 3}
      const schema = new MySchema().max(5)
      // use schema
      helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      }, done)
    })

    it('should fail with max', (done) => {
      const data = {a: 1, b: 2, c: 3}
      const schema = new MySchema().max(2)
      // use schema
      helper.validateFail(schema, data, undefined, done)
    })

    it('should work with length', (done) => {
      const data = {a: 1, b: 2, c: 3}
      const schema = new MySchema().length(3)
      // use schema
      helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      }, done)
    })

    it('should fail with length', (done) => {
      const data = {a: 1, b: 2, c: 3}
      const schema = new MySchema().length(2)
      // use schema
      helper.validateFail(schema, data, undefined, done)
    })

    it('should work with min and max', (done) => {
      const data = {a: 1, b: 2, c: 3}
      const schema = new MySchema().min(2).max(5)
      // use schema
      helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      }, done)
    })

    it('should remove min', (done) => {
      const data = {a: 1, b: 2, c: 3}
      const schema = new MySchema().min(5).not.min()
      // use schema
      helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      }, done)
    })

    it('should remove max', (done) => {
      const data = {a: 1, b: 2, c: 3}
      const schema = new MySchema().max(2).not.max()
      // use schema
      helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      }, done)
    })

    it('should remove length', (done) => {
      const data = {a: 1, b: 2, c: 3}
      const schema = new MySchema().length(5).not.length()
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

  })

  describe('requiredKeys', () => {

    it('should work with required key', (done) => {
      const data = {a: 1, b: 2, c: 3}
      const schema = new MySchema().requiredKeys('a')
      // use schema
      helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      }, done)
    })

    it('should work with required key list', (done) => {
      const data = {a: 1, b: 2, c: 3}
      const schema = new MySchema().requiredKeys('a', 'b', 'c')
      // use schema
      helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      }, done)
    })

    it('should work with required key array', (done) => {
      const data = {a: 1, b: 2, c: 3}
      const schema = new MySchema().requiredKeys(['a', 'b', 'c'])
      // use schema
      helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      }, done)
    })

    it('should fail with required keys', (done) => {
      const data = {a: 1, b: 2, c: 3}
      const schema = new MySchema().requiredKeys('d')
      // use schema
      helper.validateFail(schema, data, undefined, done)
    })

    it('should allow to remove with not', (done) => {
      const data = {a: 1, b: 2, c: 3}
      const schema = new MySchema().requiredKeys('a', 'b', 'c', 'd')
      .not.requiredKeys('d')
      // use schema
      helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      }, done)
    })

    it('should describe min and max', () => {
      const schema = new MySchema().requiredKeys('a', 'b', 'c')
      // use schema
      expect(helper.description(schema)).to.be.a('string')
    })

  })

  describe('forbiddenKeys', () => {

    it('should work with forbidden key', (done) => {
      const data = {a: 1, b: 2, c: 3}
      const schema = new MySchema().forbiddenKeys('d')
      // use schema
      helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      }, done)
    })

    it('should work with forbidden key list', (done) => {
      const data = {a: 1, b: 2, c: 3}
      const schema = new MySchema().forbiddenKeys('d', 'e', 'f')
      // use schema
      helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      }, done)
    })

    it('should work with forbidden key array', (done) => {
      const data = {a: 1, b: 2, c: 3}
      const schema = new MySchema().forbiddenKeys(['d', 'e', 'f'])
      // use schema
      helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      }, done)
    })

    it('should fail with forbidden keys', (done) => {
      const data = {a: 1, b: 2, c: 3}
      const schema = new MySchema().forbiddenKeys('a')
      // use schema
      helper.validateFail(schema, data, undefined, done)
    })

    it('should allow to remove with not', (done) => {
      const data = {a: 1, b: 2, c: 3}
      const schema = new MySchema().forbiddenKeys('c', 'd', 'e', 'f')
      .not.forbiddenKeys('c')
      // use schema
      helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      }, done)
    })

    it('should describe min and max', () => {
      const schema = new MySchema().forbiddenKeys('a', 'b', 'c')
      // use schema
      expect(helper.description(schema)).to.be.a('string')
    })

  })

  describe('logic', () => {

    it('should work with and', (done) => {
      const data = {a: 1, b: 2, c: 3}
      const schema = new MySchema().and('a', 'b', 'c')
      // use schema
      helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      }, done)
    })

    it('should fail with and', (done) => {
      const data = {a: 1, b: 2}
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
      const data = {a: 1, b: 2}
      const schema = new MySchema().not.and('a', 'b', 'c')
      // use schema
      helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      }, done)
    })

    it('should fail with nand', (done) => {
      const data = {a: 1, b: 2, c: 3}
      const schema = new MySchema().not.and('a', 'b', 'c')
      // use schema
      helper.validateFail(schema, data, undefined, done)
    })

    it('should describe nand', () => {
      const schema = new MySchema().not.and('a', 'b', 'c')
      // use schema
      expect(helper.description(schema)).to.be.a('string')
    })

    it('should work with or', (done) => {
      const data = {a: 1, b: 2}
      const schema = new MySchema().or('a', 'b', 'c')
      // use schema
      helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      }, done)
    })

    it('should fail with or', (done) => {
      const data = {d: 1, e: 2}
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
      const data = {a: 1}
      const schema = new MySchema().xor('a', 'b', 'c')
      // use schema
      helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      }, done)
    })

    it('should fail with xor', (done) => {
      const data = {a: 1, b: 2}
      const schema = new MySchema().xor('a', 'b', 'c')
      // use schema
      helper.validateFail(schema, data, undefined, done)
    })

    it('should describe xor', () => {
      const schema = new MySchema().xor('a', 'b', 'c')
      // use schema
      expect(helper.description(schema)).to.be.a('string')
    })

    it('should work with not or', (done) => {
      const data = {d: 1, e: 2, f: 3}
      const schema = new MySchema().not.or('a', 'b', 'c')
      // use schema
      helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      }, done)
    })

    it('should fail with not or', (done) => {
      const data = {a: 1, b: 2}
      const schema = new MySchema().not.or('a', 'b', 'c')
      // use schema
      helper.validateFail(schema, data, undefined, done)
    })

    it('should describe not or', () => {
      const schema = new MySchema().not.or('a', 'b', 'c')
      // use schema
      expect(helper.description(schema)).to.be.a('string')
    })

    it('should work with not xor', (done) => {
      const data = {d: 1, e: 2, f: 3}
      const schema = new MySchema().not.xor('a', 'b', 'c')
      // use schema
      helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      }, done)
    })

    it('should fail with not xor', (done) => {
      const data = {a: 1, b: 2}
      const schema = new MySchema().not.xor('a', 'b', 'c')
      // use schema
      helper.validateFail(schema, data, undefined, done)
    })

    it('should describe not xor', () => {
      const schema = new MySchema().not.xor('a', 'b', 'c')
      // use schema
      expect(helper.description(schema)).to.be.a('string')
    })

    it('should work with with', (done) => {
      const data = {a: 1, b: 2, c: 3}
      const schema = new MySchema().with('a', 'b', 'c')
      // use schema
      helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      }, done)
    })

    it('should fail with with', (done) => {
      const data = {a: 1, b: 2}
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
      const data = {a: 1, d: 2, e: 3}
      const schema = new MySchema().not.with('a', 'b', 'c')
      // use schema
      helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      }, done)
    })

    it('should fail with without', (done) => {
      const data = {a: 1, b: 2}
      const schema = new MySchema().not.with('a', 'b', 'c')
      // use schema
      helper.validateFail(schema, data, undefined, done)
    })

    it('should describe without', () => {
      const schema = new MySchema().not.with('a', 'b', 'c')
      // use schema
      expect(helper.description(schema)).to.be.a('string')
    })

    it('should allow to clearLogic', (done) => {
      const data = {a: 1, b: 2}
      const schema = new MySchema().and('a', 'b', 'c').clearLogic
      // use schema
      helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      }, done)
    })

  })

  describe('deepen/flatten', () => {

    it('should work with deepen as string', (done) => {
      const data = {'a.a': 1, 'a.b': 2, c: 3}
      const schema = new MySchema().deepen('.')
      // use schema
      helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal({a: {a: 1, b: 2}, c: 3})
      }, done)
    })

    it('should work with flatten as string', (done) => {
      const data = {a: {a: 1, b: 2}, c: 3}
      const schema = new MySchema().flatten('.')
      // use schema
      helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal({'a.a': 1, 'a.b': 2, c: 3})
      }, done)
    })

    it('should remove deepen', (done) => {
      const data = {'a.a': 1, 'a.b': 2, c: 3}
      const schema = new MySchema().deepen('.').not.deepen()
      // use schema
      helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      }, done)
    })

    it('should remove flatten', (done) => {
      const data = {a: {a: 1, b: 2}, c: 3}
      const schema = new MySchema().flatten('.').not.flatten()
      // use schema
      helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      }, done)
    })

    it('should describe deepen', () => {
      const schema = new MySchema().deepen('.')
      // use schema
      expect(helper.description(schema)).to.be.a('string')
    })

    it('should describe flatten', () => {
      const schema = new MySchema().flatten('.')
      // use schema
      expect(helper.description(schema)).to.be.a('string')
    })

  })

})
