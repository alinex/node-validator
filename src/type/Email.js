// @flow
import promisify from 'es6-promisify' // may be removed with node util.promisify later
import Debug from 'debug'

// load on demand: request-promise-native, dns, net

import StringSchema from './String'
import DomainSchema from './Domain'
import IPSchema from './IP'
import ValidationError from '../Error'
import type Data from '../Data'
import Reference from '../Reference'

const debug = Debug('validator:email')

let myIP: string = ''
function getMyIP(): Promise<any> {
  if (myIP.length) return Promise.resolve(myIP)
  return import('request-promise-native')
    .then((request: any) => request('http://ipinfo.io/ip'))
    .then(html => new IPSchema().validate(html.trim()))
    .then((ip) => {
      myIP = ip
      return ip
    })
    .catch(err => Promise.reject(new Error(`Could not get own IP address (needed for further checks): ${err.message}`)))
}

function connect(record: Object): Promise<bool> {
  const domain = record.exchange
  return getMyIP()
    .then(() => import('net'))
    .then(net => new Promise((resolve) => {
      const client = net.createConnection(25, domain, () => {
        debug('Send HELO command to mailserver...')
        client.write(`HELO ${myIP}\r\n`)
        client.write('QUIT\r\n')
        client.end()
      })
      let res = ''
      client.on('data', (data) => {
        res += data.toString()
      })
      client.on('error', (err) => {
        debug(`Error from server ${domain}: ${err.message}`)
        resolve(false)
      })
      client.on('end', () => {
        if (res.length) {
          debug(`Server ${domain} responded with:\n${res.trim()}`)
          return resolve(true)
        }
        debug(`No valid response from server ${domain}`)
        return resolve(false)
      })
    }))
}

function checklist(name: string, access: Object, record: Object): Promise<string> {
  const domain = record.exchange
  const reverse = `${domain.split('.').reverse().join('.')}.${access.zone}`
  return import('dns')
    .then(dns => promisify(dns.resolve)(reverse))
    .then(() => name)
    .catch(() => '')
}

class EmailSchema extends StringSchema {
  constructor(base?: any) {
    super(base)
    // add check rules
    let raw = this._rules.descriptor.pop()
    let allow = this._rules.descriptor.pop()
    this._rules.descriptor.push(
      this._structDescriptor,
      allow,
      this._connectDescriptor,
      this._blacklistDescriptor,
      this._greylistDescriptor,
      this._formatDescriptor,
      raw,
    )
    raw = this._rules.validator.pop()
    allow = this._rules.validator.pop()
    this._rules.validator.push(
      this._structValidator,
      allow,
      this._connectValidator,
      this._blacklistValidator,
      this._greylistValidator,
      this._formatValidator,
      raw,
    )
  }

  stripEmpty(): this { return this._setError('stripEmpty') }
  truncate(): this { return this._setError('truncate') }
  pad(): this { return this._setError('pad') }

  // domain settings
  dns(flag?: bool | Reference): this { return this._setFlag('dns', flag) }
  punycode(flag?: bool | Reference): this { return this._setFlag('punycode', flag) }
  resolve(flag?: bool | Reference): this { return this._setFlag('resolve', flag) }

  _typeDescriptor() { // eslint-disable-line class-methods-use-this
    return 'It has to be a reasonable email address with optional descriptive part.\n'
  }

  normalize(flag?: bool | Reference): this { return this._setFlag('normalize', flag) }

  _structDescriptor() {
    const set = this._setting
    let msg = ''
    if (set.normalize) {
      if (this._isReference('normalize')) {
        msg += `Extended formats like additional domains, sub domains and tags which mostly belong to \
the same mailbox will be removed. if set under ${set.normalize.description}. `
      } else {
        msg += 'Extended formats like additional domains, sub domains and tags which mostly belong \
to the same mailbox will be removed. '
      }
    }
    const schema = new DomainSchema()
    if (set.dns) schema.dns('MX')
    if (set.punycode) schema.punycode()
    else if (set.resolve) schema.resolve()
    return `${msg}- domain part: ${schema.description}\n\n`
  }

