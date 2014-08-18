require('alinex-error').install()
async = require 'async'
chai = require 'chai'
expect = chai.expect

test = require '../test'
reference = require '../../lib/reference'

describe "Reference", ->

  describe "name resolution", ->

    it "should find values absolute", ->
      result = reference.valueByName 'test.address', 'address.street',
        self:
          address:
            name: 'James'
            street: 'Bond Street'
      expect(result).to.equal 'Bond Street'

    it "should find values relative", ->
      result = reference.valueByName 'test.address', '@street',
        self:
          address:
            name: 'James'
            street: 'Bond Street'
      expect(result).to.equal 'Bond Street'

    it "should find values relative with backreference", ->
      result = reference.valueByName 'test.address', '@<address.street',
        self:
          address:
            name: 'James'
            street: 'Bond Street'
      expect(result).to.equal 'Bond Street'

    it "should find values in external reference", ->
      result = reference.valueByName 'test.address', '#street',
        self:
          address:
            name: 'James'
            street: 'Bond Street'
        data:
          street: "City Line"
      expect(result).to.equal 'City Line'

#    - validator - field ref: 'sensors.[*].sensor' # through any array/key element
#- validator - field ref: '@sensor' # relative
#- validator - field ref: '@<sensor' # relative back
#- validator - field ref: '#config.monitor.contacts' # other data element

  describe "sync check", ->

    it "should support greater option", ->
      test.same
        type: 'object'
        entries:
          one:
            type: 'integer'
          two:
            type: 'integer'
            reference:
              greater: 'one'
      ,
        one: 2
        two: 5

  describe "description", ->

    it "should give simple description", ->
      test.desc
        type: 'object'
        entries:
          one:
            type: 'integer'
          two:
            type: 'integer'
            reference:
              greater: 'one'

