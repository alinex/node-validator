import chai from 'chai'

import { AnySchema, ArraySchema, Reference } from '../../../src/index'
import Schema from '../../../src/Schema'
import * as helper from '../helper'

const expect = chai.expect

// to simplify copy and paste in other Schemas
const MySchema = ArraySchema

describe.only('array', () => {

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

    it('should describe', () => {
      const schema = new MySchema().split(',')
      // use schema
      expect(helper.description(schema)).to.be.an('string')
    })

  })

})
