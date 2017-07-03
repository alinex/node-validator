// @flow
import Numeral from 'numeral'
import convert from 'convert-units'

import AnySchema from './AnySchema'
import SchemaError from './SchemaError'
import type SchemaData from './SchemaData'
import Reference from './Reference'

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

  constructor(title?: string, detail?: string) {
    super(title, detail)
    // add check rules
    this._rules.descriptor.push(
      this._unitDescriptor,
      this._sanitizeDescriptor,
//      this._roundDescriptor,
//      this._minmaxDescriptor,
//      this._multipleDescriptor,
//      this._formatDescriptor,
    )
    this._rules.validator.push(
      this._unitValidator,
      this._sanitizeValidator,
//      this._roundValidator,
//      this._minmaxValidator,
//      this._multipleValidator,
//      this._formatValidator,
    )
  }

  // sanitize

  sanitize(flag?: bool | Reference): this { return this._setFlag('sanitize', flag) }

  // unit

  unit(unit?: string | Reference): this {
    const set = this._setting
    if (unit instanceof Reference) set.unit = unit
    else if (unit) {
      try {
        convert().from(unit)
        set.unit = unit
      } catch (e) { throw new Error(`Unit ${unit} not recognized`) }
    } else delete set.unit
    return this
  }

  toUnit(unit?: string | Reference): this {
    const set = this._setting
    if (!set.unit) throw new Error('First define the input `unit()` before converting further')
    if (unit instanceof Reference) set.toUnit = unit
    else if (unit) {
      try {
        convert().from(unit)
        set.toUnit = unit
      } catch (e) { throw new Error(`Unit ${unit} not recognized`) }
    } else delete set.toUnit
    return this
  }

  _unitDescriptor() {
    const set = this._setting
    let msg = ''
    if (set.unit) {
      if (set.unit instanceof Reference) {
        msg += `The value is given in unit specified in ${set.unit.description}. `
      } else msg += `Give the values in \`${set.unit}\`. `
      if (set.toUnit instanceof Reference) {
        msg += `The value converted to unit specified in ${set.toUnit.description}. `
      } else if (set.toUnit) {
        msg = msg.replace(/\. $/, ` and onvert the values to \`${set.toUnit}\`. `)
      }
    }
    return msg.length ? msg.replace(/ $/, '\n') : ''
  }

  _unitValidator(data: SchemaData): Promise<void> {
    const check = this._check
    if (check.unit) {
      try {
        convert().from(check.unit)
      } catch (e) { throw new Error(`Unit ${check.unit} not recognized`) }
    }
    if (check.toUnit) {
      try {
        convert().from(check.toUnit)
      } catch (e) { throw new Error(`Unit ${check.toUnit} not recognized`) }
    }
    // check value
    if (check.unit && typeof data.value === 'string') {
      if (check.sanitize) data.value = data.value.replace(/^.*?([-+]?\d+\.?\d*\s*\S*).*?$/, '$1')
      let quantity
      try {
        const match = data.value.match(/(^[-+]?\d+\.?\d*)\s*(\S*)/)
        quantity = convert(match[1]).from(match[2])
      } catch (e) {
        return Promise.reject(new SchemaError(this, data,
        `Could not parse the unit of ${data.value}: ${e.message}`))
      }
      try {
        data.value = quantity.to(check.unit)
      } catch (e) {
        return Promise.reject(new SchemaError(this, data,
        `Could not convert to ${check.unit}: ${e.message}`))
      }
    }
    if (check.unit && check.toUnit && typeof data.value === 'number') {
      try {
        data.value = convert(data.value).from(check.unit).to(check.toUnit)
      } catch (e) {
        return Promise.reject(new SchemaError(this, data,
        `Could not convert ${check.unit} to ${check.toUnit}: ${e.message}`))
      }
    }
    return Promise.resolve()
  }


