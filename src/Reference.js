// @flow
import util from 'alinex-util'

import SchemaData from './SchemaData'

function resolvePath(data: any, def: string): any {
  // work on SchemaData
  if (data instanceof SchemaData) {
    // back references
    if (def[0] === '/') data = data.root
    // ../
    // other
    return 'xxx'
  }
  // work on other data structures
  def = def.replace(/^(\.{,2}\/)+/, '') // no initial back references
  return util.object.path(data, def)
}

// range
// search

// split
// match
// parse
// join
// filter
// addRef
// fn


class Reference {

  base: any
  // direct object
  // file
  // web
  // command
  // fn

  access: Array<Array<any>>

  constructor(base: any) {
    this.base = base
    this.access = []
  }

  path(def: string): this {
    def = def.replace(/\/\.\//g, '/').replace(/^\.?\//, '')
    this.access.push([resolvePath, def])
    return this
  }

  read(): Promise<any> {
    // run rules seriously
    let p = Promise.resolve(this.base)
    this.access.forEach(([fn, def]) => { p = p.then(data => fn.call(this, data, def)) })
    return p.then(data => data)
    .catch(err => (err instanceof Error ? Promise.reject(err) : err))
  }

}


export default Reference
