// @flow
import util from 'alinex-util'

import NumberSchema from './NumberSchema'
import SchemaError from './SchemaError'
import type SchemaData from './SchemaData'
import Reference from './Reference'


const portNames = {
  // from /etc/services
  'acr-nema': 104,
  afbackup: 2988,
  afmbackup: 2989,
  afpovertcp: 548,
  'afs3-bos': 7007,
  'afs3-callback': 7001,
  'afs3-errors': 7006,
  'afs3-fileserver': 7000,
  'afs3-kaserver': 7004,
  'afs3-prserver': 7002,
  'afs3-rmtsys': 7009,
  'afs3-update': 7008,
  'afs3-vlserver': 7003,
  'afs3-volser': 7005,
  amanda: 10080,
  amandaidx: 10082,
  amidxtape: 10083,
  amqp: 5672,
  aol: 5190,
  'asf-rmcp': 623,
  asp: 27374,
  'at-echo': 204,
  'at-nbp': 202,
  'at-rtmp': 201,
  'at-zis': 206,
  auth: 113,
  'bacula-dir': 9101,
  'bacula-fd': 9102,
  'bacula-sd': 9103,
  bgp: 179,
  bgpd: 2605,
  bgpsim: 5675,
  biff: 512,
  binkp: 24554,
  bootpc: 68,
  bootps: 67,
  bpcd: 13782,
  bpdbm: 13721,
  'bpjava-msvc': 13722,
  bprd: 13720,
  canna: 5680,
  cfengine: 5308,
  cfinger: 2003,
  chargen: 19,
  'cisco-sccp': 2000,
  'clc-build-daemon': 8990,
  clearcase: 371,
  'cmip-agent': 164,
  'cmip-man': 163,
  codaauth2: 370,
  codasrv: 2432,
  'codasrv-se': 2433,
  conference: 531,
  courier: 530,
  'csnet-ns': 105,
  csync2: 30865,
  customs: 1001,
  cvspserver: 2401,
  daap: 3689,
  datametrics: 1645,
  daytime: 13,
  'db-lsp': 17500,
  dcap: 22125,
  'dhcpv6-client': 546,
  'dhcpv6-server': 547,
  dicom: 11112,
  dict: 2628,
  dircproxy: 57000,
  discard: 9,
  distcc: 3632,
  distmp3: 4600,
  domain: 53,
  echo: 7,
  eklogin: 2105,
  'enbd-cstatd': 5051,
  'enbd-sstatd': 5052,
  epmd: 4369,
  exec: 512,
  'f5-globalsite': 2792,
  'f5-iquery': 4353,
  fatserv: 347,
  fax: 4557,
  fido: 60179,
  finger: 79,
  'font-service': 7100,
  freeciv: 5556,
  frox: 2121,
  fsp: 21,
  ftp: 21,
  'ftp-data': 20,
  ftps: 990,
  'ftps-data': 989,
  gdomap: 538,
  'gds-db': 3050,
  ggz: 5688,
  git: 9418,
  gnunet: 2086,
  'gnutella-rtr': 6347,
  'gnutella-svc': 6346,
  gopher: 70,
  gpsd: 2947,
  gris: 2135,
  groupwise: 1677,
  gsidcap: 22128,
  gsiftp: 2811,
  gsigatekeeper: 2119,
  hkp: 11371,
  'hmmp-ind': 612,
  hostmon: 5355,
  hostnames: 101,
  http: 80,
  'http-alt': 8080,
  https: 443,
  hylafax: 4559,
  iax: 4569,
  icpv2: 3130,
  idfp: 549,
  imap2: 143,
  imap3: 220,
  imaps: 993,
  imsp: 406,
  ingreslock: 1524,
  ipp: 631,
  iprop: 2121,
  'ipsec-nat-t': 4500,
  ipx: 213,
  irc: 194,
  ircd: 6667,
  ircs: 994,
  isakmp: 500,
  'iscsi-target': 3260,
  isdnlog: 20011,
  isisd: 2608,
  'iso-tsap': 102,
  kamanda: 10081,
  kazaa: 1214,
  kerberos4: 750,
  kerberos: 88,
  'kerberos-adm': 749,
  'kerberos-master': 751,
  kermit: 1649,
  klogin: 543,
  knetd: 2053,
  kpasswd: 464,
  kpop: 1109,
  'krb-prop': 754,
  krbupdate: 760,
  kshell: 544,
  kx: 2111,
  l2f: 1701,
  ldap: 389,
  ldaps: 636,
  link: 87,
  linuxconf: 98,
  'loc-srv': 135,
  login: 513,
  'log-server': 1958,
  lotusnote: 1352,
  mailq: 174,
  mandelspawn: 9359,
  mdns: 5353,
  'microsoft-ds': 445,
  mmcc: 5050,
  'moira-db': 775,
  'moira-update': 777,
  'moira-ureg': 779,
  mon: 2583,
  mrtd: 5674,
  msnp: 1863,
  msp: 18,
  'ms-sql-m': 1434,
  'ms-sql-s': 1433,
  mtn: 4691,
  mtp: 57,
  munin: 4949,
  mysql: 3306,
  'mysql-proxy': 6446,
  nameserver: 42,
  nbd: 10809,
  nbp: 2,
  nessus: 1241,
  'netbios-dgm': 138,
  'netbios-ns': 137,
  'netbios-ssn': 139,
  netnews: 532,
  netstat: 15,
  netwall: 533,
  nextstep: 178,
  nfs: 2049,
  ninstall: 2150,
  nntp: 119,
  nntps: 563,
  noclog: 5354,
  'npmp-gui': 611,
  'npmp-local': 610,
  nqs: 607,
  nrpe: 5666,
  nsca: 5667,
  ntalk: 518,
  ntp: 123,
  nut: 3493,
  omirr: 808,
  omniorb: 8088,
  openvpn: 1194,
  ospf6d: 2606,
  ospfapi: 2607,
  ospfd: 2604,
  'passwd-server': 752,
  pawserv: 345,
  pcrd: 5151,
  'pipe-server': 2010,
  pop2: 109,
  pop3: 110,
  pop3s: 995,
  poppassd: 106,
  postgresql: 5432,
  predict: 1210,
  printer: 515,
  proofd: 1093,
  prospero: 191,
  'prospero-np': 1525,
  pwdgen: 129,
  qmqp: 628,
  qmtp: 209,
  qotd: 17,
  radius: 1812,
  'radius-acct': 1813,
  'radmin-port': 4899,
  're-mail-ck': 50,
  remctl: 4373,
  remotefs: 556,
  remoteping: 1959,
  rfe: 5002,
  ripd: 2602,
  ripngd: 2603,
  rje: 77,
  rlp: 39,
  rmiregistry: 1099,
  rmtcfg: 1236,
  rootd: 1094,
  route: 520,
  rpc2portmap: 369,
  rplay: 5555,
  rsync: 873,
  'rtcm-sc104': 2101,
  rtelnet: 107,
  rtmp: 1935,
  rtsp: 554,
  saft: 487,
  'sa-msg-port': 1646,
  'sane-port': 6566,
  search: 2010,
  sftp: 115,
  'sge-execd': 6445,
  'sge-qmaster': 6444,
  'sgi-cad': 17004,
  'sgi-cmsd': 17001,
  'sgi-crsd': 17002,
  'sgi-gcd': 17003,
  shell: 514,
  sieve: 4190,
  silc: 706,
  sip: 5060,
  'sip-tls': 5061,
  skkserv: 1178,
  smsqp: 11201,
  smtp: 25,
  smux: 199,
  snmp: 161,
  'snmp-trap': 162,
  snpp: 444,
  socks: 1080,
  spamd: 783,
  ssh: 22,
  submission: 587,
  sunrpc: 111,
  supdup: 95,
  supfiledbg: 1127,
  supfilesrv: 871,
  support: 1529,
  suucp: 4031,
  svn: 3690,
  svrloc: 427,
  swat: 901,
  syslog: 514,
  'syslog-tls': 6514,
  sysrqd: 4094,
  systat: 11,
  tacacs: 49,
  'tacacs-ds': 65,
  talk: 517,
  tcpmux: 1,
  telnet: 23,
  telnets: 992,
  tempo: 526,
  tfido: 60177,
  tftp: 69,
  time: 37,
  timed: 525,
  tinc: 655,
  tproxy: 8081,
  ulistserv: 372,
  'unix-status': 1957,
  urd: 465,
  uucp: 540,
  'uucp-path': 117,
  vboxd: 20012,
  venus: 2430,
  'venus-se': 2431,
  vnetd: 13724,
  vopied: 13783,
  webmin: 10000,
  webster: 765,
  who: 513,
  whois: 43,
  wipld: 1300,
  wnn6: 22273,
  'x11-1': 6001,
  'x11-2': 6002,
  'x11-3': 6003,
  'x11-4': 6004,
  'x11-5': 6005,
  x11: 6000,
  'x11-6': 6006,
  'x11-7': 6007,
  xdmcp: 177,
  xinetd: 9098,
  xmms2: 9667,
  'xmpp-client': 5222,
  'xmpp-server': 5269,
  xpilot: 15345,
  xtel: 1313,
  xtell: 4224,
  xtelw: 1314,
  z3950: 210,
  'zabbix-agent': 10050,
  'zabbix-trapper': 10051,
  zebra: 2601,
  zebrasrv: 2600,
  'zephyr-clt': 2103,
  'zephyr-hm': 2104,
  'zephyr-srv': 2102,
  zip: 6,
  zope: 9673,
  'zope-ftp': 8021,
  zserv: 346,
}

