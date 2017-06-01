// @flow
class Schema {

  data: any
  result: any

  // validation data

  _optional: bool

  constructor() {
    this._optional = true
  }

  optional(value: bool) {
    this._optional = value
    return this
  }

  // using schema

  load(data: any) {
    this.data = data
  }

  describe(): string {
    return this.toString()
  }

  validate(): Promise<void> {
    this.result = this.data
    return Promise.resolve()
  }

  // after validating

  object(): any {
    return this.result
  }
}

export default Schema
