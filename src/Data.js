// @flow
import util from 'util'

class Data {
  value: any // current value (will change while validating)
  orig: any // original value for reporting
  source: string // source path for reporting
  options: Object // open for enhancement
  temp: Object // storage for additional data between the rules
  parent: Data // parent data structure (used for references)
  root: Data // root data structure (used for references)
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

  inspect(depth: number, options: Object): string {
    const newOptions = Object.assign({}, options, {
      depth: options.depth === null ? null : options.depth - 1,
    })
    const inner = util.inspect(this.value, newOptions)
    return `${options.stylize(this.constructor.name, 'class')} at ${this.source} ${inner} `
  }

  sub(key: string): Data {
    const sub = new Data(this.value[key],
      `${this.source.replace(/\/$/, '')}/${key}`, this.options)
    sub.parent = this
    sub.root = this.root
    return sub
  }

  get clone(): this {
    return Object.assign((Object.create(this): any), this)
  }
}

export default Data
