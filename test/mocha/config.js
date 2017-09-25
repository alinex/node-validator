// @flow
import chai from 'chai'
import chaiAsPromised from 'chai-as-promised'
import Debug from 'debug'
import util from 'util'
import promisify from 'es6-promisify' // may be removed with node util.promisify later
import childProcess from 'child_process'
import fs from 'fs'

import validator from '../../src/index'
import * as builder from '../../src/builder'
import ValidationError from '../../src/Error'
import Data from '../../src/Data'
import * as helper from './helper'

chai.use(chaiAsPromised)
const expect = chai.expect
const debug = Debug('test')


const validateOk = promisify(helper.validateOk)

describe.only('config', () => {

  const goal = {
    title: 'Dr.',
    name: 'Alfons Ranze',
    street: 'Im Heubach 3',
    plz: '10565',
    city: 'Berlin',
  }

  it('should validate file', () => validator.load('test/data/address-ok.yml')
    .then(data => validator.check(data, `${__dirname}/../data/address.schema`))
    .then((res) => {
      expect(res).deep.equal(goal)
    }))

  it('should validate using fork', () => new Promise((resolve) => {
    const forked = childProcess.fork('test/data/config-fork.js')
    forked.on('message', (data) => {
      console.log(data)
      resolve(expect(data).deep.equal(goal))
    })
  }))

  it('should transform with spawn', () => promisify(childProcess.exec)(`bin/validator -i test/data/address-ok.yml \
-s test/data/address.schema.js -o test/data/address-ok.json`)
    .then(() => promisify(fs.readFile)('test/data/address-ok.json'))
    .then(res => JSON.parse(res))
    .then((res) => {
      expect(res).deep.equal(goal)
    }))

})
