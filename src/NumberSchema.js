// @flow
import Quantity from 'js-quantities'

import AnySchema from './AnySchema'
import SchemaError from './SchemaError'
import type SchemaData from './SchemaData'

const INTTYPE = {
  byte: 8,
  short: 16,
  long: 32,
  safe: 53,
  quad: 64,
}

class Round {
  precision: number
  method: 'arithmetic' | 'floor' | 'ceil'

  constructor(precision: number = 0, method: 'arithmetic' | 'floor' | 'ceil' = 'arithmetic') {
    if (precision < 0) throw new Error('Precision for round should be 0 or greater.')
    this.precision = precision
    this.method = method
  }
}

class NumberSchema extends AnySchema {

  // validation data

  _sanitize: bool
  _unit: string
  _toUnit: string
  _round: Round
  _min: number
  _max: number
  _less: number
  _greater: number
  _positive: bool
  _negative: bool
  _integer: bool
  _integerType: number
  _multiple: number

  constructor(title?: string, detail?: string) {
    super(title, detail)
    // init settings
    this._sanitize = false
    this._positive = false
    this._negative = false
    this._integer = false
    // add check rules
    this._rules.add([this._unitDescriptor, this._unitValidator])
    this._rules.add([this._sanitizeDescriptor, this._sanitizeValidator])
    this._rules.add([this._roundDescriptor, this._roundValidator])
    this._rules.add([this._minmaxDescriptor, this._minmaxValidator])
    this._rules.add([this._multipleDescriptor, this._multipleValidator])
  }

  // setup schema

  get sanitize(): this {
    this._sanitize = !this._negate
    this._negate = false
    return this
  }

  unit(unit?: string): this {
    if (this._negate) {
      delete this._unit
      this._negate = false
    } else if (unit) {
      try {
        Quantity(unit)
      } catch (e) { throw new Error(`Unit ${unit} not recognized`) }
      this._unit = unit
    } else {
      throw new Error('To set a unit specify it as parameter to `unit()`')
    }
    return this
  }

  toUnit(unit?: string): this {
    if (!this._unit) throw new Error('First define the input `unit()` before converting further')
    if (this._negate) {
      delete this._toUnit
      this._negate = false
    } else if (unit) {
      try {
        Quantity(unit)
      } catch (e) { throw new Error(`Unit ${unit} not recognized`) }
      this._toUnit = unit
    } else {
      throw new Error('To convert to a unit specify it as parameter to `toUnit()`')
    }
    return this
  }

  round(precision?: number, method?: 'arithmetic' | 'floor' | 'ceil'): this {
    if (this._negate) {
      delete this._round
      this._negate = false
    } else {
      if (this._integer) throw new Error('Rounding not possible because defined as integer')
      this._round = new Round(precision, method)
    }
    return this
  }

  get integer(): this {
    this._integer = !this._negate
    this._negate = false
    return this
  }

  integerType(type: number | 'byte' | 'short' | 'long' | 'safe' | 'quad'): this {
    if (this._negate) {
      this._negate = false
      delete this._integerType
    } else {
      this._integer = true
      if (INTTYPE[type]) this._integerType = INTTYPE[type]
      else if (typeof type === 'number') {
        if (Object.values(INTTYPE).includes(type)) this._integerType = type
      } else throw new Error(`Undefined type ${type} for integer.`)
    }
    return this
  }

  min(value: number): this {
    if (this._negate) {
      delete this._min
      this._negate = false
    } else {
      if (this._max && value > this._max) {
        throw new Error('Min can´t be greater than max value')
      }
      if (this._less && value >= this._less) {
        throw new Error('Min can´t be greater or equal less value')
      }
      if (this._negative && value > 0) {
        throw new Error('Min can´t be positive, because defined as negative')
      }
      this._min = value
    }
    return this
  }

  max(value: number): this {
    if (this._negate) {
      delete this._max
      this._negate = false
    } else {
      if (this._min && value < this._min) {
        throw new Error('Max can´t be less than min value')
      }
      if (this._greater && value <= this._greater) {
        throw new Error('Max can´t be less or equal greater value')
      }
      if (this._positive && value < 0) {
        throw new Error('Max can´t be negative, because defined as positive')
      }
      this._max = value
    }
    return this
  }

