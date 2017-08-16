// @flow
import chai from 'chai'

import Reference from '../../../src/Reference'
import NumberSchema from '../../../src/NumberSchema'
import Schema from '../../../src/Schema'
import * as helper from '../helper'

const expect = chai.expect

// to simplify copy and paste in other Schemas
const MySchema = NumberSchema

describe('number', () => {
  it('should work without specification', () => {
    const data = 12.8
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

  describe('unit', () => {

    it('should work with float', () => {
      const data = 12.8
      const schema = new MySchema().unit('cm')
      // use schema
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(12.8)
      })
    })

    it('should convert', () => {
      const data = '1.28 m'
      const schema = new MySchema().unit('cm')
      // use schema
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(128)
      })
    })

    it('should convert to other unit', () => {
      const data = 1.28
      const schema = new MySchema().unit('m').toUnit('cm')
      // use schema
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(128)
      })
    })

    it('should fail with unknown unit', () => {
      const data = '12.8 alex'
      const schema = new MySchema().unit('cm')
      // use schema
      return helper.validateFail(schema, data, undefined)
    })

    it('should fail with not convertable unit', () => {
      const data = '12.8 kg'
      const schema = new MySchema().unit('cm')
      // use schema
      return helper.validateFail(schema, data, undefined)
    })

    it('should remove unit', () => {
      const data = '1.28 m'
      const schema = new MySchema().unit('cm').unit()
      // use schema
      return helper.validateFail(schema, data, undefined)
    })

    it('should remove toUnit', () => {
      const data = '1.28 m'
      const schema = new MySchema().unit('cm').toUnit('km').toUnit()
      // use schema
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(128)
      })
    })

    it('should allow reference for unit', () => {
      const data = '1.28 m'
      const ref = new Reference('cm')
      const schema = new MySchema().unit(ref)
      // use schema
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(128)
      })
    })

    it('should allow reference to other unit', () => {
      const data = 1.28
      const ref = new Reference('cm')
      const schema = new MySchema().unit('m').toUnit(ref)
      // use schema
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(128)
      })
    })

    it('should convert sanitze, too', () => {
      const data = 'the 1.28 m length'
      const schema = new MySchema().unit('cm').sanitize()
      // use schema
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(128)
      })
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
    it('should work with string number', () => {
      const data = '12.8'
      const schema = new MySchema()
      // use schema
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(12.8)
      })
    })

    it('should work with additional text', () => {
      const data = 'use 12.8 cm'
      const schema = new MySchema().sanitize()
      // use schema
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(12.8)
      })
    })

    it('should fail with additional text', () => {
      const data = 'use 12.8 cm'
      const schema = new MySchema()
      // use schema
      return helper.validateFail(schema, data, undefined)
    })

    it('should allow remove', () => {
      const data = 'use 12.8 cm'
      const schema = new MySchema().sanitize().sanitize(false)
      // use schema
      return helper.validateFail(schema, data, undefined)
    })

    it('should allow reference', () => {
      const data = 'use 12.8 cm'
      const ref = new Reference(true)
      const schema = new MySchema().sanitize(ref)
      // use schema
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(12.8)
      })
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

  describe('round', () => {

    it('should work with additional text', () => {
      const data = 12.8
      const schema = new MySchema().round()
      // use schema
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(13)
      })
    })

    it('should work with given precision', () => {
      const data = 12.876
      const schema = new MySchema().round(2)
      // use schema
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(12.88)
      })
    })

    it('should work with floor', () => {
      const data = 12.876
      const schema = new MySchema().round(2, 'floor')
      // use schema
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(12.87)
      })
    })

    it('should work with ceil', () => {
      const data = 12.876
      const schema = new MySchema().round(2, 'ceil')
      // use schema
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(12.88)
      })
    })

    it('should describe round', () => {
      const schema = new MySchema().round(2, 'ceil')
      // use schema
      expect(helper.description(schema)).to.be.a('string')
    })

    it('should round to integer', () => {
      const data = 12.8
      const schema = new MySchema().integer().sanitize()
      // use schema
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(13)
      })
    })

    it('should check for integer', () => {
      const data = 12
      const schema = new MySchema().integer()
      // use schema
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      })
    })

    it('should fail with float for integer', () => {
      const data = 12.8
      const schema = new MySchema().integer()
      // use schema
      return helper.validateFail(schema, data, undefined)
    })

    it('should remove round setting', () => {
      const data = 12.8
      const schema = new MySchema().round().round(false)
      // use schema
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      })
    })

    it('should remove integer setting', () => {
      const data = 12.8
      const schema = new MySchema().integer().integer(false)
      // use schema
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      })
    })

    it('should use reference for integer', () => {
      const data = 12.8
      const ref = new Reference(true)
      const schema = new MySchema().integer(ref)
      // use schema
      return helper.validateFail(schema, data, undefined)
    })

    it('should describe integer', () => {
      const schema = new MySchema().integer()
      // use schema
      expect(helper.description(schema)).to.be.a('string')
    })

    it('should describe with reference', () => {
      const ref = new Reference(true)
      const schema = new MySchema().integer(ref)
      // use schema
      expect(helper.description(schema)).to.be.a('string')
    })

  })

  describe('minmax', () => {

    it('should be positive', () => {
      const data = 12
      const schema = new MySchema().positive()
      // use schema
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      })
    })

    it('should fail with positive', () => {
      const data = -12
      const schema = new MySchema().positive()
      // use schema
      return helper.validateFail(schema, data, undefined)
    })

    it('should describe positive', () => {
      const schema = new MySchema().positive()
      // use schema
      expect(helper.description(schema)).to.be.a('string')
    })

    it('should be negative', () => {
      const data = -12
      const schema = new MySchema().negative()
      // use schema
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      })
    })

    it('should fail with negative', () => {
      const data = 12
      const schema = new MySchema().negative()
      // use schema
      return helper.validateFail(schema, data, undefined)
    })

    it('should describe negative', () => {
      const schema = new MySchema().negative()
      // use schema
      expect(helper.description(schema)).to.be.a('string')
    })

    it('should be positive', () => {
      const data = 12
      const schema = new MySchema().positive()
      // use schema
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      })
    })

    it('should fail with positive', () => {
      const data = -12
      const schema = new MySchema().positive()
      // use schema
      return helper.validateFail(schema, data, undefined)
    })

    it('should describe positive', () => {
      const schema = new MySchema().positive()
      // use schema
      expect(helper.description(schema)).to.be.a('string')
    })

    it('should support min', () => {
      const data = 12
      const schema = new MySchema().min(5)
      // use schema
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      })
    })

    it('should fail with min', () => {
      const data = -12
      const schema = new MySchema().min(5)
      // use schema
      return helper.validateFail(schema, data, undefined)
    })

    it('should describe min', () => {
      const schema = new MySchema().min(5)
      // use schema
      expect(helper.description(schema)).to.be.a('string')
    })

    it('should support greater', () => {
      const data = 12
      const schema = new MySchema().greater(5)
      // use schema
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      })
    })

    it('should fail with greater', () => {
      const data = 5
      const schema = new MySchema().greater(5)
      // use schema
      return helper.validateFail(schema, data, undefined)
    })

    it('should describe greater', () => {
      const schema = new MySchema().greater(5)
      // use schema
      expect(helper.description(schema)).to.be.a('string')
    })

    it('should support less', () => {
      const data = 4
      const schema = new MySchema().less(5)
      // use schema
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      })
    })

    it('should fail with less', () => {
      const data = 5
      const schema = new MySchema().less(5)
      // use schema
      return helper.validateFail(schema, data, undefined)
    })

    it('should describe less', () => {
      const schema = new MySchema().less(5)
      // use schema
      expect(helper.description(schema)).to.be.a('string')
    })

    it('should support max', () => {
      const data = 4
      const schema = new MySchema().max(5)
      // use schema
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      })
    })

    it('should fail with max', () => {
      const data = 12
      const schema = new MySchema().max(5)
      // use schema
      return helper.validateFail(schema, data, undefined)
    })

    it('should describe max', () => {
      const schema = new MySchema().max(5)
      // use schema
      expect(helper.description(schema)).to.be.a('string')
    })

    it('should support integer type', () => {
      const data = 4
      const schema = new MySchema().integerType(8)
      // use schema
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      })
    })

    it('should support integer type name', () => {
      const data = 4
      const schema = new MySchema().integerType('byte')
      // use schema
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      })
    })

    it('should support unsigned integer type', () => {
      const data = 4
      const schema = new MySchema().integerType(8).positive()
      // use schema
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      })
    })

    it('should fail with integer type', () => {
      const data = 12000000
      const schema = new MySchema().integerType(8)
      // use schema
      return helper.validateFail(schema, data, undefined)
    })

    it('should describe integer type', () => {
      const schema = new MySchema().integerType(8)
      // use schema
      expect(helper.description(schema)).to.be.a('string')
    })

    it('should allow reference for positive', () => {
      const data = -12
      const ref = new Reference(true)
      const schema = new MySchema().positive(ref)
      // use schema
      return helper.validateFail(schema, data, undefined)
    })

    it('should allow reference for negative', () => {
      const data = 12
      const ref = new Reference(true)
      const schema = new MySchema().negative(ref)
      // use schema
      return helper.validateFail(schema, data, undefined)
    })

    it('should allow reference for min', () => {
      const data = 12
      const ref = new Reference(16)
      const schema = new MySchema().min(ref)
      // use schema
      return helper.validateFail(schema, data, undefined)
    })

    it('should allow reference for max', () => {
      const data = 12
      const ref = new Reference(10)
      const schema = new MySchema().max(ref)
      // use schema
      return helper.validateFail(schema, data, undefined)
    })

    it('should allow reference for greater', () => {
      const data = -12
      const ref = new Reference(-12)
      const schema = new MySchema().greater(ref)
      // use schema
      return helper.validateFail(schema, data, undefined)
    })

    it('should allow reference for less', () => {
      const data = -12
      const ref = new Reference(-12)
      const schema = new MySchema().less(ref)
      // use schema
      return helper.validateFail(schema, data, undefined)
    })

    it('should describe with reference for positive', () => {
      const ref = new Reference(true)
      const schema = new MySchema().positive(ref)
      // use schema
      expect(helper.description(schema)).to.be.a('string')
    })

    it('should describe with reference for negative', () => {
      const ref = new Reference(true)
      const schema = new MySchema().negative(ref)
      // use schema
      expect(helper.description(schema)).to.be.a('string')
    })

    it('should describe with reference for min', () => {
      const ref = new Reference(5)
      const schema = new MySchema().min(ref)
      // use schema
      expect(helper.description(schema)).to.be.a('string')
    })

    it('should describe with reference for max', () => {
      const ref = new Reference(5)
      const schema = new MySchema().max(ref)
      // use schema
      expect(helper.description(schema)).to.be.a('string')
    })

    it('should describe with reference for greater', () => {
      const ref = new Reference(5)
      const schema = new MySchema().greater(ref)
      // use schema
      expect(helper.description(schema)).to.be.a('string')
    })

    it('should describe with reference for less', () => {
      const ref = new Reference(5)
      const schema = new MySchema().less(ref)
      // use schema
      expect(helper.description(schema)).to.be.a('string')
    })

  })

  describe('multiple', () => {

    it('should work', () => {
      const data = 16
      const schema = new MySchema().multiple(8)
      // use schema
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      })
    })

    it('should fail', () => {
      const data = 12
      const schema = new MySchema().multiple(8)
      // use schema
      return helper.validateFail(schema, data, undefined)
    })

    it('should remove', () => {
      const data = 12
      const schema = new MySchema().multiple(8).multiple()
      // use schema
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      })
    })

    it('should allow reference', () => {
      const data = 12
      const ref = new Reference(8)
      const schema = new MySchema().multiple(ref)
      // use schema
      return helper.validateFail(schema, data, undefined)
    })

    it('should describe', () => {
      const schema = new MySchema().multiple(8)
      // use schema
      expect(helper.description(schema)).to.be.a('string')
    })

    it('should describe with reference', () => {
      const ref = new Reference(8)
      const schema = new MySchema().multiple(ref)
      // use schema
      expect(helper.description(schema)).to.be.a('string')
    })

  })

  describe('format', () => {

    it('should work', () => {
      const data = 16
      const schema = new MySchema().format('0.00')
      // use schema
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal('16.00')
      })
    })

    it('should work with unit', () => {
      const data = 16
      const schema = new MySchema().unit('cm').format('0.00 $unit')
      // use schema
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal('16.00 cm')
      })
    })

    it('should work with best unit', () => {
      const data = 16000
      const schema = new MySchema().unit('cm').format('0.00 $best')
      // use schema
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal('160.00 m')
      })
    })

    it('should remove', () => {
      const data = 16
      const schema = new MySchema().format('0.00').format()
      // use schema
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      })
    })

    it('should allow reference', () => {
      const data = 16
      const ref = new Reference('0.00')
      const schema = new MySchema().format(ref)
      // use schema
      return helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal('16.00')
      })
    })

    it('should describe', () => {
      const schema = new MySchema().format('0.00')
      // use schema
      expect(helper.description(schema)).to.be.a('string')
    })

    it('should describe with reference', () => {
      const ref = new Reference('0.00')
      const schema = new MySchema().format(ref)
      // use schema
      expect(helper.description(schema)).to.be.a('string')
    })

  })

})
