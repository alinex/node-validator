import chai from 'chai'
import Debug from 'debug'

import * as validator from '../../src/index'

const expect = chai.expect
const debug = Debug('test')

describe('basic', () => {

  it('should load validator', () => {
    expect(validator).to.be.an('object')
    expect(validator.Object).to.be.a('function')
  })

  it('should work with data loading', () => {
    const schema = new validator.Any()
    expect(schema).to.be.an('object')
    const data = 5
    schema.load(data)
    expect(async () => {
      await schema.validate()
    }).to.not.throw()
    expect(schema.object()).to.equal(data)
  })

  it('should allow validation options', () => {
    const data = 'a'
    const schema = new validator.Any()
    schema.allow('a')
    schema.load(data)
    expect(async () => {
      await schema.validate()
    }).to.not.throw()
    expect(schema.object()).to.equal(data)
  })

  // should work with instance changes


  it('should describe', () => {
    const schema = new validator.Any()
    expect(schema.describe()).to.be.a('string')
  })

})
