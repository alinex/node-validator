// @flow
import promisify from 'es6-promisify' // may be removed with node util.promisify later

import AnySchema from './Any'
import ValidationError from '../Error'
import type Data from '../Data'
import Reference from '../Reference'

// load on demand: ipaddr.js, dns

const specialRanges = {
  unspecified: [
    '0.0.0.0/8',
    '0::/128', // RFC4291, here and after
  ],
  broadcast: ['255.255.255.255/32'],
  multicast: [
    '224.0.0.0/4', // RFC3171
    'ff00::/8',
  ],
  linklocal: [
    '169.254.0.0/16', // RFC3927
    'fe80::/10',
  ],
  loopback: [
    '127.0.0.0/8',
    '::1/128',
  ], // RFC5735
  private: [
    '10.0.0.0/8', // RFC1918
    '172.16.0.0/12', // RFC1918
    '192.168.0.0/16', // RFC1918
  ],
  // Reserved and testing-only ranges; RFCs 5735, 5737, 2544, 1700
  reserved: [
    '192.0.0.0/24',
    '192.88.99.0/24',
    '198.51.100.0/24',
    '203.0.113.0/24',
    '240.0.0.0/4',
    '2001:db8::/32', // RFC4291
  ],
  uniquelocal: ['fc00::/7'],
  ipv4mapped: ['::ffff:0:0/96'],
  rfc6145: ['::ffff:0:0:0/96'], // RFC6145
  rfc6052: ['64:ff9b::/96'], // RFC6052
  '6to4': ['2002::/16'], // RFC3056
  teredo: ['2001::/32'], // RFC6052, RFC6146
  special: [], // fill up with all special ranges
}
for (const key of Object.keys(specialRanges)) {
  if (key !== 'special') specialRanges.special.push(specialRanges[key])
}

class IPSchema extends AnySchema {
  constructor(base?: any) {
    super(base)
    this._setting.format = 'short'
    // add check rules
    let raw = this._rules.descriptor.pop()
    let allow = this._rules.descriptor.pop()
    this._rules.descriptor.push(
      this._typeDescriptor,
      allow,
      this._versionDescriptor,
      this._formatDescriptor,
      raw,
    )
    raw = this._rules.validator.pop()
    allow = this._rules.validator.pop()
    this._rules.validator.push(
      this._typeValidator,
      allow,
      this._versionValidator,
      this._formatValidator,
      raw,
    )
  }

  lookup(flag?: bool | Reference): this { return this._setFlag('lookup', flag) }

  _typeDescriptor() { // eslint-disable-line class-methods-use-this
    return 'An IP address as string or byte array is needed here.\n'
  }

  _typeValidator(data: Data): Promise<void> {
    const check = this._check
    // parse date
    return import('ipaddr.js')
      .then((ipaddr) => {
        if (Array.isArray(data.value) && (data.value.length === 4 || data.value.length === 16)) {
          const ip = ipaddr.fromByteArray(data.value)
          data.value = ip
          return Promise.resolve()
        }
        if (typeof data.value === 'string') {
          let ip = null
          try {
            ip = ipaddr.parse(data.value)
          } catch (err) {
            if (check.lookup) {
              return import('dns')
                .then(dns => promisify(dns.lookup)(data.value, { family: check.version })
                  .then((resolved) => {
                    data.value = ipaddr.parse(resolved)
                    return true
                  }))
            }
          }
          data.value = ip
          return Promise.resolve()
        }
        return Promise.reject(new ValidationError(this, data,
          `An ${typeof data.value} could not be transformed to an IP address`))
      })
  }