  less(value: number): this {
    if (this._negate) {
      delete this._less
      this._negate = false
    } else {
      if (this._min && value <= this._min) {
        throw new Error('Less can´t be less than min value')
      }
      if (this._greater && value <= this._greater) {
        throw new Error('Less can´t be less or equal greater value')
      }
      if (this._positive && value <= 0) {
        throw new Error('Less can´t be negative, because defined as positive')
      }
      this._less = value
    }
    return this
  }

  greater(value: number): this {
    if (this._negate) {
      delete this._greater
      this._negate = false
    } else {
      if (this._max && value >= this._max) {
        throw new Error('Greater can´t be greater than max value')
      }
      if (this._less && value >= this._less) {
        throw new Error('Greater can´t be greater or equal less value')
      }
      if (this._negative && value >= 0) {
        throw new Error('Greater can´t be positive, because defined as negative')
      }
      this._greater = value
    }
    return this
  }

  get positive(): this {
    this._positive = !this._negate
    if (!this._negate) {
      if (this._max < 0) {
        throw new Error('Positive can´t be set because max value is negative')
      }
      if (this._less <= 0) {
        throw new Error('Positive can´t be set because less value is negative')
      }
      this._negative = false
    }
    this._negate = false
    return this
  }

  get negative(): this {
    this._negative = !this._negate
    if (!this._negate) {
      if (this._min > 0) {
        throw new Error('Negative can´t be set because min value is positive')
      }
      if (this._greater >= 0) {
        throw new Error('Negative can´t be set because greater value is positive')
      }
      this._positive = false
    }
    this._negate = false
    return this
  }

  multiple(value: number): this {
    if (this._negate) {
      delete this._multiple
      this._negate = false
    } else {
      if (this._negative && value > 0) throw new Error('Multiplicator has to be negative, too.')
      if (this._positive && value < 0) throw new Error('Multiplicator has to be positive, too.')
      this._multiple = value
    }
    return this
  }

  // using schema

  _unitDescriptor() {
    let msg = ''
    if (this._unit) {
      msg += `Give the values in \`${this._unit}\`. `
      if (this._toUnit) msg = msg.replace(/\. $/, ` and onvert the values to \`${this._toUnit}\`. `)
    }
    return msg.length ? msg.replace(/ $/, '\n') : ''
  }

  _unitValidator(data: SchemaData): Promise<void> {
    if (this._unit && typeof data.value === 'string') {
      if (this._sanitize) data.value = data.value.replace(/^.*?([-+]?\d+\.?\d*\s*\S*).*?$/, '$1')
      let quantity
      try {
        quantity = new Quantity(data.value)
      } catch (e) {
        return Promise.reject(new SchemaError(this, data,
        `Could not parse the unit of ${data.value}: ${e.message}`))
      }
      try {
        data.value = quantity.to(this._unit).scalar
      } catch (e) {
        return Promise.reject(new SchemaError(this, data,
        `Could not convert to ${this._unit}: ${e.message}`))
      }
    }
    if (this._unit && this._toUnit && typeof data.value === 'number') {
      try {
        data.value = new Quantity(data.value, this._unit).to(this._toUnit).scalar
      } catch (e) {
        return Promise.reject(new SchemaError(this, data,
        `Could not convert ${this._unit} to ${this._toUnit}: ${e.message}`))
      }
    }
    return Promise.resolve()
  }

  _sanitizeDescriptor() {
    let msg = 'A numerical value is needed. '
    if (this._sanitize) msg += 'Strings are sanitized to get the first numerical value out of it. '
    return msg.replace(/ $/, '\n')
  }

  _sanitizeValidator(data: SchemaData): Promise<void> {
    if (typeof data.value === 'string') {
      if (this._sanitize) data.value = data.value.replace(/^.*?([-+]?\d+\.?\d*).*?$/, '$1')
      data.value = Number(data.value)
    }
    if (typeof data.value !== 'number') {
      return Promise.reject(new SchemaError(this, data,
      `The given value is of type ${typeof data.value} but a number is needed.`))
    } else if (isNaN(data.value)) {
      return Promise.reject(new SchemaError(this, data,
      `The given string \`${data.orig}\` is no valid number.`))
    }
    return Promise.resolve()
  }

  _roundDescriptor() {
    if (this._integer && this._sanitize) return 'The value is rounded to an integer.\n'
    if (this._round && this._integer) {
      return `The value is rounded to \`${this._round.method}\` to get an integer.\n`
    }
    if (this._round) {
      return `The value is rounded to \`${this._round.method}\` with \
${this._round.precision} digits precision.\n`
    }
    if (this._integer && !this._integerType) return 'An integer value is needed.\n'
    return ''
  }

