// @flow
import util from 'util'
import Debug from 'debug'

import Schema from '../../src/Schema'
import SchemaData from '../../src/SchemaData'
import Reference from '../../src/Reference'

export default function (element: any, type: string = 'test') {
  const debugLog = Debug(type.match(/^test/) ? type : `test:${type}`)
  if (element instanceof Promise) {
    element.then((data) => {
      debugLog(`Promise succeded with ${util.inspect(data)}`)
    })
    .catch((err) => {
      if (err instanceof Error) {
        debugLog(`Promise failed with ${err.constructor.name}: ${err.message}`)
      } else debugLog(`Promise failed with ${util.inspect(err)}`)
    })
  } else if (element instanceof Schema) {
    debugLog(`${element.constructor.name} set up with: %o`, element._setting)
  } else if (element instanceof SchemaData && element.orig instanceof Reference) {
    debugLog(`Given reference as data: ${element.orig.base} -> ${element.orig.access.join(' -> ')}`)
  } else if (element instanceof SchemaData) {
    debugLog(`Given data: ${util.inspect(element.orig)}`)
  } else {
    debugLog(`Returned ${util.inspect(element)}`)
  }
}