// named port ranges to use in allow/deny,
const portRanges = {
  system: [0, 1023],
  registered: [1024, 49151],
  dynamic: [49152, 65535],
}

class PortSchema extends NumberSchema {
  constructor(title?: string, detail?: string) {
    super(title, detail)
    super.integerType('short')
    super.positive()
  }

  sanitize(): this { return this._setError('sanitize') }

  _sanitizeDescriptor() {
    const set = this._setting
    let msg = 'A port number or name is needed, the names will be replaced with their standard \
    ports. '
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
    const orig = data.value
    if (typeof data.value === 'string') {
      const lc = data.value.toLowerCase()
      if (portNames[lc]) data.value = portNames[lc]
      if (check.sanitize) data.value = data.value.replace(/^.*?([-+]?\d+\.?\d*).*?$/, '$1')
      if (typeof data.value === 'string') data.value = parseInt(data.value, 10)
      data.value = Number(data.value)
    }
    if (typeof data.value !== 'number') {
      return Promise.reject(new SchemaError(this, data,
        `The given value is of type ${typeof data.value} but a number is needed.`))
    } else if (isNaN(data.value)) {
      return Promise.reject(new SchemaError(this, data,
        `The given element \`${util.inspect(orig)}\` is no valid number.`))
    }
    return Promise.resolve()
  }

