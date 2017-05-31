import chai from 'chai'
import Debug from 'debug'

import * as validator from '../../src/index'

const expect = chai.expect
const debug = Debug('test')

describe('builder', () => {

  it('should load validator', () => {
    expect(validator).to.be.an('object')
    expect(validator.Object).to.be.a('function')
  })

})

describe('type any', () => {

  it('should validate with number', () => {
    const data = 5
    const schema = new validator.Any(data)
    expect(schema).to.be.an('object')
    expect(async () => {
      await schema.validate()
    }).to.not.throw()
    expect(schema.object()).to.equal(data)
  })

  it('should describe', () => {
    const schema = new validator.Any()
    expect(schema.describe()).to.be.a('string')
  })

})
