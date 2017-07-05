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

  constructor(precision: number = 0,
    method: 'arithmetic' | 'floor' | 'ceil' = 'arithmetic') {
    if (precision < 0) {
      throw new Error('Precision for round should be 0 or greater.')
    }
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
      this._roundDescriptor,
      this._minmaxDescriptor,
//      this._multipleDescriptor,
//      this._formatDescriptor,
    )
    this._rules.validator.push(
      this._unitValidator,
      this._sanitizeValidator,
      this._roundValidator,
      this._minmaxValidator,
//      this._multipleValidator,
//      this._formatValidator,
    )
  }

  // sanitize

  sanitize(flag?: bool | Reference): this { return this._setFlag('sanitize', flag) }

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
    try {
      this._checkBoolean('sanitize')
    } catch (err) {
      return Promise.reject(new SchemaError(this, data, err.message))
    }
    // check value
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

  // min / max

  min(value?: number | Reference): this {
    const set = this._setting
    if (value) {
      if (!(value instanceof Reference)) {
        if (set.max && !this._isReference('max') && value > set.max) {
          throw new Error('Min can´t be greater than max value')
        }
        if (set.less && !this._isReference('less') && value >= set.less) {
          throw new Error('Min can´t be greater or equal less value')
        }
        if (set.negative && !this._isReference('negative') && value > 0) {
          throw new Error('Min can´t be positive, because defined as negative')
        }
      }
      set.min = value
    } else delete set.min
    return this
  }

  max(value?: number | Reference): this {
    const set = this._setting
    if (value) {
      if (!(value instanceof Reference)) {
        if (set.min && !this._isReference('min') && value < set.min) {
          throw new Error('Max can´t be less than min value')
        }
        if (set.greater && !this._isReference('greater') && value >= set.greater) {
          throw new Error('Max can´t be less or equal greater value')
        }
        if (set.positive && !this._isReference('positive') && value < 0) {
          throw new Error('Max can´t be negative, because defined as positive')
        }
      }
      set.max = value
    } else delete set.max
    return this
  }

  less(value?: number | Reference): this {
    const set = this._setting
    if (value) {
      if (!(value instanceof Reference)) {
        if (set.min && !this._isReference('min') && value <= set.min) {
          throw new Error('Less can´t be less than min value')
        }
        if (set.greater && !this._isReference('greater') && value <= set.greater) {
          throw new Error('Less can´t be less or equal greater value')
        }
        if (set.positive && !this._isReference('positive') && value <= 0) {
          throw new Error('Less can´t be negative, because defined as positive')
        }
      }
      set.less = value
    } else delete set.less
    return this
  }

  greater(value?: number | Reference): this {
    const set = this._setting
    if (value) {
      if (!(value instanceof Reference)) {
        if (set.max && !this._isReference('max') && value >= set.max) {
          throw new Error('Greater can´t be greater than max value')
        }
        if (set.less && !this._isReference('less') && value >= set.less) {
          throw new Error('Greater can´t be greater or equal less value')
        }
        if (set.negative && !this._isReference('negative') && value >= 0) {
          throw new Error('Greater can´t be positive, because defined as negative')
        }
      }
      set.greater = value
    } else delete set.greater
    return this
  }

  positive(flag: bool | Reference = true): this {
    const set = this._setting
    if (flag) {
      if (!(flag instanceof Reference)) {
        if (!this._isReference('max') && set.max < 0) {
          throw new Error('Positive can´t be set because max value is negative')
        }
        if (!this._isReference('less') && set.less <= 0) {
          throw new Error('Positive can´t be set because less value is negative')
        }
        if (!this._isReference('negative')) set.negative = false
      }
      set.positive = true
    } else delete set.positive
    return this
  }

  negative(flag: bool | Reference = true): this {
    const set = this._setting
    if (flag) {
      if (!(flag instanceof Reference)) {
        if (!this._isReference('min') && set.min > 0) {
          throw new Error('Negative can´t be set because min value is positive')
        }
        if (!this._isReference('greater') && set.greater >= 0) {
          throw new Error('Negative can´t be set because greater value is positive')
        }
        if (!this._isReference('positive')) set.positive = false
      }
      set.negative = true
    } else delete set.negative
    return this
  }

  integer(flag?: bool | Reference): this { return this._setFlag('integer', flag) }

  integerType(type: number | 'byte' | 'short' | 'long' | 'safe' | 'quad' | Reference): this {
    const set = this._setting
    if (type) {
      if (!(type instanceof Reference)) {
        set.integer = true
        if (INTTYPE[type]) set.integerType = INTTYPE[type]
        else if (typeof type === 'number') {
          if (Object.values(INTTYPE).includes(type)) set.integerType = type
        } else throw new Error(`Undefined type ${type} for integer.`)
      } else {
        set.integerType = type
      }
    } else delete set.integerType
    return this
  }

  _minmaxDescriptor() {
    const set = this._setting
    // optimize
    let max
    let min
    if (set.integer && set.integerType) {
      const unsigned = set.positive ? 1 : 0
      max = (2 ** ((set.integerType - 1) + unsigned)) - 1
      min = (((unsigned - 1) * max) - 1) + unsigned
    }
    if (min === undefined || !(set.min <= min)) min = set.min
    if (max === undefined || !(set.max >= max)) max = set.max
    if (min !== undefined && set.greater !== undefined) {
      if (set.greater >= min) min = undefined
      else delete set.greater
    }
    if (max !== undefined && set.less !== undefined) {
      if (set.less <= max) max = undefined
      else delete set.less
    }
    // get message
    let msg = ''
    if (set.integer && set.integerType) {
      msg += `It has to be an ${set.positive ? 'unsigned ' : ''}\
 ${set.integerType}-bit integer. `
    }
    if (set.positive) msg += 'The number should be positive. '
    if (set.negative) msg += 'The number should be negative. '
    if (min !== undefined) msg += `The value has to be at least \`${set.min}\`. `
    if (set.greater !== undefined) {
      msg += `The value has to be greater than \`${set.greater}\`. `
    }
    if (set.less !== undefined) msg += `The value has to be less than \`${set.less}\`. `
    if (max !== undefined) msg += `The value has to be at most \`${set.max}\`. `
    if ((min !== undefined || set.greater !== undefined)
    && (max !== undefined && set.less !== undefined)) {
      msg = msg.replace(/(.*)\. The value has to be/, '$1 and')
    }
    return msg.replace(/ $/, '\n')
  }

  _minmaxValidator(data: SchemaData): Promise<void> {
    const check = this._check
    // optimize
    let max
    let min
    if (check.integer && check.integerType) {
      const unsigned = check.positive ? 1 : 0
      max = (2 ** ((check.integerType - 1) + unsigned)) - 1
      min = (((unsigned - 1) * max) - 1) + unsigned
    }
    if (min === undefined || (check.min !== undefined && !(check.min <= min))) min = check.min
    if (max === undefined || (check.max !== undefined && !(check.max >= max))) max = check.max
    if (min !== undefined && check.greater !== undefined) {
      if (check.greater >= min) min = undefined
      else delete check.greater
    }
    if (max !== undefined && check.less !== undefined) {
      if (check.less <= max) max = undefined
      else delete check.less
    }
    // check
    if (check.positive && data.value < 0) {
      return Promise.reject(new SchemaError(this, data,
        'The number should be positive.'))
    }
    if (check.negative && data.value > 0) {
      return Promise.reject(new SchemaError(this, data,
        'The number should be negative.'))
    }
    if (min !== undefined && data.value < min) {
      return Promise.reject(new SchemaError(this, data,
        `The value has to be at least ${min}.`))
    }
    if (check.greater !== undefined && data.value <= check.greater) {
      return Promise.reject(new SchemaError(this, data,
        `The value has to be greater than ${check.greater}.`))
    }
    if (check.less !== undefined && data.value >= check.less) {
      return Promise.reject(new SchemaError(this, data,
        `The value has to be less than ${check.less}.`))
    }
    if (max !== undefined && data.value > max) {
      return Promise.reject(new SchemaError(this, data,
        `The value has to be at least ${max}.`))
    }
    return Promise.resolve()
  }

  round(precision: boolean | number = 0
    , method?: 'arithmetic' | 'floor' | 'ceil'): this {
    const set = this._setting
    if (typeof precision === 'boolean' && !precision) delete set.round
    else {
      if (set.integer && !(set.integer instanceof Reference)) {
        throw new Error('Rounding not possible because defined as integer')
      }
      set.round = new Round(typeof precision === 'boolean' ? 0 : precision, method)
    }
    return this
  }

  _roundDescriptor() {
    const set = this._setting
    if (set.integer && set.sanitize) return 'The value is rounded to an integer.\n'
    if (set.round && set.integer) {
      return `The value is rounded to \`${set.round.method}\` to get an integer.\n`
    }
    if (set.round) {
      return `The value is rounded to \`${set.round.method}\` with \
 ${set.round.precision} digits precision.\n`
    }
    if (set.integer && !set.integerType) return 'An integer value is needed.\n'
    return ''
  }

  _roundValidator(data: SchemaData): Promise<void> {
    const check = this._check
    if (check.round) {
      const exp = check.integer ? 1 : 10 ** check.round.precision
      let value = data.value * exp
      if (check.round.method === 'ceil') value = Math.ceil(value)
      else if (check.round.method === 'floor') value = Math.floor(value)
      else value = Math.round(value)
      data.value = value / exp
    } else if (check.integer && !Number.isInteger(data.value)) {
      if (check.sanitize) data.value = Math.round(data.value)
      else {
        return Promise.reject(new SchemaError(this, data,
          'The value has to be an integer number.'))
      }
    }
    return Promise.resolve()
  }

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


//
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
