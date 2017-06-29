// @flow
import chai from 'chai'
import Debug from 'debug'

import Reference from '../../src/Reference'
import SchemaData from '../../src/SchemaData'
import Schema from '../../src/Schema'

import * as helper from './helper'

const expect = chai.expect
const debug = Debug('test')

describe('reference', () => {

  it('should get direct value', (done) => {
    const ref = new Reference({ a: 1 })
    helper.reference(ref, (res) => {
      expect(res).deep.equal({ a: 1 })
    }, done)
  })

  describe('path', () => {

    it('should get subelement of object', (done) => {
      const ref = new Reference({ a: 1 }).path('a')
      helper.reference(ref, (res) => {
        expect(res).deep.equal(1)
      }, done)
    })

  })

  describe('in data', () => {

    it('should resolve', (done) => {
      const data = 'abc'
      const ref = new Reference(data)
      const schema = new Schema()
      // use schema
      helper.validateOk(schema, ref, (res) => {
        expect(res).deep.equal(data)
      }, done)
    })

  })

  describe('in schema', () => {

    it('should resolve', (done) => {
      const data = 'abc'
      const ref = new Reference(data)
      const schema = new Schema().default(ref)
      // use schema
      helper.validateOk(schema, undefined, (res) => {
        expect(res).deep.equal(data)
      }, done)
    })

    it('should describe', () => {
      const data = 'abc'
      const ref = new Reference(data)
      const schema = new Schema().default(ref)
      // use schema
      expect(helper.description(schema))
      .to.equal('It will default to reference at \'abc\' if not set.')
    })

  })
  // usage in schema -> schema

})
