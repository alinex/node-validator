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

describe('preset', () => {

  it('should work with word', () => {
    expect(builder).to.be.an('object')
    const schema = builder.preset.word()
    return helper.validateOk(schema, 'hello')
  })

  it('should work with character', () => {
    expect(builder).to.be.an('object')
    const schema = builder.preset.character()
    return helper.validateOk(schema, 'h')
  })

  it('should work with md5', () => {
    expect(builder).to.be.an('object')
    const schema = builder.preset.md5()
    return helper.validateOk(schema, '598d4c200461b81522a3328565c25f7c')
  })

  it('should work with sha1', () => {
    expect(builder).to.be.an('object')
    const schema = builder.preset.sha1()
    return helper.validateOk(schema, 'da39a3ee5e6b4b0d3255bfef95601890afd80709')
  })

  it('should work with sha256', () => {
    expect(builder).to.be.an('object')
    const schema = builder.preset.sha256()
    return helper.validateOk(schema, '5891b5b522d5df086d0ff0b110fbd9d21bb4fc7163af34d08286a2e846f6be03')
  })

  it('should work with hostOrIP', () => {
    expect(builder).to.be.an('object')
    const schema = builder.preset.hostOrIP()
    return helper.validateOk(schema, '127.0.0.1')
  })

  it('should work with plz', () => {
    expect(builder).to.be.an('object')
    const schema = builder.preset.plz()
    return helper.validateOk(schema, 123)
  })

})
