# TCP/UDP Ports
# =================================================

# Check options:
#
# - `allow` - (list) list of allowed ports or ranges 'system', 'registered', 'dynamic'
# - `deny` - (list) list of denied ports or ranges 'system', 'registered', 'dynamic'

# Node modules
# -------------------------------------------------
debug = require('debug')('validator:port')
util = require 'util'
chalk = require 'chalk'
# alinex modules
object = require('alinex-util').object
# include classes and helper
check = require '../check'


# Named ports
# -------------------------------------------------
# cat /etc/services | sed 's/\/.*//' | sed 's/[ \t][ \t]*/: /'
# | sed "s/\([0-9a-z-]*\)/'\1'/" | sort -u
ports =
  'rtmp': 1935
  # from /etc/services
  'acr-nema': 104
  'afbackup': 2988
  'afmbackup': 2989
  'afpovertcp': 548
  'afs3-bos': 7007
  'afs3-callback': 7001
  'afs3-errors': 7006
  'afs3-fileserver': 7000
  'afs3-kaserver': 7004
  'afs3-prserver': 7002
  'afs3-rmtsys': 7009
  'afs3-update': 7008
  'afs3-vlserver': 7003
  'afs3-volser': 7005
  'amanda': 10080
  'amandaidx': 10082
  'amidxtape': 10083
  'amqp': 5672
  'aol': 5190
  'asf-rmcp': 623
  'asp': 27374
  'at-echo': 204
  'at-nbp': 202
  'at-rtmp': 201
  'at-zis': 206
  'auth': 113
  'bacula-dir': 9101
  'bacula-fd': 9102
  'bacula-sd': 9103
  'bgp': 179
  'bgpd': 2605
  'bgpsim': 5675
  'biff': 512
  'binkp': 24554
  'bootpc': 68
  'bootps': 67
  'bpcd': 13782
  'bpdbm': 13721
  'bpjava-msvc': 13722
  'bprd': 13720
  'canna': 5680
  'cfengine': 5308
  'cfinger': 2003
  'chargen': 19
  'cisco-sccp': 2000
  'clc-build-daemon': 8990
  'clearcase': 371
  'cmip-agent': 164
  'cmip-man': 163
  'codaauth2': 370
  'codasrv': 2432
  'codasrv-se': 2433
  'conference': 531
  'courier': 530
  'csnet-ns': 105
  'csync2': 30865
  'customs': 1001
  'cvspserver': 2401
  'daap': 3689
  'datametrics': 1645
  'daytime': 13
  'db-lsp': 17500
  'dcap': 22125
  'dhcpv6-client': 546
  'dhcpv6-server': 547
  'dicom': 11112
  'dict': 2628
  'dircproxy': 57000
  'discard': 9
  'distcc': 3632
  'distmp3': 4600
  'domain': 53
  'echo': 4
  'echo': 7
  'eklogin': 2105
  'enbd-cstatd': 5051
  'enbd-sstatd': 5052
  'epmd': 4369
  'exec': 512
  'f5-globalsite': 2792
  'f5-iquery': 4353
  'fatserv': 347
  'fax': 4557
  'fido': 60179
  'finger': 79
  'font-service': 7100
  'freeciv': 5556
  'frox': 2121
  'fsp': 21
  'ftp': 21
  'ftp-data': 20
  'ftps': 990
  'ftps-data': 989
  'gdomap': 538
  'gds-db': 3050
  'ggz': 5688
  'git': 9418
  'gnunet': 2086
  'gnutella-rtr': 6347
  'gnutella-svc': 6346
  'gopher': 70
  'gpsd': 2947
  'gris': 2135
  'groupwise': 1677
  'gsidcap': 22128
  'gsiftp': 2811
  'gsigatekeeper': 2119
  'hkp': 11371
  'hmmp-ind': 612
  'hostmon': 5355
  'hostnames': 101
  'http': 80
  'http-alt': 8080
  'https': 443
  'hylafax': 4559
  'iax': 4569
  'icpv2': 3130
  'idfp': 549
  'imap2': 143
  'imap3': 220
  'imaps': 993
  'imsp': 406
  'ingreslock': 1524
  'ipp': 631
  'iprop': 2121
  'ipsec-nat-t': 4500
  'ipx': 213
  'irc': 194
  'ircd': 6667
  'ircs': 994
  'isakmp': 500
  'iscsi-target': 3260
  'isdnlog': 20011
  'isisd': 2608
  'iso-tsap': 102
  'kamanda': 10081
  'kazaa': 1214
  'kerberos4': 750
  'kerberos': 88
  'kerberos-adm': 749
  'kerberos-master': 751
  'kermit': 1649
  'klogin': 543
  'knetd': 2053
  'kpasswd': 464
  'kpop': 1109
  'krb-prop': 754
  'krbupdate': 760
  'kshell': 544
  'kx': 2111
  'l2f': 1701
  'ldap': 389
  'ldaps': 636
  'link': 87
  'linuxconf': 98
  'loc-srv': 135
  'login': 513
  'log-server': 1958
  'lotusnote': 1352
  'mailq': 174
  'mandelspawn': 9359
  'mdns': 5353
  'microsoft-ds': 445
  'mmcc': 5050
  'moira-db': 775
  'moira-update': 777
  'moira-ureg': 779
  'mon': 2583
  'mrtd': 5674
  'msnp': 1863
  'msp': 18
  'ms-sql-m': 1434
  'ms-sql-s': 1433
  'mtn': 4691
  'mtp': 57
  'munin': 4949
  'mysql': 3306
  'mysql-proxy': 6446
  'nameserver': 42
  'nbd': 10809
  'nbp': 2
  'nessus': 1241
  'netbios-dgm': 138
  'netbios-ns': 137
  'netbios-ssn': 139
  'netnews': 532
  'netstat': 15
  'netwall': 533
  'nextstep': 178
  'nfs': 2049
  'ninstall': 2150
  'nntp': 119
  'nntps': 563
  'noclog': 5354
  'npmp-gui': 611
  'npmp-local': 610
  'nqs': 607
  'nrpe': 5666
  'nsca': 5667
  'ntalk': 518
  'ntp': 123
  'nut': 3493
  'omirr': 808
  'omniorb': 8088
  'openvpn': 1194
  'ospf6d': 2606
  'ospfapi': 2607
  'ospfd': 2604
  'passwd-server': 752
  'pawserv': 345
  'pcrd': 5151
  'pipe-server': 2010
  'pop2': 109
  'pop3': 110
  'pop3s': 995
  'poppassd': 106
  'postgresql': 5432
  'predict': 1210
  'printer': 515
  'proofd': 1093
  'prospero': 191
  'prospero-np': 1525
  'pwdgen': 129
  'qmqp': 628
  'qmtp': 209
  'qotd': 17
  'radius': 1812
  'radius-acct': 1813
  'radmin-port': 4899
  're-mail-ck': 50
  'remctl': 4373
  'remotefs': 556
  'remoteping': 1959
  'rfe': 5002
  'ripd': 2602
  'ripngd': 2603
  'rje': 77
  'rlp': 39
  'rmiregistry': 1099
  'rmtcfg': 1236
  'rootd': 1094
  'route': 520
  'rpc2portmap': 369
  'rplay': 5555
  'rsync': 873
  'rtcm-sc104': 2101
  'rtelnet': 107
  'rtmp': 1
  'rtsp': 554
  'saft': 487
  'sa-msg-port': 1646
  'sane-port': 6566
  'search': 2010
  'sftp': 115
  'sge-execd': 6445
  'sge-qmaster': 6444
  'sgi-cad': 17004
  'sgi-cmsd': 17001
  'sgi-crsd': 17002
  'sgi-gcd': 17003
  'shell': 514
  'sieve': 4190
  'silc': 706
  'sip': 5060
  'sip-tls': 5061
  'skkserv': 1178
  'smsqp': 11201
  'smtp': 25
  'smux': 199
  'snmp': 161
  'snmp-trap': 162
  'snpp': 444
  'socks': 1080
  'spamd': 783
  'ssh': 22
  'submission': 587
  'sunrpc': 111
  'supdup': 95
  'supfiledbg': 1127
  'supfilesrv': 871
  'support': 1529
  'suucp': 4031
  'svn': 3690
  'svrloc': 427
  'swat': 901
  'syslog': 514
  'syslog-tls': 6514
  'sysrqd': 4094
  'systat': 11
  'tacacs': 49
  'tacacs-ds': 65
  'talk': 517
  'tcpmux': 1
  'telnet': 23
  'telnets': 992
  'tempo': 526
  'tfido': 60177
  'tftp': 69
  'time': 37
  'timed': 525
  'tinc': 655
  'tproxy': 8081
  'ulistserv': 372
  'unix-status': 1957
  'urd': 465
  'uucp': 540
  'uucp-path': 117
  'vboxd': 20012
  'venus': 2430
  'venus-se': 2431
  'vnetd': 13724
  'vopied': 13783
  'webmin': 10000
  'webster': 765
  'who': 513
  'whois': 43
  'wipld': 1300
  'wnn6': 22273
  'x11-1': 6001
  'x11-2': 6002
  'x11-3': 6003
  'x11-4': 6004
  'x11-5': 6005
  'x11': 6000
  'x11-6': 6006
  'x11-7': 6007
  'xdmcp': 177
  'xinetd': 9098
  'xmms2': 9667
  'xmpp-client': 5222
  'xmpp-server': 5269
  'xpilot': 15345
  'xtel': 1313
  'xtell': 4224
  'xtelw': 1314
  'z3950': 210
  'zabbix-agent': 10050
  'zabbix-trapper': 10051
  'zebra': 2601
  'zebrasrv': 2600
  'zephyr-clt': 2103
  'zephyr-hm': 2104
  'zephyr-srv': 2102
  'zip': 6
  'zope': 9673
  'zope-ftp': 8021
  'zserv': 346

