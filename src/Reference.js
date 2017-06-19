// @flow
class Reference {

  path: string
  context: any

  constructor(path: string) {
    this.path = path
  }

  context(value: any): this {
    this.context = value
    return this
  }

  read(): Promise<any> {
    return Promise.resolve(this.context[this.path])
  }

}

export default Reference
