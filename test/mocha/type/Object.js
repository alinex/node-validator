import chai from 'chai'

import * as validator from '../../../src/index'
import Schema from '../../../src/Schema'
import * as helper from '../helper'

const expect = chai.expect

// to simplify copy and paste in other Schemas
const MySchema = validator.Object

describe('type object', () => {

  it('should work without specification', (done) => {
    const data = {a: 1}
    const schema = new MySchema()
    expect(schema, 'schema').to.be.an('object')
    // use schema
    helper.validateOk(schema, data, (res) => {
      expect(res).deep.equal(data)
      done()
    })
  })

  it('should fail if no object', (done) => {
    const data = 'a'
    const schema = new MySchema()
    // use schema
    helper.validateFail(schema, data, undefined, done)
  })

  it('should describe', () => {
    const schema = new MySchema()
    // use schema
    expect(helper.description(schema)).to.equal('Any data type. It is optional and must not be set. A data object is needed.')
  })

  describe('optional/default', () => {

    it('should work with required', (done) => {
      const data = {a: 1}
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
      const data = { a: 1 }
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

  describe('key/pattern', () => {

    it('should work with defined keys', (done) => {
      const data = {a: 1}
      const schema = new MySchema()
      expect(schema).to.be.an('object')
      schema.key('a', new validator.Any())
      // use schema
      helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      }, done)
    })

    it('should describe with defined keys', () => {
      const schema = new MySchema()
      schema.key('a', new validator.Any())
      // use schema
      expect(helper.description(schema)).to.equal('Any data type. It is optional and must not be set. \
A data object is needed. The following keys have a special format:\n\
- `a`: Any data type. It is optional and must not be set.')
    })

    it('should work with defined pattern', (done) => {
      const data = {name1: 1}
      const schema = new MySchema()
      expect(schema).to.be.an('object')
      schema.pattern(/name\d/, new validator.Any())
      // use schema
      helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      }, done)
    })

    it('should describe with defined pattern', () => {
      const schema = new MySchema()
      schema.pattern(/name\d/, new validator.Any())
      // use schema
      expect(helper.description(schema)).to.equal('Any data type. It is optional and must not be set. \
A data object is needed. The following keys have a special format:\n\
- `/name\\d/`: Any data type. It is optional and must not be set.')
    })

  })

  describe('removeUnspecified', () => {

    it('should work with defined keys', (done) => {
      const data = {a: 1, b: 2, c: 3}
      const schema = new MySchema().removeUnspecified
      .key('a', new validator.Any())
      // use schema
      helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal({a: 1})
      }, done)
    })

    it('should work with pattern', (done) => {
      const data = {a: 1, b: 2, c: 3}
      const schema = new MySchema().removeUnspecified
      .pattern(/[ab]/, new validator.Any())
      // use schema
      helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal({a: 1, b: 2})
      }, done)
    })

    it('should describe', () => {
      const schema = new MySchema().removeUnspecified
      .key('a', new validator.Any())
      // use schema
      expect(helper.description(schema)).to.equal('Any data type. \
It is optional and must not be set. A data object is needed. \
The following keys have a special format:\n\
- `a`: Any data type. It is optional and must not be set.\n\
\n\
Keys not defined with the rules before will be removed.')
    })

  })

  describe('length', () => {

    it('should work with min', (done) => {
      const data = {a: 1, b: 2, c: 3}
      const schema = new MySchema().min(2)
      // use schema
      helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      }, done)
    })

    it('should fail with min', (done) => {
      const data = {a: 1, b: 2, c: 3}
      const schema = new MySchema().min(5)
      // use schema
      helper.validateFail(schema, data, undefined, done)
    })

    it('should work with max', (done) => {
      const data = {a: 1, b: 2, c: 3}
      const schema = new MySchema().max(5)
      // use schema
      helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      }, done)
    })

    it('should fail with max', (done) => {
      const data = {a: 1, b: 2, c: 3}
      const schema = new MySchema().max(2)
      // use schema
      helper.validateFail(schema, data, undefined, done)
    })

    it('should work with length', (done) => {
      const data = {a: 1, b: 2, c: 3}
      const schema = new MySchema().length(3)
      // use schema
      helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      }, done)
    })

    it('should fail with length', (done) => {
      const data = {a: 1, b: 2, c: 3}
      const schema = new MySchema().length(2)
      // use schema
      helper.validateFail(schema, data, undefined, done)
    })

    it('should work with min and max', (done) => {
      const data = {a: 1, b: 2, c: 3}
      const schema = new MySchema().min(2).max(5)
      // use schema
      helper.validateOk(schema, data, (res) => {
        expect(res).deep.equal(data)
      }, done)
    })

    it('should describe length', () => {
      const schema = new MySchema().length(4)
      // use schema
      expect(helper.description(schema)).to.be.a('string')
    })

    it('should describe min and max', () => {
      const schema = new MySchema().min(2).max(5)
      // use schema
      expect(helper.description(schema)).to.be.a('string')
    })

  })

})
