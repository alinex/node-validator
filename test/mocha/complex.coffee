require('alinex-error').install()
async = require 'alinex-async'

test = require '../test'

#process.setMaxListeners 0


describe "Complex", ->

  describe "structures", ->

    it "should work with deep located types", (cb) ->
      test.equal
        type: 'object'
        keys:
          percent:
            type: 'percent'
          interval:
            type: 'interval'
          byte:
            type: 'byte'
          regexp:
            type: 'regexp'
          hostname:
            type: 'hostname'
          ipaddr:
            type: 'ipaddr'
      , [[
        percent: '8%'
        interval:  '1s'
        byte: '1kB'
        regexp: /test/
        hostname: 'localhost'
        ipaddr: '127.0.0.1'
      ,
        percent: 0.08
        interval: 1000
        byte: 1000
        regexp: /test/
        hostname: 'localhost'
        ipaddr: '127.0.0.1'
      ]], cb

  describe "describe", ->

    it "should work with deep located types", (cb) ->
      test.describe
        type: 'object'
        keys:
          percent:
            type: 'percent'
          interval:
            type: 'interval'
          byte:
            type: 'byte'
          regexp:
            type: 'regexp'
          hostname:
            type: 'hostname'
          ipaddr:
            type: 'ipaddr'
      , cb
