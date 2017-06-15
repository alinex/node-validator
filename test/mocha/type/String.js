// @flow
import chai from 'chai'

import {StringSchema} from '../../../src/index'
import Schema from '../../../src/Schema'
import * as helper from '../helper'

const expect = chai.expect

// to simplify copy and paste in other Schemas
const MySchema = StringSchema

describe('type string', () => {

  it('should work without specification', (done) => {
    const data = 'abc'
    const schema = new MySchema()
    expect(schema, 'schema').to.be.an('object')
    // use schema
    helper.validateOk(schema, data, (res) => {
      expect(res).deep.equal(data)
      done()
    })
  })

  it('should describe', () => {
    const schema = new MySchema()
    // use schema
    expect(helper.description(schema)).to.be.a('string')
  })

  describe('optional/default', () => {

    it('should work with required', (done) => {
      const data = 'abc'
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
      const data = 'abc'
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

  describe('makeString', () => {

    it('should convert number', (done) => {
      const data = 12
      const schema = new MySchema().makeString
      helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal('12')
      }, done)
    })

    it('should fail without', (done) => {
      const data = 12
      const schema = new MySchema()
      // use schema
      helper.validateFail(schema, data, undefined, done)
    })

    it('should disable with not', (done) => {
      const data = 12
      const schema = new MySchema().makeString.not.makeString
      // use schema
      helper.validateFail(schema, data, undefined, done)
    })

    it('should describe', () => {
      const schema = new MySchema().makeString
      // use schema
      expect(helper.description(schema)).to.be.a('string')
    })

  })

  describe('trim', () => {

    it('should work', (done) => {
      const data = '   abc  '
      const schema = new MySchema().trim
      helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal('abc')
      }, done)
    })

    it('should not work if removed', (done) => {
      const data = '   abc  '
      const schema = new MySchema().trim.not.trim
      helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      }, done)
    })

    it('should describe', () => {
      const schema = new MySchema().trim
      // use schema
      expect(helper.description(schema)).to.be.a('string')
    })

  })

  describe('replace', () => {

    it('should work', (done) => {
      const data = 'abc'
      const schema = new MySchema()
      .replace(/a/, '1', 'a').replace(/b/, '2', 'b').replace(/c/, '3', 'c')
      helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal('123')
      }, done)
    })

    it('should work with references', (done) => {
      const data = 'b2c'
      const schema = new MySchema().replace(/(.)2/, 'a$1')
      helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal('abc')
      }, done)
    })

    it('should work with remove', (done) => {
      const data = 'abc'
      const schema = new MySchema()
      .replace(/a/)
      helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal('bc')
      }, done)
    })

    it('should remove named replace only', (done) => {
      const data = 'abc'
      const schema = new MySchema()
      .replace(/a/, '1', 'a').replace(/b/, '2', 'b').replace(/c/, '3', 'c')
      .not.replace('b')
      helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal('1b3')
      }, done)
    })

    it('should remove all replaces', (done) => {
      const data = 'abc'
      const schema = new MySchema()
      .replace(/a/, '1', 'a').replace(/b/, '2', 'b').replace(/c/, '3', 'c')
      .not.replace()
      helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      }, done)
    })

    it('should describe', () => {
      const schema = new MySchema()
      .replace(/a/, '1', 'a').replace(/b/, '2', 'b').replace(/c/, '3', 'c')
      // use schema
      expect(helper.description(schema)).to.be.a('string')
    })

  })

  describe('case', () => {

    it('should convert to lowercase', (done) => {
      const data = 'ABC'
      const schema = new MySchema().lowercase()
      helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal('abc')
      }, done)
    })

    it('should convert to uppercase', (done) => {
      const data = 'abc'
      const schema = new MySchema().uppercase()
      helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal('ABC')
      }, done)
    })

    it('should convert to lowercase first', (done) => {
      const data = 'ABC'
      const schema = new MySchema().lowercase('first')
      helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal('aBC')
      }, done)
    })

    it('should convert to uppercase first', (done) => {
      const data = 'abc'
      const schema = new MySchema().uppercase('first')
      helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal('Abc')
      }, done)
    })

    it('should convert to lowercase', (done) => {
      const data = 'ABC'
      const schema = new MySchema().lowercase().not.lowercase()
      helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      }, done)
    })

    it('should convert to uppercase', (done) => {
      const data = 'abc'
      const schema = new MySchema().uppercase().not.uppercase()
      helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      }, done)
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

  })

  describe('check', () => {

    it('should only allow alphanum characters', (done) => {
      const data = 'abc'
      const schema = new MySchema().alphanum
      helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      }, done)
    })

    it('should fail for non alphanum characters', (done) => {
      const data = 'a+bc'
      const schema = new MySchema().alphanum
      // use schema
      helper.validateFail(schema, data, undefined, done)
    })

    it('should remove non alphanum characters', (done) => {
      const data = 'a+bc'
      const schema = new MySchema().alphanum.stripDisallowed
      helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal('abc')
      }, done)
    })

    it('should describe alphanum chech', () => {
      const schema = new MySchema().alphanum.stripDisallowed
      // use schema
      expect(helper.description(schema)).to.be.a('string')
    })

    it('should only allow hexadecimal characters', (done) => {
      const data = 'a6c4'
      const schema = new MySchema().hex
      helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      }, done)
    })

    it('should fail for non hexadecimal characters', (done) => {
      const data = 'abxy'
      const schema = new MySchema().hex
      // use schema
      helper.validateFail(schema, data, undefined, done)
    })

    it('should remove non hexadecimal characters', (done) => {
      const data = 'abxy'
      const schema = new MySchema().hex.stripDisallowed
      helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal('ab')
      }, done)
    })

    it('should describe hexadecimal chech', () => {
      const schema = new MySchema().hex.stripDisallowed
      // use schema
      expect(helper.description(schema)).to.be.a('string')
    })

    it('should also allow control characters', (done) => {
      const data = 'a\bb'
      const schema = new MySchema().controls
      helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      }, done)
    })

    it('should fail for non control characters', (done) => {
      const data = 'a\bb'
      const schema = new MySchema()
      // use schema
      helper.validateFail(schema, data, undefined, done)
    })

    it('should remove control characters', (done) => {
      const data = 'a\bb'
      const schema = new MySchema().stripDisallowed
      helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal('ab')
      }, done)
    })

    it('should describe control chech', () => {
      const schema = new MySchema().controls.stripDisallowed
      // use schema
      expect(helper.description(schema)).to.be.a('string')
    })

    it('should allow tags', (done) => {
      const data = '<b>abc</b>'
      const schema = new MySchema()
      helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      }, done)
    })

    it('should fail for not allowed tags', (done) => {
      const data = '<b>abc</b>'
      const schema = new MySchema().noHTML
      // use schema
      helper.validateFail(schema, data, undefined, done)
    })

    it('should remove html tags', (done) => {
      const data = '<b>abc</b>'
      const schema = new MySchema().noHTML.stripDisallowed
      helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal('abc')
      }, done)
    })

    it('should describe no HTML', () => {
      const schema = new MySchema().noHTML.stripDisallowed
      // use schema
      expect(helper.description(schema)).to.be.a('string')
    })

  })

  describe('length', () => {

    it('should check for minimal length', (done) => {
      const data = 'abc'
      const schema = new MySchema().min(3)
      helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      }, done)
    })

    it('should fail for minimal length', (done) => {
      const data = 'abc'
      const schema = new MySchema().min(5)
      // use schema
      helper.validateFail(schema, data, undefined, done)
    })

    it('should describe minimal length', () => {
      const schema = new MySchema().min(3)
      // use schema
      expect(helper.description(schema)).to.be.a('string')
    })

    it('should check for maximal length', (done) => {
      const data = 'abc'
      const schema = new MySchema().max(3)
      helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      }, done)
    })

    it('should fail for maximal length', (done) => {
      const data = 'abc'
      const schema = new MySchema().max(2)
      // use schema
      helper.validateFail(schema, data, undefined, done)
    })

    it('should describe maximal length', () => {
      const schema = new MySchema().max(5)
      // use schema
      expect(helper.description(schema)).to.be.a('string')
    })

    it('should check for exact length', (done) => {
      const data = 'abc'
      const schema = new MySchema().length(3)
      helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      }, done)
    })

    it('should fail for exact length', (done) => {
      const data = 'abc'
      const schema = new MySchema().length(2)
      // use schema
      helper.validateFail(schema, data, undefined, done)
    })

    it('should describe exact length', () => {
      const schema = new MySchema().length(5)
      // use schema
      expect(helper.description(schema)).to.be.a('string')
    })

    it('should check for range', (done) => {
      const data = 'abc'
      const schema = new MySchema().min(2).max(5)
      helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      }, done)
    })

    it('should fail for range', (done) => {
      const data = 'abc'
      const schema = new MySchema().min(4).max(5)
      // use schema
      helper.validateFail(schema, data, undefined, done)
    })

    it('should describe range', () => {
      const schema = new MySchema().min(3).max(5)
      // use schema
      expect(helper.description(schema)).to.be.a('string')
    })

  })

  describe('pad/truncate', () => {

    it('should not pad', (done) => {
      const data = 'abc'
      const schema = new MySchema().min(3).pad()
      helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      }, done)
    })

    it('should pad', (done) => {
      const data = 'abc'
      const schema = new MySchema().min(5).pad()
      helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal('abc  ')
      }, done)
    })

    it('should pad left', (done) => {
      const data = 'abc'
      const schema = new MySchema().min(5).pad('left')
      helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal('  abc')
      }, done)
    })

    it('should pad both', (done) => {
      const data = 'abc'
      const schema = new MySchema().min(6).pad('both')
      helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(' abc  ')
      }, done)
    })

    it('should pad right char', (done) => {
      const data = 'abc'
      const schema = new MySchema().min(6).pad('right', '12345')
      helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal('abc345')
      }, done)
    })

    it('should pad left char', (done) => {
      const data = 'abc'
      const schema = new MySchema().min(6).pad('left', '12345')
      helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal('123abc')
      }, done)
    })

    it('should pad both char', (done) => {
      const data = 'abc'
      const schema = new MySchema().min(8).pad('both', '-<>-')
      helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal('-<abc>--')
      }, done)
    })

    it('should describe pad', () => {
      const schema = new MySchema().min(5).pad()
      // use schema
      expect(helper.description(schema)).to.be.a('string')
    })

    it('should not truncate', (done) => {
      const data = 'abc'
      const schema = new MySchema().max(3).truncate
      helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      }, done)
    })

    it('should truncate', (done) => {
      const data = 'abcdefg'
      const schema = new MySchema().max(3).truncate
      helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal('abc')
      }, done)
    })

    it('should describe truncate', () => {
      const schema = new MySchema().max(5).truncate
      // use schema
      expect(helper.description(schema)).to.be.a('string')
    })

  })

})
