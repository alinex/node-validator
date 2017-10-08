// @flow
import moment from 'moment-timezone'
import chrono from 'chrono-node'

import ValidationError from '../Error'
import AnySchema from './Any'
import type Data from '../Data'
import Reference from '../Reference'


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
  constructor(base?: any) {
    super(base)
    this._setting.type = 'datetime'
    // add check rules
    let raw = this._rules.descriptor.pop()
    let allow = this._rules.descriptor.pop()
    this._rules.descriptor.push(
      this._typeDescriptor,
      allow,
      this._rangeDescriptor,
      this._formatDescriptor,
      raw,
    )
    raw = this._rules.validator.pop()
    allow = this._rules.validator.pop()
    this._rules.validator.push(
      this._typeValidator,
      allow,
      this._rangeValidator,
      this._formatValidator,
      raw,
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

  _typeValidator(data: Data): Promise<void> {
    const check = this._check
    try {
      this._checkString('timezone')
      this._checkString('type')
      if (!types.includes(check.type)) {
        throw new Error(`Invalid type setting, use one of ${types.join(', ')}`)
      }
    } catch (err) {
      return Promise.reject(new ValidationError(this, data, err.message))
    }
    // parse date
    if (check.timezone) data.value = moment.tz(data.value, check.timezone)
    else data.value = moment(data.value)
    if (!data.value.isValid()) {
      return Promise.reject(new ValidationError(
        this, data,
        `The given text is not parse able as ${check.type}`,
      ))
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
      if (set.max && !this._isReference('max') && value > set.max) {
        throw new Error('Min can´t be greater than max value')
      }
      if (set.less && !this._isReference('less') && value >= set.less) {
        throw new Error('Min can´t be greater or equal less value')
      }
      if (set.negative && !this._isReference('negative') && value > 0) {
        throw new Error('Min can´t be positive, because defined as negative')
      }
      set.min = value
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
      if (set.min && !this._isReference('min') && value < set.min) {
        throw new Error('Max can´t be less than min value')
      }
      if (set.greater && !this._isReference('greater') && value >= set.greater) {
        throw new Error('Max can´t be less or equal greater value')
      }
      if (set.positive && !this._isReference('positive') && value < 0) {
        throw new Error('Max can´t be negative, because defined as positive')
      }
      set.max = value
    } else set.max = value
    return this
  }

  less(value?: Date | string | Reference): this {
    const set = this._setting
    if (value === undefined) delete set.less
    else if (!(value instanceof Reference)) {
      if (set.timezone) value = moment.tz(value, set.timezone)
      else value = moment(value)
      if (!value.isValid()) {
        throw new Error('The given text is not parse able as date')
      }
      if (set.min && !this._isReference('min') && value <= set.min) {
        throw new Error('Less can´t be less than min value')
      }
      if (set.greater && !this._isReference('greater') && value <= set.greater) {
        throw new Error('Less can´t be less or equal greater value')
      }
      if (set.positive && !this._isReference('positive') && value <= 0) {
        throw new Error('Less can´t be negative, because defined as positive')
      }
      set.less = value
    } else set.less = value
    return this
  }

  greater(value?: Date | string | Reference): this {
    const set = this._setting
    if (value === undefined) delete set.greater
    else if (!(value instanceof Reference)) {
      if (set.timezone) value = moment.tz(value, set.timezone)
      else value = moment(value)
      if (!value.isValid()) {
        throw new Error('The given text is not parse able as date')
      }
      if (set.max && !this._isReference('max') && value >= set.max) {
        throw new Error('Greater can´t be greater than max value')
      }
      if (set.less && !this._isReference('less') && value >= set.less) {
        throw new Error('Greater can´t be greater or equal less value')
      }
      if (set.negative && !this._isReference('negative') && value >= 0) {
        throw new Error('Greater can´t be positive, because defined as negative')
      }
      set.greater = value
    } else set.greater = value
    return this
  }

  _rangeDescriptor() {
    const set = this._setting
    let msg = ''
    if (this._isReference('min')) {
      msg += `The ${set.type} has to be at least the number given in ${set.min.description}. `
    } else if (set.min !== undefined) msg += `The ${set.type} has to be at least \`${set.min}\`. `
    if (this._isReference('greater')) {
      msg += `The ${set.type} has to be higher than given in ${set.greater.description}. `
    } else if (set.greater !== undefined) {
      msg += `The ${set.type} has to be greater than \`${set.greater}\`. `
    }
    if (this._isReference('less')) {
      msg += `The ${set.type} has to be at lower than given in ${set.less.description}. `
    } else if (set.less !== undefined) msg += `The ${set.type} has to be less than \`${set.less}\`. `
    if (this._isReference('max')) {
      msg += `The ${set.type} has to be at least the number given in ${set.max.description}. `
    } else if (set.max !== undefined) msg += `The ${set.type} has to be at most \`${set.max}\`. `
    if ((set.min !== undefined || set.greater !== undefined)
    && (set.max !== undefined || set.less !== undefined)) {
      msg = msg.replace(/(.*)\. The \w+ has to be/, '$1 and')
    }
    return msg.replace(/ $/, '\n')
  }

  _rangeValidator(data: Data): Promise<void> {
    const check = this._check
    // optimize
    if (check.min && this._isReference('min')) {
      if (check.timezone) check.min = moment.tz(check.min, check.timezone)
      else check.min = moment(check.min)
      if (!check.min.isValid()) {
        return Promise.reject(new ValidationError(
          this, data,
          `The given text is not parse able as ${check.type}`,
        ))
      }
    }
    if (check.max && this._isReference('max')) {
      if (check.timezone) check.max = moment.tz(check.max, check.timezone)
      else check.max = moment(check.max)
      if (!check.max.isValid()) {
        return Promise.reject(new ValidationError(
          this, data,
          `The given text is not parse able as ${check.type}`,
        ))
      }
    }
    if (check.greater && this._isReference('greater')) {
      if (check.timezone) check.greater = moment.tz(check.greater, check.timezone)
      else check.greater = moment(check.greater)
      if (!check.greater.isValid()) {
        return Promise.reject(new ValidationError(
          this, data,
          `The given text is not parse able as ${check.type}`,
        ))
      }
    }
    if (check.less && this._isReference('less')) {
      if (check.timezone) check.less = moment.tz(check.less, check.timezone)
      else check.less = moment(check.less)
      if (!check.less.isValid()) {
        return Promise.reject(new ValidationError(
          this, data,
          `The given text is not parse able as ${check.type}`,
        ))
      }
    }
    // check range
    if (check.min && check.min.isSameOrAfter(data.value)) {
      return Promise.reject(new ValidationError(
        this, data,
        `The ${check.type} is before the defined range. It has to be ${check.min} or later.`,
      ))
    }
    if (check.max && check.max.isSameOrBefore(data.value)) {
      return Promise.reject(new ValidationError(
        this, data,
        `The ${check.type} is after the defined range. It has to be ${check.max} or earlier.`,
      ))
    }
    if (check.greater && check.greater.isAfter(data.value)) {
      return Promise.reject(new ValidationError(
        this, data,
        `The ${check.type} is before the defined range. It has to be after ${check.greater}.`,
      ))
    }
    if (check.less && check.less.isBefore(data.value)) {
      return Promise.reject(new ValidationError(
        this, data,
        `The ${check.type} is after the defined range. It has to be before ${check.less}.`,
      ))
    }
    return Promise.resolve()
  }

  format(value?: string | Reference): this {
    if (value === 'unix') value = 'seconds'
    return this._setAny('format', value)
  }
  toLocale(value?: string | Reference): this { return this._setAny('toLocale', value) }
  toTimezone(value?: string | Reference): this {
    const set = this._setting
    if (value === undefined) delete set.toTimezone
    else if (typeof value === 'string') set.toTimezone = zones[value] || value
    else set.toTimezone = value
    return this
  }

  _formatDescriptor() {
    const set = this._setting
    let msg = ''
    if (set.format) {
      if (this._isReference('format')) {
        msg += `The ${set.type} will be formatted like defined under ${set.format.description}. `
      } else msg += `The ${set.type} will be formatted like: ${set.format}. `
    }
    return msg.length ? `${msg.trim()}\n` : msg
  }

  _formatValidator(data: Data): Promise<void> {
    const check = this._check
    try {
      this._checkString('format')
      if (alias[check.type] && alias[check.type][check.format]) {
        check.format = alias[check.type][check.format]
      }
    } catch (err) {
      return Promise.reject(new ValidationError(this, data, err.message))
    }
    // parse date
    if (check.toLocale) data.value = data.value.locale(check.toLocale)
    if (check.toTimezone) data.value = data.value.tz(check.toTimezone)
    if (check.format) {
      if (check.format === 'milliseconds') data.value = data.value.valueOf()
      else if (check.format === 'seconds') data.value = data.value.unix()
      else data.value = data.value.format(check.format)
    } else data.value = data.value.toDate()
    return Promise.resolve()
  }
}

export default DateSchema
