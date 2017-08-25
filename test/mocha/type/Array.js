import chai from 'chai'

import Reference from '../../../src/Reference'
import ArraySchema from '../../../src/type/Array'
import AnySchema from '../../../src/type/Any'
import NumberSchema from '../../../src/type/Number'
import Schema from '../../../src/type/Schema'
import * as helper from '../helper'

const expect = chai.expect

// to simplify copy and paste in other Schemas
const MySchema = ArraySchema

describe('array', () => {

  it('should work without specification', () => {
    const data = [1, 2]
    const schema = new MySchema()
    expect(schema, 'schema').to.be.an('object')
    // use schema
    return helper.validateOk(schema, data, (res) => {
      expect(res).deep.equal(data)
    })
  })

  it('should fail if no array', () => {
    const data = 'a'
    const schema = new MySchema()
    // use schema
    return helper.validateFail(schema, data, undefined)
  })

  it('should describe', () => {
    const schema = new MySchema()
    // use schema
    expect(helper.description(schema)).to.equal('An array list is needed.')
  })

  describe('split', () => {

    it('should work with string', () => {
      const data = 'a,b,c'
      const schema = new MySchema().split(',')
      // use schema
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(['a', 'b', 'c'])
      })
    })

    it('should work with pattern', () => {
      const data = '1,2-3 -> 4'
      const schema = new MySchema().split(/\D+/)
      // use schema
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(['1', '2', '3', '4'])
      })
    })

    it('should remove setting', () => {
      const data = 'a,b,c'
      const schema = new MySchema().split(',').split()
      // use schema
      return helper.validateFail(schema, data, undefined)
    })

    it('should work with reference', () => {
      const data = 'a,b,c'
      const ref = new Reference(',')
      const schema = new MySchema().split(ref)
      // use schema
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(['a', 'b', 'c'])
      })
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

    it('should work with error', () => {
      const data = [1, 2, 3, 2]
      const schema = new MySchema().unique()
      // use schema
      return helper.validateFail(schema, data, undefined)
    })

    it('should work with sanitize', () => {
      const data = [1, 2, 3, 2]
      const schema = new MySchema().unique().sanitize()
      // use schema
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal([1, 2, 3])
      })
    })

    it('should allow remove', () => {
      const data = [1, 2, 3, 2]
      const schema = new MySchema().unique().unique(false)
      // use schema
      return helper.validateOk(schema, data, undefined)
    })

    it('should work with reference', () => {
      const data = [1, 2, 3, 2]
      const ref = new Reference(true)
      const schema = new MySchema().unique(ref)
      // use schema
      return helper.validateFail(schema, data, undefined)
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

    it('should work with shuffle', () => {
      const data = [1, 2, 3, 4, 5]
      const schema = new MySchema().shuffle()
      // use schema
      return helper.validateOk(schema, data, (res) => {
        expect(res).not.deep.equal([1, 2, 3, 4, 5])
      })
    })

    it('should remove shuffle', () => {
      const data = [1, 2, 3, 4, 5]
      const schema = new MySchema().shuffle().shuffle(false)
      // use schema
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal([1, 2, 3, 4, 5])
      })
    })

    it('should work with shuffle as reference', () => {
      const data = [1, 2, 3, 4, 5]
      const ref = new Reference(true)
      const schema = new MySchema().shuffle(ref)
      // use schema
      return helper.validateOk(schema, data, (res) => {
        expect(res).not.deep.equal([1, 2, 3, 4, 5])
      })
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

    it('should work with sort', () => {
      const data = [1, 4, 3, 2, 5]
      const schema = new MySchema().sort()
      // use schema
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal([1, 2, 3, 4, 5])
      })
    })

    it('should remove sort', () => {
      const data = [1, 4, 3, 2, 5]
      const schema = new MySchema().sort().sort(false)
      // use schema
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal([1, 4, 3, 2, 5])
      })
    })

    it('should work with sort as reference', () => {
      const data = [1, 4, 3, 2, 5]
      const ref = new Reference(true)
      const schema = new MySchema().sort(ref)
      // use schema
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal([1, 2, 3, 4, 5])
      })
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

    it('should work with reverse', () => {
      const data = [1, 2, 3, 4, 5]
      const schema = new MySchema().reverse()
      // use schema
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal([5, 4, 3, 2, 1])
      })
    })

    it('should remove reverse', () => {
      const data = [1, 2, 3, 4, 5]
      const schema = new MySchema().reverse().reverse(false)
      // use schema
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal([1, 2, 3, 4, 5])
      })
    })

    it('should work with reverse as reference', () => {
      const data = [1, 2, 3, 4, 5]
      const ref = new Reference(true)
      const schema = new MySchema().reverse(ref)
      // use schema
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal([5, 4, 3, 2, 1])
      })
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

    it('should work with one schema for all', () => {
      const data = ['1', '2', 3, 2]
      const schema = new MySchema()
        .item(new NumberSchema())
      // use schema
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal([1, 2, 3, 2])
      })
    })

    it('should work with ordered elements', () => {
      const data = ['1', '2', 3, 2]
      const schema = new MySchema()
        .item(new AnySchema())
        .item(new NumberSchema())
      // use schema
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(['1', 2, 3, 2])
      })
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

    it('should work with min', () => {
      const data = [1, 2, 3]
      const schema = new MySchema().min(3)
      // use schema
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal([1, 2, 3])
      })
    })

    it('should fail with min', () => {
      const data = [1, 2, 3]
      const schema = new MySchema().min(6)
      // use schema
      return helper.validateFail(schema, data, undefined)
    })

    it('should remove min', () => {
      const data = [1, 2, 3]
      const schema = new MySchema().min(3).min()
      // use schema
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal([1, 2, 3])
      })
    })

    it('should allow reference', () => {
      const data = [1, 2, 3]
      const ref = new Reference(6)
      const schema = new MySchema().min(ref)
      // use schema
      return helper.validateFail(schema, data, undefined)
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

    it('should work with max', () => {
      const data = [1, 2, 3]
      const schema = new MySchema().max(3)
      // use schema
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal([1, 2, 3])
      })
    })

    it('should fail with max', () => {
      const data = [1, 2, 3]
      const schema = new MySchema().max(2)
      // use schema
      return helper.validateFail(schema, data, undefined)
    })

    it('should remove max', () => {
      const data = [1, 2, 3]
      const schema = new MySchema().max(2).max()
      // use schema
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal([1, 2, 3])
      })
    })

    it('should allow reference', () => {
      const data = [1, 2, 3]
      const ref = new Reference(2)
      const schema = new MySchema().max(ref)
      // use schema
      return helper.validateFail(schema, data, undefined)
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

    it('should work with length', () => {
      const data = [1, 2, 3]
      const schema = new MySchema().length(3)
      // use schema
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal([1, 2, 3])
      })
    })

    it('should fail with length', () => {
      const data = [1, 2, 3]
      const schema = new MySchema().length(2)
      // use schema
      return helper.validateFail(schema, data, undefined)
    })

    it('should remove length', () => {
      const data = [1, 2, 3]
      const schema = new MySchema().length(2).length()
      // use schema
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal([1, 2, 3])
      })
    })

    it('should allow reference', () => {
      const data = [1, 2, 3]
      const ref = new Reference(2)
      const schema = new MySchema().length(ref)
      // use schema
      return helper.validateFail(schema, data, undefined)
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

    it('should work with json', () => {
      const data = [1, 2, { a: 1 }]
      const schema = new MySchema().format('json')
      // use schema
      return helper.validateOk(schema, data, (res) => {
        expect(res).to.be.a('string')
      })
    })

    it('should work with pretty', () => {
      const data = [1, 2, { a: 1 }]
      const schema = new MySchema().format('pretty')
      // use schema
      return helper.validateOk(schema, data, (res) => {
        expect(res).to.be.a('string')
      })
    })

    it('should work with simple', () => {
      const data = [1, 2, { a: 1 }]
      const schema = new MySchema().format('simple')
      // use schema
      return helper.validateOk(schema, data, (res) => {
        expect(res).to.be.a('string')
      })
    })

    it('should remove', () => {
      const data = [1, 2, { a: 1 }]
      const schema = new MySchema().format('json').format()
      // use schema
      return helper.validateOk(schema, data, (res) => {
        expect(res).to.not.be.a('string')
      })
    })

    it('should work with reference', () => {
      const data = [1, 2, { a: 1 }]
      const ref = new Reference('json')
      const schema = new MySchema().format(ref)
      // use schema
      return helper.validateOk(schema, data, (res) => {
        expect(res).to.be.a('string')
      })
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
