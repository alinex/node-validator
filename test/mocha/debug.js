// @flow
import util from 'util'
import Debug from 'debug'

import Schema from '../../src/Schema'
import SchemaData from '../../src/SchemaData'
import Reference from '../../src/Reference'

export default function (element: any, type: string = 'test', title?: string) {
  const debugLog = Debug(type.match(/^test/) ? type : `test:${type}`)
  if (element instanceof Promise) {
    element.then((data) => {
      debugLog(`Promise succeded with ${util.inspect(data)}`)
    })
      .catch((err) => {
        if (err instanceof Error) {
          debugLog(`Promise failed with ${err.constructor.name}: ${err.stack}`)
        } else debugLog(`Promise failed with ${util.inspect(err)}`)
      })
  } else if (element instanceof Schema) {
    debugLog(`${element.constructor.name} set up with: %o`, element)
  } else if (element instanceof SchemaData && element.orig instanceof Reference) {
    debugLog(`Given reference as data: ${element.orig.base} -> ${element.orig.access.join(' -> ')}`)
  } else if (element instanceof SchemaData) {
    debugLog(`Given data: ${util.inspect(element.orig)}`)
  } else {
    debugLog(`${title || 'Returned'}: ${util.inspect(element)}`)
  }
}
