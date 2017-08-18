// @flow
import chai from 'chai'
import chaiAsPromised from 'chai-as-promised'
import Debug from 'debug'
import util from 'util'
import promisify from 'es6-promisify' // may be removed with node util.promisify later

import validator from '../../src/index'
import * as builder from '../../src/builder'
import SchemaError from '../../src/SchemaError'
import SchemaData from '../../src/SchemaData'
import * as helper from './helper'

chai.use(chaiAsPromised)
const expect = chai.expect
const debug = Debug('test')


const validateOk = promisify(helper.validateOk)

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

    it('should work with require', () => {
      const addressSchema = require('../data/address.schema') // eslint-disable-line global-require
      const data = {
        title: 'Dr.',
        name: 'Alfons Ranze',
        street: 'Im Heubach 3',
        plz: '565',
        city: 'Berlin',
      }
      return helper.validateOk(addressSchema, data)
    })

    it('should work', () => {
      const data = {
        title: 'Dr.',
        name: 'Alfons Ranze',
        street: 'Im Heubach 3',
        plz: '565',
        city: 'Berlin',
      }
      return validator.schema(`${__dirname}/../data/address.schema`)
        .then(addressSchema => validateOk(addressSchema, data))
    })

    it('should fail', () => {
      const addressSchema = require('../data/address.schema') // eslint-disable-line global-require
      const data = {
        name: 'Alfons Ranze',
        street: 'Im Heubach 3',
        plz: '999105',
        city: 'Berlin',
      }
      return helper.validateFail(addressSchema, data)
    })

  })

  describe('check', () => {

    it('should load specific file', () => {
      const addressSchema = require('../data/address.schema') // eslint-disable-line global-require
      const goal = {
        title: 'Dr.',
        name: 'Alfons Ranze',
        street: 'Im Heubach 3',
        plz: '10565',
        city: 'Berlin',
      }
      const schemaFile = `${__dirname}/../data/address-ok.yml`
      const dataFile = `${__dirname}/../data/address.schema`
      return validator.check(schemaFile, dataFile)
        .then((data) => {
          expect(data).deep.equal(goal)
        })
        .catch(err => console.log('ERROR', err))
    })

  })

  describe('transform', () => {

  })

})
