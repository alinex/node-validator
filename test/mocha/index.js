// @flow
import chai from 'chai'
import chaiAsPromised from 'chai-as-promised'
import Debug from 'debug'
import util from 'util'
import promisify from 'es6-promisify' // may be removed with node util.promisify later
import fs from 'fs'

import Validator from '../../src/index'
import * as builder from '../../src/builder'
import ValidationError from '../../src/Error'
import Data from '../../src/Data'
import * as helper from './helper'

chai.use(chaiAsPromised)
const { expect } = chai
const debug = Debug('test')


const validateOk = promisify(helper.validateOk)

describe('use', () => {

  describe('schema', () => {

    it('should load complete builder', () => {
      expect(builder).to.be.an('object')
      expect(builder.Any).to.be.a('function')
    })

    it('should load presets', () => {
      expect(builder).to.be.an('object')
      const schema = builder.preset.plz()
      return helper.validateOk(schema, 123)
    })

    it('should describe error', () => {
      const schema = new builder.Any()
      const value = 5
      const data = new Data(value, '/any/path')
      const err = new ValidationError(schema, data, 'Something is wrong.')
      const msg = err.text
      debug(msg)
      expect(msg).to.equal(`__Something is wrong.__

> Given value was: \`5\`
> At path: \`/any/path\`

But __Any__ should be defined with:
`)
    })

    it('should access sub schema', () => {
      const addressSchema = require('../data/address.schema') // eslint-disable-line global-require
      debug(addressSchema.schema('keys/name'))
      return true
    })

  })

  describe('loader', () => {

    it('should work with multifile', () => new Validator()
      .load(['test/data/address-fail.yml', 'test/data/address-ok.yml'])
      .then((data) => {
        debug('got', util.inspect(data).replace(/\s*\n\s*/g, ' '))
      }))

    it('should work with direct file', () => new Validator().load('test/data/address-ok.yml')
      .then((data) => {
        debug('got', util.inspect(data).replace(/\s*\n\s*/g, ' '))
      }))

    it('should work with glob', () => new Validator().load('test/data/*.yml')
      .then((data) => {
        debug('got', util.inspect(data).replace(/\s*\n\s*/g, ' '))
      }))

    it('should work recursive', () => new Validator().load('test/**/*.yml')
      .then((data) => {
        debug('got', util.inspect(data).replace(/\s*\n\s*/g, ' '))
      }))

  })

  describe('validate', () => {

    it('should work with require', () => {
      const data = {
        title: 'Dr.',
        name: 'Alfons Ranze',
        street: 'Im Heubach 3',
        plz: '565',
        city: 'Berlin',
      }
      const addressSchema = require('../data/address.schema') // eslint-disable-line global-require
      return helper.validateOk(addressSchema, data)
    })

    it('should work with include', () => {
      const data = {
        title: 'Dr.',
        name: 'Alfons Ranze',
        street: 'Im Heubach 3',
        plz: '565',
        city: 'Berlin',
      }
      return import('../data/address.schema')
        .then((addressSchema: any) => helper.validateOk(addressSchema, data))
    })

    it('should work', () => {
      const data = {
        title: 'Dr.',
        name: 'Alfons Ranze',
        street: 'Im Heubach 3',
        plz: '565',
        city: 'Berlin',
      }
      return new Validator().schema(`${__dirname}/../data/address.schema`)
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

    it('should work with data', () => {
      const addressSchema = require('../data/address.schema') // eslint-disable-line global-require
      const goal = {
        title: 'Dr.',
        name: 'Alfons Ranze',
        street: 'Im Heubach 3',
        plz: '10565',
        city: 'Berlin',
      }
      const schemaFile = `${__dirname}/../data/address.schema`
      return new Validator().check(Promise.resolve(goal), schemaFile)
        .then((res) => {
          expect(res).deep.equal(goal)
        })
        .catch(err => console.log('ERROR', err))
    })

    it('should load specific file', () => {
      const addressSchema = require('../data/address.schema') // eslint-disable-line global-require
      const goal = {
        title: 'Dr.',
        name: 'Alfons Ranze',
        street: 'Im Heubach 3',
        plz: '10565',
        city: 'Berlin',
      }
      const schemaFile = `${__dirname}/../data/address.schema`
      const data = new Validator().load(`${__dirname}/../data/address-ok.yml`)
      return new Validator().check(data, schemaFile)
        .then((res) => {
          expect(res).deep.equal(goal)
        })
        .catch(err => console.log('ERROR', err))
    })

    it('should load by file name', () => {
      const addressSchema = require('../data/address.schema') // eslint-disable-line global-require
      const goal = {
        title: 'Dr.',
        name: 'Alfons Ranze',
        street: 'Im Heubach 3',
        plz: '10565',
        city: 'Berlin',
      }
      const schemaFile = `${__dirname}/../data/address.schema`
      const dataFile = `${__dirname}/../data/address-ok.yml`
      return new Validator().check(dataFile, schemaFile)
        .then((res) => {
          expect(res).deep.equal(goal)
        })
        .catch(err => console.log('ERROR', err))
    })

  })

  describe('transform', () => {

    const goal = {
      title: 'Dr.',
      name: 'Alfons Ranze',
      street: 'Im Heubach 3',
      plz: '10565',
      city: 'Berlin',
    }
    const schemaFile = `${__dirname}/../data/address.schema.js`
    const dataFile = `${__dirname}/../data/address-ok.yml`
    const dataJSON = `${__dirname}/../data/address-ok.json`

    it('should transform and load created file', () => promisify(fs.unlink)(dataJSON)
      .catch(() => true)
      .then(() => new Validator().transform(dataFile, schemaFile, dataJSON, { force: true }))
      .then(() => {
        const d = require(dataJSON) // eslint-disable-line global-require,import/no-dynamic-require
        expect(d).deep.equal(goal)
      }))

  })

})
