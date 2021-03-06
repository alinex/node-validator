// @flow
import chai from 'chai'

import Reference from '../../../src/Reference'
import LogicSchema from '../../../src/type/Logic'
import NumberSchema from '../../../src/type/Number'
import StringSchema from '../../../src/type/String'
import ObjectSchema from '../../../src/type/Object'
import AnySchema from '../../../src/type/Any'
import Schema from '../../../src/type/Schema'
import * as helper from '../helper'

const expect = chai.expect

// to simplify copy and paste in other Schemas
const MySchema = LogicSchema

describe('logic', () => {

  it('should work without specification', () => {
    const data = 5
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
    expect(helper.description(schema)).to.equal('')
  })

  describe('and', () => {

    it('should work', () => {
      const data = '5_5'
      const schema = new MySchema()
        .allow(new StringSchema().replace(/_/g, '', 'remove _'))
        .and(new NumberSchema())
      // use schema
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(55)
      })
    })

    it('should fail', () => {
      const data = '5-5'
      const schema = new MySchema()
        .allow(new StringSchema().replace(/_/g, '', 'remove _'))
        .and(new NumberSchema())
      // use schema
      return helper.validateFail(schema, data, undefined)
    })

    it('should deny', () => {
      const data = '5_5'
      const schema = new MySchema()
        .deny(new StringSchema().replace(/_/g, '', 'remove _'))
        .and(new NumberSchema())
      // use schema
      return helper.validateFail(schema, data, undefined)
    })

    it('should work with deny', () => {
      const data = '5-5'
      const schema = new MySchema()
        .deny(new StringSchema().replace(/_/g, '', 'remove _'))
        .and(new NumberSchema())
      // use schema
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal('5-5')
      })
    })

    it('should describe', () => {
      const schema = new MySchema()
        .allow(new StringSchema().replace(/_/g, '', 'remove _'))
        .and(new NumberSchema())
      // use schema
      expect(helper.description(schema)).to.be.a('string')
    })

  })

  describe('OR', () => {

    it('should work', () => {
      const data = 'one'
      const schema = new MySchema()
        .allow(new StringSchema().replace(/^one$/i, '1').allow('1'))
        .or(new NumberSchema().positive())
      // use schema
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal('1')
      })
    })

    it('should work with alternative', () => {
      const data = 14
      const schema = new MySchema()
        .allow(new StringSchema().replace(/^one$/i, '1').allow('1'))
        .or(new NumberSchema().positive())
      // use schema
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(14)
      })
    })

    it('should fail', () => {
      const data = 'eins'
      const schema = new MySchema()
        .allow(new StringSchema().replace(/^one$/i, '1').allow('1'))
        .or(new NumberSchema().positive())
      // use schema
      return helper.validateFail(schema, data, undefined)
    })

    it('should describe', () => {
      const schema = new MySchema()
        .allow(new StringSchema().replace(/^one$/i, '1').allow('1'))
        .or(new NumberSchema().positive())
      // use schema
      expect(helper.description(schema)).to.be.a('string')
    })

  })

  describe('if', () => {

    it('should work with then', () => {
      const schema = new LogicSchema()
        .if(new NumberSchema().max(500))
        .then(new NumberSchema().unit('cm').format('0.00 $best'))
        .else(new NumberSchema().unit('g').format('0.00 $best'),
        )
      return helper.validateOk(schema, 150)
    })

    it('should work with else', () => {
      const schema = new LogicSchema()
        .if(new NumberSchema().max(500))
        .then(new NumberSchema().unit('cm').format('0.00 $best'))
        .else(new NumberSchema().unit('g').format('0.00 $best'),
        )
      return helper.validateOk(schema, 5000)
    })

    it('should work allow complex', () => {
      const schema = new ObjectSchema()
        .key('init',
          new LogicSchema()
            .if(new NumberSchema(new Reference().path('/start')).min(1))
            .then(new AnySchema().forbidden())
            .else(new AnySchema().required()),
        )
      const data = {
        start: 3,
        init: 'already running',
      }
      return helper.validateFail(schema, data)
    })

    it('should describe', () => {
      const schema = new LogicSchema()
        .if(new NumberSchema(new Reference().path('/start')).min(1))
        .then(new AnySchema().required())
        .else(new AnySchema().forbidden())
      expect(helper.description(schema)).to.be.a('string')
    })

  })

})