  _structValidator(data: Data): Promise<void> {
    const check = this._check
    // split address
    const match = data.value.match(/^(.*\S)\s+<(.*)>\s*$/)
    const full = (match ? match[2] : data.value).trim()
    const result = {}
    if (match) result.name = match[1]
    else result.name = null
    const at = full.lastIndexOf('@')
    if (at === -1) result.local = full
    else {
      result.local = full.substring(0, at)
      result.domain = full.substring(at + 1)
    }
    data.value = result
    // normalize
    if (check.normalize) {
      if (result.domain.match(/^g(oogle)?mail\.com$/i)) {
        result.local = result.local.replace(/\.|\+.*$/g, '') // dots or +... are removed
        result.domain = 'gmail.com'
      }
      if (result.domain.match(/^facebook\.com$/i)) {
        result.local = result.local.replace(/\./g, '') // dots are removed
      }
    }
    // check parts
    if (!data.value.domain) {
      return Promise.reject(new ValidationError(this, data, 'The email address is missing the server \
part starting with \'@\''))
    }
    if (data.value.local.length > 64) {
      return Promise.reject(new ValidationError(this, data, 'The local mailbox name is too long (64 \
chars max per specification)'))
    }
    // check domain
    const schema = new DomainSchema()
    if (check.dns) schema.dns('MX')
    if (check.punycode) schema.punycode()
    else if (check.resolve) schema.resolve()
    else schema.raw()
    return schema._validate(data.sub('domain'))
      .then((d) => {
        data.value.domain = d.value
        return Promise.resolve()
      })
  }

  _allowValidator(data: Data): Promise<void> {
    const check = this._check
    this._checkArray('allow')
    this._checkArray('deny')
    // checking
    let denyPriority = 0
    let allowPriority = 0
    const email = `${data.value.local}@${data.value.domain || 'localhost'}`.toLowerCase()
    if (check.deny && check.deny.length) {
      for (const e of check.deny) {
        const match = e.match(/^(.*\S)\s+<(.*)>\s*$/)
        let full = (match ? match[2] : e).trim().toLowerCase()
        const at = full.lastIndexOf('@')
        let domain = null
        if (at === -1) {
          domain = full
          full = undefined
        } else domain = full.substring(at + 1)
        if (email === full) {
          denyPriority = 99
          break
        }
        if (email.endsWith(`.${domain}`) || email.endsWith(`@${domain}`)) {
          const m = domain.match(/\./g)
          const level = m ? m.length + 1 : 1
          if (level > denyPriority) denyPriority = level
        }
      }
    }
    if (check.allow && check.allow.length) {
      for (const e of check.allow) {
        const match = e.match(/^(.*\S)\s+<(.*)>\s*$/)
        let full = (match ? match[2] : e).trim().toLowerCase()
        const at = full.lastIndexOf('@')
        let domain = null
        if (at === -1) {
          domain = full
          full = undefined
        } else domain = full.substring(at + 1)
        if (email === full) {
          allowPriority = 99
          break
        }
        if (email.endsWith(`.${domain}`) || email.endsWith(`@${domain}`)) {
          const m = domain.match(/\./g)
          const level = m ? m.length + 1 : 1
          if (level > allowPriority) allowPriority = level
        }
      }
    }
    if (denyPriority > allowPriority) {
      return Promise.reject(new ValidationError(this, data,
        'Email found in blacklist (denied item).'))
    }
    return Promise.resolve()
  }

  connect(flag?: bool | Reference): this { return this._setFlag('connect', flag) }

  _connectDescriptor() {
    const set = this._setting
    let msg = ''
    if (set.connect) {
      if (this._isReference('connect')) {
        msg += `A handshake with the mail server should be possible possible if set under \
${set.connect.description}. `
      } else msg += 'A handshake with the mail server should be possible. '
    }
    return msg.length ? `${msg.trim()}\n` : msg
  }

