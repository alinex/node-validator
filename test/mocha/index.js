// @flow
import chai from 'chai'
import chaiAsPromised from 'chai-as-promised'
import Debug from 'debug'

import validator from '../../src/index'
import * as builder from '../../src/builder'
import SchemaError from '../../src/SchemaError'
import SchemaData from '../../src/SchemaData'
import * as helper from './helper'

chai.use(chaiAsPromised)
const expect = chai.expect
const debug = Debug('test')

describe.only('use', () => {

  describe('schema', () => {

    it('should load complete builder', () => {
      expect(builder).to.be.an('object')
      expect(builder.Any).to.be.a('function')
    })

    it('should describe error', () => {
      const schema = new builder.Any()
      const value = 5
      const data = new SchemaData(value, '/any/path')
      const err = new SchemaError(schema, data, 'Something is wrong.')
      const msg = err.text
      debug(msg)
      expect(msg).to.equal(`__Something is wrong.__

> Given value was: \`5\`
> At path: \`/any/path\`

But __Any__ should be defined with:
It is optional and must not be set.`)
    })

  })

  describe('validate', () => {

    it('should work', (done) => {
      const addressSchema = require('../data/address.schema') // eslint-disable-line global-require
      const data = {
        title: 'Dr.',
        name: 'Alfons Ranze',
        street: 'Im Heubach 3',
        plz: '565',
        city: 'Berlin',
      }
      helper.validateOk(addressSchema, data, undefined, done)
    })

    it('should fail', (done) => {
      const addressSchema = require('../data/address.schema') // eslint-disable-line global-require
      const data = {
        name: 'Alfons Ranze',
        street: 'Im Heubach 3',
        plz: '999105',
        city: 'Berlin',
      }
      helper.validateFail(addressSchema, data, undefined, done)
    })

  })

  describe('load', () => {

  })

  describe('transform', () => {

  })

})