  _allowValidator(data: Data): Promise<void> {
    const check = this._check
    this._checkArray('allow')
    this._checkArray('deny')
    // resolve ranges
    const deny = []
    if (check.deny) {
      for (const e of check.deny) {
        if (specialRanges[e]) {
          for (const n of specialRanges[e]) { deny.push(`${n}#`) }
        } else deny.push(e)
      }
    }
    const allow = []
    if (check.allow) {
      for (const e of check.allow) {
        if (specialRanges[e]) {
          for (const n of specialRanges[e]) { allow.push(`${n}#`) }
        } else allow.push(e)
      }
    }
    if (allow && deny && allow.length && deny.length) {
      check.deny = check.deny.filter(e => !check.allow.includes(e))
    }
    // checking
    return import('ipaddr.js')
      .then((ipaddr) => {
        // reject if marked as invalid
        let denyBits = 0
        if (deny.length) {
          for (const e of deny) {
            const n = e.replace(/#$/, '')
            let range
            if (n.match(/\//)) range = ipaddr.parseCIDR(n)
            else {
              const ip = ipaddr.parse(n)
              range = ip.kind === 4 ? [ip, 32] : [ip, 128]
            }
            if (data.value.match(range)) {
              let bits = n.length < e.length ? 1 : range[1]
              if (isNaN(bits)) bits = 0
              if (bits > denyBits) denyBits = bits
            }
          }
        }
        let allowBits = 0
        if (allow.length) {
          allowBits = -1
          for (const e of allow) {
            const n = e.replace(/#$/, '')
            let range
            if (n.match(/\//)) range = ipaddr.parseCIDR(n)
            else {
              const ip = ipaddr.parse(n)
              range = ip.kind === 4 ? [ip, 32] : [ip, 128]
            }
            if (data.value.match(range)) {
              let bits = n.length < e.length ? 1 : range[1]
              if (isNaN(bits)) bits = 0
              if (bits > allowBits) allowBits = bits
            }
          }
        }
        //        console.log(denyBits, allowBits)
        if (denyBits > allowBits) {
          return Promise.reject(new ValidationError(this, data,
            'Element found in blacklist (denied item).'))
        }
        return Promise.resolve()
      })
  }

  version(value?: 4 | 6 | Reference): this {
    return this._setAny('version', value)
  }
  mapping(flag?: bool | Reference): this { return this._setFlag('mapping', flag) }

  _versionDescriptor() {
    const set = this._setting
    let msg = ''
    if (set.version) {
      if (this._isReference('version')) {
        msg += `Valid addresses has to be of IP version defined at ${set.version.description}. `
      } else msg += `Only IPv${set.version} addresses are valid. `
    }
    if (set.mapping) {
      if (this._isReference('mapping')) {
        msg += `IPv4 adresses may be automatically converted if set under ${set.mapping.description}. `
      } else msg += 'IPv4 addresses may be automatically converted. '
    }
    return msg.length ? `${msg.trim()}\n` : msg
  }

  _versionValidator(data: Data): Promise<void> {
    const check = this._check
    try {
      this._checkNumber('version')
      this._checkBoolean('mapping')
      if (check.version && ![4, 6].includes(check.version)) {
        throw new Error(`Only IP version 4 or 6 are valid, ${check.version} is unknown`)
      }
    } catch (err) {
      return Promise.reject(new ValidationError(this, data, err.message))
    }
    // version
    if (check.version) {
      if (check.version === 4) {
        if (data.value.kind() === 'ipv6') {
          if (check.mapping && data.value.isIPv4MappedAddress()) data.value = data.value.toIPv4Address()
          else {
            return Promise.reject(new ValidationError(this, data,
              `The given value is no valid IPv${check.version} address`))
          }
        }
      } else if (data.value.kind() === 'ipv4') {
        if (check.mapping) data.value = data.value.toIPv4MappedAddress()
        else {
          return Promise.reject(new ValidationError(this, data,
            `The given value is no valid IPv${check.version} address`))
        }
      }
    }
    return Promise.resolve()
  }

  format(value: 'short' | 'long' | 'array' | Reference = 'short'): this {
    return this._setAny('format', value)
  }

  _formatDescriptor() {
    const set = this._setting
    let msg = ''
    if (set.format) {
      if (this._isReference('format')) {
        msg += `The ip address will be formatted like defined under //${set.format.description}. `
      } else msg += `The ip address will be formatted in ${set.format} form. `
    }
    return msg.length ? `${msg.trim()}\n` : msg
  }

  _formatValidator(data: Data): Promise<void> {
    const check = this._check
    try {
      this._checkString('format')
      if (!['short', 'long', 'array'].includes(check.format)) {
        throw new Error(`One of 'short', 'long' or 'array' is needed for format but ${check.format} \
was given`)
      }
    } catch (err) {
      return Promise.reject(new ValidationError(this, data, err.message))
    }
    // format result
    if (check.format === 'array') {
      data.value = data.value.octets || data.value.parts
    } else if (data.value.kind() === 'ipv6' && check.format === 'long') {
      data.value = data.value.toNormalizedString()
    } else data.value = data.value.toString()
    return Promise.resolve()
  }
}


export default IPSchema