  _connectValidator(data: Data): Promise<void> {
    const check = this._check
    try {
      this._checkBoolean('connect')
    } catch (err) {
      return Promise.reject(new ValidationError(this, data, err.message))
    }
    // format
    if (check.connect) {
      return import('dns')
        // get all mx record
        .then(dns => promisify(dns.resolve)(data.value.domain, 'MX'))
        .then(list => Promise.all(list.map(e => connect(e))))
        .then((res) => {
          if (res.filter(e => e).length) return undefined
          return Promise.reject(new Error('No correct responding mail server could be detected for this domain'))
        })
    }
    return Promise.resolve()
  }

  blackList(flag?: bool | Reference): this { return this._setFlag('blackList', flag) }

  _blacklistDescriptor() {
    const set = this._setting
    let msg = ''
    if (set.blackList) {
      if (this._isReference('blackList')) {
        msg += `The mail server should not be on any black list if set under \
${set.blackList.description}. `
      } else msg += 'The mail server should not be on any black list. '
    }
    return msg.length ? `${msg.trim()}\n` : msg
  }

  _blacklistValidator(data: Data): Promise<void> {
    const check = this._check
    try {
      this._checkBoolean('blackList')
    } catch (err) {
      return Promise.reject(new ValidationError(this, data, err.message))
    }
    // format
    if (check.blackList) {
      return import('../../config/blacklists.json')
        .then(list => Promise.all(Object.keys(list).map((k) => {
          debug(`check in blacklist: ${k}`)
          return import('dns')
            // get all mx record
            .then(dns => promisify(dns.resolve)(data.value.domain, 'MX'))
            .then(addr => Promise.all(addr.map(e => checklist(k, list[k], e))))
            .then((res) => {
              const found = res.filter(e => !e)
              if (found.length) return undefined
              return Promise.reject(new Error(`Found on the blacklists: ${found.join(', ')}`))
            })
        })))
        .then()
    }
    return Promise.resolve()
  }

  greyList(flag?: bool | Reference): this { return this._setFlag('greyList', flag) }

  _greylistDescriptor() {
    const set = this._setting
    let msg = ''
    if (set.greyList) {
      if (this._isReference('greyList')) {
        msg += `The mail server should not be on any black list if set under \
${set.greyList.description}. `
      } else msg += 'The mail server should not be on any black list. '
    }
    return msg.length ? `${msg.trim()}\n` : msg
  }

  _greylistValidator(data: Data): Promise<void> {
    const check = this._check
    try {
      this._checkBoolean('greyList')
    } catch (err) {
      return Promise.reject(new ValidationError(this, data, err.message))
    }
    // format
    if (check.greyList) {
      return import('../../config/greylists.json')
        .then(list => Promise.all(Object.keys(list).map((k) => {
          debug(`check in greylist: ${k}`)
          return import('dns')
            // get all mx record
            .then(dns => promisify(dns.resolve)(data.value.domain, 'MX'))
            .then(addr => Promise.all(addr.map(e => checklist(k, list[k], e))))
            .then((res) => {
              const found = res.filter(e => !e)
              if (found.length) return undefined
              return Promise.reject(new Error(`Found on the greylists: ${found.join(', ')}`))
            })
        })))
        .then()
    }
    return Promise.resolve()
  }

  withName(flag?: bool | Reference): this { return this._setFlag('withName', flag) }

  _formatDescriptor() {
    const set = this._setting
    let msg = ''
    if (set.withName) {
      if (this._isReference('withName')) {
        msg += `The email address may contain a descriptive name if defined under \
${set.withName.description}. `
      } else msg += 'The email address may contain a descriptive name. '
    }
    return msg.length ? `${msg.trim()}\n` : msg
  }

  _formatValidator(data: Data): Promise<void> {
    const check = this._check
    try {
      this._checkBoolean('withName')
    } catch (err) {
      return Promise.reject(new ValidationError(this, data, err.message))
    }
    // format
    let email = data.value.local
    if (data.value.domain) email += `@${data.value.domain}`
    if (check.withName && data.value.name) email = `${data.value.name} <${email}>`
    data.value = email
    return Promise.resolve()
  }
}


export default EmailSchema
