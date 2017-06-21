// @flow
function resolvePath(data: any, def: string): any {
  // relative
  // absolute
  return 'xxx'
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
    this.access.push([resolvePath, def])
    return this
  }

  read(): Promise<any> {
    const data = this.base
    // run rules seriously
    let p = Promise.resolve()
    this.access.forEach(([fn, def]) => { p = p.then(() => fn.call(this, data, def)) })
    return p.then(() => data)
    .catch(err => (err ? Promise.reject(err) : data))
  }

}


export default Reference
