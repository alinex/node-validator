// @flow
class SchemaData {

  value: any
  orig: any
  source: string
  options: Object

  constructor(value: any, source?: string, options?: Object) {
    this.value = value
    this.orig = value
    this.source = source || '/'
    this.options = options || {}
  }

}

export default SchemaData