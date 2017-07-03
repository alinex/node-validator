// @flow
import chai from 'chai'

import { NumberSchema, Reference } from '../../../src/index'
import Schema from '../../../src/Schema'
import * as helper from '../helper'

const expect = chai.expect

// to simplify copy and paste in other Schemas
const MySchema = NumberSchema

describe('number', () => {
  it('should work without specification', (done) => {
    const data = 12.8
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

  describe('unit', () => {
    it('should work with float', (done) => {
      const data = 12.8
      const schema = new MySchema().unit('cm')
      // use schema
      helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(12.8)
      }, done)
    })

    it('should convert', (done) => {
      const data = '1.28 m'
      const schema = new MySchema().unit('cm')
      // use schema
      helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(128)
      }, done)
    })

    it('should convert to other unit', (done) => {
      const data = 1.28
      const schema = new MySchema().unit('m').toUnit('cm')
      // use schema
      helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(128)
      }, done)
    })

    it('should fail with unknown unit', (done) => {
      const data = '12.8 alex'
      const schema = new MySchema().unit('cm')
      // use schema
      helper.validateFail(schema, data, undefined, done)
    })

    it('should fail with not convertable unit', (done) => {
      const data = '12.8 kg'
      const schema = new MySchema().unit('cm')
      // use schema
      helper.validateFail(schema, data, undefined, done)
    })

    it('should remove unit', (done) => {
      const data = '1.28 m'
      const schema = new MySchema().unit('cm').unit()
      // use schema
      helper.validateFail(schema, data, undefined, done)
    })

    it('should remove toUnit', (done) => {
      const data = '1.28 m'
      const schema = new MySchema().unit('cm').toUnit('km').toUnit()
      // use schema
      helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(128)
      }, done)
    })

    it('should allow reference for unit', (done) => {
      const data = '1.28 m'
      const ref = new Reference('cm')
      const schema = new MySchema().unit(ref)
      // use schema
      helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(128)
      }, done)
    })

    it('should allow reference to other unit', (done) => {
      const data = 1.28
      const ref = new Reference('cm')
      const schema = new MySchema().unit('m').toUnit(ref)
      // use schema
      helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(128)
      }, done)
    })

    it('should convert sanitze, too', (done) => {
      const data = 'the 1.28 m length'
      const schema = new MySchema().unit('cm').sanitize()
      // use schema
      helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(128)
      }, done)
    })

    it('should describe', () => {
      const schema = new MySchema().unit('cm')
      // use schema
      expect(helper.description(schema)).to.be.a('string')
    })

    it('should describe with reference', () => {
      const ref1 = new Reference('cm')
      const ref2 = new Reference('mm')
      const schema = new MySchema().unit(ref1).toUnit(ref2)
      // use schema
      expect(helper.description(schema)).to.be.a('string')
    })

  })

  describe('sanitize', () => {
    it('should work with string number', (done) => {
      const data = '12.8'
      const schema = new MySchema()
      // use schema
      helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(12.8)
      }, done)
    })

    it('should work with additional text', (done) => {
      const data = 'use 12.8 cm'
      const schema = new MySchema().sanitize()
      // use schema
      helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(12.8)
      }, done)
    })

    it('should fail with additional text', (done) => {
      const data = 'use 12.8 cm'
      const schema = new MySchema()
      // use schema
      helper.validateFail(schema, data, undefined, done)
    })

    it('should allow remove', (done) => {
      const data = 'use 12.8 cm'
      const schema = new MySchema().sanitize().sanitize(false)
      // use schema
      helper.validateFail(schema, data, undefined, done)
    })

    it('should allow reference', (done) => {
      const data = 'use 12.8 cm'
      const ref = new Reference(true)
      const schema = new MySchema().sanitize(ref)
      // use schema
      helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(12.8)
      }, done)
    })

    it('should describe', () => {
      const schema = new MySchema().sanitize()
      // use schema
      expect(helper.description(schema)).to.be.a('string')
    })

    it('should describe with reference', () => {
      const ref = new Reference(true)
      const schema = new MySchema().sanitize(ref)
      // use schema
      expect(helper.description(schema)).to.be.a('string')
    })

  })
