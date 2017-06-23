// @flow
import chai from 'chai'
import Debug from 'debug'

import Reference from '../../src/Reference'
import SchemaData from '../../src/SchemaData'

import * as helper from './helper'

const expect = chai.expect
const debug = Debug('test')

describe.only('reference', () => {

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

  // usage in data structure
  // usage in schema
  // usage in schema -> schema

})
