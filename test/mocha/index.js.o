// @flow
import chai from 'chai'
import chaiAsPromised from 'chai-as-promised'
import Debug from 'debug'

import * as validator from '../../src/index'
import SchemaError from '../../src/SchemaError'
import SchemaData from '../../src/SchemaData'

chai.use(chaiAsPromised)
const expect = chai.expect
const debug = Debug('test')

describe('base', () => {

  it('should load validator', () => {
    expect(validator, 'module').to.be.an('object')
    expect(validator.AnySchema, 'AnySchema').to.be.a('function')
  })

  it('should describe error', () => {
    const schema = new validator.AnySchema()
    const value = 5
    const data = new SchemaData(value, '/any/path')
    const err = new SchemaError(schema, data, 'Something is wrong.')
    const msg = err.text
    debug(msg)
    expect(msg, 'detail').to.equal(`__Something is wrong.__

> Given value was: \`5\`
> At path: \`/any/path\`

But __Any__ should be defined with:
It is optional and must not be set.`)
  })

})
