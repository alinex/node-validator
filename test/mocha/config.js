// @flow
import chai from 'chai'
import chaiAsPromised from 'chai-as-promised'
import Debug from 'debug'
import util from 'util'
import promisify from 'es6-promisify' // may be removed with node util.promisify later
import childProcess from 'child_process'
import fs from 'fs'

import Validator from '../../src/index'
import * as builder from '../../src/builder'
import ValidationError from '../../src/Error'
import Data from '../../src/Data'
import * as helper from './helper'

chai.use(chaiAsPromised)
const expect = chai.expect
const debug = Debug('test')


const validateOk = promisify(helper.validateOk)

describe('config', () => {

  const goal = {
    title: 'Dr.',
    name: 'Alfons Ranze',
    street: 'Im Heubach 3',
    plz: '10565',
    city: 'Berlin',
  }
  const fileData = `${__dirname}/../data/address-ok.yml`
  const fileSchema = `${__dirname}/../data/address.schema.js`
  const fileJSON = `${__dirname}/../data/address-ok.json`

  it('should validate file',
    () => new Validator().check(fileData, fileSchema)
      .then(res => expect(res).deep.equal(goal)))

  //  it('should validate using fork', () => new Promise((resolve) => {
  //    const forked = childProcess.fork('test/data/config-fork.js', { execPath: "node_modules/.bin/babel-node" })
  //    forked.on('message', (data) => {
  //      console.log(data)
  //      resolve(expect(data).deep.equal(goal))
  //    })
  //  }))

  it('should transform if neccessary',
    () => new Validator().transform(fileData, fileSchema, fileJSON)
      .catch(err => promisify(fs.readFile)(fileJSON).then(res => JSON.parse(res)))
      .then(res => expect(res).deep.equal(goal)))

  it('should transform with spawn',
    () => promisify(childProcess.exec)(`${__dirname}/../../bin/validator -i ${fileData} \
-s ${fileSchema} -o ${fileJSON}`)
      .then(() => promisify(fs.readFile)(fileJSON))
      .then(res => JSON.parse(res))
      .then((res) => {
        expect(res).deep.equal(goal)
      }))

  it('done', () => true)
})
