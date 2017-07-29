// @flow
import util from 'util'
import moment from 'moment-timezone'
import chrono from 'chrono-node'

import AnySchema from './AnySchema'
import SchemaError from './SchemaError'
import type SchemaData from './SchemaData'
import Reference from './Reference'


moment.createFromInputFallback = (config) => {
  if (config._i.toLowerCase() === 'now') config._d = new Date()
  else config._d = chrono.parseDate(config._i)
}

const types = ['date', 'time', 'datetime']

const zones = {
  'Eastern Standard Time': 'EST',
  'Eastern Daylight Time': 'EDT',
  'Central Standard Time': 'CST',
  'Central Daylight Time': 'CDT',
  'Mountain Standard Time': 'MST',
  'Mountain Daylight Time': 'MDT',
  'Pacific Standard Time': 'PST',
  'Pacific Daylight Time': 'PDT',
  'Central European Time': 'CET',
  'Central European Summer Time': 'CEST',
  MESZ: 'CEST',
  MEZ: 'CET',
}

const alias = {
  datetime: {
    ISO8601: 'YYYY-MM-DDTHH:mm:ssZ',
    RFC1123: 'ddd, DD MMM YYYY HH:mm:ss z',
    RFC2822: 'ddd, DD MMM YYYY HH:mm:ss ZZ',
    RFC822: 'ddd, DD MMM YY HH:mm:ss ZZ',
    RFC1036: 'ddd, D MMM YY HH:mm:ss ZZ',
//    RFC850:  'dddd, D-MMM-ZZ HH:mm:ss Europe/Paris',
//    COOKIE:  'Friday, 13-Feb-09 14:53:27 Europe/Paris',
  },
  date: {
    ISO8601: 'YYYY-MM-DD',
  },
}

class DateSchema extends AnySchema {

  constructor(title?: string, detail?: string) {
    super(title, detail)
    this._setting.type = 'datetime'
    // add check rules
    let allow = this._rules.descriptor.pop()
    this._rules.descriptor.push(
      this._typeDescriptor,
//      this._makeStringDescriptor,
//      this._replaceDescriptor,
//      this._caseDescriptor,
//      this._checkDescriptor,
      this._rangeDescriptor,
//      this._matchDescriptor,
      allow,
    )
    allow = this._rules.validator.pop()
    this._rules.validator.push(
//      this._fromStringValidator,
      this._typeValidator,
//      this._replaceValidator,
//      this._caseValidator,
//      this._checkValidator,
      this._rangeValidator,
//      this._matchValidator,
      this._formatValidator,
      allow,
    )
  }

  // setup schema

  type(value: 'date'|'time'|'datetime' | Reference = 'datetime'): this {
    return this._setAny('type', value)
  }

  timezone(value?: string | Reference): this {
    const set = this._setting
    if (value === undefined) delete set.timezone
    else if (typeof value === 'string') set.timezone = zones[value] || value
    else set.timezone = value
    return this
  }

  _typeDescriptor() { // eslint-disable-line class-methods-use-this
    const set = this._setting
    let msg
    if (set.type instanceof Reference) {
      msg = `It has to be of type defined in ${set.type.description}. \
It may also be given in string format. `
    } else {
      msg = `It has to be a ${set.type}. It may also be given in string format. `
    }
    if (set.timezone) {
      if (set.timezone instanceof Reference) {
        msg += `The time is assumed as timezone defined under ${set.timezone.description}. `
      } else {
        msg += `The time is assumed as timezone ${set.timezone}. `
      }
    }
    return msg.replace(/ $/, '\n')
  }

  _typeValidator(data: SchemaData): Promise<void> {
    const check = this._check
    try {
      this._checkString('timezone')
      this._checkString('type')
      if (!types.includes(check.type)) {
        throw new Error(`Invalid type setting, use one of ${types.join(', ')}`)
      }
    } catch (err) {
      return Promise.reject(new SchemaError(this, data, err.message))
    }
    // parse date
    if (check.timezone) data.value = moment.tz(data.value, check.timezone)
    else data.value = moment(data.value)
    if (!data.value.isValid()) {
      return Promise.reject(new SchemaError(this, data,
        `The given text is not parse able as ${check.type}`))
    }
    return Promise.resolve()
  }

  min(value?: Date | string | Reference): this {
    const set = this._setting
    if (value === undefined) delete set.min
    else if (!(value instanceof Reference)) {
      if (set.timezone) value = moment.tz(value, set.timezone)
      else value = moment(value)
      if (!value.isValid()) {
        throw new Error('The given text is not parse able as date')
      }
      set.min = value
      if (set.max && !this._isReference('max') && value > set.max) {
        throw new Error('Min can´t be greater than max value')
      }
    } else set.min = value
    return this
  }

  max(value?: Date | string | Reference): this {
    const set = this._setting
    if (value === undefined) delete set.max
    else if (!(value instanceof Reference)) {
      if (set.timezone) value = moment.tz(value, set.timezone)
      else value = moment(value)
      if (!value.isValid()) {
        throw new Error('The given text is not parse able as date')
      }
      set.max = value
      if (set.min && !this._isReference('min') && value < set.min) {
        throw new Error('Max can´t be less than min value')
      }
    } else set.max = value
    return this
  }