  _roundValidator(data: SchemaData): Promise<void> {
    if (this._round) {
      const exp = this._integer ? 1 : 10 ** this._round.precision
      let value = data.value * exp
      if (this._round.method === 'ceil') value = Math.ceil(value)
      else if (this._round.method === 'floor') value = Math.floor(value)
      else value = Math.round(value)
      data.value = value / exp
    } else if (this._integer && !Number.isInteger(data.value)) {
      if (this._sanitize) data.value = Math.round(data.value)
      else {
        return Promise.reject(new SchemaError(this, data,
          'The value has to be an integer number.'))
      }
    }
    return Promise.resolve()
  }

  _minmaxDescriptor() {
    // optimize
    let max
    let min
    if (this._integer && this._integerType) {
      const unsigned = this._positive ? 1 : 0
      max = (2 ** ((this._integerType - 1) + unsigned)) - 1
      min = (((unsigned - 1) * max) - 1) + unsigned
    }
    if (min === undefined || !(this._min <= min)) min = this._min
    if (max === undefined || !(this._max >= max)) max = this._max
    if (min !== undefined && this._greater !== undefined) {
      if (this._greater >= min) min = undefined
      else delete this._greater
    }
    if (max !== undefined && this._less !== undefined) {
      if (this._less <= max) max = undefined
      else delete this._less
    }
    // get message
    let msg = ''
    if (this._integer && this._integerType) {
      msg += `It has to be an ${this._positive ? 'unsigned ' : ''}\
${this._integerType}-bit integer. `
    }
    if (this._positive) msg += 'The number should be positive. '
    if (this._negative) msg += 'The number should be negative. '
    if (min !== undefined) msg += `The value has to be at least \`${this._min}\`. `
    if (this._greater !== undefined) {
      msg += `The value has to be greater than \`${this._greater}\`. `
    }
    if (this._less !== undefined) msg += `The value has to be less than \`${this._less}\`. `
    if (max !== undefined) msg += `The value has to be at most \`${this._max}\`. `
    if ((min !== undefined || this._greater !== undefined)
    && (max !== undefined && this._less !== undefined)) {
      msg = msg.replace(/(.*)\. The value has to be/, '$1 and')
    }
    return msg.replace(/ $/, '\n')
  }

  _minmaxValidator(data: SchemaData): Promise<void> {
    // optimize
    let max
    let min
    if (this._integer && this._integerType) {
      const unsigned = this._positive ? 1 : 0
      max = (2 ** ((this._integerType - 1) + unsigned)) - 1
      min = (((unsigned - 1) * max) - 1) + unsigned
    }
    if (min === undefined || (this._min !== undefined && !(this._min <= min))) min = this._min
    if (max === undefined || (this._max !== undefined && !(this._max >= max))) max = this._max
    if (min !== undefined && this._greater !== undefined) {
      if (this._greater >= min) min = undefined
      else delete this._greater
    }
    if (max !== undefined && this._less !== undefined) {
      if (this._less <= max) max = undefined
      else delete this._less
    }
    // check
    if (this._positive && data.value < 0) {
      return Promise.reject(new SchemaError(this, data,
        'The number should be positive.'))
    }
    if (this._negative && data.value > 0) {
      return Promise.reject(new SchemaError(this, data,
        'The number should be negative.'))
    }
    if (min !== undefined && data.value < min) {
      return Promise.reject(new SchemaError(this, data,
        `The value has to be at least ${min}.`))
    }
    if (this._greater !== undefined && data.value <= this._greater) {
      return Promise.reject(new SchemaError(this, data,
        `The value has to be greater than ${this._greater}.`))
    }
    if (this._less !== undefined && data.value >= this._less) {
      return Promise.reject(new SchemaError(this, data,
        `The value has to be less than ${this._less}.`))
    }
    if (max !== undefined && data.value > max) {
      return Promise.reject(new SchemaError(this, data,
        `The value has to be at least ${max}.`))
    }
    return Promise.resolve()
  }

  _multipleDescriptor() {
    if (this._multiple) return `The value has to be multiple of ${this._multiple}.\n`
    return ''
  }

  _multipleValidator(data: SchemaData): Promise<void> {
    if (this._multiple && data.value % this._multiple) {
      return Promise.reject(new SchemaError(this, data,
        `The value has to be a multiple of ${this._multiple}.`))
    }
    return Promise.resolve()
  }

}

export default NumberSchema
