class SchemaAny {

  constructor(data) {
    this.data = data
  }

  describe() {
    return this.toString()
  }

  validate() {
    this.result = this.data
    return Promise.resolve()
  }

  object() {
    return this.result
  }
}

export default SchemaAny
