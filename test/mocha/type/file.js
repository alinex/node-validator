// @flow
import chai from 'chai'

import Reference from '../../../src/Reference'
import FileSchema from '../../../src/type/File'
import Schema from '../../../src/type/Schema'
import * as helper from '../helper'

const expect = chai.expect

// to simplify copy and paste in other Schemas
const MySchema = FileSchema

describe.only('file', () => {

  describe('simple', () => {

    it('should work', () => {
      const data = 'http://alinex.github.io'
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

  })

})
