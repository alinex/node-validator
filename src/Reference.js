// @flow
class Reference {

  path: string
  context: Object

  constructor(path: string) {
    this.path = path
  }

  set context(value: Object): this {
    this.context = value
    return this
  }

  read(): Promise<any> {
    return Promise.resolve(this.path)
  }

}

export default Reference
