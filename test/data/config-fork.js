const validator = require('../../dist/index').default

validator.load(`${__dirname}/address-ok.yml`)
  .then((data) => {
    console.log(111, data)
    return validator.check(data, `${__dirname}/address.schema`)
  })
  .then((res) => {
    console.log(222, res)
    return process.send(res)
  })
  .catch((err) => {
    console.log(333, err)
    process.send(err)
  })

console.log('done')
