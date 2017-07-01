// @flow
import chai from 'chai'

import { BooleanSchema, Reference } from '../../../src/index'
import * as helper from '../helper'

const expect = chai.expect

// to simplify copy and paste in other Schemas
const MySchema = BooleanSchema

describe('boolean', () => {

  it('should work without specification', (done) => {
    const data = true
    const schema = new MySchema()
    expect(schema, 'schema').to.be.an('object')
    // use schema
    helper.validateOk(schema, data, (res) => {
      expect(res).deep.equal(data)
    }, done)
  })

  it('should describe', () => {
    const schema = new MySchema()
    // use schema
    expect(helper.description(schema)).to.be.a('string')
  })

  describe('default parser', () => {

    it('should work for true', (done) => {
      const data = true
      const schema = new MySchema()
      // use schema
      helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      }, done)
    })

    it('should work for false', (done) => {
      const data = true
      const schema = new MySchema()
      // use schema
      helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      }, done)
    })

  })

  describe('truthy/falsy', () => {

    it('should work for true with arguments', (done) => {
      const data = 1
      const schema = new MySchema().truthy(1, 'yes')
      // use schema
      helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(true)
      }, done)
    })

    it('should work for true with list', (done) => {
      const data = 1
      const schema = new MySchema().truthy([1, 'yes'])
      // use schema
      helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(true)
      }, done)
    })

    it('should work for false with list', (done) => {
      const data = 'no'
      const schema = new MySchema().falsy([0, 'no'])
      // use schema
      helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(false)
      }, done)
    })

    it('should work for false with arguments', (done) => {
      const data = 'no'
      const schema = new MySchema().falsy(0, 'no')
      // use schema
      helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(false)
      }, done)
    })

    it('should allow reference for truthy list', (done) => {
      const data = 1
      const ref = new Reference([1, 'yes'])
      const schema = new MySchema().truthy(ref)
      // use schema
      helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(true)
      }, done)
    })

    it('should allow reference in truthy list', (done) => {
      const data = 1
      const ref = new Reference(1)
      const schema = new MySchema().truthy('yes', ref)
      // use schema
      helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(true)
      }, done)
    })

    it('should allow reference for falsy list', (done) => {
      const data = 1
      const ref = new Reference([1, 'no'])
      const schema = new MySchema().falsy(ref)
      // use schema
      helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(false)
      }, done)
    })

    it('should allow reference in falsy list', (done) => {
      const data = 1
      const ref = new Reference(1)
      const schema = new MySchema().falsy('no', ref)
      // use schema
      helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(false)
      }, done)
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

    it('should work', (done) => {
      const data = 'no'
      const schema = new MySchema().tolerant()
      // use schema
      helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(false)
      }, done)
    })

    it('should fail after clear', (done) => {
      const schema = new MySchema().truthy(1).tolerant(false)
      // use schema
      helper.validateFail(schema, 1, undefined, done)
    })

    it('should describe', () => {
      const schema = new MySchema().tolerant()
      // use schema
      expect(helper.description(schema)).to.be.a('string')
    })

  })

  describe('insensitive', () => {

    it('should work', (done) => {
      const data = 'NO'
      const schema = new MySchema().tolerant().insensitive()
      // use schema
      helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(false)
      }, done)
    })

    it('should fail if case sensitive', (done) => {
      const schema = new MySchema().tolerant()
      // use schema
      helper.validateFail(schema, 'NO', undefined, done)
    })

    it('should describe', () => {
      const schema = new MySchema().tolerant().insensitive()
      // use schema
      expect(helper.description(schema)).to.be.a('string')
    })

  })

  describe('format', () => {

    it('should work with defined true output', (done) => {
      const data = true
      const schema = new MySchema().format('JA', 'NEIN')
      // use schema
      helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal('JA')
      }, done)
    })

    it('should work with defined false object', (done) => {
      const data = false
      const schema = new MySchema().format('JA', { no: 1 })
      // use schema
      helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal({ no: 1 })
      }, done)
    })
// only one element
// ?????????
    it('should describe', () => {
      const schema = new MySchema().format('JA', { no: 1 })
      // use schema
      expect(helper.description(schema)).to.be.a('string')
    })

  })

})
