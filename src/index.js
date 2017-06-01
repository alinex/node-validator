// @flow
import fs from 'fs'
import path from 'path'

// dynamically get all schema classes therefore use require and module.exports

const types: { [string]: Function } = {}

// read types from directory
fs.readdirSync(`${__dirname}/type`)
.forEach((file: string): void => {
  // get class name from filename
  const mod: string = path.basename(file, path.extname(file))
  // eslint-disable-next-line global-require, import/no-dynamic-require
  types[mod] = require(`./type/${mod}`).default
})

module.exports = types