  unit(): this { return this._setError('unit') }
  toUnit(): this { return this._setError('toUnit') }
  positive(): this { return this._setError('positive') }
  negative(): this { return this._setError('negative') }
  integer(): this { return this._setError('integer') }
  integerType(): this { return this._setError('integerType') }
  round(): this { return this._setError('round') }
  multiple(): this { return this._setError('multiple') }

  // support names and ranges
  _allowValidator(data: SchemaData): Promise<void> {
    const check = this._check
    this._checkArray('allow')
    this._checkArray('deny')
    // resolve names and ranges
    if (check.deny) {
      const numbers = []
      for (const e of check.deny) {
        if (typeof e === 'string') {
          if (portNames[e]) numbers.push(portNames[e])
          else if (portRanges[e]) {
            for (let n = portRanges[e][0]; n <= portRanges[e][1]; n += 1) numbers.push(n)
          }
        } else {
          numbers.push(e)
        }
      }
      check.deny = numbers
    }
    if (check.allow) {
      const numbers = []
      for (const e of check.allow) {
        if (typeof e === 'string') {
          if (portNames[e]) numbers.push(portNames[e])
          else if (portRanges[e]) {
            for (let n = portRanges[e][0]; n <= portRanges[e][1]; n += 1) numbers.push(n)
          }
        } else {
          numbers.push(e)
        }
      }
      check.allow = numbers
    }
    if (check.allow && check.deny) check.deny = check.deny.filter(e => !check.allow.includes(e))
    // checking
    return super._allowValidator(data)
  }
}


export default PortSchema
