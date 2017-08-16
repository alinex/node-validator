// @flow
import chai from 'chai'

import Reference from '../../../src/Reference'
import BooleanSchema from '../../../src/BooleanSchema'
import * as helper from '../helper'

const expect = chai.expect

// to simplify copy and paste in other Schemas
const MySchema = BooleanSchema

describe('boolean', () => {

  it('should work without specification', () => {
    const data = true
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

  describe('default parser', () => {

    it('should work for true', () => {
      const data = true
      const schema = new MySchema()
      // use schema
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      })
    })

    it('should work for false', () => {
      const data = true
      const schema = new MySchema()
      // use schema
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      })
    })

  })

  describe('truthy/falsy', () => {

    it('should work for true with arguments', () => {
      const data = 1
      const schema = new MySchema().truthy(1, 'yes')
      // use schema
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(true)
      })
    })

    it('should work for true with list', () => {
      const data = 1
      const schema = new MySchema().truthy([1, 'yes'])
      // use schema
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(true)
      })
    })

    it('should work for false with list', () => {
      const data = 'no'
      const schema = new MySchema().falsy([0, 'no'])
      // use schema
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(false)
      })
    })

    it('should work for false with arguments', () => {
      const data = 'no'
      const schema = new MySchema().falsy(0, 'no')
      // use schema
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(false)
      })
    })

    it('should allow reference for truthy list', () => {
      const data = 1
      const ref = new Reference([1, 'yes'])
      const schema = new MySchema().truthy(ref)
      // use schema
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(true)
      })
    })

    it('should allow to remove truthy', () => {
      const data = 1
      const schema = new MySchema().truthy(1, 'yes').truthy()
      // use schema
      return helper.validateFail(schema, data, undefined)
    })

    it('should allow to remove falsy', () => {
      const data = 0
      const schema = new MySchema().falsy(0, 'no').falsy()
      // use schema
      return helper.validateFail(schema, data, undefined)
    })

    it('should allow reference in truthy list', () => {
      const data = 1
      const ref = new Reference(1)
      const schema = new MySchema().truthy('yes', ref)
      // use schema
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(true)
      })
    })

    it('should allow reference for falsy list', () => {
      const data = 1
      const ref = new Reference([1, 'no'])
      const schema = new MySchema().falsy(ref)
      // use schema
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(false)
      })
    })

    it('should allow reference in falsy list', () => {
      const data = 1
      const ref = new Reference(1)
      const schema = new MySchema().falsy('no', ref)
      // use schema
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(false)
      })
    })

    it('should describe', () => {
      const schema = new MySchema().truthy([1, 'yes']).falsy([0, 'no'])
      // use schema
      expect(helper.description(schema)).to.be.a('string')
    })

    it('should describe with reference', () => {
      const ref1 = new Reference([1, 'yes'])
      const ref2 = new Reference([0, 'no'])
      const schema = new MySchema().truthy(ref1).falsy(ref2)
      // use schema
      expect(helper.description(schema)).to.be.a('string')
    })

  })

  describe('tolerant', () => {

    it('should work', () => {
      const data = 'no'
      const schema = new MySchema().tolerant()
      // use schema
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(false)
      })
    })

    it('should fail after clear', () => {
      const schema = new MySchema().truthy(1).tolerant(false)
      // use schema
      return helper.validateFail(schema, 1, undefined)
    })

    it('should work with reference', () => {
      const data = 'no'
      const ref = new Reference(true)
      const schema = new MySchema().tolerant(ref)
      // use schema
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(false)
      })
    })

    it('should describe', () => {
      const schema = new MySchema().tolerant()
      // use schema
      expect(helper.description(schema)).to.be.a('string')
    })

    it('should describe with reference', () => {
      const ref = new Reference(true)
      const schema = new MySchema().tolerant(ref)
      // use schema
      expect(helper.description(schema)).to.be.a('string')
    })

  })

  describe('insensitive', () => {

    it('should work', () => {
      const data = 'NO'
      const schema = new MySchema().tolerant().insensitive()
      // use schema
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(false)
      })
    })

    it('should fail if case sensitive', () => {
      const schema = new MySchema().tolerant()
      // use schema
      return helper.validateFail(schema, 'NO', undefined)
    })

    it('should allow to remove', () => {
      const schema = new MySchema().tolerant().insensitive().insensitive(false)
      // use schema
      return helper.validateFail(schema, 'NO', undefined)
    })

    it('should work with reference', () => {
      const data = 'NO'
      const ref = new Reference(true)
      const schema = new MySchema().tolerant().insensitive(ref)
      // use schema
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(false)
      })
    })

    it('should describe', () => {
      const schema = new MySchema().tolerant().insensitive()
      // use schema
      expect(helper.description(schema)).to.be.a('string')
    })

    it('should describe with reference', () => {
      const ref = new Reference(true)
      const schema = new MySchema().tolerant().insensitive(ref)
      // use schema
      expect(helper.description(schema)).to.be.a('string')
    })

  })

  describe('format', () => {

    it('should work with defined true output', () => {
      const data = true
      const schema = new MySchema().format('JA', 'NEIN')
      // use schema
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal('JA')
      })
    })

    it('should work with defined false object', () => {
      const data = false
      const schema = new MySchema().format('JA', { no: 1 })
      // use schema
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal({ no: 1 })
      })
    })

    it('should work with only true output', () => {
      const data = true
      const schema = new MySchema().format('JA')
      // use schema
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal('JA')
      })
    })

    it('should work with only false object', () => {
      const data = false
      const schema = new MySchema().format(null, 'NEIN')
      // use schema
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal('NEIN')
      })
    })

    it('should allow to remove', () => {
      const data = true
      const schema = new MySchema().format('JA', 'NEIN').format()
      // use schema
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(true)
      })
    })

    it('should allow reference', () => {
      const data = true
      const ref = new Reference('JA')
      const schema = new MySchema().format(ref, 'NEIN')
      // use schema
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal('JA')
      })
    })

    it('should describe', () => {
      const schema = new MySchema().format('JA', { no: 1 })
      // use schema
      expect(helper.description(schema)).to.be.a('string')
    })

    it('should describe with reference', () => {
      const ref = new Reference('Nein')
      const schema = new MySchema().format('JA', ref)
      // use schema
      expect(helper.description(schema)).to.be.a('string')
    })

  })

})