# Type implementation
# -------------------------------------------------
exports.describe = (work, cb) ->
  # combine into message
  text = "A TCP/UDP port number or name. "
  text += check.optional.describe work
  text = text.replace /\. It's/, ' which is'
  if work.pos.deny
    text += "The port should not be: '#{work.pos.deny.join '\', \''}'. "
    if work.pos.allow
      text += "But the following ports are allowed: '#{work.pos.allow.join '\', \''}' are allowed. "
  else if work.pos.allow
    text += "The port have to be: '#{work.pos.allow.join '\', \''}'. "
  cb null, text

subcheck =
  type: 'or'
  or: [
    type: 'integer'
    min: 0
    max: 65535
  ,
    type: 'string'
    values: Object.keys ports
  ]

exports.run = (work, cb) ->
  debug "#{work.debug} with #{util.inspect work.value} as #{work.pos.type}"
  debug "#{work.debug} #{chalk.grey util.inspect work.pos}"
  # base checks
  try
    return cb() if check.optional.run work
  catch err
    return work.report err, cb
  # first check input type
  name = work.spec.name ? 'value'
  if work.path.length
    name += "/#{work.path.join '/'}"
  check.run
    name: name
    value: work.value
    schema: subcheck
  , (err, value) ->
    return cb err if err
    # transform string to int
    value = ports[value] if typeof value is 'string'
    # check allow / deny
    if work.pos.allow
      for entry in (work.pos.allow.map (e) -> ports[e] ? e)
        if typeof entry is 'string'
          if (entry is 'system' and value < 1024) or
          (entry is 'registered' and 1024 <= value <= 49151) or
          (entry is 'dynamic' and 49152 <= value <= 65535)
            debug "#{work.debug} result #{util.inspect value}"
            return cb null, value
        else if value is entry
          debug "#{work.debug} result #{util.inspect value}"
          return cb null, value
      # ip not in the allowed range
      unless work.pos.deny
        return work.report (new Error "The given tcp/udp port '#{value}' is not in
          the allowed ranges"), cb
    if work.pos.deny
      for entry in (work.pos.deny.map (e) -> ports[e] ? e)
        if typeof entry is 'string'
          if (entry is 'system' and value < 1024) or
          (entry is 'registered' and 1024 <= value <= 49151) or
          (entry is 'dynamic' and 49152 <= value <= 65535)
            return work.report (new Error "The given tcp/udp port '#{value}' is
              denied because in range #{entry}"), cb
        else if value is entry
          return work.report (new Error "The given tcp/udp port '#{value}' is denied."), cb
    # ip also not in the denied range so allowed again
    # done return resulting value
    debug "#{work.debug} result #{util.inspect value}"
    cb null, value

exports.selfcheck = (schema, cb) ->
  check.run
    schema:
      type: 'object'
      allowedKeys: true
      keys: object.extend {}, check.base,
        default:
          type: 'float'
          optional: true
        allow:
          type: 'array'
          optional: true
          entries:
            type: 'or'
            or: [
              type: 'integer'
            ,
              type: 'string'
              values: ['system', 'registered', 'dynamic']
            ,
              type: 'string'
              values: Object.keys ports
            ]
        deny:
          type: 'array'
          optional: true
          entries:
            type: 'or'
            or: [
              type: 'integer'
            ,
              type: 'string'
              values: ['system', 'registered', 'dynamic']
            ,
              type: 'string'
              values: Object.keys ports
            ]
    value: schema
  , cb
