// @flow
import Schema from '../Schema'

class ObjectSchema extends Schema {

  // validation data

  // setup validation


  // using schema

  validate(): Promise<void> {
    return new Promise((resolve, reject) => {
      if (this._optional && this.data === undefined) return resolve()
      // ok
      this.result = this.data
      return resolve()
    })
  }

}

export default ObjectSchema
