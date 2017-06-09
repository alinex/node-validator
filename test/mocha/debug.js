// @flow
import util from 'util'
import Debug from 'debug'

import Schema from '../../src/Schema'
import SchemaData from '../../src/SchemaData'

export default function(element: any, type: string = 'test') {
  const debugLog = Debug(type.match(/^test/) ? type : `test:${type}`)
  if (element instanceof Promise) {
    element.then(data => {
      debugLog(`Promise succeded with ${util.inspect(data)}`)
    })
    .catch(err => {
      if (err instanceof Error) debugLog(`Promise failed with ${err.constructor.name}: ${err.message}`)
      else debugLog(`Promise failed with ${util.inspect(err)}`)
    })
  } else if (element instanceof Schema) {
    const disallowed = ['title', 'detail', '_rules']
    const filtered = Object.keys(element)
    .filter(key => !disallowed.includes(key))
    .reduce((obj, key) => {
      obj[key] = element[key];
      return obj;
    }, {});
    debugLog(`${element.constructor.name} set up with: %o`, filtered)
  } else if (element instanceof SchemaData) {
    debugLog(`Given data: ${util.inspect(element.orig)}`)
  } else {
    debugLog(`Returned ${util.inspect(element)}`)
  }
}
