// @flow
class SchemaData {
  value: any // current value (will change while validating)
  orig: any // original value for reporting
  source: string // source path for reporting
  options: Object // open for enhancement
  temp: Object // storage for additional data between the rules
  parent: SchemaData // parent data structure (used for references)
  root: SchemaData // root data structure (used for references)
  status: Promise<any> // wait till value is checked (for references)
  done: Function // method used to fullfill status promise

  constructor(value: any, source?: string, options?: Object) {
    this.value = value
    this.orig = value
    this.source = source || '/'
    this.options = options || {}
    this.temp = {}
    this.root = this
    this.status = new Promise((resolve) => {
      this.done = resolve
    })
  }

  sub(key: string): SchemaData {
    const sub = new SchemaData(this.value[key],
      `${this.source.replace(/\/$/, '')}/${key}`, this.options)
    sub.parent = this
    sub.root = this.root
    return sub
  }

  get clone(): this {
    return Object.assign((Object.create(this): any), this)
  }
}

export default SchemaData
