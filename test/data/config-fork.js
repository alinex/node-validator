const validator = require('../../dist/index').default

return validator.load(`${__dirname}/address-ok.yml`)
  .then(data => validator.check(data, `${__dirname}/address.schema`))
  .then(res => process.send(res))
  .catch(err => process.send(err))
