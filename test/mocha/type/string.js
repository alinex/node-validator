// @flow
import chai from 'chai'

import Schema from '../../../src/type/Schema'
import Reference from '../../../src/Reference'
import StringSchema from '../../../src/type/String'
import * as helper from '../helper'

const expect = chai.expect

// to simplify copy and paste in other Schemas
const MySchema = StringSchema

describe('string', () => {

  it('should work without specification', () => {
    const data = 'abc'
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

  describe('makeString', () => {

    it('should convert number', () => {
      const data = 12
      const schema = new MySchema().makeString()
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal('12')
      })
    })

    it('should fail without', () => {
      const data = 12
      const schema = new MySchema()
      // use schema
      return helper.validateFail(schema, data, undefined)
    })

    it('should remove', () => {
      const data = 12
      const schema = new MySchema().makeString().makeString(false)
      // use schema
      return helper.validateFail(schema, data, undefined)
    })

    it('should allow reference', () => {
      const data = 12
      const ref = new Reference(true)
      const schema = new MySchema().makeString(ref)
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal('12')
      })
    })

    it('should describe', () => {
      const schema = new MySchema().makeString()
      // use schema
      expect(helper.description(schema)).to.be.a('string')
    })

    it('should describe with reference', () => {
      const ref = new Reference(true)
      const schema = new MySchema().makeString(ref)
      // use schema
      expect(helper.description(schema)).to.be.a('string')
    })

  })

  describe('trim', () => {

    it('should work', () => {
      const data = '   abc  '
      const schema = new MySchema().trim()
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal('abc')
      })
    })

    it('should remove setting', () => {
      const data = '   abc  '
      const schema = new MySchema().trim().trim(false)
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      })
    })

    it('should allow reference', () => {
      const data = '   abc  '
      const ref = new Reference(true)
      const schema = new MySchema().trim(ref)
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal('abc')
      })
    })

    it('should describe', () => {
      const schema = new MySchema().trim()
      // use schema
      expect(helper.description(schema)).to.be.a('string')
    })

    it('should describe with reference', () => {
      const ref = new Reference(true)
      const schema = new MySchema().trim(ref)
      // use schema
      expect(helper.description(schema)).to.be.a('string')
    })

  })

  describe('replace', () => {

    it('should work', () => {
      const data = 'abc'
      const schema = new MySchema()
        .replace(/a/, '1', 'a').replace(/b/, '2', 'b').replace(/c/, '3', 'c')
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal('123')
      })
    })

    it('should work with references', () => {
      const data = 'b2c'
      const schema = new MySchema().replace(/(.)2/, 'a$1')
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal('abc')
      })
    })

    it('should work with remove', () => {
      const data = 'abc'
      const schema = new MySchema()
        .replace(/a/)
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal('bc')
      })
    })

    it('should remove named replace only', () => {
      const data = 'abc'
      const schema = new MySchema()
        .replace(/a/, '1', 'a').replace(/b/, '2', 'b').replace(/c/, '3', 'c')
        .replace('b')
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal('1b3')
      })
    })

    it('should remove all replaces', () => {
      const data = 'abc'
      const schema = new MySchema()
        .replace(/a/, '1', 'a').replace(/b/, '2', 'b').replace(/c/, '3', 'c')
        .replace()
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      })
    })

    it('should describe', () => {
      const schema = new MySchema()
        .replace(/a/, '1', 'a').replace(/b/, '2', 'b').replace(/c/, '3', 'c')
      // use schema
      expect(helper.description(schema)).to.be.a('string')
    })

  })

  describe('case', () => {

    it('should convert to lowercase', () => {
      const data = 'ABC'
      const schema = new MySchema().lowercase()
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal('abc')
      })
    })

    it('should convert to uppercase', () => {
      const data = 'abc'
      const schema = new MySchema().uppercase()
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal('ABC')
      })
    })

    it('should convert to lowercase first', () => {
      const data = 'ABC'
      const schema = new MySchema().lowercase('first')
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal('aBC')
      })
    })

    it('should convert to uppercase first', () => {
      const data = 'abc'
      const schema = new MySchema().uppercase('first')
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal('Abc')
      })
    })

    it('should remove lowercase', () => {
      const data = 'ABC'
      const schema = new MySchema().lowercase().lowercase(false)
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      })
    })

    it('should remove uppercase', () => {
      const data = 'abc'
      const schema = new MySchema().uppercase().uppercase(false)
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      })
    })

    it('should convert to lowercase with reference', () => {
      const data = 'ABC'
      const ref = new Reference(true)
      const schema = new MySchema().lowercase(ref)
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal('abc')
      })
    })

    it('should convert to uppercase with reference', () => {
      const data = 'abc'
      const ref = new Reference(true)
      const schema = new MySchema().uppercase(ref)
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal('ABC')
      })
    })

    it('should describe uppercase, lowercase first', () => {
      const schema = new MySchema().uppercase().lowercase('first')
      // use schema
      expect(helper.description(schema)).to.be.a('string')
    })

    it('should describe lowercase, uppercase first', () => {
      const schema = new MySchema().lowercase().uppercase('first')
      // use schema
      expect(helper.description(schema)).to.be.a('string')
    })

    it('should describe uppercase with reference', () => {
      const ref = new Reference(true)
      const schema = new MySchema().uppercase(ref)
      // use schema
      expect(helper.description(schema)).to.be.a('string')
    })

    it('should describe lowercase with reference', () => {
      const ref = new Reference(true)
      const schema = new MySchema().lowercase(ref)
      // use schema
      expect(helper.description(schema)).to.be.a('string')
    })

  })

  describe('check', () => {

    it('should only allow alphanum characters', () => {
      const data = 'abc'
      const schema = new MySchema().alphanum()
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      })
    })

    it('should fail for non alphanum characters', () => {
      const data = 'a+bc'
      const schema = new MySchema().alphanum()
      // use schema
      return helper.validateFail(schema, data, undefined)
    })

    it('should remove non alphanum characters', () => {
      const data = 'a+bc'
      const schema = new MySchema().alphanum().stripDisallowed()
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal('abc')
      })
    })

    it('should remove alphanum setting', () => {
      const data = 'a+bc'
      const schema = new MySchema().alphanum().alphanum(false)
      // use schema
      return helper.validateOk(schema, data, undefined)
    })

    it('should allow reference for alphanum', () => {
      const data = 'a+bc'
      const ref = new Reference(true)
      const schema = new MySchema().alphanum(ref)
      // use schema
      return helper.validateFail(schema, data, undefined)
    })

    it('should describe alphanum chech', () => {
      const schema = new MySchema().alphanum().stripDisallowed()
      // use schema
      expect(helper.description(schema)).to.be.a('string')
    })

    it('should describe alphanum reference', () => {
      const ref = new Reference(true)
      const schema = new MySchema().alphanum(ref)
      // use schema
      expect(helper.description(schema)).to.be.a('string')
    })

    it('should only allow hexadecimal characters', () => {
      const data = 'a6c4'
      const schema = new MySchema().hex()
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      })
    })

    it('should fail for non hexadecimal characters', () => {
      const data = 'abxy'
      const schema = new MySchema().hex()
      // use schema
      return helper.validateFail(schema, data, undefined)
    })

    it('should remove non hexadecimal characters', () => {
      const data = 'abxy'
      const schema = new MySchema().hex().stripDisallowed()
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal('ab')
      })
    })

    it('should remove hexadecimal setting', () => {
      const data = 'abxy'
      const schema = new MySchema().hex().hex(false)
      // use schema
      return helper.validateOk(schema, data, undefined)
    })

    it('should allow hexadecimal reference', () => {
      const data = 'abxy'
      const ref = new Reference(true)
      const schema = new MySchema().hex(ref)
      // use schema
      return helper.validateFail(schema, data, undefined)
    })

    it('should describe hexadecimal chech', () => {
      const schema = new MySchema().hex().stripDisallowed()
      // use schema
      expect(helper.description(schema)).to.be.a('string')
    })

    it('should also allow control characters', () => {
      const data = 'a\bb'
      const schema = new MySchema().controls()
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      })
    })

    it('should fail for non control characters', () => {
      const data = 'a\bb'
      const schema = new MySchema()
      // use schema
      return helper.validateFail(schema, data, undefined)
    })

    it('should remove control characters', () => {
      const data = 'a\bb'
      const schema = new MySchema().stripDisallowed()
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal('ab')
      })
    })

    it('should remove control setting', () => {
      const data = 'a\bb'
      const schema = new MySchema().controls().controls(false)
      // use schema
      return helper.validateFail(schema, data, undefined)
    })

    it('should fail for non control characters', () => {
      const data = 'a\bb'
      const ref = new Reference(true)
      const schema = new MySchema().controls(ref)
      // use schema
      return helper.validateOk(schema, data, undefined)
    })

    it('should describe control chech', () => {
      const schema = new MySchema().controls().stripDisallowed()
      // use schema
      expect(helper.description(schema)).to.be.a('string')
    })

    it('should describe control reference', () => {
      const ref = new Reference(true)
      const schema = new MySchema().controls(ref)
      // use schema
      expect(helper.description(schema)).to.be.a('string')
    })

    it('should allow tags', () => {
      const data = '<b>abc</b>'
      const schema = new MySchema()
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      })
    })

    it('should fail for not allowed tags', () => {
      const data = '<b>abc</b>'
      const schema = new MySchema().noHTML()
      // use schema
      return helper.validateFail(schema, data, undefined)
    })

    it('should remove html tags', () => {
      const data = '<b>abc</b>'
      const schema = new MySchema().noHTML().stripDisallowed()
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal('abc')
      })
    })

    it('should remove not allowed tags settings', () => {
      const data = '<b>abc</b>'
      const schema = new MySchema().noHTML().noHTML(true)
      // use schema
      return helper.validateFail(schema, data, undefined)
    })

    it('should not allowed tags with reference', () => {
      const data = '<b>abc</b>'
      const ref = new Reference(true)
      const schema = new MySchema().noHTML(ref)
      // use schema
      return helper.validateFail(schema, data, undefined)
    })

    it('should describe no HTML', () => {
      const schema = new MySchema().noHTML().stripDisallowed()
      // use schema
      expect(helper.description(schema)).to.be.a('string')
    })

    it('should describe no HTML with reference', () => {
      const ref = new Reference(true)
      const schema = new MySchema().noHTML(ref)
      // use schema
      expect(helper.description(schema)).to.be.a('string')
    })

  })

  describe('length', () => {

    it('should check for minimal length', () => {
      const data = 'abc'
      const schema = new MySchema().min(3)
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      })
    })

    it('should fail for minimal length', () => {
      const data = 'abc'
      const schema = new MySchema().min(5)
      // use schema
      return helper.validateFail(schema, data, undefined)
    })

    it('should remove minimal length setting', () => {
      const data = 'abc'
      const schema = new MySchema().min(5).min()
      // use schema
      return helper.validateOk(schema, data, undefined)
    })

    it('should allow reference for minimal length', () => {
      const data = 'abc'
      const ref = new Reference(5)
      const schema = new MySchema().min(ref)
      // use schema
      return helper.validateFail(schema, data, undefined)
    })

    it('should describe minimal length', () => {
      const schema = new MySchema().min(3)
      // use schema
      expect(helper.description(schema)).to.be.a('string')
    })

    it('should describe minimal length with reference', () => {
      const ref = new Reference(5)
      const schema = new MySchema().min(ref)
      // use schema
      expect(helper.description(schema)).to.be.a('string')
    })

    it('should check for maximal length', () => {
      const data = 'abc'
      const schema = new MySchema().max(3)
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      })
    })

    it('should fail for maximal length', () => {
      const data = 'abc'
      const schema = new MySchema().max(2)
      // use schema
      return helper.validateFail(schema, data, undefined)
    })

    it('should remove maximal length setting', () => {
      const data = 'abc'
      const schema = new MySchema().max(2).max()
      // use schema
      return helper.validateOk(schema, data, undefined)
    })

    it('should allow reference for maximal length', () => {
      const data = 'abc'
      const ref = new Reference(2)
      const schema = new MySchema().max(ref)
      // use schema
      return helper.validateFail(schema, data, undefined)
    })

    it('should describe maximal length', () => {
      const schema = new MySchema().max(5)
      // use schema
      expect(helper.description(schema)).to.be.a('string')
    })

    it('should describe maximal length with reference', () => {
      const ref = new Reference(5)
      const schema = new MySchema().max(ref)
      // use schema
      expect(helper.description(schema)).to.be.a('string')
    })

    it('should check for exact length', () => {
      const data = 'abc'
      const schema = new MySchema().length(3)
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      })
    })

    it('should fail for exact length', () => {
      const data = 'abc'
      const schema = new MySchema().length(2)
      // use schema
      return helper.validateFail(schema, data, undefined)
    })

    it('should allow to remove complete length setting', () => {
      const data = 'abc'
      const schema = new MySchema().min(12).max(15).length()
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      })
    })

    it('should allow reference for exact length', () => {
      const data = 'abc'
      const ref = new Reference(5)
      const schema = new MySchema().length(ref)
      // use schema
      return helper.validateFail(schema, data, undefined)
    })

    it('should describe exact length', () => {
      const schema = new MySchema().length(5)
      // use schema
      expect(helper.description(schema)).to.be.a('string')
    })

    it('should describe exact length with reference', () => {
      const ref = new Reference(5)
      const schema = new MySchema().length(ref)
      // use schema
      expect(helper.description(schema)).to.be.a('string')
    })

    it('should check for range', () => {
      const data = 'abc'
      const schema = new MySchema().min(2).max(5)
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      })
    })

    it('should fail for range', () => {
      const data = 'abc'
      const schema = new MySchema().min(4).max(5)
      // use schema
      return helper.validateFail(schema, data, undefined)
    })

    it('should describe range', () => {
      const schema = new MySchema().min(3).max(5)
      // use schema
      expect(helper.description(schema)).to.be.a('string')
    })

  })

  describe('pad/truncate', () => {

    it('should not pad', () => {
      const data = 'abc'
      const schema = new MySchema().min(3).pad()
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      })
    })

    it('should pad', () => {
      const data = 'abc'
      const schema = new MySchema().min(5).pad()
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal('abc  ')
      })
    })

    it('should pad left', () => {
      const data = 'abc'
      const schema = new MySchema().min(5).pad('left')
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal('  abc')
      })
    })

    it('should pad both', () => {
      const data = 'abc'
      const schema = new MySchema().min(6).pad('both')
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(' abc  ')
      })
    })

    it('should pad right char', () => {
      const data = 'abc'
      const schema = new MySchema().min(6).pad('right', '12345')
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal('abc345')
      })
    })

    it('should pad left char', () => {
      const data = 'abc'
      const schema = new MySchema().min(6).pad('left', '12345')
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal('123abc')
      })
    })

    it('should pad both char', () => {
      const data = 'abc'
      const schema = new MySchema().min(8).pad('both', '-<>-')
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal('-<abc>--')
      })
    })

    it('should describe pad', () => {
      const schema = new MySchema().min(5).pad()
      // use schema
      expect(helper.description(schema)).to.be.a('string')
    })

    it('should not truncate', () => {
      const data = 'abc'
      const schema = new MySchema().max(3).truncate()
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      })
    })

    it('should truncate', () => {
      const data = 'abcdefg'
      const schema = new MySchema().max(3).truncate()
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal('abc')
      })
    })

    it('should remove truncate setting', () => {
      const data = 'abcdefg'
      const schema = new MySchema().max(3).truncate().truncate(false)
      return helper.validateFail(schema, data, undefined)
    })

    it('should allow reference for truncate', () => {
      const data = 'abcdefg'
      const ref = new Reference(true)
      const schema = new MySchema().max(3).truncate(ref)
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal('abc')
      })
    })

    it('should describe truncate', () => {
      const schema = new MySchema().max(5).truncate()
      // use schema
      expect(helper.description(schema)).to.be.a('string')
    })

    it('should describe truncate with reference', () => {
      const ref = new Reference(true)
      const schema = new MySchema().max(5).truncate(ref)
      // use schema
      expect(helper.description(schema)).to.be.a('string')
    })

  })

  describe('match', () => {

    it('should match', () => {
      const data = 'abc'
      const schema = new MySchema().match(/ab/)
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      })
    })

    it('should fail for match', () => {
      const data = 'abc'
      const schema = new MySchema().match(/cd/)
      // use schema
      return helper.validateFail(schema, data, undefined)
    })

    it('should allow reference', () => {
      const data = 'abc'
      const ref = new Reference(/cd/)
      const schema = new MySchema().match(ref)
      // use schema
      return helper.validateFail(schema, data, undefined)
    })

    it('should allow reference as string', () => {
      const data = 'abc'
      const ref = new Reference('/cd/')
      const schema = new MySchema().match(ref)
      // use schema
      return helper.validateFail(schema, data, undefined)
    })

    it('should describe match', () => {
      const schema = new MySchema().match(/ab/)
      // use schema
      expect(helper.description(schema)).to.be.a('string')
    })

    it('should describe match with reference', () => {
      const ref = new Reference('/cd/')
      const schema = new MySchema().match(ref)
      // use schema
      expect(helper.description(schema)).to.be.a('string')
    })

    it('should not match', () => {
      const data = 'abc'
      const schema = new MySchema().notMatch(/cd/)
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      })
    })

    it('should not match with reference', () => {
      const data = 'abc'
      const ref = new Reference(/ab/)
      const schema = new MySchema().notMatch(ref)
      // use schema
      return helper.validateFail(schema, data, undefined)
    })

    it('should fail for not match', () => {
      const data = 'abc'
      const schema = new MySchema().notMatch(/ab/)
      // use schema
      return helper.validateFail(schema, data, undefined)
    })

    it('should describe not match', () => {
      const schema = new MySchema().notMatch(/ab/)
      // use schema
      expect(helper.description(schema)).to.be.a('string')
    })

    it('should describe not match with reference', () => {
      const ref = new Reference(/ab/)
      const schema = new MySchema().notMatch(ref)
      // use schema
      expect(helper.description(schema)).to.be.a('string')
    })

    it('should clear match', () => {
      const data = 'abc'
      const schema = new MySchema().notMatch(/ab/).notMatch()
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      })
    })

  })

})
