// @flow
import chai from 'chai'
import Debug from 'debug'

import Reference from '../../src/Reference'
import SchemaData from '../../src/SchemaData'

import * as helper from './helper'

const expect = chai.expect
const debug = Debug('test')

describe('reference', () => {

  it('should create reference', (done) => {
    const ref = new Reference('a')
//    ref.context({ a: 1 })
//    helper.reference(ref, (res) => {
//      expect(res).deep.equal(1)
//    }, done)
    done()
  })

})