//
//  describe('round', () => {
//    it('should work with additional text', (done) => {
//      const data = 12.8
//      const schema = new MySchema().round()
//      // use schema
//      helper.validateOk(schema, data, (res) => {
//        expect(res).deep.equal(13)
//      }, done)
//    })
//
//    it('should work with given precision', (done) => {
//      const data = 12.876
//      const schema = new MySchema().round(2)
//      // use schema
//      helper.validateOk(schema, data, (res) => {
//        expect(res).deep.equal(12.88)
//      }, done)
//    })
//
//    it('should work with floor', (done) => {
//      const data = 12.876
//      const schema = new MySchema().round(2, 'floor')
//      // use schema
//      helper.validateOk(schema, data, (res) => {
//        expect(res).deep.equal(12.87)
//      }, done)
//    })
//
//    it('should work with ceil', (done) => {
//      const data = 12.876
//      const schema = new MySchema().round(2, 'ceil')
//      // use schema
//      helper.validateOk(schema, data, (res) => {
//        expect(res).deep.equal(12.88)
//      }, done)
//    })
//
//    it('should describe round', () => {
//      const schema = new MySchema().round(2, 'ceil')
//      // use schema
//      expect(helper.description(schema)).to.be.a('string')
//    })
//
//    it('should round to integer', (done) => {
//      const data = 12.8
//      const schema = new MySchema().integer.sanitize
//      // use schema
//      helper.validateOk(schema, data, (res) => {
//        expect(res).deep.equal(13)
//      }, done)
//    })
//
//    it('should check for integer', (done) => {
//      const data = 12
//      const schema = new MySchema().integer
//      // use schema
//      helper.validateOk(schema, data, (res) => {
//        expect(res).deep.equal(data)
//      }, done)
//    })
//
//    it('should fail with float for integer', (done) => {
//      const data = 12.8
//      const schema = new MySchema().integer
//      // use schema
//      helper.validateFail(schema, data, undefined, done)
//    })
//
//    it('should describe integer', () => {
//      const schema = new MySchema().integer
//      // use schema
//      expect(helper.description(schema)).to.be.a('string')
//    })
//  })
//
//  describe('minmax', () => {
//    it('should be positive', (done) => {
//      const data = 12
//      const schema = new MySchema().positive
//      // use schema
//      helper.validateOk(schema, data, (res) => {
//        expect(res).deep.equal(data)
//      }, done)
//    })
//
//    it('should fail with positive', (done) => {
//      const data = -12
//      const schema = new MySchema().positive
//      // use schema
//      helper.validateFail(schema, data, undefined, done)
//    })
//
//    it('should describe positive', () => {
//      const schema = new MySchema().positive
//      // use schema
//      expect(helper.description(schema)).to.be.a('string')
//    })
//
//    it('should be negative', (done) => {
//      const data = -12
//      const schema = new MySchema().negative
//      // use schema
//      helper.validateOk(schema, data, (res) => {
//        expect(res).deep.equal(data)
//      }, done)
//    })
//
//    it('should fail with negative', (done) => {
//      const data = 12
//      const schema = new MySchema().negative
//      // use schema
//      helper.validateFail(schema, data, undefined, done)
//    })
//
//    it('should describe negative', () => {
//      const schema = new MySchema().negative
//      // use schema
//      expect(helper.description(schema)).to.be.a('string')
//    })
//
//    it('should be positive', (done) => {
//      const data = 12
//      const schema = new MySchema().positive
//      // use schema
//      helper.validateOk(schema, data, (res) => {
//        expect(res).deep.equal(data)
//      }, done)
//    })
//
//    it('should fail with positive', (done) => {
//      const data = -12
//      const schema = new MySchema().positive
//      // use schema
//      helper.validateFail(schema, data, undefined, done)
//    })
//
//    it('should describe positive', () => {
//      const schema = new MySchema().positive
//      // use schema
//      expect(helper.description(schema)).to.be.a('string')
//    })
//
//    it('should support min', (done) => {
//      const data = 12
//      const schema = new MySchema().min(5)
//      // use schema
//      helper.validateOk(schema, data, (res) => {
//        expect(res).deep.equal(data)
//      }, done)
//    })
//
//    it('should fail with min', (done) => {
//      const data = -12
//      const schema = new MySchema().min(5)
//      // use schema
//      helper.validateFail(schema, data, undefined, done)
//    })
//
//    it('should describe min', () => {
//      const schema = new MySchema().min(5)
//      // use schema
//      expect(helper.description(schema)).to.be.a('string')
//    })
//
//    it('should support greater', (done) => {
//      const data = 12
//      const schema = new MySchema().greater(5)
//      // use schema
//      helper.validateOk(schema, data, (res) => {
//        expect(res).deep.equal(data)
//      }, done)
//    })
//
//    it('should fail with greater', (done) => {
//      const data = 5
//      const schema = new MySchema().greater(5)
//      // use schema
//      helper.validateFail(schema, data, undefined, done)
//    })
//
//    it('should describe greater', () => {
//      const schema = new MySchema().greater(5)
//      // use schema
//      expect(helper.description(schema)).to.be.a('string')
//    })
//
//    it('should support less', (done) => {
//      const data = 4
//      const schema = new MySchema().less(5)
//      // use schema
//      helper.validateOk(schema, data, (res) => {
//        expect(res).deep.equal(data)
//      }, done)
//    })
//
//    it('should fail with less', (done) => {
//      const data = 5
//      const schema = new MySchema().less(5)
//      // use schema
//      helper.validateFail(schema, data, undefined, done)
//    })
//
//    it('should describe less', () => {
//      const schema = new MySchema().less(5)
//      // use schema
//      expect(helper.description(schema)).to.be.a('string')
//    })
//
//    it('should support max', (done) => {
//      const data = 4
//      const schema = new MySchema().max(5)
//      // use schema
//      helper.validateOk(schema, data, (res) => {
//        expect(res).deep.equal(data)
//      }, done)
//    })
//
//    it('should fail with max', (done) => {
//      const data = 12
//      const schema = new MySchema().max(5)
//      // use schema
//      helper.validateFail(schema, data, undefined, done)
//    })
//
//    it('should describe max', () => {
//      const schema = new MySchema().max(5)
//      // use schema
//      expect(helper.description(schema)).to.be.a('string')
//    })
//
//    it('should support integer type', (done) => {
//      const data = 4
//      const schema = new MySchema().integerType(8)
//      // use schema
//      helper.validateOk(schema, data, (res) => {
//        expect(res).deep.equal(data)
//      }, done)
//    })
//
//    it('should support integer type name', (done) => {
//      const data = 4
//      const schema = new MySchema().integerType('byte')
//      // use schema
//      helper.validateOk(schema, data, (res) => {
//        expect(res).deep.equal(data)
//      }, done)
//    })
//
//    it('should support unsigned integer type', (done) => {
//      const data = 4
//      const schema = new MySchema().integerType(8).positive
//      // use schema
//      helper.validateOk(schema, data, (res) => {
//        expect(res).deep.equal(data)
//      }, done)
//    })
//
//    it('should fail with integer type', (done) => {
//      const data = 12000000
//      const schema = new MySchema().integerType(8)
//      // use schema
//      helper.validateFail(schema, data, undefined, done)
//    })
//
//    it('should describe integer type', () => {
//      const schema = new MySchema().integerType(8)
//      // use schema
//      expect(helper.description(schema)).to.be.a('string')
//    })
//  })
//
//  describe('multiple', () => {
//    it('should work', (done) => {
//      const data = 16
//      const schema = new MySchema().multiple(8)
//      // use schema
//      helper.validateOk(schema, data, (res) => {
//        expect(res).deep.equal(data)
//      }, done)
//    })
//
//    it('should fail', (done) => {
//      const data = 12
//      const schema = new MySchema().multiple(8)
//      // use schema
//      helper.validateFail(schema, data, undefined, done)
//    })
//
//    it('should describe', () => {
//      const schema = new MySchema().multiple(8)
//      // use schema
//      expect(helper.description(schema)).to.be.a('string')
//    })
//  })
//
//  describe('format', () => {
//    it('should work', (done) => {
//      const data = 16
//      const schema = new MySchema().format('0.00')
//      // use schema
//      helper.validateOk(schema, data, (res) => {
//        expect(res).deep.equal('16.00')
//      }, done)
//    })
//
//    it('should work with unit', (done) => {
//      const data = 16
//      const schema = new MySchema().unit('cm').format('0.00 $unit')
//      // use schema
//      helper.validateOk(schema, data, (res) => {
//        expect(res).deep.equal('16.00 cm')
//      }, done)
//    })
//
//    it('should work with best unit', (done) => {
//      const data = 16000
//      const schema = new MySchema().unit('cm').format('0.00 $best')
//      // use schema
//      helper.validateOk(schema, data, (res) => {
//        expect(res).deep.equal('160.00 m')
//      }, done)
//    })
//
//    it('should describe', () => {
//      const schema = new MySchema().format('0.00')
//      // use schema
//      expect(helper.description(schema)).to.be.a('string')
//    })
//  })
})
