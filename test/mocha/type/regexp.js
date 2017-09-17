// @flow
import chai from 'chai'

import Reference from '../../../src/Reference'
import RegExpSchema from '../../../src/type/RegExp'
import * as helper from '../helper'

const expect = chai.expect

// to simplify copy and paste in other Schemas
const MySchema = RegExpSchema

describe.only('regexp', () => {

  it('should work with object', () => {
    const data = /abc/
    const schema = new MySchema()
    expect(schema).to.be.an('object')
    // use schema
    return helper.validateOk(schema, data, (res) => {
      expect(res).deep.equal(data)
    })
  })

  it('should work with string', () => {
    const data = '/abc/g'
    const schema = new MySchema()
    expect(schema).to.be.an('object')
    // use schema
    return helper.validateOk(schema, data, (res) => {
      expect(res).deep.equal(/abc/g)
    })
  })

  it('should fail for other text', () => {
    const data = 'xxxx'
    const schema = new MySchema()
    // use schema
    return helper.validateFail(schema, data, undefined)
  })

  it('should describe', () => {
    const schema = new MySchema()
    // use schema
    expect(helper.description(schema)).to.be.a('string')
  })

  describe('length', () => {

    it('should work with min', () => {
      const data = /a(b|c)/
      const schema = new MySchema().min(1)
      expect(schema).to.be.an('object')
      // use schema
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      })
    })

    it('should fail for min', () => {
      const data = /abc/
      const schema = new MySchema().min(1)
      // use schema
      return helper.validateFail(schema, data, undefined)
    })
  })
})
