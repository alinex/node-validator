// @flow
import ObjectSchema from '../../src/ObjectSchema'
import StringSchema from '../../src/StringSchema'
import NumberSchema from '../../src/NumberSchema'

const schema = new ObjectSchema()
  .key('title', new StringSchema().allow(['Dr.', 'Prof.']))
  .key('name', new StringSchema().min(3).required())
  .key('street', new StringSchema().min(3).required())
  .key('plz', new NumberSchema().required()
    .positive().max(99999)
    .format('00000'))
  .key('city', new StringSchema().required().min(3))


module.exports = schema