  _rangeDescriptor() {
    const set = this._setting
    let msg = ''
    if (set.min instanceof Reference) {
      msg += `Minimum ${set.type} depends on ${set.min.description}. `
    }
    if (set.max instanceof Reference) {
      msg += `Maximum ${set.type} depends on ${set.max.description}. `
    }
    if (!this._isReference('min') && !this._isReference('max') && set.min && set.max) {
      msg = set.min === set.max ? `The ${set.type} has to be after ${set.min}. `
      : `The ${set.type} should be between ${set.min} and ${set.max}. `
    } else if (!this._isReference('min') && set.min) {
      msg = `The ${set.type} needs to be after ${set.min}. `
    } else if (!this._isReference('max') && set.max) {
      msg = `The ${set.type} needs to be before ${set.min}. `
    }
    return msg.length ? `${msg.trim()}\n` : msg
  }

  _rangeValidator(data: SchemaData): Promise<void> {
    const check = this._check
    if (check.min && this._isReference('min')) {
      if (check.timezone) check.min = moment.tz(check.min, check.timezone)
      else check.min = moment(check.min)
      if (!check.min.isValid()) {
        return Promise.reject(new SchemaError(this, data,
          `The given text is not parse able as ${check.type}`))
      }
      if (data.value < check.min) {
        return Promise.reject(new SchemaError(this, data,
          `${check.type} can´t be before min ${check.type}`))
      }
    }
    if (check.max && this._isReference('max')) {
      if (check.timezone) check.max = moment.tz(check.max, check.timezone)
      else check.max = moment(check.max)
      if (!check.max.isValid()) {
        return Promise.reject(new SchemaError(this, data,
          `The given text is not parse able as ${check.type}`))
      }
      if (data.value > check.max) {
        return Promise.reject(new SchemaError(this, data,
          `${check.type} can´t be after min ${check.type}`))
      }
    }
    // check range
    if (check.min && check.min.isAfter(data.value)) {
      return Promise.reject(new SchemaError(this, data,
      `The ${check.type} is before the defined range. It has to be after ${check.min}.`))
    }
    if (check.max && check.max.isBefore(data.value)) {
      return Promise.reject(new SchemaError(this, data,
      `The ${check.type} is after the defined range. It has to be before ${check.max}.`))
    }
    return Promise.resolve()
  }

  _formatValidator(data: SchemaData): Promise<void> {
    const check = this._check
    data.value = data.value.toDate()
    return Promise.resolve()
  }


//   # min/max
//   if @schema.range?
//     if @schema.min? and (@value[0] < @schema.min) or @value[1] < @schema.min
//       return @sendError "The #{@schema.part} has to be at or after #{@schema.min}", cb
//     if @schema.max? and (@value[0] > @schema.max) or @value[1] > @schema.max
//       return @sendError "The #{@schema.part} has to be at or before #{@schema.max}", cb
//   else
//     if @schema.min? and @value < @schema.min
//       return @sendError "The #{@schema.part} has to be at or after #{@schema.min}", cb
// if @schema.max? and @value > @schema.max
//       return @sendError "The #{@schema.part} has to be at or before #{@schema.max}", cb
//   # format value
//   if @schema.toTimezone
//     @schema.toTimezone = zones[@schema.toTimezone] ? @schema.toTimezone
//   if @schema.range?
//     if @schema.format?
//       if alias[@schema.part]?[@schema.format]?
//         @schema.format = alias[@schema.part][@schema.format]
//       for p in [0, 1]
//         m = moment @value[p]
//         m = m.tz @schema.timezone if @schema.toTimezone
//         if @schema.locale?
//           m.locale @schema.locale
//         @value[p] = switch @schema.format
//           when 'unix' then  m.unix()
//           else m.format @schema.format
//   else
//     if @schema.format?
//       if alias[@schema.part]?[@schema.format]?
//         @schema.format = alias[@schema.part][@schema.format]
//       m = moment @value
//       if @schema.locale?
//         m.locale @schema.locale
//       m = m.tz @schema.toTimezone if @schema.toTimezone
//       @value = switch @schema.format
//         when 'unix' then  m.unix()
//         else m.format @schema.format
//   # done checking and sanuitizing
// @sendSuccess cb


//  makeString(flag?: bool | Reference): this { return this._setFlag('makeString', flag) }
//
//  _makeStringDescriptor() {
//    const set = this._setting
//    let msg = 'A text is needed. '
//    if (set.makeString instanceof Reference) {
//      msg += `It will be converted to string depending on ${set.makeString.description}. `
//    } else if (set.makeString) {
//      msg += 'If the value is no string it will be converted to one. '
//    }
//    return msg.replace(/ $/, '\n')
//  }
//
//  _makeStringValidator(data: SchemaData): Promise<void> {
//    const check = this._check
//    try {
//      this._checkBoolean('makeString')
//    } catch (err) {
//      return Promise.reject(new SchemaError(this, data, err.message))
//    }
//    // check value
//    if (check.makeString && typeof data.value !== 'string') data.value = data.value.toString()
//    if (typeof data.value !== 'string') {
//      return Promise.reject(new SchemaError(this, data, 'A `string` value is needed here.'))
//    }
//    return Promise.resolve()
//  }


}

export default DateSchema
