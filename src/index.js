import fs from 'fs'
import path from 'path'

// dynamically get all schema classes therefore use require and module.exports

const types = {}

// read types from directory
fs.readdirSync(`${__dirname}/type`)
.forEach((file) => {
  // get class name from filename
  const mod = path.basename(file, path.extname(file))
  // eslint-disable-next-line global-require, import/no-dynamic-require
  types[mod] = require(`./type/${mod}`).default
})

module.exports = types
