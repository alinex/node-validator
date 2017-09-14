// @flow
import promisify from 'es6-promisify' // may be removed with node util.promisify later

// load on demand: request-promise-native, dns, net

import StringSchema from './String'
import DomainSchema from './Domain'
import IPSchema from './IP'
import ValidationError from '../Error'
import type Data from '../Data'
import Reference from '../Reference'


let myIP = null
function getMyIP(): Promise<any> {
  if (myIP) return Promise.resolve(myIP)
  return import('request-promise-native')
    .then((request: any) => request('http://ipinfo.io/ip'))
    .then(html => new IPSchema().validate(html))
    .then((ip) => {
      myIP = ip
      return ip
    })
    .catch((err) => {
      Promise.reject(new Error(`Could not get own IP address (needed for further checks): ${err.message}`))
    })
}

function connect(record: Object): Promise<bool> {
  return import('net')
    .then(net => new Promise((resolve, reject) => {
      const domain = record.exchange
      console.log(domain)
      const client = net.createConnection(25, domain, () => {
        console.log('send')
        client.write('HELO #{ip}\r\n')
        client.end()
      })
      console.log('+++++++')
      let res = ''
      client.on('data', (data) => {
        console.log('data', data)
        res += data.toString()
      })
      client.on('error', (err) => {
        console.log('error', err)
        reject(err)
      })
      client.on('end', () => {
        console.log('----', res)
        if (res.length) resolve(true)
        reject(new Error('No response from server'))
      })
    }).catch(() => false)
      .then((res) => {
        console.log('========')
        return res
      }),
    )
}

//     async.detect list, (domain, cb) =>
//       if @debug.enabled
//         @debug chalk.grey "#{@name}: check mail server under #{domain}"
//       res = ''
//       client = net.connect
//         port: 25
//         host: domain
//       , ->
//         client.write "HELO #{ip}\r\n"
//         client.end()
//       client.on 'data', (data) ->
//   res += data.toString()
//       client.on 'error', (err) =>
//         if @debug.enabled
//           @debug chalk.magenta err
//       client.on 'end', =>
//         if @debug.enabled
//           @debug chalk.grey l for l in res.split /\n/
//         cb null, res?.length > 0
//     , (err, res) ->
//       return cb() if res
//       cb new Error "No correct responding mail server could be detected for this domain"

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
      this._formatDescriptor,
      raw,
    )
    raw = this._rules.validator.pop()
    allow = this._rules.validator.pop()
    this._rules.validator.push(
      this._structValidator,
      allow,
      this._connectValidator,
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

  _structDescriptor() {
    const set = this._setting
    const schema = new DomainSchema()
    if (set.dns) schema.dns('MX')
    if (set.punycode) schema.punycode()
    else if (set.resolve) schema.resolve()
    return `- domain part: ${schema.description}\n`
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
        msg += `Check if a handshake with the mailserver is possible if set under \
${set.connect.description}. `
      } else msg += 'Check if a handshake with the mailserver is possible. '
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
        .then(list => Promise.all(list.map(e => connect(e)))
          .then((res) => {
            console.log('done', res)
            if (res.filter(e => e).length) return undefined
            return Promise.reject(new Error('No correct responding mail server could be detected for this domain'))
          }))
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
