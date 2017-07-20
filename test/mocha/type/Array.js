import chai from 'chai'

import { AnySchema, ArraySchema, NumberSchema, Reference } from '../../../src/index'
import Schema from '../../../src/Schema'
import * as helper from '../helper'

const expect = chai.expect

// to simplify copy and paste in other Schemas
const MySchema = ArraySchema

describe('array', () => {

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

  describe('sort', () => {

    it('should work with shuffle', (done) => {
      const data = [1, 2, 3, 4, 5]
      const schema = new MySchema().shuffle()
      // use schema
      helper.validateOk(schema, data, (res) => {
        expect(res).not.deep.equal([1, 2, 3, 4, 5])
      }, done)
    })

    it('should remove shuffle', (done) => {
      const data = [1, 2, 3, 4, 5]
      const schema = new MySchema().shuffle().shuffle(false)
      // use schema
      helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal([1, 2, 3, 4, 5])
      }, done)
    })

    it('should work with shuffle as reference', (done) => {
      const data = [1, 2, 3, 4, 5]
      const ref = new Reference(true)
      const schema = new MySchema().shuffle(ref)
      // use schema
      helper.validateOk(schema, data, (res) => {
        expect(res).not.deep.equal([1, 2, 3, 4, 5])
      }, done)
    })

    it('should describe shuffle', () => {
      const schema = new MySchema().shuffle()
      // use schema
      expect(helper.description(schema)).to.be.an('string')
    })

    it('should describe shuffle with reference', () => {
      const ref = new Reference(true)
      const schema = new MySchema().shuffle(ref)
      // use schema
      expect(helper.description(schema)).to.be.an('string')
    })

    it('should work with sort', (done) => {
      const data = [1, 4, 3, 2, 5]
      const schema = new MySchema().sort()
      // use schema
      helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal([1, 2, 3, 4, 5])
      }, done)
    })

    it('should remove sort', (done) => {
      const data = [1, 4, 3, 2, 5]
      const schema = new MySchema().sort().sort(false)
      // use schema
      helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal([1, 4, 3, 2, 5])
      }, done)
    })

    it('should work with sort as reference', (done) => {
      const data = [1, 4, 3, 2, 5]
      const ref = new Reference(true)
      const schema = new MySchema().sort(ref)
      // use schema
      helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal([1, 2, 3, 4, 5])
      }, done)
    })

    it('should describe sort', () => {
      const schema = new MySchema().sort()
      // use schema
      expect(helper.description(schema)).to.be.an('string')
    })

    it('should describe sort with reference', () => {
      const ref = new Reference(true)
      const schema = new MySchema().sort(ref)
      // use schema
      expect(helper.description(schema)).to.be.an('string')
    })

    it('should work with reverse', (done) => {
      const data = [1, 2, 3, 4, 5]
      const schema = new MySchema().reverse()
      // use schema
      helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal([5, 4, 3, 2, 1])
      }, done)
    })

    it('should remove reverse', (done) => {
      const data = [1, 2, 3, 4, 5]
      const schema = new MySchema().reverse().reverse(false)
      // use schema
      helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal([1, 2, 3, 4, 5])
      }, done)
    })

    it('should work with reverse as reference', (done) => {
      const data = [1, 2, 3, 4, 5]
      const ref = new Reference(true)
      const schema = new MySchema().reverse(ref)
      // use schema
      helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal([5, 4, 3, 2, 1])
      }, done)
    })

    it('should describe reverse', () => {
      const schema = new MySchema().reverse()
      // use schema
      expect(helper.description(schema)).to.be.an('string')
    })

    it('should describe reverse with reference', () => {
      const ref = new Reference(true)
      const schema = new MySchema().reverse(ref)
      // use schema
      expect(helper.description(schema)).to.be.an('string')
    })

  })

  describe('items', () => {

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

  describe('length ', () => {

    it('should work with min', (done) => {
      const data = [1, 2, 3]
      const schema = new MySchema().min(3)
      // use schema
      helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal([1, 2, 3])
      }, done)
    })

    it('should fail with min', (done) => {
      const data = [1, 2, 3]
      const schema = new MySchema().min(6)
      // use schema
      helper.validateFail(schema, data, undefined, done)
    })

    it('should remove min', (done) => {
      const data = [1, 2, 3]
      const schema = new MySchema().min(3).min()
      // use schema
      helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal([1, 2, 3])
      }, done)
    })

    it('should allow reference', (done) => {
      const data = [1, 2, 3]
      const ref = new Reference(6)
      const schema = new MySchema().min(ref)
      // use schema
      helper.validateFail(schema, data, undefined, done)
    })

    it('should describe min', () => {
      const schema = new MySchema().min(2)
      // use schema
      expect(helper.description(schema)).to.be.an('string')
    })

    it('should describe min with reference', () => {
      const ref = new Reference(6)
      const schema = new MySchema().min(ref)
      // use schema
      expect(helper.description(schema)).to.be.an('string')
    })

    it('should work with max', (done) => {
      const data = [1, 2, 3]
      const schema = new MySchema().max(3)
      // use schema
      helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal([1, 2, 3])
      }, done)
    })

    it('should fail with max', (done) => {
      const data = [1, 2, 3]
      const schema = new MySchema().max(2)
      // use schema
      helper.validateFail(schema, data, undefined, done)
    })

    it('should remove max', (done) => {
      const data = [1, 2, 3]
      const schema = new MySchema().max(2).max()
      // use schema
      helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal([1, 2, 3])
      }, done)
    })

    it('should allow reference', (done) => {
      const data = [1, 2, 3]
      const ref = new Reference(2)
      const schema = new MySchema().max(ref)
      // use schema
      helper.validateFail(schema, data, undefined, done)
    })

    it('should describe max', () => {
      const schema = new MySchema().max(2)
      // use schema
      expect(helper.description(schema)).to.be.an('string')
    })

    it('should describe max with reference', () => {
      const ref = new Reference(6)
      const schema = new MySchema().max(ref)
      // use schema
      expect(helper.description(schema)).to.be.an('string')
    })

    it('should describe between', () => {
      const schema = new MySchema().min(2).max(4)
      // use schema
      expect(helper.description(schema)).to.be.an('string')
    })

    it('should work with length', (done) => {
      const data = [1, 2, 3]
      const schema = new MySchema().length(3)
      // use schema
      helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal([1, 2, 3])
      }, done)
    })

    it('should fail with length', (done) => {
      const data = [1, 2, 3]
      const schema = new MySchema().length(2)
      // use schema
      helper.validateFail(schema, data, undefined, done)
    })

    it('should remove length', (done) => {
      const data = [1, 2, 3]
      const schema = new MySchema().length(2).length()
      // use schema
      helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal([1, 2, 3])
      }, done)
    })

    it('should allow reference', (done) => {
      const data = [1, 2, 3]
      const ref = new Reference(2)
      const schema = new MySchema().length(ref)
      // use schema
      helper.validateFail(schema, data, undefined, done)
    })

    it('should describe length', () => {
      const schema = new MySchema().length(2)
      // use schema
      expect(helper.description(schema)).to.be.an('string')
    })

    it('should describe length with reference', () => {
      const ref = new Reference(6)
      const schema = new MySchema().length(ref)
      // use schema
      expect(helper.description(schema)).to.be.an('string')
    })

  })

  describe('format', () => {

    it('should work with json', (done) => {
      const data = [1, 2, { a: 1 }]
      const schema = new MySchema().format('json')
      // use schema
      helper.validateOk(schema, data, (res) => {
        expect(res).to.be.a('string')
      }, done)
    })

    it('should work with pretty', (done) => {
      const data = [1, 2, { a: 1 }]
      const schema = new MySchema().format('pretty')
      // use schema
      helper.validateOk(schema, data, (res) => {
        expect(res).to.be.a('string')
      }, done)
    })

    it('should work with simple', (done) => {
      const data = [1, 2, { a: 1 }]
      const schema = new MySchema().format('simple')
      // use schema
      helper.validateOk(schema, data, (res) => {
        expect(res).to.be.a('string')
      }, done)
    })

    it('should remove', (done) => {
      const data = [1, 2, { a: 1 }]
      const schema = new MySchema().format('json').format()
      // use schema
      helper.validateOk(schema, data, (res) => {
        expect(res).to.not.be.a('string')
      }, done)
    })

    it('should work with reference', (done) => {
      const data = [1, 2, { a: 1 }]
      const ref = new Reference('json')
      const schema = new MySchema().format(ref)
      // use schema
      helper.validateOk(schema, data, (res) => {
        expect(res).to.be.a('string')
      }, done)
    })

    it('should describe', () => {
      const schema = new MySchema().format('pretty')
      // use schema
      expect(helper.description(schema)).to.be.a('string')
    })

    it('should describe with reference', () => {
      const ref = new Reference('pretty')
      const schema = new MySchema().format(ref)
      // use schema
      expect(helper.description(schema)).to.be.a('string')
    })

  })

})