//  round(precision?: number, method?: 'arithmetic' | 'floor' | 'ceil'): this {
//    const set = this._setting
//    if (set.negate) {
//      delete set.round
//      set.negate = false
//    } else {
//      if (set.integer && !(set.integer instanceof Reference)) {
//        throw new Error('Rounding not possible because defined as integer')
//      }
//      set.round = new Round(precision, method)
//    }
//    return this
//  }
//
//  integer(flag?: bool | Reference): this { return set.setFlag('integer', flag) }
//
//  integerType(type: number | 'byte' | 'short' | 'long' | 'safe' | 'quad'): this {
//    const set = this._setting
//    if (set.negate) {
//      set.negate = false
//      delete set.integerType
//    } else {
//      set.integer = true
//      if (INTTYPE[type]) set.integerType = INTTYPE[type]
//      else if (typeof type === 'number') {
//        if (Object.values(INTTYPE).includes(type)) set.integerType = type
//      } else throw new Error(`Undefined type ${type} for integer.`)
//    }
//    return this
//  }
//
//  min(value?: number | Reference): this {
//    const set = this._setting
//    if (value) set.min = value
//    else delete set.min
//
//      if (set.max && value > set.max) {
//        throw new Error('Min can´t be greater than max value')
//      }
//      if (set.less && value >= set.less) {
//        throw new Error('Min can´t be greater or equal less value')
//      }
//      if (set.negative && value > 0) {
//        throw new Error('Min can´t be positive, because defined as negative')
//      }
//      set.min = value
//    }
//    return this
//  }
//
//  max(value: number): this {
//    const set = this._setting
//    if (set.negate) {
//      delete set.max
//      set.negate = false
//    } else {
//      if (set.min && value < set.min) {
//        throw new Error('Max can´t be less than min value')
//      }
//      if (set.greater && value <= set.greater) {
//        throw new Error('Max can´t be less or equal greater value')
//      }
//      if (set.positive && value < 0) {
//        throw new Error('Max can´t be negative, because defined as positive')
//      }
//      set.max = value
//    }
//    return this
//  }
//
//  less(value: number): this {
//    const set = this._setting
//    if (set.negate) {
//      delete set.less
//      set.negate = false
//    } else {
//      if (set.min && value <= set.min) {
//        throw new Error('Less can´t be less than min value')
//      }
//      if (set.greater && value <= set.greater) {
//        throw new Error('Less can´t be less or equal greater value')
//      }
//      if (set.positive && value <= 0) {
//        throw new Error('Less can´t be negative, because defined as positive')
//      }
//      set.less = value
//    }
//    return this
//  }
//
//  greater(value: number): this {
//    const set = this._setting
//    if (set.negate) {
//      delete set.greater
//      set.negate = false
//    } else {
//      if (set.max && value >= set.max) {
//        throw new Error('Greater can´t be greater than max value')
//      }
//      if (set.less && value >= set.less) {
//        throw new Error('Greater can´t be greater or equal less value')
//      }
//      if (set.negative && value >= 0) {
//        throw new Error('Greater can´t be positive, because defined as negative')
//      }
//      set.greater = value
//    }
//    return this
//  }
//
//  get positive(): this {
//    const set = this._setting
//    set.positive = !set.negate
//    if (!set.negate) {
//      if (set.max < 0) {
//        throw new Error('Positive can´t be set because max value is negative')
//      }
//      if (set.less <= 0) {
//        throw new Error('Positive can´t be set because less value is negative')
//      }
//      set.negative = false
//    }
//    set.negate = false
//    return this
//  }
//
//  get negative(): this {
//    const set = this._setting
//    set.negative = !set.negate
//    if (!set.negate) {
//      if (set.min > 0) {
//        throw new Error('Negative can´t be set because min value is positive')
//      }
//      if (set.greater >= 0) {
//        throw new Error('Negative can´t be set because greater value is positive')
//      }
//      set.positive = false
//    }
//    set.negate = false
//    return this
//  }
//
//  multiple(value: number): this {
//    const set = this._setting
//    if (set.negate) {
//      delete set.multiple
//      set.negate = false
//    } else {
//      if (set.negative && value > 0) throw new Error('Multiplicator has to be negative, too.')
//      if (set.positive && value < 0) throw new Error('Multiplicator has to be positive, too.')
//      set.multiple = value
//    }
//    return this
//  }
//
//  format(format: string): this {
//    const set = this._setting
//    if (set.negate) {
//      delete set.format
//      set.negate = false
//    } else {
//      set.format = format
//    }
//    return this
//  }

  // using schema

  _sanitizeDescriptor() {
    const set = this._setting
    let msg = 'A numerical value is needed. '
    if (set.sanitize instanceof Reference) {
      msg += `Strings are sanitized depending on ${set.sanitize.description}. `
    } else if (set.sanitize) {
      msg += 'Strings are sanitized to get the first numerical value out of it. '
    }
    return msg.replace(/ $/, '\n')
  }

  _sanitizeValidator(data: SchemaData): Promise<void> {
    const check = this._check
    if (typeof data.value === 'string') {
      if (check.sanitize) data.value = data.value.replace(/^.*?([-+]?\d+\.?\d*).*?$/, '$1')
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

//  _roundDescriptor() {
//    if (this._integer && this._sanitize) return 'The value is rounded to an integer.\n'
//    if (this._round && this._integer) {
//      return `The value is rounded to \`${this._round.method}\` to get an integer.\n`
//    }
//    if (this._round) {
//      return `The value is rounded to \`${this._round.method}\` with \
// ${this._round.precision} digits precision.\n`
//    }
//    if (this._integer && !this._integerType) return 'An integer value is needed.\n'
//    return ''
//  }
//
//  _roundValidator(data: SchemaData): Promise<void> {
//    if (this._round) {
//      const exp = this._integer ? 1 : 10 ** this._round.precision
//      let value = data.value * exp
//      if (this._round.method === 'ceil') value = Math.ceil(value)
//      else if (this._round.method === 'floor') value = Math.floor(value)
//      else value = Math.round(value)
//      data.value = value / exp
//    } else if (this._integer && !Number.isInteger(data.value)) {
//      if (this._sanitize) data.value = Math.round(data.value)
//      else {
//        return Promise.reject(new SchemaError(this, data,
//          'The value has to be an integer number.'))
//      }
//    }
//    return Promise.resolve()
//  }
//
//  _minmaxDescriptor() {
//    // optimize
//    let max
//    let min
//    if (this._integer && this._integerType) {
//      const unsigned = this._positive ? 1 : 0
//      max = (2 ** ((this._integerType - 1) + unsigned)) - 1
//      min = (((unsigned - 1) * max) - 1) + unsigned
//    }
//    if (min === undefined || !(this._min <= min)) min = this._min
//    if (max === undefined || !(this._max >= max)) max = this._max
//    if (min !== undefined && this._greater !== undefined) {
//      if (this._greater >= min) min = undefined
//      else delete this._greater
//    }
//    if (max !== undefined && this._less !== undefined) {
//      if (this._less <= max) max = undefined
//      else delete this._less
//    }
//    // get message
//    let msg = ''
//    if (this._integer && this._integerType) {
//      msg += `It has to be an ${this._positive ? 'unsigned ' : ''}\
// ${this._integerType}-bit integer. `
//    }
//    if (this._positive) msg += 'The number should be positive. '
//    if (this._negative) msg += 'The number should be negative. '
//    if (min !== undefined) msg += `The value has to be at least \`${this._min}\`. `
//    if (this._greater !== undefined) {
//      msg += `The value has to be greater than \`${this._greater}\`. `
//    }
//    if (this._less !== undefined) msg += `The value has to be less than \`${this._less}\`. `
//    if (max !== undefined) msg += `The value has to be at most \`${this._max}\`. `
//    if ((min !== undefined || this._greater !== undefined)
//    && (max !== undefined && this._less !== undefined)) {
//      msg = msg.replace(/(.*)\. The value has to be/, '$1 and')
//    }
//    return msg.replace(/ $/, '\n')
//  }
//
//  _minmaxValidator(data: SchemaData): Promise<void> {
//    // optimize
//    let max
//    let min
//    if (this._integer && this._integerType) {
//      const unsigned = this._positive ? 1 : 0
//      max = (2 ** ((this._integerType - 1) + unsigned)) - 1
//      min = (((unsigned - 1) * max) - 1) + unsigned
//    }
//    if (min === undefined || (this._min !== undefined && !(this._min <= min))) min = this._min
//    if (max === undefined || (this._max !== undefined && !(this._max >= max))) max = this._max
//    if (min !== undefined && this._greater !== undefined) {
//      if (this._greater >= min) min = undefined
//      else delete this._greater
//    }
//    if (max !== undefined && this._less !== undefined) {
//      if (this._less <= max) max = undefined
//      else delete this._less
//    }
//    // check
//    if (this._positive && data.value < 0) {
//      return Promise.reject(new SchemaError(this, data,
//        'The number should be positive.'))
//    }
//    if (this._negative && data.value > 0) {
//      return Promise.reject(new SchemaError(this, data,
//        'The number should be negative.'))
//    }
//    if (min !== undefined && data.value < min) {
//      return Promise.reject(new SchemaError(this, data,
//        `The value has to be at least ${min}.`))
//    }
//    if (this._greater !== undefined && data.value <= this._greater) {
//      return Promise.reject(new SchemaError(this, data,
//        `The value has to be greater than ${this._greater}.`))
//    }
//    if (this._less !== undefined && data.value >= this._less) {
//      return Promise.reject(new SchemaError(this, data,
//        `The value has to be less than ${this._less}.`))
//    }
//    if (max !== undefined && data.value > max) {
//      return Promise.reject(new SchemaError(this, data,
//        `The value has to be at least ${max}.`))
//    }
//    return Promise.resolve()
//  }
//
//  _multipleDescriptor() {
//    if (this._multiple) return `The value has to be multiple of ${this._multiple}.\n`
//    return ''
//  }
//
//  _multipleValidator(data: SchemaData): Promise<void> {
//    if (this._multiple && data.value % this._multiple) {
//      return Promise.reject(new SchemaError(this, data,
//        `The value has to be a multiple of ${this._multiple}.`))
//    }
//    return Promise.resolve()
//  }
//
//  _formatDescriptor() {
//    if (this._format) {
//      return `The value will be formatted as string in the form \`${this._format}\`.\n`
//    }
//    return ''
//  }
//
//  _formatValidator(data: SchemaData): Promise<void> {
//    if (this._format) {
//      const match = this._format.match(/(^.*?)(\s*\$(?:unit|best))/)
//      let unit = match ? match[2] : ''
//      if (unit.includes('$best')) {
//        const quantity = convert(data.value).from(this._toUnit || this._unit).toBest()
//        data.value = quantity.val
//        unit = unit.replace('$best', quantity.unit)
//      }
//      if (unit.includes('$unit')) unit = unit.replace('$unit', this._toUnit || this._unit || '')
//      const format = match ? match[1] : this._format
//      try {
//        data.value = `${Numeral(data.value).format(format)}${unit}`
//      } catch (e) {
//        return Promise.reject(new SchemaError(this, data,
//          `Could not format value: ${e.message}`))
//      }
//    }
//    return Promise.resolve()
//  }

}

export default NumberSchema
