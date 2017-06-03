import chai from 'chai'
import chaiAsPromised from 'chai-as-promised'
import Debug from 'debug'

import * as validator from '../../src/index'

chai.use(chaiAsPromised)
const expect = chai.expect
const debug = Debug('test')

describe('base', () => {

  it('should load validator', () => {
    expect(validator, 'module').to.be.an('object')
    expect(validator.Any, 'AnySchema').to.be.a('function')
  })

})
