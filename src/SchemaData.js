// @flow
class SchemaData {

  value: any
  orig: any
  source: string

  constructor(value: any, source?: string) {
    this.value = value
    this.orig = value
    this.source = source || '/'
  }

}

export default SchemaData
